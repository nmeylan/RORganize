require 'test_helper'

require 'test_utilities/record_not_found_tests'
class CommentsControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', done: 0, project_id: @project.id, due_date: '2012-12-31')
    @comment = Comment.create(content: 'this a comment', project_id: 1, commentable_id: @issue.id, commentable_type: 'Issue', user_id: User.current.id)
    @comment_not_owned = Comment.create(content: 'this a comment', project_id: 1, commentable_id: @issue.id, commentable_type: 'Issue', user_id: 2)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should create comment" do
    allow_user_to('comment', 'issues')
    assert_difference('Comment.count') do
      _post :create, comment: {commentable_id: @issue.id, commentable_type: "Issue", content: "Leave a comment"}, format: :js
    end
    assert @response.header["flash-message"]
    assert_nil @response.header["flash-error-message"]
  end

  test "should not create comment when content is missing" do
    allow_user_to('comment', 'issues')
    assert_no_difference('Comment.count') do
      _post :create, comment: {commentable_id: @issue, commentable_type: "Issue", content: ""}, format: :js
    end
    assert_response :success
    assert_not_empty @response.header["flash-error-message"]
  end

  test "should edit comment" do
    _get :edit, id: @comment.id, format: :js
    assert_response :success
    assert_not_nil assigns(:comment)
  end

  test "should show comment" do
    _get :show, id: @comment.id, format: :js
    assert_response :success
    assert_not_nil assigns(:comments_decorator)
  end

  test "should update comment when user is author" do
    _patch :update, id: @comment.id, comment: {content: "Edit owned comment"}, format: :js
    assert_response :success
    assert @response.header["flash-message"]
    assert_nil @response.header["flash-error-message"]
  end

  test "should not update comment when content is missing" do
    _patch :update, id: @comment.id, comment: {content: ""}, format: :js
    assert_response :success
    assert_not_empty @response.header["flash-error-message"]
  end

  test "should destroy comment when user is author" do
    assert_difference('Comment.count', -1) do
      _delete :destroy, id: @comment, format: :js
    end
    assert_response :success
  end

  test "should update comment when user is not the author" do
    allow_user_to('edit_comment_not_owner')
    _patch :update, id: @comment.id, comment: {content: "Edit owned comment"}, format: :js
    assert_response :success
    assert @response.header["flash-message"]
    assert_nil @response.header["flash-error-message"]
  end

  test "should destroy comment when user is not the author" do
    allow_user_to('destroy_comment_not_owner')
    assert_difference('Comment.count', -1) do
      _delete :destroy, id: @comment, format: :js
    end
    assert_response :success
  end

  # Forbidden action
  test "should get 403 on update when user is not author" do
    should_get_403_on(:_patch, :update, id: @comment_not_owned.id, comment: {content: "Edit owned comment"}, format: :js)
  end

  test "should get 403 on destroy when user is not author" do
    should_get_403_on(:_delete, :destroy, id: @comment_not_owned.id, comment: {content: "Edit owned comment"}, format: :js)
  end

  test "should get 403 on create when user has not the permission" do
    should_get_403_on(:_post, :create, comment: {commentable_id: @issue, commentable_type: "Issue", content: "Leave a comment"}, format: :js)
  end

end
