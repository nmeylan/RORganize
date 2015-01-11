# Author: Nicolas Meylan
# Date: 11.01.15
# Encoding: UTF-8
# File: tracker_test.rb
require 'test_helper'

class TrackerTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @tracker = Tracker.create(name: 'Test tracker')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test 'permit attributes should contains' do
    assert_equal [:name], Tracker.permit_attributes
  end

  test 'caption should be equal to name' do
    assert_equal @tracker.name, @tracker.caption
  end

  test 'Decrement position' do
    old_position = @tracker.position
    @tracker.change_position('dec')
    @tracker.change_position('dec')
    @tracker.reload
    assert_equal old_position - 2, @tracker.position
  end

  test 'Increment position must fail' do
    old_position = @tracker.position
    @tracker.change_position('inc')
    @tracker.reload
    assert_equal old_position, @tracker.position
  end

  test 'Crap param position must fail' do
    old_position = @tracker.position
    @tracker.change_position('crap')
    @tracker.reload
    assert_equal old_position, @tracker.position
  end

  test 'set position before create' do
    tracker = Tracker.new(name: 'Hello')
    position_expectation = Tracker.all.count + 1
    assert_not tracker.position
    assert tracker.save
    assert_equal position_expectation, tracker.position
  end

  test 'set position after destroy' do
    tracker = Tracker.new(name: 'Hello')
    assert tracker.save
    assert tracker.position > @tracker.position
    tracker.change_position('dec')
    tracker.reload
    @tracker.reload
    assert tracker.position < @tracker.position
    old_tracker_position = @tracker.position

    tracker.destroy
    @tracker.reload
    assert_equal old_tracker_position - 1, @tracker.position
  end

  test 'it should not be saved if name is invalid' do
    tracker = Tracker.new
    assert_not tracker.save

    tracker = Tracker.new(name: 'a')
    assert_not tracker.save

    tracker = Tracker.new(name: 'LE')
    assert tracker.save

    tracker = Tracker.new(name: 'LE')
    assert_not tracker.save

    tracker = Tracker.new(name: generate_string_of_length(51))
    assert_not tracker.save
  end

  test 'it has many issues and should nullify when it is destroyed' do
    tracker = Tracker.create(name: 'Hello')
    issue = Issue.create(tracker_id: tracker.id, subject: 'Bug1', status_id: 1, project_id: 1)

    assert issue.id
    assert issue.tracker_id

    tracker.destroy
    issue.reload
    assert_not issue.tracker_id
  end
end