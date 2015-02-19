# Author: Nicolas Meylan
# Date: 19.02.15 17:13
# Encoding: UTF-8
# File: permissions_handler_test.rb
require 'test_helper'

class PermissionsHandlerTest < Rorganize::Decorator::TestCase
  include Rorganize::Managers::PermissionManager::PermissionHandler
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "it do not build a link to the action when user is not allowed to perform it in a project context" do
    assert_nil link_to_with_permissions('New issue', new_issue_path(@project), @project, nil)
  end

  test "it do not build a link to the action when user is not allowed to perform it out of project context" do
    assert_nil link_to_with_permissions('New tracker', new_tracker_path, nil, nil)
  end

  test "it build a link to the action when user is allowed to perform it in a project context" do
    allow_user_to('new', 'issues')
    link_output = link_to_with_permissions('New issue', new_issue_path(@project), @project, nil)
    assert_not_nil link_output

    node(link_output)
    assert_select 'a', 1
    assert_select 'a[href=?]', new_issue_path(@project)
    assert_select 'a', text: 'New issue'

  end

  test "it build a link to the action when user is allowed to perform it out of project context" do
    allow_user_to('new', 'trackers')
    link_output = link_to_with_permissions('New tracker', new_tracker_path, @project, nil, {class: 'custom-class'})
    assert_not_nil link_output

    node(link_output)
    assert_select 'a', 1
    assert_select 'a[href=?]', new_tracker_path
    assert_select 'a', text: 'New tracker'
    assert_select 'a.custom-class', 1
  end

  test "it build a link to remote action" do
    allow_user_to('destroy', 'issues')
    link_output = link_to_with_permissions('Delete issue', issue_path(@project, 666), @project, nil,
                                           {remote: true, method: :delete, confirm: 'Are you sure you want to...'})
    assert_not_nil link_output

    node(link_output)
    assert_select 'a', 1
    assert_select 'a', text: 'Delete issue'
    assert_select 'a[data-remote=?]', 'true'
    assert_select 'a[data-confirm=?]', 'Are you sure you want to...'
  end
end