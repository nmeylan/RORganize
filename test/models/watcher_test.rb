# Author: Nicolas Meylan
# Date: 15.01.15
# Encoding: UTF-8
# File: watcher_test.rb
require 'test_helper'

class WatcherTest < ActiveSupport::TestCase

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

  test 'permit attributes should contains' do
    assert_equal  [:watchable_id, :watchable_type], Watcher.permit_attributes
  end

  test 'it should not be saved if user id is missing' do
    watcher = Watcher.new(watchable_type: 'Issue', watchable_id: 666, project_id: 666)
    assert_not watcher.save
    watcher.user_id = 1
    assert watcher.save
  end

  test 'it should not be saved if watchable type or watchable id are missing' do
    watcher = Watcher.new(project_id: 666, user_id: 1)
    assert_not watcher.save
    watcher.watchable_type = 'Issue'
    assert_not watcher.save
    watcher.watchable_id = 1
    assert watcher.save
  end
end