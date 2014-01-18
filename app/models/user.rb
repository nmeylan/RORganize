class User < RorganizeActiveRecord
  include ProjectHelper
  include Rorganize::PermissionManager::PermissionManagerHelper
  include Rorganize::ModuleManager::ModuleManagerHelper
  #Class variables
  #noinspection RubyStringKeysInHashInspection
  assign_journalized_properties({'name' => 'Name', 'admin' => 'Administrator', 'email' => 'Email', 'login' => 'Login'})
  assign_foreign_keys({})
  assign_journalized_icon('/assets/activity_group.png')
  #SLug
  extend FriendlyId
  friendly_id :name, use: :slugged
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :login, :email, :name, :password, :password_confirmation, :remember_me
  #Relations
  has_many :members, :class_name => 'Member', :dependent => :destroy
  has_many :members_archived, :class_name => 'Member', :include => :project, :conditions => {'projects.is_archived' => true}
  has_many :members_opened, :class_name => 'Member', :include => :project, :conditions => {'projects.is_archived' => false}
  has_many :issues, :class_name => 'Issue', :foreign_key => :author_id, :dependent => :nullify
  has_many :issues, :class_name => 'Issue', :foreign_key => :assigned_to_id, :dependent => :nullify
  has_many :journals, :as => :journalized, :conditions => {:journalized_type => self.to_s}, :dependent => :nullify
  validates :login, :presence => true, :length => 4..50, :uniqueness => true
  validates :name, :presence => true, :length => 4..50
  #Triggers
  after_create :create_journal
  after_update :update_journal
  after_destroy :destroy_journal

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
    TimeEntry.where("user_id = ? AND spent_on >= ? AND spent_on <= ?", self.id, start_of_month, end_of_month).includes(:project)
  end

  def projects
    members= self.members.includes(:project => [:attachments])
    members.sort! { |x, y| x.project_position <=> y.project_position }
    members.collect { |member| member.project }
  end

  def starred_projects
    members= self.members.includes(:project => [:attachments]).select { |member| member.is_project_starred }
    members.sort! { |x, y| x.project_position <=> y.project_position }
    members.collect { |member| member.project }
  end

  def archived_projects
    members= self.members_archived.includes(:project => [:attachments])
    members.sort! { |x, y| x.project_position <=> y.project_position }
    members.collect { |member| member.project }
  end

  def opened_projects
    members= self.members_opened.includes(:project => [:attachments])
    members.sort! { |x, y| x.project_position <=> y.project_position }
    members.collect { |member| member.project }
  end

  def allowed_statuses(project)
    self.members.select { |member| member.project_id == project.id }.first.role.old_issues_statuses.sort { |x, y| x.enumeration.position <=> y.enumeration.position }
  end

  def allowed_to?(action, controller, project = nil)
    return true if self.is_admin? && act_as_admin? && (project && module_enabled?(project.id.to_s, action, controller) || !project)
    m = self.members
    if project
      member = m.select { |mb| mb.project_id == project.id }.first
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


    #    return self.members.role.permission(action, controller)
  end

  def self.paginated_users(page, per_page, order)
    paginate(:page => page,
             :per_page => per_page,
             :order => order)
  end

  #Get owned projects with filters
  def owned_projects(filter)
    if self.act_as_admin?
      case filter
        when 'opened'
          projects = Project.where(:is_archived => false)
        when 'archived'
          projects = Project.where(:is_archived => true)
        when 'starred'
          projects = self.starred_projects
        else
          projects = Project.select('*')
      end
    else
      case filter
        when 'opened'
          projects = self.opened_projects
        when 'archived'
          projects = self.archived_projects
        when 'starred'
          projects = self.starred_projects
        else
          projects = self.projects
      end
    end
  end

  #Get all coworkers for each project
  def coworkers_per_project
    coworkers = Hash.new { |h, k| h[k] = [] }
    self.members.includes(:role, :project => [:members => [:user, :role]]).each do |member|
      if self.allowed_to?('display_activities', 'Coworkers', member.project)
        coworkers[member.project.name] = member.project.members.delete_if { |m| m.user_id.eql?(self.id) }
      end
    end
    coworkers
  end

  #Load latest assigned requests
  def latest_assigned_issues(order, limit)
    Issue.select('issues.*')
    .where('issues.id IN (?)', Issue.select('issues.id').where('assigned_to_id = ?', self.id).limit(limit).order('issues.id DESC'))
    .includes(:tracker, :project, :status => [:enumeration])
    .order(order)
  end

  def latest_activities(limit)
    Journal.select('journals.*').where(:user_id => self.id).includes(:details, :project, :user, :journalized).limit(limit).order('created_at DESC')
  end


end
