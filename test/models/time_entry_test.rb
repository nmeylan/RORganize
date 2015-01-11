# Author: Nicolas Meylan
# Date: 11.01.15
# Encoding: UTF-8
# File: time_entry_test.rb
require 'test_helper'

class TimeEntryTest < ActiveSupport::TestCase

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
    assert_equal [:spent_on, :spent_time, :comment], TimeEntry.permit_attributes
  end

  test 'it should not be saved when attributes are missing' do
    time_entry = TimeEntry.new
    assert_not time_entry.save

    time_entry = TimeEntry.new(issue_id: 1, project_id: 1)
    assert_not time_entry.save

    time_entry = TimeEntry.new(issue_id: 1, project_id: 1, spent_time: 4)
    assert_not time_entry.save

    time_entry = TimeEntry.new(issue_id: 1, project_id: 1, spent_time: 4)
    assert_not time_entry.save

    time_entry = TimeEntry.new(issue_id: 1, project_id: 1, spent_time: 4, spent_on: Date.new(2012, 12, 23))
    assert_not time_entry.save

    time_entry = TimeEntry.new(issue_id: 1, project_id: 1, spent_time: 4, spent_on: Date.new(2012, 12, 23), user_id: User.current.id)
    assert time_entry.save
  end
end