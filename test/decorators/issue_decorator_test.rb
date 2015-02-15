require 'test_helper'

class IssueDecoratorTest < Rorganize::Decorator::TestCase

  def setup
    @project = projects(:projects_001)
    @issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', done: 0, project_id: @project.id)
    @issue_decorator = @issue.decorate(context: {project: @project})
  end

  test "it displays a link to edit when user is allowed to" do
    allow_user_to('edit')
    node(@issue_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_issue_path(@project.slug, @issue.id)
  end

  test "it should not display a link to edit when user is not allowed to" do
    assert_nil @issue_decorator.edit_link
  end

  test "it displays a link to view when user is allowed to" do
    allow_user_to('show')
    node(@issue_decorator.show_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', issue_path(@project.slug, @issue.id)
  end

  test "it should not display a link to view when user is not allowed to" do
    assert_nil @issue_decorator.show_link
  end

  test "it displays a link to delete when user is allowed to" do
    allow_user_to('destroy')
    node(@issue_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', issue_path(@project.slug, @issue.id)
  end

  test "it should not display a link to delete when user is not allowed to" do
    assert_nil @issue_decorator.delete_link
  end

  test "it displays a link to delete issue attachment when user is allowed to" do
    allow_user_to('delete_attachment')
    attachment = Attachment.new(attachable_type: 'Issue', attachable_id: 666, id: 666)
    node(@issue_decorator.delete_attachment_link(attachment))
    assert_select 'a', 1
    assert_select 'a[href=?]', delete_attachment_issues_path(@project.slug, attachment.id)
  end

  test "it should not display a link to delete issue attachment when user is not allowed to" do
    attachment = Attachment.new(attachable_type: 'Issue', attachable_id: 666, id: 666)
    assert_nil @issue_decorator.delete_attachment_link(attachment)
  end

  test "it displays a link to create a new issue when user is allowed to" do
    allow_user_to('new')
    node(@issue_decorator.new_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', new_issue_path(@project.slug)
  end

  test "it should not display a link to create a new issue when user is not allowed to" do
    assert_nil @issue_decorator.new_link
  end

  test "it displays a link to the issue for activity context" do
    node(concat @issue_decorator.display_object_type(@project))
    assert_select 'a', 1
    assert_select 'a[href=?]', issue_path(@project.slug, @issue.id)
    assert_select 'b', 1
    assert_select 'b', "#{I18n.t(:label_issue)} ##{@issue.id}".downcase
  end

  test "it displays a link to watch a issue when user is allowed" do
    allow_user_to('watch')
    node(@issue_decorator.watch(@project))
    assert_select 'a', 1
    assert_select 'a[href=?]', toggle_watchers_path(@project.slug, 'Issue', @issue.id)
    assert_select 'a', text: I18n.t(:link_watch)
  end

  test "it displays a link to unwatch a issue when user is allowed" do
    allow_user_to('watch')
    node(@issue_decorator.unwatch(@project))
    assert_select 'a', 1
    assert_select 'a[href=?]', toggle_watchers_path(@project.slug, 'Issue', @issue.id)
    assert_select 'a', text: I18n.t(:link_unwatch)
  end

  test "it displays a link to log time when user is allowed to" do
    allow_user_to('new', 'time_entries')
    node(@issue_decorator.log_time_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', fill_overlay_time_entries_path(@issue.id)
  end

  test "it should not display a link to log time when user is not allowed to" do
    assert_nil @issue_decorator.log_time_link
  end

  test "it displays the history of the issues when it contains journals or comments" do
    # Add one journal
    @issue.category = Category.create(name: 'Specs')
    @issue.save
    history = History.new(Journal.journalizable_activities(@issue_decorator.id, 'Issue'), @issue_decorator.comments)
    node(@issue_decorator.display_history(history))
    assert_select '#history', 1
    assert_select 'h2', text: I18n.t(:label_history)
    assert_select '#history-blocks', 1
  end

  test "it should not display the history of the issues when it contains nothing" do
    history = History.new(Journal.journalizable_activities(@issue_decorator.id, 'Issue'), @issue_decorator.comments)
    node(@issue_decorator.display_history(history))
    assert_select '#history', 1
    assert_select 'h2', 0
    assert_select '#history-blocks', 0
  end

  test "it displays a readable identifier for activity context" do
    node(@issue_decorator.activity_issue_caption)
    assert_select 'b', 1
    assert_select 'b', text: "task ##{@issue.id}"
  end

  test "it displays a formatted due date" do
    assert_equal '-', @issue_decorator.display_due_date
    @issue.due_date = Date.new(2012, 12, 01)
    assert_equal '1 Dec. 2012', @issue_decorator.display_due_date
  end

  test "it displays a formatted start date" do
    assert_equal '-', @issue_decorator.display_start_date
    @issue.start_date = Date.new(2012, 12, 01)
    assert_equal '1 Dec. 2012', @issue_decorator.display_start_date
  end

  test "it displays a formatted updated at" do
    @issue.updated_at = Time.new(2012, 12, 01, 12, 25, 25)
    assert_equal '1 Dec. 2012 12:25 PM.', @issue_decorator.display_updated_at
  end

  test "it displays a link to the assigned user when it exits" do
    assert_equal '-', @issue_decorator.display_assigned_to
    @issue.assigned_to = User.current
    node(@issue_decorator.display_assigned_to)
    assert_select 'a', 1
    assert_select 'img', 1 #avatar
    assert_select 'a[href=?]', "/#{@issue.assigned_to.slug_before_type_cast}"
  end

  test "it displays assigned to thumb avatar" do
    assert_nil @issue_decorator.display_assigned_to_avatar
    @issue.assigned_to = User.current
    node(@issue_decorator.display_assigned_to_avatar)
    assert_select 'a' do
      assert_select 'img', 1
    end
  end

  test "it display estimated time when it exists" do
    assert_equal '-', @issue_decorator.estimated_time
    @issue.estimated_time = 12
    assert_equal 12.0, @issue_decorator.estimated_time
  end

  test "it displays status in a color container" do
    node(@issue_decorator.display_status)
    assert_select 'span', 1
    assert_select 'span[style=?]', "background-color:#6cc644; color:white"
    assert_select 'span', text: @issue.status.caption
  end

  test "it displays done progression in a progress bar" do
    node(@issue_decorator.display_done_progression)
    assert_select 'span' do
      assert_select 'span.progress', 1
    end
  end

  test "it display task list progress if issue has one" do
    assert_nil @issue_decorator.checklist_progression
    @issue.description = "- [ ] task1"
    node(@issue_decorator.checklist_progression)
    assert_select 'span' do
      assert_select 'span', text: '0 of 1'
    end

    @issue.description = "- [x] task1"
    node(@issue_decorator.checklist_progression)
    assert_select 'span' do
      assert_select 'span', text: '1 of 1'
    end
  end

  test 'it displays a link to new comment' do
    allow_user_to('comment')
    node(@issue_decorator.new_comment_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', '#add-comment'
  end

  test "it should not display a link to add a new comment when user is not allowed to" do
    assert_nil @issue_decorator.new_comment_link
  end

  test "it should display a comment form block" do
    allow_user_to('comment')
    node(@issue_decorator.add_comment_block)
    assert_select 'form'
  end

  test "it should display a smooth gray comment icon when issue has no comments" do
    node(@issue_decorator.comment_presence_indicator)
    assert_select '.octicon-comment', 1
    assert_select '.smooth-gray', 1
    assert_select 'span', text: ''
  end

  test "it should display a comment icon when issue has comments" do
    Comment.create!(content: 'this a comment', user_id: User.current.id, project_id: @project.id,
                    commentable_id: @issue.id, commentable_type: 'Issue')
    @issue.reload
    node(@issue_decorator.comment_presence_indicator)
    assert_select '.octicon-comment', 1
    assert_select '.smooth-gray', 0
    assert_select 'span', text: '1'
  end
end
