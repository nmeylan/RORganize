# Author: Nicolas Meylan
# Date: 09.01.15
# Encoding: UTF-8
# File: issue_gantt_test.rb
require 'test_helper'

class IssueGanttTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1)
    @issue2 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1)
    @issue3 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 2)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  test "it should not save when predecessor is self" do
    assert @issue1.predecessor_is_self?(@issue1)
    @issue1.parent = @issue1
    assert_not @issue1.save
  end

  test 'it should not save when predecessor does not exist in the project' do
    assert @issue1.predecessor_not_exists?(@issue3)
    @issue1.parent = @issue3
    assert_not @issue1.save
  end

  test 'it should not save when predecessor is a child' do
    @issue2.parent = @issue1
    assert @issue2.save

    assert_equal @issue1, @issue2.parent
    assert @issue1.children.include?(@issue2)

    assert @issue1.predecessor_is_a_child?(@issue2)
    @issue1.parent = @issue2
    assert_not @issue1.save
  end

  test 'it should override predecessor when it is already set' do
    @issue1.parent = @issue2
    assert @issue1.save
    assert_equal @issue2, @issue1.parent

    @issue1.parent = @issue3
    assert @issue3.save
    assert_equal @issue3, @issue1.parent
  end

  test 'it should bulk edit attributes after gantt edition' do
    start_date = Date.new(2012, 12, 31)
    due_date = Date.new(2013, 01, 31)
    issue_id_attributes_changed_hash = {
        @issue1.id => {start_date: start_date},
        @issue2.id => {start_date: start_date, due_date: due_date}
    }

    assert_nil @issue1.start_date
    assert_nil @issue2.start_date

    Issue.gantt_edit(issue_id_attributes_changed_hash)
    @issue1.reload
    @issue2.reload
    assert_equal start_date, @issue1.start_date
    assert_equal start_date, @issue2.start_date
    assert_equal due_date, @issue2.due_date
  end

  test 'it should no bulk edit attributes after gantt edition when dates are invalid' do
    start_date = Date.new(2012, 12, 31)
    due_date = Date.new(2012, 12, 01)
    issue_id_attributes_changed_hash = {
        @issue1.id => {start_date: start_date},
        @issue2.id => {start_date: start_date, due_date: due_date}
    }

    errors = Issue.gantt_edit(issue_id_attributes_changed_hash)
    @issue1.reload
    @issue2.reload
    assert_equal start_date, @issue1.start_date
    assert_nil @issue2.start_date
    assert_nil @issue2.due_date

    assert errors.any?{|error| error[:start_date]}
  end
end