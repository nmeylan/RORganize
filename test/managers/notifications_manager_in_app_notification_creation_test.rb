# Author: Nicolas Meylan
# Date: 24.01.15 15:53
# Encoding: UTF-8
# File: notifications_manager_in_app_notification_creation_test.rb
require 'test_helper'

class NotificationsManagerInAppNotificationCreationTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @user = User.create(name: 'Steve Doe', login: 'stdoe', admin: 0, email: 'steve.doe@example.com', password: 'qwertz')
    @user1 = User.create(name: 'John Doe', login: 'jhdoe', admin: 0, email: 'john.doe@example.com', password: 'qwertz')

    @notifiable = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '',
                               status_id: '1', project_id: @project.id, author_id: User.current.id)

    @notifiable_user_mentioned = Issue.create(tracker_id: 1, subject: 'Issue creation',
                                              description: "cc @#{@user.slug}", status_id: '1', project_id: @project.id, author_id: User.current.id)

    @notifiable_user_assigned = Issue.create(tracker_id: 1, subject: 'Issue creation',description: '', assigned_to_id: @user.id,
                                             status_id: '1', project_id: @project.id, author_id: User.current.id)

    @notifiable_user_author = Issue.create(tracker_id: 1, subject: 'Issue creation',description: '',
                                             status_id: '1', project_id: @project.id, author_id: @user.id)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Notifiable creation
  test "should create notification on notifiable creation for users whose watch the project" do
    create_watcher_for(@user, 'Project', @project.id)
    notifiable = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '',
                               status_id: '1', project_id: @project.id, author_id: User.current.id)
    notification = find_journal_type_notification(notifiable, @user)

    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'watchers', notification.recipient_type
    assert_nil find_journal_type_notification(notifiable, @user1)
  end

  test "should create notification on notifiable creation for user who is assigned to it" do

    assert_nil find_journal_type_notification(@notifiable_user_assigned, @user1)
    notification = find_journal_type_notification(@notifiable_user_assigned, @user)
    assert_not_nil notification
    assert_equal 'participants', notification.recipient_type
  end

  test "should create notification on notifiable creation for user who is mentioned on it" do
    notification = find_journal_type_notification(@notifiable_user_mentioned, @user)
    assert_not_nil notification
    assert_equal 'participants', notification.recipient_type
    assert_nil find_journal_type_notification(@notifiable_user_mentioned, @user1)
  end

  # Notifiable update
  test "should create notification on notifiable update for users whose watch the project" do
    create_watcher_for(@user, 'Project', @project.id)
    @notifiable.update_attribute(:status_id, 2)
    notification = find_journal_type_notification(@notifiable, @user)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'watchers', notification.recipient_type

    assert_nil find_journal_type_notification(@notifiable, @user1)
  end

  test "should create notification on notifiable update for users whose watch the notifiable" do
    create_watcher_for(@user, 'Issue', @notifiable.id)
    @notifiable.update_attribute(:status_id, 2)
    notification = find_journal_type_notification(@notifiable, @user)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'watchers', notification.recipient_type

    assert_nil find_journal_type_notification(@notifiable, @user1)
  end

  test "should create notification on notifiable update for user who is assigned to it" do
    @notifiable.update_attribute(:assigned_to_id, @user.id)
    notification = find_journal_type_notification(@notifiable, @user)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'participants', notification.recipient_type
    assert_nil find_journal_type_notification(@notifiable, @user1)

    @notifiable.update_attribute(:assigned_to_id, @user1.id)
    notification = find_journal_type_notification(@notifiable, @user1)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'participants', notification.recipient_type
    assert_nil find_journal_type_notification(@notifiable, @user)

    @notifiable.update_attribute(:status_id, 2)
    notification = find_journal_type_notification(@notifiable, @user1)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'participants', notification.recipient_type
    assert_nil find_journal_type_notification(@notifiable, @user)

    @notifiable_user_assigned.update_attribute(:status_id, 2)
    notification = find_journal_type_notification(@notifiable_user_assigned, @user)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'participants', notification.recipient_type
    assert_nil find_journal_type_notification(@notifiable_user_assigned, @user1)
  end

  test "should create notification on notifiable update for user who is mentioned on it" do
    @notifiable_user_mentioned.update_attribute(:status_id, 1)
    notification = find_journal_type_notification(@notifiable_user_mentioned, @user)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'participants', notification.recipient_type
    assert_nil find_journal_type_notification(@notifiable_user_mentioned, @user1)

    @notifiable_user_mentioned.update_attribute(:assigned_to_id, @user1.id)
    notification = find_journal_type_notification(@notifiable_user_mentioned, @user1)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'participants', notification.recipient_type

    notification = find_journal_type_notification(@notifiable_user_mentioned, @user)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'participants', notification.recipient_type
  end

  # Notifiable comment
  test "should create notification on notifiable comment for users whose watch the project" do
    create_watcher_for(@user, 'Project', @project.id)
    create_comment_on(@user1, @notifiable, 'Hello')
    notification = find_comment_type_notification(@notifiable, @user)
    assert_not_nil notification
    assert_equal 'Comment', notification.trigger_type
    assert_equal 'watchers', notification.recipient_type
    assert_nil find_comment_type_notification(@notifiable, @user1)
  end

  test "should create notification on notifiable comment for users whose watch the notifiable" do
    create_watcher_for(@user, 'Issue', @notifiable.id)
    create_comment_on(@user1, @notifiable, 'Hello')
    notification = find_comment_type_notification(@notifiable, @user)
    assert_not_nil notification
    assert_equal 'Comment', notification.trigger_type
    assert_equal 'watchers', notification.recipient_type
    assert_nil find_comment_type_notification(@notifiable, @user1)
  end

  # Not in the specs
  # test "should create notification on notifiable comment for user who is assigned to it" do
  #   create_comment_on(@user1, @notifiable_user_assigned, 'Hello')
  #   notification = find_comment_type_notification(@notifiable_user_assigned, @user)
  #   assert_not_nil notification
  #   assert_equal 'Comment', notification.trigger_type
  #   assert_equal 'watchers', notification.recipient_type
  #   assert_nil find_comment_type_notification(@notifiable_user_assigned, @user1)
  # end

  test "should create notification on notifiable comment for user who is mentioned on it" do
    create_comment_on(@user1, @notifiable, "cc @#{@user.slug}")
    notification = find_comment_type_notification(@notifiable, @user)
    assert_not_nil notification
    assert_equal 'Comment', notification.trigger_type
    assert_equal 'participants', notification.recipient_type
    assert_nil find_comment_type_notification(@notifiable, @user1)

    create_comment_on(@user1, @notifiable, "OK NP")
    assert_nil find_comment_type_notification(@notifiable, @user)
    assert_nil find_comment_type_notification(@notifiable, @user1)
  end

  test "should create notification on notifiable comment for user who is the author of it" do
    create_comment_on(@user1, @notifiable, "OK NP")
    assert_nil find_comment_type_notification(@notifiable, @user)
    assert_nil find_comment_type_notification(@notifiable, @user1)

    create_comment_on(@user, @notifiable, "OK NP")
    notification = find_comment_type_notification(@notifiable, @user1)
    assert_not_nil notification
    assert_equal 'Comment', notification.trigger_type
    assert_equal 'participants', notification.recipient_type
    assert_nil find_comment_type_notification(@notifiable, @user)
  end

  # Notifiable bulk edited
  test "should create notification on notifiable bulk edited for users whose watch the project" do
    create_watcher_for(@user, 'Project', @project.id)
    Issue.bulk_edit([@notifiable.id], {status_id: 4}, @project)

    notification = find_journal_type_notification(@notifiable, @user)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'watchers', notification.recipient_type
    assert_nil find_journal_type_notification(@notifiable, @user1)
  end

  test "should create notification on notifiable bulk edited for users whose watch notifiable" do
    create_watcher_for(@user, 'Issue', @notifiable.id)
    Issue.bulk_edit([@notifiable.id], {status_id: 4}, @project)

    notification = find_journal_type_notification(@notifiable, @user)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'watchers', notification.recipient_type
    assert_nil find_journal_type_notification(@notifiable, @user1)
  end

  test "should create notification on notifiable bulk edited for users who is assigned to it" do
    Issue.bulk_edit([@notifiable.id], {assigned_to_id: @user.id}, @project)

    notification = find_journal_type_notification(@notifiable, @user)
    assert_not_nil notification
    assert_equal 'Journal', notification.trigger_type
    assert_equal 'participants', notification.recipient_type
    assert_nil find_journal_type_notification(@notifiable, @user1)
  end

  private
  def create_watcher_for(user, watchable_type, watchable_id)
    Watcher.create(watchable_type: watchable_type, watchable_id: watchable_id, project_id: @project.id, user_id: user.id)
  end

  def create_comment_on(author, commentable, content)
    Comment.create(content: content, user_id: author.id, project_id: 1, commentable_id: commentable.id, commentable_type: 'Issue')
  end

  def find_journal_type_notification(notifiable, user)
    journal = notifiable.journals.last
    Notification.find_by_notifiable_id_and_notifiable_type_and_user_id_and_trigger_type_and_trigger_id(notifiable.id, 'Issue', user.id, 'Journal', journal.id)
  end

  def find_comment_type_notification(notifiable, user)
    comment = notifiable.comments.last
    Notification.find_by_notifiable_id_and_notifiable_type_and_user_id_and_trigger_type_and_trigger_id(notifiable.id, 'Issue', user.id, 'Comment', comment.id)
  end
end