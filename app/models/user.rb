class User < ActiveRecord::Base

  include ProjectHelper
  include Rorganize::PermissionManager::PermissionManagerHelper
  include Rorganize::ModuleManager::ModuleManagerHelper
  #SLug
  extend FriendlyId
  friendly_id :name, use: :slugged
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :email, :name, :password, :password_confirmation, :remember_me

  has_many :members, :class_name => 'Member', :dependent => :destroy
  has_many :issues, :class_name => 'Issue', :foreign_key => :author_id, :dependent => :nullify
  has_many :issues, :class_name => 'Issue', :foreign_key => :assigned_to_id, :dependent => :nullify
  has_many :journals, :as => :journalized,  :conditions => {:journalized_type => self.to_s}, :dependent => :nullify
  validates :login, :presence => true, :length => 4..50, :uniqueness => true
  validates :name, :presence => true, :length => 4..50

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
  def allowed_to?(action, controller, project = nil)
    return true if self.is_admin? && act_as_admin?
    m = self.members.includes(:project,:role)
    if project
      member = m.select{|mb| mb.project_id == project.id}.first
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
end
