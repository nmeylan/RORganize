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
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    User.stub_any_instance :generate_default_avatar, nil do
      initialize_project_context
      initialize_permissions
      assign_roles_permissions
      reload_enabled_module(@project_private.id)
      reload_enabled_module(@project_public.id)
      Rorganize::Managers::PermissionManager.reload_permissions
    end
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test 'users with master role should be allowed to perform all actions' do
    allowed_actions = %w(new edit show index destroy)
    allowed_controller = [LOWER_CONTROLLER, UPPER_CONTROLLER]
    allowed_controller.each do |controller|
      allowed_actions.each do |action|
        permissions_assert(@user_master, action, controller, @project_private)
      end
    end
  end

  private
  def permissions_assert(user, action, controller, project)
    User.current = user
    assert user.allowed_to?(action, controller, project), assertion_error_message(true, user, action, controller, project)
  end

  def permissions_assert_not(user, action, controller, project)
    User.current = user
    assert_not user.allowed_to?(action, controller, project), assertion_error_message(false, user, action, controller, project)
  end

  def assertion_error_message(assertion_type, user, action, controller, project)
    "#{user.name} #{assertion_type ? 'should' : 'should not'} be allowed to perform #{action}##{controller} on project : #{project.name}"
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
    @user_semi_master = User.create(name: 'Tony Doe', login: 'tony', admin: 0, email: 'tony.doe@example.com', password: 'qwertz')
    @user_trainee = User.create(name: 'Roger Doe', login: 'rodoe', admin: 0, email: 'roger.doe@example.com', password: 'qwertz')
    @user_non_member = User.create(name: 'Non member', login: 'nonmber', admin: 0, email: 'non.member@example.com', password: 'qwertz')
    @user_anonymous = AnonymousUser.instance

    @role_master = Role.create(name: 'Master')
    @role_semi_master = Role.create(name: 'Semi master')
    @role_trainee = Role.create(name: 'Trainee')
    @role_non_member = Role.non_member

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
    @permission_lower_delete = Permission.create(action: 'destroy', controller: LOWER_CONTROLLER, name: 'Destroy')
    @permission_lower_show = Permission.create(action: 'show', controller: LOWER_CONTROLLER, name: 'Show')
    @permission_lower_index = Permission.create(action: 'index', controller: LOWER_CONTROLLER, name: 'Index')

    @permission_upper_new = Permission.create(action: 'new', controller: UPPER_CONTROLLER, name: 'New')
    @permission_upper_edit = Permission.create(action: 'edit', controller: UPPER_CONTROLLER, name: 'Edit')
    @permission_upper_delete = Permission.create(action: 'destroy', controller: UPPER_CONTROLLER, name: 'Destroy')
    @permission_upper_show = Permission.create(action: 'show', controller: UPPER_CONTROLLER, name: 'Show')
    @permission_upper_index = Permission.create(action: 'index', controller: UPPER_CONTROLLER, name: 'Index')
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
    assert @role_master.save
  end

  def assign_semi_master_permissions
    @role_semi_master.permissions << @permission_lower_new
    @role_semi_master.permissions << @permission_lower_show
    @role_semi_master.permissions << @permission_lower_index

    @role_semi_master.permissions << @permission_upper_new
    @role_semi_master.permissions << @permission_upper_show
    @role_semi_master.permissions << @permission_upper_index
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
end