# Author: Nicolas Meylan
# Date: 21.01.15 08:32
# Encoding: UTF-8
# File: project_watchable_test.rb
require 'test_helper'

class ProjectWatchableTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1',
                          done: 10, project_id: 1, start_date: '2012-12-01', due_date: '2012-12-31')
    User.stub_any_instance :generate_default_avatar, nil do
      @user = User.create(name: 'Steve Doe', login: 'stdoe', admin: 0, email: 'steve.doe@example.com', password: 'qwertz')
      @user1 = User.create(name: 'John Doe', login: 'jhdoe', admin: 0, email: 'john.doe@example.com', password: 'qwertz')
    end
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test 'it retrieve all real watchers' do
    assert_empty @project.real_watchers
    watcher = Watcher.create(watchable_type: 'Project', watchable_id: @project.id, project_id: @project.id, user_id: @user.id)

    assert_match_array [watcher], @project.real_watchers.to_a

    watcher.update_attribute(:is_unwatch, true)
    @project.reload
    assert_empty @project.real_watchers.to_a
    assert_match_array [watcher], @project.watchers.to_a

    watcher1 = Watcher.create(watchable_type: 'Project', watchable_id: @project.id, project_id: @project.id, user_id: @user1.id)
    assert_match_array [watcher1], @project.real_watchers.to_a

    watcher.update_attribute(:is_unwatch, false)

    assert_match_array [watcher1, watcher], @project.real_watchers.to_a
  end
end