require 'test_helper'

class CommentDecoratorTest < Rorganize::Decorator::TestCase

  def setup
    @project = projects(:projects_001)
    @issue = issues(:issues_001)
    @comment = Comment.create(content: 'this a comment', user_id: User.current.id, project_id: @project.id,
                              commentable_id: @issue.id, commentable_type: 'Issue',
                              created_at: Time.new(2015, 02, 04, 12, 30, 45),
                              updated_at: Time.new(2015, 02, 04, 12, 30, 45))
    @comment_decorator = @comment.decorate
  end

  test "it has a method to display creation date" do
    assert_equal 'Wed. 4 Feb. 12:30 PM.', @comment_decorator.creation_date
  end

  test "it has a method to display edition date" do
    assert_equal 'Wed. 4 Feb. 12:30 PM.', @comment_decorator.update_date
  end

  test "it has a method to display short creation date" do
    assert_equal '12:30PM', @comment_decorator.display_creation_at
  end

  test "it has a method to display author name without avatar" do
    node(@comment_decorator.display_author(false))
    assert_select 'a', 1
    assert_select 'a[href=?]', "/#{User.current.slug}"
    assert_select 'img', 0
  end

  test "it has a method to display author name with avatar" do
    node(@comment_decorator.display_author(true))
    assert_select 'a', 1
    assert_select 'a[href=?]', "/#{User.current.slug}"
    assert_select 'img', 1
  end

  test "it should not display author name when author does not exists anymore" do
    @comment_decorator.author = nil
    assert_equal I18n.t(:label_unknown), @comment_decorator.display_author(true)
  end

  test "it should display a link to project" do
    node(@comment_decorator.project_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', overview_projects_path(@project.slug)
  end

  test "it displays a link to edit when user is allowed to" do
    @comment.author = nil
    @comment.save
    allow_user_to('edit_comment_not_owner')
    node(@comment_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_comment_path(@comment)
  end

  test "it displays a link to edit when user is author of the comment" do
    node(@comment_decorator.edit_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', edit_comment_path(@comment)
  end

  test "it should not display a link to edit when user is not allowed to" do
    @comment.author = nil
    @comment.save
    assert_nil @comment_decorator.edit_link
  end

  test "it displays a link to delete when user is allowed to" do
    @comment.author = nil
    @comment.save
    allow_user_to('destroy_comment_not_owner')
    node(@comment_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', comment_path(@comment)
  end

  test "it displays a link to delete when user is author of the comment" do
    node(@comment_decorator.delete_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', comment_path(@comment)
  end

  test "it should not display a link to delete when user is not allowed to" do
    @comment.author = nil
    @comment.save
    assert_nil @comment_decorator.delete_link
  end

  test "it displays a link to view the comment thread" do
    node(@comment_decorator.remote_show_link)
    assert_select 'a', 1
    assert_select 'a[href=?]', comment_path(@comment)
    assert_select 'a[data-remote="true"]', 1
  end

  test "it has a method to display a link to the commentable object" do
    node(concat @comment_decorator.display_object_type)
    assert_select 'b', 1
    assert_select 'b', "#{I18n.t(:label_issue)} ##{@issue.sequence_id}".downcase
    assert_select 'a', 1
    assert_select 'a[href=?]', issue_path(@project.slug, @issue)
  end

  test "it has a method to display that something has been commented" do
    node(concat @comment_decorator.render_header)
    assert_select 'a', 2
    assert_select 'a[href=?]', issue_path(@project.slug, @issue)
    assert_select 'a[href=?]', comment_path(@comment)
  end

  test "it has a method to display that someone leave a comment" do
    node(@comment_decorator.render_details)
    assert_select 'a', 2
    assert_select 'a[href=?]', "/#{User.current.slug}"
    assert_select 'a[href=?]', comment_path(@comment)
  end
end
