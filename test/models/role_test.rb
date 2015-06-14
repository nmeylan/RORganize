# Author: Nicolas Meylan
# Date: 11.01.15
# Encoding: UTF-8
# File: role_test.rb
require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @role = Role.create(name: 'Role test')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test 'caption should be equal to name' do
    role = roles(:roles_001)
    assert_equal role.name, role.caption
  end

  test 'update permissions' do
    permission = Permission.new(action: 'new', controller: 'controller', name: 'New')
    permission1 = Permission.new(action: 'edit', controller: 'controller', name: 'Edit')
    permission2 = Permission.new(action: 'show', controller: 'controller', name: 'Show')
    assert permission.save, permission.errors.messages
    assert permission1.save, permission1.errors.messages
    assert permission2.save, permission2.errors.messages

    permissions = [permission, permission1, permission2]
    permissions_params = permissions.inject({}) { |memo, perm| memo[perm.name] = perm.id; memo }

    assert_equal [], @role.permissions
    @role.update_permissions(permissions_params)
    assert_match_array permissions, @role.permissions
  end

  test 'it should not be saved if name is invalid' do
    role = Role.new
    assert_not role.save

    role.name = '1'
    assert_not role.save

    role.name = 'LE'
    assert role.save, role.errors.messages

    role.name = generate_string_of_length(256)
    assert_not role.save
  end
end