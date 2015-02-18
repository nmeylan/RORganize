# Author: Nicolas Meylan
# Date: 18.02.15 10:50
# Encoding: UTF-8
# File: permissions_manager_test.rb
require 'test_helper'

class PermissionsManagerTest < ActiveSupport::TestCase
  include Rorganize::Managers::PermissionManager::PermissionListCreator

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "it loads controllers" do
    expectation = %w(issues documents wiki)
    assert_equal expectation, expectation & load_controllers
  end

  test "it select a controller group" do
    project_group = Rorganize::Managers::PermissionManager.select_controller_group(:project)
    assert_equal I18n.t(:label_project), project_group.caption
    assert_not_empty project_group.controllers
  end

  test "it build a hash of controllers groups" do
    build_controller_group_hash
    project_group_controllers = %w(issues documents)
    administration_group_controllers = %w(roles trackers)
    project_group = Rorganize::Managers::PermissionManager.select_controller_group(:project)
    administration_group = Rorganize::Managers::PermissionManager.select_controller_group(:administration)

    assert_equal project_group_controllers, project_group_controllers & project_group.controllers
    assert_equal administration_group_controllers, administration_group_controllers & administration_group.controllers
  end

  test "it load permissions" do
    roles_permissions_hash = Rorganize::Managers::PermissionManager.load_permissions
    role1 = roles(:roles_master)
    role2 = roles(:roles_semi_master)
    roles = [role1.id.to_s, role2.id.to_s]
    master_permissions = role1.permissions

    assert_equal roles, roles & roles_permissions_hash.keys
    expectation = master_permissions.collect { |permission| {action: permission.action.downcase, controller: permission.controller.downcase} }
    assert_equal expectation, roles_permissions_hash[role1.id.to_s]
  end

  test "it load permissions for the given role" do
    role = Role.create!(name: 'Role Test Manager')
    permission = Permission.create!(action: 'new', controller: 'controller', name: 'New')
    role.permissions << permission
    role.save

    assert_empty Rorganize::Managers::PermissionManager.permissions[role.id.to_s]

    roles_permissions_hash = Rorganize::Managers::PermissionManager.load_permissions_spec_role(role.id)

    assert_not_empty Rorganize::Managers::PermissionManager.permissions[role.id.to_s]
    assert_equal [{action: 'new', controller: 'controller'}], Rorganize::Managers::PermissionManager.permissions[role.id.to_s]

  end
end