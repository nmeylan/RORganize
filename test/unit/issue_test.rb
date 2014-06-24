# Author: Nicolas
# Date: 02/05/2014
# Encoding: UTF-8
# File: issue_test.rb
# require 'test/unit'
require 'test_helper'
class IssueTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    User.current = User.find_by_id(1)
    @issue = Issue.new(tracker_id: 1, subject: "Issue creation", status_id: "1", done: 0, project_id: 1, due_date: '2012-12-31')
    @issue.save
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @issue.destroy
  end

  test "Journal creation on issue create" do
    journal = Journal.find_by_journalized_id_and_journalized_type(@issue.id, 'Issue')
    assert_not_nil(journal)
  end

  test "Journal creation on issue update" do
    @issue.attributes = {tracker_id: 2}
    @issue.save
    journal = Journal.where(journalized_id: @issue.id, journalized_type: 'Issue').order('id desc').first
    journal_details = journal.details.to_a
    assert_equal(1, journal_details.size)
    assert_equal('tracker_id', journal_details.first.property_key)
  end

  test "Set done  before create callback" do
    #Status 4 is "Fixed to test", default done value is 100
    @issue.attributes = {status_id: 4}
    @issue.save
    assert_equal(100, @issue.done)
  end

  test "Set due date before update callback" do
    version = Version.find_by_id(2)
    assert_not_equal(@issue.due_date, version.target_date)
    @issue.version = version
    @issue.save
    assert_equal(version.target_date, @issue.due_date)
  end

end