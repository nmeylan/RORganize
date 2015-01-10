# Author: Nicolas Meylan
# Date: 10.01.15
# Encoding: UTF-8
# File: permission_test.rb
require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

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

  test 'caption should be equal to name' do
    permission = permissions(:permissions_001)
    assert_equal permission.name, permission.caption
  end

  test 'it should not save if name action and controller are not provide' do
    permission = Permission.new(action: 'new', controller: 'controller')
    assert_not permission.save

    permission = Permission.new(name: 'New', controller: 'controller')
    assert_not permission.save

    permission = Permission.new(name: 'New')
    assert_not permission.save

    permission = Permission.new(action: 'new', controller: 'controller', name: 'New')
    assert permission.save
  end

  test 'permit attribute should contains' do
    assert_match_array [:name, :action, :controller], Permission.permit_attributes
  end
end