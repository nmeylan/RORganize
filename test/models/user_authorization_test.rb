# Author: Nicolas Meylan
# Date: 12.01.15
# Encoding: UTF-8
# File: user_authorization_test.rb
require 'test_helper'
require 'rorganize/anonymous_user'

class UserAuthorizationTest < ActiveSupport::TestCase
  include Rorganize::Managers::ModuleManager::ModuleManagerHelper
  LOWER_CONTROLLER = 'lower'
  UPPER_CONTROLLER = 'Upper'
  ADMINISTRATION_CONTROLLER = 'administration'
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    User.stub_any_instance :generate_default_avatar, nil do
      initialize_project_context
      initialize_permissions
      assign_roles_permissions
      reload_enabled_module(@project_private.id)
      reload_enabled_module(@project_public.id)
      @controllers = [LOWER_CONTROLLER, UPPER_CONTROLLER]
      Rorganize::Managers::PermissionManager.reload_permissions
    end
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test 'users with master role should be allowed to perform all actions on private project' do
    allowed_actions = %w(new edit show index destroy)
    @controllers.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_master, action, controller, @project_private)
      end
    end
  end

  test 'users with master role should be allowed to perform all actions on public project' do
    allowed_actions = %w(new edit show index destroy)
    @controllers.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_master, action, controller, @project_public)
      end
    end
  end

  test 'users with semi-master role should be allowed to perform new show index actions on private project' do
    allowed_actions = %w(new show index)
    forbidden_actions = %w(destroy edit)
    @controllers.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_semi_master, action, controller, @project_private)
      end
    end

    @controllers.each do |controller|
      forbidden_actions.each do |action|
        permissions_assert_not(@user_semi_master, action, controller, @project_private)
      end
    end
  end

  test 'users with semi-master role should be allowed to perform new show index actions on public project' do
    allowed_actions = %w(new show index)
    forbidden_actions = %w(destroy edit)
    @controllers.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_semi_master, action, controller, @project_public)
      end
    end

    @controllers.each do |controller|
      forbidden_actions.each do |action|
        permissions_assert_not(@user_semi_master, action, controller, @project_public)
      end
    end
  end

  test 'users with trainee role should be allowed to perform new show index actions on private project' do
    allowed_actions = %w(show index)
    forbidden_actions = %w(destroy edit new)
    @controllers.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_trainee, action, controller, @project_private)
      end
    end

    @controllers.each do |controller|
      forbidden_actions.each do |action|
        permissions_assert_not(@user_trainee, action, controller, @project_private)
      end
    end
  end

  test 'users with trainee role should be allowed to perform new show index actions on public project' do
    allowed_actions = %w(show index)
    forbidden_actions = %w(destroy edit new)
    @controllers.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_trainee, action, controller, @project_public)
      end
    end
    @controllers.each do |controller|
      forbidden_actions.each do |action|
        permissions_assert_not(@user_trainee, action, controller, @project_public)
      end
    end
  end

  test 'users with non member should not be allowed to perform any actions on private project' do
    actions = %w(show index destroy edit new)
    @controllers.each do |controller|
      actions.each do |action|
        permissions_assert_not(@user_non_member, action, controller, @project_private)
      end
    end
  end

  test 'anonymous should not be allowed to perform any actions on private project' do
    actions = %w(show index destroy edit new)
    @controllers.each do |controller|
      actions.each do |action|
        permissions_assert_not(@user_anonymous, action, controller, @project_private)
      end
    end
  end

  test 'users with non member should be allowed to perform index actions on public project' do
    allowed_actions = %w(index)
    forbidden_actions = %w(destroy edit new show)
    @controllers.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_non_member, action, controller, @project_public)
      end
    end

    @controllers.each do |controller|
      forbidden_actions.each do |action|
        permissions_assert_not(@user_non_member, action, controller, @project_public)
      end
    end
  end

  test 'anonymous should be allowed to perform index actions on public project' do
    allowed_actions = %w(index)
    forbidden_actions = %w(destroy edit new show)
    @controllers.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_non_member, action, controller, @project_public)
      end
    end

    @controllers.each do |controller|
      forbidden_actions.each do |action|
        permissions_assert_not(@user_non_member, action, controller, @project_public)
      end
    end
  end

  test 'admin acting as user should not be allowed to perform any actions on private project' do
    actions = %w(show index destroy edit new)
    @controllers.each do |controller|
      actions.each do |action|
        permissions_assert_not(@user_admin, action, controller, @project_private)
      end
    end
  end

  test 'admin acting as user should be allowed to perform index actions on public project' do
    allowed_actions = %w(index)
    forbidden_actions = %w(destroy edit new show)
    @controllers.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_admin, action, controller, @project_public)
      end
    end

    @controllers.each do |controller|
      forbidden_actions.each do |action|
        permissions_assert_not(@user_admin, action, controller, @project_public)
      end
    end
  end

  test 'admin acting as admin should be allowed to perform any actions on all projects' do
    actions = %w(show index destroy edit new)
    @user_admin.act_as_admin('Admin')
    @controllers.each do |controller|
      actions.each do |action|
        permissions_assert(@user_admin, action, controller, @project_private)
        permissions_assert(@user_admin, action, controller, @project_public)
      end
    end
    @user_admin.act_as_admin('User')
  end

  # It should never happen, but we also test this case.
  test 'non member acting as admin should be allowed to perform any actions on private project' do
    actions = %w(show index destroy edit new)
    @user_non_member.act_as_admin('Admin')
    @controllers.each do |controller|
      actions.each do |action|
        permissions_assert_not(@user_non_member, action, controller, @project_private)
      end
    end
    @user_non_member.act_as_admin('User')
  end

  test 'admin acting as admin should be allowed to perform any actions on admin context' do
    actions = %w(show index destroy edit new)
    @user_admin.act_as_admin('Admin')
    actions.each do |action|
      permissions_assert(@user_admin, action, ADMINISTRATION_CONTROLLER)
    end
    @user_admin.act_as_admin('User')
  end

  test 'admin acting as user should not be allowed to perform any actions on admin context' do
    actions = %w(show index destroy edit new)
    actions.each do |action|
      permissions_assert_not(@user_admin, action, ADMINISTRATION_CONTROLLER)
    end
  end

  test 'users with master role should be allowed to perform all actions on admin context' do
    allowed_actions = %w(show index)
    allowed_actions.each do |action|
      permissions_assert(@user_master, action, ADMINISTRATION_CONTROLLER)
    end
  end

  test 'users with semi master role should be allowed to perform index actions on admin context' do
    allowed_actions = %w(index)
    allowed_actions.each do |action|
      permissions_assert(@user_semi_master, action, ADMINISTRATION_CONTROLLER)
    end
  end

  test 'users with semi master role acting as admin should be allowed to perform all actions on admin context' do
    allowed_actions = %w(index show)
    @user_semi_master.act_as_admin('Admin')
    allowed_actions.each do |action|
      permissions_assert(@user_semi_master, action, ADMINISTRATION_CONTROLLER)
    end
    @user_semi_master.act_as_admin('User')
  end

  private
  def permissions_assert(user, action, controller, project = nil)
    User.current = user
    assert user.allowed_to?(action, controller, project), assertion_error_message(true, user, action, controller, project)
  end

  def permissions_assert_not(user, action, controller, project = nil)
    User.current = user
    assert_not user.allowed_to?(action, controller, project), assertion_error_message(false, user, action, controller, project)
  end

  def assertion_error_message(assertion_type, user, action, controller, project)
    project_text = "on project : #{project.name}" if project
    "#{user.name} #{assertion_type ? 'should' : 'should not'} be allowed to perform #{action}##{controller} #{project_text}"
  end

  def initialize_project_context
    @project_private = Project.create(name: 'Rorganize test', is_public: false)
    @project_private.enabled_modules << EnabledModule.new(name: 'Lower', action: 'index', controller: LOWER_CONTROLLER)
    @project_private.enabled_modules << EnabledModule.new(name: 'Upper', action: 'index', controller: UPPER_CONTROLLER)
    @project_private.save

    @project_public = Project.create(name: 'Rorganize test public', is_public: true)
    @project_public.enabled_modules << EnabledModule.new(name: 'Lower', action: 'index', controller: LOWER_CONTROLLER)
    @project_public.enabled_modules << EnabledModule.new(name: 'Upper', action: 'index', controller: UPPER_CONTROLLER)
    @project_public.save

    @user_admin = User.create(name: 'Admin Doe', login: 'admindoe', admin: 1, email: 'admin.doe@example.com', password: 'qwertz')
    @user_master = User.create(name: 'Steve Doe', login: 'stdoe', admin: 0, email: 'steve.doe@example.com', password: 'qwertz')
    @user_semi_master = User.create(name: 'Tony Doe', login: 'tony', admin: 1, email: 'tony.doe@example.com', password: 'qwertz')
    @user_trainee = User.create(name: 'Roger Doe', login: 'rodoe', admin: 0, email: 'roger.doe@example.com', password: 'qwertz')
    @user_non_member = User.create(name: 'Non member', login: 'nonmber', admin: 0, email: 'non.member@example.com', password: 'qwertz')
    @user_anonymous = AnonymousUser.instance

    @role_master = Role.create(name: 'Master')
    @role_semi_master = Role.create(name: 'Semi master')
    @role_trainee = Role.create(name: 'Trainee')
    @role_non_member = Role.non_member
    @role_anonymous = Role.find_by_name('Anonymous')

    @member_master_private = Member.create(user_id: @user_master.id, project_id: @project_private.id, role_id: @role_master.id)
    @member_semi_master_private = Member.create(user_id: @user_semi_master.id, project_id: @project_private.id, role_id: @role_semi_master.id)
    @member_trainee_private = Member.create(user_id: @user_trainee.id, project_id: @project_private.id, role_id: @role_trainee.id)

    @member_master_public = Member.create(user_id: @user_master.id, project_id: @project_public.id, role_id: @role_master.id)
    @member_semi_master_public = Member.create(user_id: @user_semi_master.id, project_id: @project_public.id, role_id: @role_semi_master.id)
    @member_trainee_public = Member.create(user_id: @user_trainee.id, project_id: @project_public.id, role_id: @role_trainee.id)
  end

  def initialize_permissions
    @permission_lower_new = Permission.create(action: 'new', controller: LOWER_CONTROLLER, name: 'New')
    @permission_lower_edit = Permission.create(action: 'edit', controller: LOWER_CONTROLLER, name: 'Edit')
    @permission_lower_delete = Permission.create(action: 'destRoy', controller: LOWER_CONTROLLER, name: 'Destroy')
    @permission_lower_show = Permission.create(action: 'show', controller: LOWER_CONTROLLER, name: 'Show')
    @permission_lower_index = Permission.create(action: 'index', controller: LOWER_CONTROLLER, name: 'Index')

    @permission_upper_new = Permission.create(action: 'new', controller: UPPER_CONTROLLER, name: 'New')
    @permission_upper_edit = Permission.create(action: 'edit', controller: UPPER_CONTROLLER, name: 'Edit')
    @permission_upper_delete = Permission.create(action: 'Destroy', controller: UPPER_CONTROLLER, name: 'Destroy')
    @permission_upper_show = Permission.create(action: 'show', controller: UPPER_CONTROLLER, name: 'Show')
    @permission_upper_index = Permission.create(action: 'index', controller: UPPER_CONTROLLER, name: 'Index')


    @permission_admin_show = Permission.create(action: 'show', controller: ADMINISTRATION_CONTROLLER, name: 'Show')
    @permission_admin_index = Permission.create(action: 'index', controller: ADMINISTRATION_CONTROLLER, name: 'Index')
  end

  def assign_roles_permissions
    assign_master_permissions
    assign_semi_master_permissions
    assign_trainee_permissions
    assign_non_member_permissions
  end

  def assign_master_permissions
    @role_master.permissions << @permission_lower_new
    @role_master.permissions << @permission_lower_edit
    @role_master.permissions << @permission_lower_delete
    @role_master.permissions << @permission_lower_show
    @role_master.permissions << @permission_lower_index

    @role_master.permissions << @permission_upper_new
    @role_master.permissions << @permission_upper_edit
    @role_master.permissions << @permission_upper_delete
    @role_master.permissions << @permission_upper_show
    @role_master.permissions << @permission_upper_index

    @role_master.permissions << @permission_admin_show
    @role_master.permissions << @permission_admin_index
    assert @role_master.save
  end

  def assign_semi_master_permissions
    @role_semi_master.permissions << @permission_lower_new
    @role_semi_master.permissions << @permission_lower_show
    @role_semi_master.permissions << @permission_lower_index

    @role_semi_master.permissions << @permission_upper_new
    @role_semi_master.permissions << @permission_upper_show
    @role_semi_master.permissions << @permission_upper_index
    @role_semi_master.permissions << @permission_admin_index
    @role_semi_master.save
  end

  def assign_trainee_permissions
    @role_trainee.permissions << @permission_lower_show
    @role_trainee.permissions << @permission_lower_index

    @role_trainee.permissions << @permission_upper_show
    @role_trainee.permissions << @permission_upper_index
    @role_trainee.save
  end

  def assign_non_member_permissions
    @role_non_member.permissions << @permission_lower_index
    @role_non_member.permissions << @permission_upper_index
    @role_non_member.save
  end

  def assign_anonymous_permissions
    @role_anonymous.permissions << @permission_lower_index
    @role_anonymous.permissions << @permission_upper_index
    @role_anonymous.save
  end
end