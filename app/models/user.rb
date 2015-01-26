class User < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Journalizable
  include Rorganize::Models::Attachable::AvatarType
  include Rorganize::Models::UserExtraMethods
  extend FriendlyId

  exclude_attributes_from_journal(:encrypted_password, :reset_password_token,
                                  :reset_password_sent_at, :remember_created_at,
                                  :sign_in_count, :current_sign_in_at,
                                  :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip)
  #Slug
  friendly_id :name, use: :slugged
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  # Setup accessible (or protected) attributes for your model
  #attr_accessible :id, :login, :email, :name, :password, :password_confirmation, :remember_me
  #Relations
  has_many :members, class_name: 'Member', dependent: :delete_all
  has_many :assigned_issues, foreign_key: :assigned_to_id, class_name: 'Issue'
  has_many :notifications, dependent: :delete_all
  has_many :preferences, dependent: :delete_all
  #Validators
  validates :login, :name, presence: true, length: 4..50, uniqueness: true
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

  def member_for(project_id)
    Member.find_by_user_id_and_project_id(self.id, project_id)
  end

  def allowed_roles(project)
    if admin_act_as_admin?
      Role.all_non_locked
    else
      member = self.member_for(project.id)
      member.role.assignable_roles
    end
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
    self.admin
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
    Thread.current[:user].checked_permissions = {} if Thread.current[:user]
  end

  def act_as_admin?
    Thread.current[:user_act_as] ||= 'User'
    Thread.current[:user_act_as].eql?('Admin')
  end

  def act_as_admin(session)
    Thread.current[:user_act_as] = session
  end

  def time_entries_for_month(year, month)
    dt = Date.new(year, month)
    start_of_month = dt.beginning_of_month
    end_of_month = dt.end_of_month
    TimeEntry.where('user_id = ? AND spent_on >= ? AND spent_on <= ?', self.id, start_of_month, end_of_month).eager_load(:project)
  end

  def allowed_statuses(project)
    member = self.member_for(project.id)
    if member
      load_allowed_statuses member.role.issues_statuses
    elsif project.is_public
      load_allowed_statuses Role.non_member.issues_statuses
    else
      load_allowed_statuses Role.find_by_name('Anonymous').issues_statuses
    end
  end

  def load_allowed_statuses(status_rel)
    status_rel.eager_load(:enumeration).order('enumerations.position ASC')
  end


  # Get projects when user is a member or when projects are public.
  # @param [String] filter which values are : 'opened' or 'archived' or 'starred'
  def owned_projects(filter)
    case filter
      when 'opened'
        conditions = "projects.is_archived = 0 AND (members.user_id = #{self.id}) "
      when 'archived'
        conditions = "projects.is_archived = 1 AND (members.user_id = #{self.id}) "
      when 'starred'
        conditions = "members.is_project_starred = 1 AND (members.user_id = #{self.id}) "
      else
        conditions = self.act_as_admin? ? '1 = 1 ' : "(members.user_id = #{self.id}) "
    end
    conditions += 'AND journals.id = (SELECT max(j.id) FROM journals j WHERE j.project_id = projects.id)'
    if self.members.any?
      Project
          .joins("INNER JOIN `members` ON `members`.`project_id` = `projects`.`id` OR
                    (`projects`.`is_public` = 1 AND projects.id NOT IN
                    (SELECT p2.id FROM projects p2 JOIN members m2 ON p2.id = m2.project_id WHERE m2.user_id = #{self.id}))
                    LEFT OUTER JOIN `watchers` ON `watchers`.`watchable_id` = `projects`.`id` AND
                    `watchers`.`watchable_type` = \'Project\' AND watchers.user_id = members.user_id")
          .eager_load(journals: :user)
          .where(conditions)
          .order('members.project_position ASC')
          .preload(:members, :watchers)
    else
      Project.eager_load(journals: :user)
          .where('journals.id = (SELECT max(j.id) FROM journals j WHERE j.project_id = projects.id) AND projects.is_public = ?', true)
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
