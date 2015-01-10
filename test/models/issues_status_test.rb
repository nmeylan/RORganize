# Author: Nicolas
# Date: 02/05/2014
# Encoding: UTF-8
# File: issues_status_test.rb
require 'test_helper'
class IssuesStatusTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @status = IssuesStatus.new({default_done_ratio: 0, is_closed: 0})
    @enumeration = Enumeration.new(name: 'TEST_STATUS', opt: 'ISTS')
    @status.enumeration = @enumeration
    @status.save
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @status.destroy
  end

  test 'Increment position on enumeration create' do
    statuses = Enumeration.where(opt: 'ISTS').order('position ASC')
    i = 1
    #Check uniq position
    statuses.each do |status|
      assert_equal status.position, i
      i += 1
    end
    #Check last enumeration created equal last index
    assert_equal @enumeration.position, i - 1
  end

  test 'Decrement position' do
    old_position = @status.enumeration.position
    @status.change_position('dec')
    @status.change_position('dec')
    @status.reload
    assert_equal old_position - 2, @status.enumeration.position
  end

  test 'Increment position must fail' do
    old_position = @status.enumeration.position
    @status.change_position('inc')
    @status.reload
    assert_equal old_position, @status.enumeration.position
  end

  test 'Crap param position must fail' do
    old_position = @status.enumeration.position
    @status.change_position('crap')
    @status.reload
    assert_equal old_position, @status.enumeration.position
  end

  test 'permit attributes should contains' do
    assert_equal [:is_closed, :default_done_ratio, :color], IssuesStatus.permit_attributes
  end

  test 'caption should be equal to enumeration name' do
    assert_equal @enumeration.name, @status.caption
  end

  test 'position should be equal to enumeration position' do
    assert_equal @enumeration.position, @status.position
  end

  test 'scope find by name' do
    status = IssuesStatus.find_by_name('TEST_STATUS')
    assert_equal @status, status
  end
  test 'status creation' do
    status = IssuesStatus.create_status('TEST_STATUS', default_done_ratio: 0, is_closed: 0)
    assert_not status.id

    assert status.errors.messages.any?
    assert_equal({name: ['must be uniq.']}, status.errors.messages)

    status = IssuesStatus.create_status(nil, default_done_ratio: 0, is_closed: 0)
    assert_not status.id

    assert status.errors.messages.any?
    assert_equal({name: ["can't be blank", "is too short (minimum is 2 characters)"]}, status.errors.messages)

    status = IssuesStatus.create_status('TEST_STATUS1', default_done_ratio: 0, is_closed: 0, color: '#566643')
    assert status.id
    assert status.enumeration
  end

  test 'opened statuses id' do
    expectation = [1, 2, 4, 5, 6, 7, 8, @status.id]
    assert_equal expectation, IssuesStatus.opened_statuses_id
  end

  test 'it belongs to enumeration delete orphan when status is destroyed' do
    status = IssuesStatus.create_status('TEST_STATUS1', default_done_ratio: 0, is_closed: 0, color: '#566643')
    assert status.id
    enumeration = status.enumeration
    assert enumeration
    status.destroy
    assert_raises(ActiveRecord::RecordNotFound) { enumeration.reload }
  end

  test 'it has many issues nullify when status is destroyed' do
    status = IssuesStatus.create_status('TEST_STATUS1', default_done_ratio: 0, is_closed: 0, color: '#566643')
    issue = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: status.id, project_id: 1)
    assert status.id, issue.status_id
    status.destroy
    issue.reload
    assert_not issue.status_id
  end

end