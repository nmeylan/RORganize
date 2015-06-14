require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @user = users(:users_001)
    @user1 = users(:users_002)
    @issue = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project.id)
    @issue1 = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project.id)
    @journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', 'created')
    @journal1 = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue1.id, 'Issue', 'created')
    @notification = Notification.create(user_id: @user.id, notifiable_id: @issue.id,
                                        notifiable_type: 'Issue', project_id: @issue.project_id, from_id: @user1.id,
                                        trigger_type: 'Journal',
                                        trigger_id: @journal.id,
                                        recipient_type: 'participants')
    @notification_bis = Notification.create(user_id: @user.id, notifiable_id: @issue1.id,
                                        notifiable_type: 'Issue', project_id: @issue1.project_id, from_id: @user1.id,
                                        trigger_type: 'Journal',
                                        trigger_id: @journal1.id,
                                        recipient_type: 'participants')
    @notification1 = Notification.create(user_id: @user1.id, notifiable_id: @issue.id,
                                         notifiable_type: 'Issue', project_id: @issue.project_id, from_id: @user.id,
                                         trigger_type: 'Journal',
                                         trigger_id: @journal.id,
                                         recipient_type: 'participants')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to notifications index" do
    _get :index
    assert_response :success
    assert_not_nil assigns(:notifications_decorator)
  end

  test "should delete notification" do
    assert_difference('Notification.count', -1) do
      _delete :destroy, id: @notification
    end
    assert_response :redirect
    assert_redirected_to project_issue_path(@project, @issue, {anchor: "journal-#{@journal.id}"})
  end

  test "should not delete other user notification" do
    assert_no_difference('Notification.count', -1) do
      _delete :destroy, id: @notification1
    end
    assert_response :missing
    assert_select "title", "The page you were looking for doesn't exist (404)"
  end

  test "should delete all notifications" do
    assert_no_difference('Notification.count', -2) do
      delete :destroy_all_for_project, project_slug: @project.slug
    end
    assert_response :redirect
  end
end
