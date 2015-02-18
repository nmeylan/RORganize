# Author: Nicolas Meylan
# Date: 12.01.15
# Encoding: UTF-8
# File: user_authorization_test.rb
require 'test_helper'
require 'rorganize/anonymous_user'

class UserAuthorizationTest < ActiveSupport::TestCase
  LOWER_CONTROLLER = 'lower'
  UPPER_CONTROLLER = 'Upper'
  ADMINISTRATION_CONTROLLER = 'administration'
  # Called before every test method runs. Can be used
  # to set up fixture information.

  def setup
    initialize_project_context
    Rorganize::Managers::ModuleManager::reload_enabled_modules(@project_private.id)
    Rorganize::Managers::ModuleManager::reload_enabled_modules(@project_public.id)

    reload_permissions
    @controllers = [LOWER_CONTROLLER, UPPER_CONTROLLER]
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

    @user_admin = users(:users_admin_fixture)
    @user_master = users(:users_master_fixture)
    @user_semi_master = users(:users_semi_master_fixture)
    @user_trainee = users(:users_trainee_fixture)
    @user_non_member = users(:users_non_member_fixture)
    @user_anonymous = AnonymousUser.instance

    @role_master = roles(:roles_master)
    @role_semi_master = roles(:roles_semi_master)
    @role_trainee = roles(:roles_trainee)
    @role_non_member = roles(:roles_non_member)
    @role_anonymous = roles(:roles_anonymous)

    @member_master_private = Member.create(user_id: @user_master.id, project_id: @project_private.id, role_id: @role_master.id)
    @member_semi_master_private = Member.create(user_id: @user_semi_master.id, project_id: @project_private.id, role_id: @role_semi_master.id)
    @member_trainee_private = Member.create(user_id: @user_trainee.id, project_id: @project_private.id, role_id: @role_trainee.id)

    @member_master_public = Member.create(user_id: @user_master.id, project_id: @project_public.id, role_id: @role_master.id)
    @member_semi_master_public = Member.create(user_id: @user_semi_master.id, project_id: @project_public.id, role_id: @role_semi_master.id)
    @member_trainee_public = Member.create(user_id: @user_trainee.id, project_id: @project_public.id, role_id: @role_trainee.id)
  end

  def reload_permissions
    groups = [
        Rorganize::Managers::PermissionManager::ControllerGroup.new(
            :project, I18n.t(:label_project), 'repo',
            %w(categories comments documents issues members projects queries roadmaps settings time_entries versions wiki wiki_pages)),

        Rorganize::Managers::PermissionManager::ControllerGroup.new(
            :administration, I18n.t(:label_administration), 'medium-crown',
            %w(administration issues_statuses permissions roles trackers users)),

        Rorganize::Managers::PermissionManager::ControllerGroup.new(:misc, I18n.t(:label_misc))
    ]

    Rorganize::Managers::PermissionManager.initialize(groups)
  end
end