class User < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Journalizable
  include Rorganize::Managers::PermissionManager::PermissionManagerHelper
  include Rorganize::Managers::ModuleManager::ModuleManagerHelper
  include Rorganize::Models::Attachable::AvatarType
  extend FriendlyId

  assign_journalizable_properties({name: 'Name', admin: 'Administrator', email: 'Email', login: 'Login'})
  #Slug
  friendly_id :name, use: :slugged
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  # Setup accessible (or protected) attributes for your model
  #attr_accessible :id, :login, :email, :name, :password, :password_confirmation, :remember_me
  #Relations
  has_many :members, :class_name => 'Member', :dependent => :destroy
  has_many :assigned_issues, foreign_key: :assigned_to_id, class_name: 'Issue'
  has_many :notifications, dependent: :destroy
  has_many :preferences, dependent: :destroy
  #Validators
  validates :login, :presence => true, :length => 4..50, :uniqueness => true
  validates :name, :presence => true, :length => 4..50
  #Triggers
  after_create :generate_default_avatar, :set_preferences
  #Scope
  default_scope { eager_load(:avatar) }

  def self.attachments_type
    :avatar
  end

  def caption
    self.name
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  def activities(journalizable_types, period, from_date)
    Journal.activities_eager_load(journalizable_types, period, from_date, "journals.user_id = #{self.id}")
  end

  def comments(journalizable_types, period, from_date)
    Comment.comments_eager_load(journalizable_types, period, from_date, "comments.user_id = #{self.id}")
  end

  #Override devise
  def self.serialize_from_session(key, salt)
    record = self.eager_load(members: :role).where(id: key)[0]
    record if record && record.authenticatable_salt == salt
  end

  #Override devise
  def self.find_for_authentication(tainted_conditions)
    self.eager_load(members: :role).find_first_by_auth_conditions(tainted_conditions)
  end

  def self.permit_attributes
    [:name, :login, :email, :password, :admin, :retype_password]
  end

  def is_admin?
    return self.admin
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def act_as_admin?
    @@session ||= 'User'
    return @@session.eql?('Admin')
  end

  def act_as_admin(session)
    @@session = session
  end

  def act_as_admin_session
    @@session ||= 'User'
    return @@session
  end

  def time_entries_for_month(year, month)
    dt = Date.new(year, month)
    start_of_month = dt.beginning_of_month
    end_of_month = dt.end_of_month
    TimeEntry.where('user_id = ? AND spent_on >= ? AND spent_on <= ?', self.id, start_of_month, end_of_month).eager_load(:project)
  end

  def allowed_statuses(project)
    member = self.members.to_a.select { |member| member.project_id == project.id }.first
    if member
      member.role.issues_statuses.eager_load(:enumeration).sort { |x, y| x.enumeration.position <=> y.enumeration.position }
    else
      Role.find_by_name('Anonymous').issues_statuses.eager_load(:enumeration).sort { |x, y| x.enumeration.position <=> y.enumeration.position }
    end
  end

  # @param [String] action : the action that user want to perform.
  # @param [String] controller : the controller concern by the action.
  # @param [Project] project the context of the action.
  def allowed_to?(action, controller, project = nil)
    return true if self.is_admin? && act_as_admin? && (project && module_enabled?(project.id.to_s, action, controller) || !project)
    if self.id.eql?(AnonymousUser::ANON_ID) #Concern unconnected users.
      if project
        (project.is_public && module_enabled?(project.id.to_s, action, controller) &&
            anonymous_permission_manager_allowed_to?(action.to_s, controller.downcase.to_s) &&
            (!project.is_archived? || (project.is_archived? && project_archive_permissions(action, controller))))
      else
        if anonymous_permission_manager_allowed_to?(action.to_s, controller.downcase.to_s)
          true
        else
          false
        end
      end
    else
      m = self.members
      if project
        member = m.to_a.select { |mb| mb.project_id == project.id }.first
        if member
          (module_enabled?(project.id.to_s, action, controller) &&
              permission_manager_allowed_to?(member.role.id.to_s, action.to_s, controller.downcase.to_s) &&
              (!project.is_archived? || (project.is_archived? && project_archive_permissions(action, controller))))
        else
          (project.is_public && module_enabled?(project.id.to_s, action, controller) &&
              non_member_permission_manager_allowed_to?(action.to_s, controller.downcase.to_s) &&
              (!project.is_archived? || (project.is_archived? && project_archive_permissions(action, controller))))
        end
      else
        if m && m.any?
          for mem in m do
            if permission_manager_allowed_to?(mem.role_id.to_s, action.to_s, controller.downcase.to_s)
              return true
            end
          end
          return false
        else
          non_member_permission_manager_allowed_to?(action.to_s, controller.downcase.to_s)
        end
      end
    end
  end

  #use to debug
  def allowed_to_do_actions_list(controller = nil, project = nil)
    m = self.members
    if project
      member = m.to_a.select { |mb| mb.project_id == project.id }.first
      puts "Current user is allowed to do following actions and has role #{member.role.caption} for project #{project.slug}"
      p allowed_to_actions_list(member.role.id.to_s, controller)
    else
      for mem in m do
        puts "Current user is allowed to do following actions and has role #{mem.role.caption} for project #{mem.project.slug}"
        p allowed_to_actions_list(mem.role.id.to_s, controller)
      end
    end
  end

  # Get projects when user is a member or when projects are public.
  # @param [String] filter which values are : 'opened' or 'archived' or 'starred'
  def owned_projects(filter)
    case filter
      when 'opened'
        conditions = "projects.is_archived = false AND (members.user_id = #{self.id}) "
      when 'archived'
        conditions = "projects.is_archived = true AND (members.user_id = #{self.id}) "
      when 'starred'
        conditions = "members.is_project_starred = true AND (members.user_id = #{self.id}) "
      else
        conditions = self.act_as_admin? ? '1 = 1 ' : "(members.user_id = #{self.id}) "
    end
    conditions += 'AND journals.id = (SELECT max(j.id) FROM journals j WHERE j.project_id = projects.id)'
    if self.members.any?
      Project.joins("INNER JOIN `members` ON `members`.`project_id` = `projects`.`id` OR (`projects`.`is_public` = true AND projects.id NOT IN (SELECT p2.id FROM projects p2 JOIN members m2 ON p2.id = m2.project_id WHERE m2.user_id = #{self.id})) LEFT OUTER JOIN `watchers` ON `watchers`.`watchable_id` = `projects`.`id` AND `watchers`.`watchable_type` = \'Project\' AND watchers.user_id = members.user_id").eager_load([journals: :user]).where(conditions).order('members.project_position ASC').preload(:members, :watchers)
    else
      Project.eager_load([journals: :user]).where('journals.id = (SELECT max(j.id) FROM journals j WHERE j.project_id = projects.id) AND projects.is_public = true')
    end
  end


  def generate_default_avatar
    path = "#{Rails.root}/public/system/identicons/#{self.slug}_avatar.png"
    Identicon.file_for self.slug, path
    file = File.open(path)
    self.avatar = Avatar.new({attachable_type: self.class.to_s})
    self.avatar.avatar = file
    avatar = self.avatar
    avatar.save(validation: false)
    file.close
  end

  def count_notification
    Notification.where(user_id: self.id).pluck('count(notifications.id)')[0]
  end

  def notified?
    count_notification > 0
  end

  def set_preferences
    Preference.create(user_id: self.id, key: Preference.keys[:notification_watcher_in_app], boolean_value: true)
    Preference.create(user_id: self.id, key: Preference.keys[:notification_watcher_email], boolean_value: true)
    Preference.create(user_id: self.id, key: Preference.keys[:notification_participant_in_app], boolean_value: true)
    Preference.create(user_id: self.id, key: Preference.keys[:notification_participant_email], boolean_value: true)
  end

end
