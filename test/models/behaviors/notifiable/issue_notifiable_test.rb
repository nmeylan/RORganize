# Author: Nicolas Meylan
# Date: 19.01.15 11:26
# Encoding: UTF-8
# File: issue_notifiable_test.rb
require 'test_helper'

class IssueNotifiableTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @user = users(:users_001)
    @user1 = users(:users_002)
    @project1 = Project.create(name: 'Rorganize test bis')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "notifiable has a method to bulk delete all notifications for a given notifiables items" do
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

    Notifiable::bulk_delete_dependent(issues.collect(&:id), 'Issue')
    assert_raise(ActiveRecord::RecordNotFound) {notifications[0].reload}
    assert_raise(ActiveRecord::RecordNotFound) {notifications[1].reload}
    assert_raise(ActiveRecord::RecordNotFound) {notifications[2].reload}
  end
end