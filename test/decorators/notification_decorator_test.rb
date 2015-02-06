require 'test_helper'

class NotificationDecoratorTest < Rorganize::Decorator::TestCase

  def setup
    @project = projects(:projects_001)
    @user = users(:users_001)
    @user1 = users(:users_002)
    create_issue_notification
  end

  test "it display a link to the updated issue notification" do
    node(@issue_update_notification_decorator.link_to_notifiable)
    assert_select 'a', 1
    assert_select 'a', text: "##{@issue.id} : #{@issue.caption}"
    assert_select 'a[href=?]', notification_path(@issue_update_notification_decorator.id)
  end

  test "it display a link to the updated document notification" do
    create_document_notification
    node(@document_update_notification_decorator.link_to_notifiable)
    assert_select 'a', 1
    assert_select 'a', text: @document.caption
    assert_select 'a[href=?]', notification_path(@document_update_notification_decorator.id)
  end

  test "it display an overview about the notification when it is an update" do
    helpers.stubs(:distance_of_time_in_words).returns('2 days ago')
    assert_equal "#{I18n.t(:label_updated)} 2 days ago #{I18n.t(:label_ago)} #{I18n.t(:label_by)} ", @issue_update_notification_decorator.notification_info
  end

  test "it display an overview about the notification when it is a comment" do
    helpers.stubs(:distance_of_time_in_words).returns('2 days ago')
    assert_equal "#{I18n.t(:label_commented)} 2 days ago #{I18n.t(:label_ago)} #{I18n.t(:label_by)} ", @issue_comment_notification_decorator.notification_info
  end

  test "it display a specific icon when user is a watcher" do
    node(@issue_comment_notification_decorator.recipient_type)
    assert_select 'span', 2
    assert_select '.octicon-eye', 1
    assert_select 'span[label=?]', I18n.t(:text_notification_recipient_type_watcher)
  end

  test "it display a specific icon when user is a participans" do
    node(@issue_update_notification_decorator.recipient_type)
    assert_select 'span', 2
    assert_select '.octicon-person', 1
    assert_select 'span[label=?]', I18n.t(:text_notification_recipient_type_participant)
  end

  private
  def create_document_notification
    @document = Document.create(name: 'concerning hobbits')
    @document_journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@document.id, 'Document', 'created')
    @document_update_notification_decorator = Notification.create!(user_id: @user.id, notifiable_id: @document.id,
                                                                notifiable_type: 'Document', project_id: 1, from_id: @user1.id,
                                                                trigger_type: 'Journal',
                                                                trigger_id: @document_journal.id,
                                                                recipient_type: 'participants').decorate
  end

  def create_issue_notification
    @issue = Issue.create(tracker_id: 1, subject: 'Bug1', status_id: 1, project_id: @project.id)
    @issue_journal = Journal.find_by_journalizable_id_and_journalizable_type_and_action_type(@issue.id, 'Issue', 'created')
    @issue_update_notification_decorator = Notification.create!(user_id: @user.id, notifiable_id: @issue.id,
                                                                notifiable_type: 'Issue', project_id: 1, from_id: @user1.id,
                                                                trigger_type: 'Journal',
                                                                trigger_id: @issue_journal.id,
                                                                recipient_type: 'participants').decorate
    @issue_comment = Comment.create(content: 'this a comment', user_id: User.current.id, project_id: @project.id,
                                    commentable_id: @issue.id, commentable_type: 'Issue',
                                    created_at: Time.new(2015, 02, 04, 12, 30, 45),
                                    updated_at: Time.new(2015, 02, 04, 12, 30, 45))
    @issue_comment_notification_decorator = Notification.create!(user_id: @user.id, notifiable_id: @issue.id,
                                                                 notifiable_type: 'Issue', project_id: 1, from_id: @user1.id,
                                                                 trigger_type: 'Comment',
                                                                 trigger_id: @issue_comment.id,
                                                                 recipient_type: 'watchers').decorate
  end
end
