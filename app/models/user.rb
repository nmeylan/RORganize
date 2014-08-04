class User < ActiveRecord::Base
  include Rorganize::SmartRecords
  include Rorganize::JounalsManager
  include Rorganize::PermissionManager::PermissionManagerHelper
  include Rorganize::ModuleManager::ModuleManagerHelper
  include Rorganize::Attachable::AvatarType
  extend FriendlyId

  assign_journalized_properties({name: 'Name', admin: 'Administrator', email: 'Email', login: 'Login'})
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
  has_many :journals, -> { where :journalized_type => 'User' }, :as => :journalized, :dependent => :nullify
  #Validators
  validates :login, :presence => true, :length => 4..50, :uniqueness => true
  validates :name, :presence => true, :length => 4..50
  #Triggers
  after_create :create_journal, :generate_default_avatar
  after_update :update_journal
  after_destroy :destroy_journal
  #Scope
  default_scope { eager_load(:avatar)}

  def self.attachments_type
    :avatar
  end

  def caption
    self.name
  end

  def should_generate_new_friendly_id?
    name_changed?
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
    self.members.to_a.select { |member| member.project_id == project.id }.first.role.issues_statuses.eager_load(:enumeration).sort { |x, y| x.enumeration.position <=> y.enumeration.position }
  end

  def allowed_to?(action, controller, project = nil)
    return true if self.is_admin? && act_as_admin? && (project && module_enabled?(project.id.to_s, action, controller) || !project)
    m = self.members
    if project
      member = m.to_a.select { |mb| mb.project_id == project.id }.first
      return (member &&
          module_enabled?(project.id.to_s, action, controller) &&
          permission_manager_allowed_to?(member.role.id.to_s, action.to_s, controller.downcase.to_s) &&
          (!project.is_archived? || (project.is_archived? && project_archive_permissions(action, controller))))
    else
      if m
        for mem in m do
          if permission_manager_allowed_to?(mem.role_id.to_s, action.to_s, controller.downcase.to_s)
            return true
          end
        end
        return false
      end
    end
  end

  #Get owned projects with filters
  def owned_projects(filter)
    case filter
      when 'opened'
        conditions = 'projects.is_archived = false '
      when 'archived'
        conditions = 'projects.is_archived = true '
      when 'starred'
        conditions = 'members.is_project_starred = true '
      else
        conditions = '1 = 1 '
    end
    unless self.act_as_admin?
      conditions += "AND members.user_id = #{self.id} "
    end
    conditions += 'AND journals.id = (SELECT max(j.id) FROM journals j WHERE j.project_id = projects.id)'
    Project.eager_load([:members, [journals: :user]]).where(conditions).group('1')
  end

  #Get all coworkers for each project
  def coworkers_per_project
    coworkers = Hash.new { |h, k| h[k] = [] }
    if self.is_admin? && self.act_as_admin?
      condition = ['users.id = ?', self.id]
    else
      condition = ['users.id = ? AND `permissions`.`action` = ? AND `permissions`.`controller` = ?', self.id, 'display_activities', 'Coworkers']
    end
    project_ids = Project.joins(members: [:user, role: :permissions]).where(condition).group('1').pluck('projects.id')
    members = Member.eager_load(:user, :role, :project).where('project_id IN (?) AND user_id <> ?', project_ids.to_a, self.id)
    members.each do |member|
      coworkers[member.project.name] << member
    end
    coworkers
  end

  #Load latest assigned requests
  def latest_assigned_issues(order, limit)
    Issue.select('issues.*')
    .where('issues.id IN (?)', Issue.select('issues.id').where('assigned_to_id = ?', self.id).order('issues.id DESC'))
    .eager_load(:tracker, :project, :status => [:enumeration])
    .order(order).limit(limit)
  end

  def latest_activities(limit)
    Journal.select('journals.*').where(:user_id => self.id).includes(:details, :project, :user, :journalized).limit(limit).order('created_at DESC')
  end

  def generate_default_avatar
    path = "#{Rails.root}/public/system/identicons/#{self.slug}_avatar.png"
    Identicon.file_for self.slug, path
    file = File.open(path)
    self.avatar = Attachment.new({object_type: self.class.to_s})
    self.avatar.avatar = file
    avatar = self.avatar
    avatar.save(validation: false)
    file.close
  end

end
