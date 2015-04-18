# Author: Nicolas Meylan
# Date: 10.01.15
# Encoding: UTF-8
# File: notification_test.rb
require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @user = users(:users_001)
    @user1 = users(:users_002)
    @project = Project.create(name: 'Rorganize test')
    @project1 = Project.create(name: 'Rorganize test bis')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


  test "it should be uniq for the a same item" do
    issue = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project.id)
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue.id, 'Issue', 'created')
    notification = Notification.create(user_id: @user.id, notifiable_id: issue.id,
                                       notifiable_type: 'Issue', project_id: 1, from_id: @user1.id,
                                       trigger_type: 'Journal',
                                       trigger_id: journal.id,
                                       recipient_type: 'participants')

    assert 1, Notification.where(user_id: @user.id,
                                 notifiable_id: issue.id,
                                 notifiable_type: 'Issue').count


    notification = Notification.create(user_id: @user.id, notifiable_id: issue.id,
                                       notifiable_type: 'Issue', project_id: 1, from_id: @user1.id,
                                       trigger_type: 'Journal',
                                       trigger_id: journal.id,
                                       recipient_type: 'participants')
    assert 1, Notification.where(user_id: @user.id,
                                 notifiable_id: issue.id,
                                 notifiable_type: 'Issue').count
  end

  test 'it count notification per project' do
    notifications = create_notifications
    expectation = {
        @project.slug => {count: 1, id: @project.id},
        @project1.slug => {count: 3, id: @project1.id}
    }

    assert_equal expectation, Notification.count_notifications_by_projects(notifications)
  end

  test 'it should count notification per recipient type' do
    create_notifications

    assert_equal 3, Notification.count_notification_by_recipient_type(@user).first # participants
    assert_equal 1, Notification.count_notification_by_recipient_type(@user)[1] # watchers
  end

  test 'it should load notification and prepare filter for a given user' do
    notifications = create_notifications
    expectation = [
        notifications,
        {all: 4, participants: 3, watchers: 1},
        {@project.slug => {count: 1, id: @project.id}, @project1.slug => {count: 3, id: @project1.id}}]
    result_notifications, filters, projects_filter = Notification.filter_notifications('1=1', '1=1', @user)
    assert_match_array expectation[0], result_notifications.to_a
    assert_equal expectation[1], filters
    assert_equal expectation[2], projects_filter
  end

  test 'it should load deleted notifications' do
    notifications = create_notifications
    notifications.each { |notif| notif.soft_delete }
    assert_empty(Notification.all)
    assert_match_array(notifications, Notification.deleted.to_a)
  end

  private
  def create_notifications
    issues = []
    issues << Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project1.id)
    issues << Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project1.id)
    issues << Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project1.id)
    notifications = []
    issues.each do |issue|
      journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue.id, 'Issue', 'created')
      notifications << Notification.create(user_id: @user.id, notifiable_id: issue.id,
                                           notifiable_type: 'Issue', project_id: issue.project_id, from_id: @user1.id,
                                           trigger_type: 'Journal',
                                           trigger_id: journal.id,
                                           recipient_type: 'participants')
    end

    issue = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project.id)
    journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(issue.id, 'Issue', 'created')
    notifications << Notification.create(user_id: @user.id, notifiable_id: issue.id,
                                         notifiable_type: 'Issue', project_id: issue.project_id, from_id: @user1.id,
                                         trigger_type: 'Journal',
                                         trigger_id: journal.id,
                                         recipient_type: 'watchers')
  end
end