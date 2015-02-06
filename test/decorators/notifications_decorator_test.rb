require 'test_helper'

class NotificationsDecoratorTest < Rorganize::Decorator::TestCase

  def setup
    @project = projects(:projects_001)
    @user = users(:users_001)
    @user1 = users(:users_002)
    create_issue_notification
    notifications, filters, projects = Notification.filter_notifications('1=1', '1=1', User.current)
    @notifications_decorator = notifications.decorate(context:{filters: filters, projects: projects})
  end

  test 'it display a sidebar to select which notification to show' do
    node(@notifications_decorator.display_filter)
    assert_select 'div.left-sidebar', 1
  end

  test 'it display a list of notification when notifications exists' do
    node(@notifications_decorator.display_collection(true, I18n.t(:text_no_notifications)))
    assert_select 'div.box.notification-list', 1
  end

  test 'it display a message when there are no notification to display' do
    @project.notifications.clear
    node(@notifications_decorator.display_collection(true, I18n.t(:text_no_notifications)))
    assert_select '#notifications-content', 1
    assert_select '.no-data', 1
    assert_select 'h3', I18n.t(:text_no_notifications)
  end

  private
  def create_issue_notification
    @issue = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project.id)
    @issue_journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', 'created')
    Notification.create!(user_id: @user.id, notifiable_id: @issue.id,
                         notifiable_type: 'Issue', project_id: @project.id, from_id: @user1.id,
                         trigger_type: 'Journal',
                         trigger_id: @issue_journal.id,
                         recipient_type: 'participants').decorate
  end
end
