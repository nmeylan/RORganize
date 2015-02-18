# Author: Nicolas Meylan
# Date: 18.02.15 14:21
# Encoding: UTF-8
# File: permissions_manager_helper_test.rb
require 'test_helper'

class PermissionsManagerHelperTest < ActiveSupport::TestCase
  include Rorganize::Managers::PermissionManager::PermissionManagerHelper
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    reload_permissions
    @role_master = roles(:roles_master)
    @role_non_member = Role.find_by_name('Non member')
    @role_anonymous = Role.find_by_name('Anonymous')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "role master is not allowed to perform new action in controller controller" do
    Rorganize::Managers::PermissionManager.load_permissions_spec_role(@role_master.id)
    assert_not permission_manager_allowed_to?(@role_master.id, 'new', 'controller')
  end

  test "role master is allowed to perform new action in controller controller" do
    permission = Permission.create!(action: 'new', controller: 'controller', name: 'New')
    @role_master.permissions << permission
    @role_master.save
    Rorganize::Managers::PermissionManager.load_permissions_spec_role(@role_master.id)
    assert permission_manager_allowed_to?(@role_master.id, 'new', 'controller')
  end

  test "role non member is not allowed to perform new action in controller controller" do
    Rorganize::Managers::PermissionManager.load_permissions_spec_role(@role_non_member.id)
    assert_not non_member_permission_manager_allowed_to?('new', 'controller')
  end

  test "role non member is allowed to perform new action in controller controller" do
    permission = Permission.create!(action: 'new', controller: 'controller', name: 'New')
    @role_non_member.permissions << permission
    @role_non_member.save
    Rorganize::Managers::PermissionManager.load_permissions_spec_role(@role_non_member.id)
    assert non_member_permission_manager_allowed_to?('new', 'controller')
  end

  test "role anonymous is not allowed to perform new action in controller controller" do
    Rorganize::Managers::PermissionManager.load_permissions_spec_role(@role_anonymous.id)
    assert_not anonymous_permission_manager_allowed_to?('new', 'controller')
  end

  test "role anonymous is allowed to perform new action in controller controller" do
    permission = Permission.create!(action: 'new', controller: 'controller', name: 'New')
    @role_anonymous.permissions << permission
    @role_anonymous.save
    Rorganize::Managers::PermissionManager.load_permissions_spec_role(@role_anonymous.id)
    assert anonymous_permission_manager_allowed_to?('new', 'controller')
  end

  private
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