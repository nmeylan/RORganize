# Author: Nicolas Meylan
# Date: 19.01.15 17:17
# Encoding: UTF-8
# File: issue_watchable_test.rb
require 'test_helper'

class IssueWatchableTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @issue = Issue.new(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1',
                          done: 10, project_id: 1, start_date: '2012-12-01', due_date: '2012-12-31')
    @issue.stubs(:auto_watch_issue).returns(nil)
    @issue.save
    @user = User.create(name: 'Steve Doe', login: 'stdoe', admin: 0, email: 'steve.doe@example.com', password: 'qwertz')
    @user1 = User.create(name: 'John Doe', login: 'jhdoe', admin: 0, email: 'john.doe@example.com', password: 'qwertz')

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "it can be watched by users" do
    assert_empty @issue.watchers.to_a
    assert_not @issue.watch_by?(@user)
    Watcher.create(watchable_type: 'Issue', watchable_id: @issue.id, project_id: @project.id, user_id: @user.id)

    @issue.reload
    assert_not_empty @issue.watchers.to_a
    assert @issue.watch_by?(@user)
    assert_not @issue.watch_by?(@user1)
  end

  test 'it is watched if user watch project' do
    assert_empty @issue.watchers.to_a
    assert_not @issue.watch_by?(@user)
    Watcher.create(watchable_type: 'Project', watchable_id: @issue.project_id, project_id: @project.id, user_id: @user.id)

    @issue.reload
    assert @issue.watch_by?(@user)
    assert_not @issue.watch_by?(@user1)
  end

  test 'it is not watched even if user watch project when user exclude it' do
    assert_empty @issue.watchers.to_a
    assert_not @issue.watch_by?(@user)
    Watcher.create(watchable_type: 'Project', watchable_id: @issue.project_id, project_id: @project.id, user_id: @user.id)
    Watcher.create(watchable_type: 'Issue', watchable_id: @issue.id, project_id: @project.id, user_id: @user.id, is_unwatch: true)

    @issue.reload
    assert_not @issue.watch_by?(@user)
  end

  test 'it give the watcher object for the given user' do
    assert_not @issue.watcher_for(@user)
    watcher = Watcher.create(watchable_type: 'Issue', watchable_id: @issue.id, project_id: @project.id, user_id: @user.id)

    @issue.reload
    assert_equal watcher, @issue.watcher_for(@user)
    assert_not @issue.watcher_for(@user1)
  end

  test 'it retrieve all real watchers' do
    assert_empty @issue.real_watchers
    watcher = Watcher.create(watchable_type: 'Issue', watchable_id: @issue.id, project_id: @project.id, user_id: @user.id)

    assert_match_array [watcher], @issue.real_watchers.to_a

    watcher.update_attribute(:is_unwatch, true)
    @issue.reload
    assert_empty @issue.real_watchers.to_a
    assert_match_array [watcher], @issue.watchers.to_a

    watcher1 = Watcher.create(watchable_type: 'Project', watchable_id: @issue.project_id, project_id: @project.id, user_id: @user1.id)
    assert_match_array [watcher1], @issue.real_watchers.to_a

    watcher.update_attribute(:is_unwatch, false)

    assert_match_array [watcher1, watcher], @issue.real_watchers.to_a
  end

  test 'it delete all watcher when bulk delete dependent is called' do
    watcher = Watcher.create(watchable_type: 'Issue', watchable_id: 666, project_id: @project.id, user_id: @user.id, is_unwatch: true)
    watcher1 = Watcher.create(watchable_type: 'Issue', watchable_id: 667, project_id: @project.id, user_id: @user.id, is_unwatch: true)

    assert watcher.reload
    assert watcher1.reload

    Rorganize::Models::Watchable::bulk_delete_dependent([666, 667], 'Issue')

    assert_raise(ActiveRecord::RecordNotFound) { watcher.reload }
    assert_raise(ActiveRecord::RecordNotFound) { watcher1.reload }
  end
end