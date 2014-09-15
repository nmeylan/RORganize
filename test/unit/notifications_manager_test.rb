# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: comment_test.rb
require 'test_helper'

class NotificationsManagerTest < ActiveSupport::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    User.current = User.find_by_id(5)
    @issue = Issue.new({subject: 'test', description: 'sample issue', tracker_id: Tracker.first.id, author_id: 1, status_id: IssuesStatus.first.id, project_id: 1})
    @issue.save
    @journal = Journal.find_by_action_type_and_journalizable_id_and_journalizable_type('created', @issue.id, @issue.class.to_s)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @issue.destroy
  end

  test 'Recipients : author and assigned on journal creation' do
    notif = @journal.create_notification
    assert_equal [1], notif.recipients.collect { |r| r.id }

    @issue.assigned_to_id = 5
    @issue.status_id = 5
    @issue.save
    @journal = Journal.where(journalizable_id: @issue.id, journalizable_type: @issue.class.to_s).last
    notif = @journal.create_notification
    assert_equal [1], notif.recipients.collect { |r| r.id }

    @issue.assigned_to_id = 7
    @issue.save
    @journal = Journal.where(journalizable_id: @issue.id, journalizable_type: @issue.class.to_s).last
    notif = @journal.create_notification
    assert_equal [1, 7], notif.recipients.collect { |r| r.id }
  end

  test 'Recipients : mentioned in description' do
    @issue.assigned_to_id = 5
    @issue.description = 'Hey @nicolas-meylan'
    @issue.save
    @journal = Journal.where(journalizable_id: @issue.id, journalizable_type: @issue.class.to_s).last
    notif = @journal.create_notification
    assert_equal [1], notif.recipients.collect { |r| r.id }

    @issue.description = 'Hey @nicolas-meylan and @stan-smith'
    @issue.save
    @journal = Journal.where(journalizable_id: @issue.id, journalizable_type: @issue.class.to_s).last
    notif = @journal.create_notification
    assert_equal [1, 7], notif.recipients.collect { |r| r.id }

    @issue.description = 'Hey @nicolas-meylan and @stan-smith @stan-smith'
    @issue.save
    @journal = Journal.where(journalizable_id: @issue.id, journalizable_type: @issue.class.to_s).last
    notif = @journal.create_notification
    assert_equal [1, 7], notif.recipients.collect { |r| r.id }
  end

  test 'Recipients : in comments thread' do
    comment1 = Comment.new({content: 'this a comment', user_id: User.current.id, project_id: 1, commentable_id: @issue.id, commentable_type: 'Issue'})
    comment2 = Comment.new({content: 'this a second comment in same thread', user_id: 1, project_id: 1, commentable_id: @issue.id, commentable_type: 'Issue'})
    comment1.save
    notif = comment1.create_notification
    assert_equal [5], notif.recipients.collect { |r| r.id }
    comment2.save
    notif = comment1.create_notification
    assert_equal [1, 5], notif.recipients.collect { |r| r.id }.sort { |x, y| x <=> y }
    notif = comment2.create_notification
    assert_equal [1, 5], notif.recipients.collect { |r| r.id }.sort { |x, y| x <=> y }
  end

  test 'Recipients : mentionned in comments' do
    comment1 = Comment.new({content: 'this a comment', user_id: 5, project_id: 1, commentable_id: @issue.id, commentable_type: 'Issue'})
    comment1.save
    notif = comment1.create_notification
    assert_equal [5], notif.recipients.collect { |r| r.id }
    comment1.content = 'Hey @nicolas-meylan and @stan-smith'
    comment1.save
    notif = comment1.create_notification
    assert_equal [1, 5, 7], notif.recipients.collect { |r| r.id }.sort { |x, y| x <=> y }
  end


end