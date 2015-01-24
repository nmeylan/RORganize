require 'test_helper'
require 'test_utilities/record_not_found_tests'

class IssuesControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @issue = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', project_id: @project.id, author_id: User.current.id)
    @issue_not_owned = Issue.create(tracker_id: 1, subject: 'Issue creation', description: '', status_id: '1', project_id: @project.id, author_id: 2)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of issues" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:issues_decorator)
  end

  test "should access to new issue" do
    get_with_permission :new
    assert_response :success
    assert_not_nil assigns(:issue_decorator)
  end

  test "should create issue" do
    assert_difference('Issue.count') do
      post_with_permission :create, issue: {subject: 'New issue', status_id: 1, tracker_id: 1}
    end
    assert_not_empty flash[:notice]
    assert_not_nil assigns(:issue_decorator)
    assert_redirected_to issue_path(@project.slug, assigns(:issue_decorator).id)
  end

  test "should refresh the page when create issue failed" do
    assert_no_difference('Issue.count') do
      post_with_permission :create, issue: {subject: ''}
    end
    assert_not_nil assigns(:issue_decorator)
    assert_response :unprocessable_entity
  end

  test "should edit issue" do
    get_with_permission :edit, id: @issue
    assert_response :success
    assert_not_nil assigns(:issue_decorator)
  end

  test "should update issue" do
    patch_with_permission :update, id: @issue, issue: {subject: 'Change issue name'}
    assert_not_empty flash[:notice]
    assert_redirected_to issue_path(@project.slug, assigns(:issue_decorator).id)
  end

  test "should view issue" do
    get_with_permission :show, id: @issue
    assert_response :success
    assert_not_nil assigns(:issue_decorator)
  end

  test "should refresh the page when update category failed" do
    patch_with_permission :update, id: @issue, issue: {subject: '', status_id: 1, tracker_id: 1}
    assert_not_nil assigns(:issue_decorator)
    assert_response :unprocessable_entity
  end

  test "should destroy issue" do
    assert_difference('Issue.count', -1) do
      delete_with_permission :destroy, id: @issue, format: :js
    end
    assert_response :success
  end

  test "should get toolbox for issues" do
    get_with_permission :toolbox, ids: [@issue.id], format: :js

    assert_response :success
    assert_template "js_templates/toolbox"
  end

  test "should edit issues with toolbox" do
    assert_nil @issue.category_id
    get_with_permission :index
    post_with_permission :toolbox, ids: [@issue.id], value: {category_id: "1", version_id: ""},format: :js
    @issue.reload
    assert_equal 1, @issue.category_id
    assert_response :success
    assert_template "index"
  end

  test "should delete issues with toolbox" do
    get_with_permission :index
    post_with_permission :toolbox, delete_ids: [@issue.id],format: :js
    assert_raise(ActiveRecord::RecordNotFound) { @issue.reload }
    assert_response :success
    assert_template "index"
  end

  test "should view overview with toolbox" do
    allow_user_to('index')
    get_with_permission :overview
    assert_response :success
    assert_template "overview"
  end

  test "should add issue predecessor" do
    assert_nil @issue.predecessor_id
    post_with_permission :add_predecessor, id: @issue, issue: {predecessor_id: @issue_not_owned.id}, format: :js
    @issue.reload
    assert_equal @issue_not_owned.id, @issue.predecessor_id
    assert_response :success
    assert_template "add_predecessor"
  end

  test "should delete issue predecessor" do
    post_with_permission :add_predecessor, id: @issue, issue: {predecessor_id: @issue_not_owned.id}, format: :js
    @issue.reload
    assert_equal @issue_not_owned.id, @issue.predecessor_id
    delete_with_permission :del_predecessor, id: @issue, format: :js
    @issue.reload
    assert_nil @issue.predecessor_id
    assert_response :success
    assert_template "add_predecessor"
  end

  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of issues" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new issue" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create issue" do
    should_get_403_on(:_post, :create, id: @issue.id)
  end

  test "should get a 403 error when user is not allowed to edit issue" do
    should_get_403_on(:_get, :edit, id: @issue.id)
  end

  test "should get a 403 error when user is not allowed to edit not owned issue" do
    should_get_403_on(:get_with_permission, :edit, id: @issue_not_owned.id)
  end

  test "should get a 403 error when user is not allowed to view issue" do
    should_get_403_on(:_get, :show, id: @issue.id)
  end

  test "should get a 403 error when user is not allowed to update issue" do
    should_get_403_on(:_patch, :update, id: @issue.id)
  end

  test "should get a 403 error when user is not allowed to update not owned issue" do
    should_get_403_on(:patch_with_permission, :update, id: @issue_not_owned.id)
  end

  test "should get a 403 error when user is not allowed to destroy issue" do
    should_get_403_on(:_delete, :destroy, id: @issue.id, format: :js)
  end

  test "should get a 403 error when user is not allowed to destroy not owned issue" do
    should_get_403_on(:delete_with_permission, :destroy, id: @issue_not_owned.id)
  end

  test "should get a 403 error when user is not allowed to get toolbox issue" do
    should_get_403_on(:_get, :toolbox, ids: [@issue.id], format: :js)
  end

  test "should get a 403 error when user is not allowed to post toolbox issue" do
    should_get_403_on(:_post, :toolbox, ids: [@issue.id], format: :js)
  end

  test "should get a 403 error when user is not allowed to view issues overview" do
    should_get_403_on(:_get, :overview)
  end

  test "should get a 403 error when user is not allowed to add predecessor issue" do
    should_get_403_on(:_post, :add_predecessor, id: @issue, issue: {predecessor_id: @issue_not_owned.id}, format: :js)
  end

  test "should get a 403 error when user is not allowed to del predecessor overview" do
    should_get_403_on(:_delete, :del_predecessor, id: @issue, format: :js)
  end
end
