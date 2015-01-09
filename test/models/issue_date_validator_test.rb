# Author: Nicolas Meylan
# Date: 09.01.15
# Encoding: UTF-8
# File: issue_date_validator_test.rb
require 'test_helper'

class IssueDateValidatorTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @issue1 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, start_date: '2012-11-29', due_date: '2012-12-31')
    @issue2 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, due_date: '2012-12-29')
    @issue3 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, start_date: '2012-12-04')
    @issue4 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, due_date: '2012-12-24')
    @issue5 = Issue.create(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, due_date: '2012-12-19')
    @version1 = Version.create(name: 'test', start_date: '2012-12-01', target_date: '2012-12-21', project_id: 1)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  def assign_version(issue, version, &block)
    issue.version = version
    yield if block_given?
    issue.save
  end

  test 'it should set due date equal to the version target date when due date is greater' do
    assert_equal Date.new(2012, 12, 31), @issue1.due_date
    assert_equal Date.new(2012, 12, 29), @issue2.due_date
    assert_nil @issue3.due_date

    assert @version1.target_date < @issue1.due_date, 'Version target date superior to issue due date'
    assert @version1.target_date < @issue2.due_date, 'Version target date superior to issue due date'

    assign_version(@issue1, @version1, &Proc.new{assert @issue1.update_due_date?(false)})
    assign_version(@issue2, @version1, &Proc.new{assert @issue2.update_due_date?(false)})
    assign_version(@issue3, @version1, &Proc.new{assert @issue3.update_due_date?(false)})

    assert_equal @version1.target_date, @issue1.due_date
    assert_equal @version1.target_date, @issue2.due_date
    assert_equal @version1.target_date, @issue3.due_date

    version = Version.create(name: 'test', start_date: '2012-12-01', target_date: '2012-12-23', project_id: 1)

    assert_equal Date.new(2012, 12, 24), @issue4.due_date

    assign_version(@issue4, version, &Proc.new{assert @issue4.update_due_date?(false)})
    assign_version(@issue5, version, &Proc.new{assert_not @issue5.update_due_date?(false)})

    assert_equal version.target_date, @issue4.due_date
    assert_equal Date.new(2012, 12, 23), @issue4.due_date
    assert_equal Date.new(2012, 12, 19), @issue5.due_date
  end

  test 'it should do not update due date when version target date is null' do
    assert_equal Date.new(2012, 12, 31), @issue1.due_date
    assert_equal Date.new(2012, 12, 29), @issue2.due_date
    version = Version.create(name: 'test', start_date: '2012-12-01', project_id: 1)

    assign_version(@issue1, version, &Proc.new{assert_not @issue1.update_due_date?(false)})
    assign_version(@issue2, version, &Proc.new{assert_not @issue2.update_due_date?(false)})

    assert_equal Date.new(2012, 12, 31), @issue1.due_date
    assert_equal Date.new(2012, 12, 29), @issue2.due_date
  end

  test 'it should set start date equal to the version target date when start date is lesser' do
    assert_equal Date.new(2012, 11, 29), @issue1.start_date
    assert_nil @issue2.start_date
    assert_equal Date.new(2012, 12, 04), @issue3.start_date

    assert @issue1.start_date < @version1.start_date, 'Version target date inferior to issue start date'
    assert @issue3.start_date > @version1.start_date, 'Version target date superior to issue start date'

    assign_version(@issue1, @version1, &Proc.new{assert @issue1.update_start_date?(false)})
    assign_version(@issue2, @version1, &Proc.new{assert @issue2.update_start_date?(false)})
    assign_version(@issue3, @version1, &Proc.new{assert_not @issue3.update_start_date?(false)})

    assert_equal @version1.start_date, @issue1.start_date
    assert_equal @version1.start_date, @issue2.start_date
    assert_equal Date.new(2012, 12, 04), @issue3.start_date
  end

  test 'it should not save when start date is greater than due date' do
    issue = Issue.new(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, start_date: '2013-01-05', due_date: '2012-12-31')
    assert issue.start_date_gt_due_date?
    assert_not issue.save, 'Saved with a start date greater than due date'
    assert_equal "must be inferior than due date : 2012-12-31", issue.errors.messages[:start_date].first

    issue = Issue.new(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, start_date: '2012-12-29', due_date: '2012-12-29')
    assert issue.start_date_gt_due_date?
    assert_not issue.save, 'Saved with a start date greater than due date'
    assert_equal "must be inferior than due date : 2012-12-29", issue.errors.messages[:start_date].first


    issue = Issue.new(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, start_date: '2012-12-30', due_date: '2012-12-31')
    assert_not issue.start_date_gt_due_date?
    assert issue.save
  end

  test 'it should not save when start date is out of version date bound' do
    issue = Issue.new(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, version_id: @version1.id,
                      start_date: '2012-12-22', due_date: '2012-12-24')
    assert issue.start_date_gt_version_due_date?
    assert_not issue.save

    issue = Issue.new(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, version_id: @version1.id,
                      start_date: '2012-11-22', due_date: '2012-12-21')
    assert issue.start_date_lt_version_start_date?
    assert_not issue.save
  end

  test 'it should not save when due date is out of version date bound' do
    issue = Issue.new(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, version_id: @version1.id,
                      start_date: '2012-12-01', due_date: '2012-12-24')
    assert issue.due_date_gt_version_due_date?, 'Due date is less less than version start date'
    assert_not issue.save

    issue = Issue.new(tracker_id: 1, subject: 'Bug', status_id: '1', project_id: 1, version_id: @version1.id,
                      start_date: '2012-11-22', due_date: '2012-11-30')
    assert issue.due_date_lt_version_start_date?, 'Due date is greater than version start date'
    assert_not issue.save
  end

  test 'it should set due date equal to the version target date when due date is greater on bulk edition' do
    issues = []
    issues << @issue1 << @issue2 << @issue3 << @issue4 << @issue5
    issues.each do |issue|
      issue.version = @version1
      issue.save
    end

    Issue.bulk_set_start_and_due_date(issues.collect(&:id), @version1.id, nil)
    issues[0, 4].each do |issue|
      assert_equal @version1.target_date, issue.due_date
    end
  end

  test 'it should set start date equal to the version start date when start date is lesser on bulk edition' do
    issues = []
    @issue2.start_date = Date.new(2012, 11, 24)
    @issue2.save

    issues << @issue1 << @issue2 << @issue3 << @issue4 << @issue5
    issues.each do |issue|
      issue.version = @version1
      issue.save
    end

    Issue.bulk_set_start_and_due_date(issues.collect(&:id), @version1.id, nil)

    [@issue1, @issue2, @issue4, @issue5].each do |issue|
      assert_equal @version1.start_date, issue.start_date
    end
  end
end