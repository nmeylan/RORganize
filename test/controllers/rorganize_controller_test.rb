require 'test_helper'

class RorganizeControllerTest < ActionController::TestCase
  include MarkdownRenderHelper
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @owned_issue = Issue.create(tracker_id: 1, subject: 'Issue task list', status_id: '1', project_id: @project.id,
                                author_id: User.current.id, description: "- [ ] task1 \n - [ ] task2")
    @not_owned_issue = Issue.create(tracker_id: 1, subject: 'Issue task list', status_id: '1', project_id: @project.id,
                                    author_id: 666, description: '- [ ] task1')

    @owned_comment = Comment.create(project_id:  @project.id, commentable_type: 'Issue', commentable_id: @owned_issue.id,
                                    user_id: User.current.id, content: '- [ ] task1')
    @not_owned_comment = Comment.create(project_id:  @project.id, commentable_type: 'Issue', commentable_id: @owned_issue.id,
                                    user_id: 666, content: '- [ ] task1')

    @document = Document.create(name: 'Document task list', description: '- [ ] task1', project_id: @project.id)
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to home page when user is logged" do
    get :index
    assert_response :success
    assert_template 'rorganize/_logged_user_home_page'
  end

  test "should access to home page when user is not logged" do
    RorganizeController.any_instance.stubs(:current_user).returns(nil)
    get :index
    assert_response :success
    assert_template 'rorganize/_anonymous_home_page'
  end

  test "should access to someone profile" do
    get :view_profile, user: User.current.slug
    assert_response :success
    assert_not_nil assigns(:user_decorator)
  end

  test "should get a 404 when access to undefined profile" do
    should_get_404_on(:get, :view_profile, user: 'undefined')
  end

  test "should access to activity" do
    get :activity, user: User.current.slug
    assert_response :success
    assert_not_nil assigns(:user_decorator)
  end

  test "has a method to preview markdown" do
    content = "## title 2"
    get :preview_markdown, content: content, format: :json
    assert_equal markdown_to_html(content), @response.body
  end

  test "should check issue task list item when author" do
    post :task_list_action_markdown, is_check: 'true', element_type: "Issue", element_id: @owned_issue.id, check_index: 0, format: :js

    assert_response :success
    assert_not_nil @response['flash-message']
    @owned_issue.reload
    assert_equal "- [x] task1 \n - [ ] task2", @owned_issue.description
  end

  test "should check issue second task list item when author" do
    post :task_list_action_markdown, is_check: 'true', element_type: "Issue", element_id: @owned_issue.id, check_index: 1, format: :js

    assert_response :success
    assert_not_nil @response['flash-message']
    @owned_issue.reload
    assert_equal "- [ ] task1 \n - [x] task2", @owned_issue.description
  end

  test "should check issue task list item when not author" do
    allow_user_to('edit', 'issues')
    post :task_list_action_markdown, is_check: 'true', element_type: "Issue", element_id: @not_owned_issue.id, check_index: 0, format: :js

    assert_response :success
    assert_not_nil @response['flash-message']
    @not_owned_issue.reload
    assert_equal '- [x] task1', @not_owned_issue.description
  end

  test "should check document task list item" do
    allow_user_to('edit', 'documents')
    post :task_list_action_markdown, is_check: 'true', element_type: "Document", element_id: @document.id, check_index: 0, format: :js

    assert_response :success
    assert_not_nil @response['flash-message']
    @document.reload
    assert_equal '- [x] task1', @document.description
  end

  test "should check comment task list item when author" do
    post :task_list_action_markdown, is_check: 'true', element_type: "Comment", element_id: @owned_comment.id, check_index: 0, format: :js

    assert_response :success
    assert_not_nil @response['flash-message']
    @owned_comment.reload
    assert_equal '- [x] task1', @owned_comment.content
  end

  test "should check comment task list item when not author" do
    allow_user_to('edit', 'comments')
    post :task_list_action_markdown, is_check: 'true', element_type: "Comment", element_id: @not_owned_comment.id, check_index: 0, format: :js

    assert_response :success
    assert_not_nil @response['flash-message']
    @not_owned_comment.reload
    assert_equal '- [x] task1', @not_owned_comment.content
  end

  test "should get a 404 when element is undefined" do
    should_get_404_on(:_post, :task_list_action_markdown, is_check: 'true', element_type: "Issue", element_id: 666, check_index: 0, format: :js)
  end

  # Forbidden action
  test "should not check issue task list item when not author and user has not the permission" do
    should_get_403_on(:_post, :task_list_action_markdown, is_check: 'true', element_type: "Issue",
                      element_id: @not_owned_issue.id, check_index: 0, format: :js)
  end

  test "should not check comment task list item when not author and user has not the permission" do
    should_get_403_on(:_post, :task_list_action_markdown, is_check: 'true', element_type: "Comment",
                      element_id: @not_owned_comment.id, check_index: 0, format: :js)
  end

  test "should not check document task list item when has not the permission" do
    User.stubs(:current).returns(users(:users_002))
    User.any_instance.stubs(:checked_permissions).returns({})
    should_get_403_on(:_post, :task_list_action_markdown, is_check: 'true', element_type: "Document",
                      element_id: @document.id, check_index: 0, format: :js)
  end
end
