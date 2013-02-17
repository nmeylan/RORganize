class User < ActiveRecord::Base
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

  validates :login, :presence => true, :length => 4..50, :uniqueness => true
  validates :name, :presence => true, :length => 4..50

  def is_admin?
    return self.admin
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
    m = self.members
    if project
      member = m.select{|mb| mb.project_id == project.id}.first
      return (member && member.role.permissions.find_by_action_and_controller(action,controller)) ? true : false
    else
      if m
        m.each do |member|
          if member.role.permissions.find_by_action_and_controller(action,controller)
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
