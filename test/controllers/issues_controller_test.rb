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

  test "should create issue when user allowed to set status" do
    allow_user_to('change_status', 'issues')
    assert_difference('Issue.count') do
      post_with_permission :create, issue: {subject: 'New issue', status_id: 1, tracker_id: 1}
    end
    assert_not_empty flash[:notice]
    assert_not_nil assigns(:issue_decorator)
    assert_redirected_to issue_path(@project.slug, assigns(:issue_decorator))
  end

  test "should set status to first one when user is not allowed to set status on issue creation" do
    assert_difference('Issue.count') do
      post_with_permission :create, issue: {subject: 'New issue', tracker_id: 1}
    end
    assert_not_empty flash[:notice]
    assert_not_nil assigns(:issue_decorator)
    assert_redirected_to issue_path(@project.slug, assigns(:issue_decorator))
  end

  test "should let assigned attribute to nil when user is not allowed to change it on issue creation" do
    post_with_permission :create, issue: {subject: 'New issue', tracker_id: 1, status_id: 1, assigned_to: 2}

    issue = assigns(:issue_decorator)
    assert_not_nil issue
    assert_nil issue.assigned_to
    assert_redirected_to issue_path(@project.slug, issue)
  end

  test "should set assigned attribute when user is allowed to change it on issue creation" do
    allow_user_to('change_assigned', 'issues')
    post_with_permission :create, issue: {subject: 'New issue', tracker_id: 1, status_id: 1, assigned_to: 2}

    issue = assigns(:issue_decorator)
    assert_not_nil issue
    assert_nil issue.assigned_to
    assert_redirected_to issue_path(@project.slug, issue)
  end

  test "should let done attribute to nil when user is not allowed to change it on issue creation" do
    allow_user_to('change_status', 'issues')
    post_with_permission :create, issue: {subject: 'New issue', tracker_id: 1, status_id: 1, done: 20}

    issue = assigns(:issue_decorator)
    assert_not_nil issue
    assert_equal 0, issue.done
    assert_redirected_to issue_path(@project.slug, issue)
  end

  test "should set done attribute when user is allowed to change it on issue creation" do
    allow_user_to('change_status', 'issues')
    allow_user_to('change_progress', 'issues')
    post_with_permission :create, issue: {subject: 'New issue', tracker_id: 1, status_id: 1, done: 20}

    issue = assigns(:issue_decorator)
    assert_not_nil issue
    assert_equal 20, issue.done
    assert_redirected_to issue_path(@project.slug, issue)
  end

  test "should let category attribute to nil when user is not allowed to change it on issue creation" do
    post_with_permission :create, issue: {subject: 'New issue', tracker_id: 1, status_id: 1, category_id: 20}

    issue = assigns(:issue_decorator)
    assert_not_nil issue
    assert_equal nil, issue.category_id
    assert_redirected_to issue_path(@project.slug, issue)
  end

  test "should set category attribute when user is allowed to change it on issue creation" do
    allow_user_to('change_category', 'issues')
    post_with_permission :create, issue: {subject: 'New issue', tracker_id: 1, status_id: 1, category_id: 20}

    issue = assigns(:issue_decorator)
    assert_not_nil issue
    assert_equal 20, issue.category_id
    assert_redirected_to issue_path(@project.slug, issue)
  end

  test "should let version attribute to nil when user is not allowed to change it on issue creation" do
    post_with_permission :create, issue: {subject: 'New issue', tracker_id: 1, status_id: 1, version_id: 20,
                                          start_date: Date.new(2012, 01, 20), due_date: Date.new(2012, 12, 20)}

    issue = assigns(:issue_decorator)
    assert_not_nil issue
    assert_equal nil, issue.version_id
    assert_equal nil, issue.start_date
    assert_equal nil, issue.due_date
    assert_redirected_to issue_path(@project.slug, issue)
  end

  test "should set version attribute when user is allowed to change it on issue creation" do
    allow_user_to('change_version', 'issues')
    post_with_permission :create, issue: {subject: 'New issue', tracker_id: 1, status_id: 1, version_id: 20,
                                          start_date: Date.new(2012, 01, 20), due_date: Date.new(2012, 12, 20)}

    issue = assigns(:issue_decorator)
    assert_not_nil issue
    assert_equal 20, issue.version_id
    assert_equal Date.new(2012, 01, 20), issue.start_date
    assert_equal Date.new(2012, 12, 20), issue.due_date
    assert_redirected_to issue_path(@project.slug, issue)
  end

  test "should refresh the page when create issue failed" do
    assert_no_difference('Issue.count') do
      post_with_permission :create, issue: {subject: ''}
    end
    assert_not_nil assigns(:issue_decorator)
    assert_response :unprocessable_entity
  end

  test "should edit issue" do
    get_with_permission :edit, id: @issue.sequence_id
    assert_response :success
    assert_not_nil assigns(:issue_decorator)
  end

  test "should update issue" do
    patch_with_permission :update, id: @issue.sequence_id, issue: {subject: 'Change issue name'}
    assert_not_empty flash[:notice]
    assert_redirected_to issue_path(@project.slug, assigns(:issue_decorator))
  end

  test "should view issue" do
    get_with_permission :show, id: @issue.sequence_id
    assert_response :success
    assert_not_nil assigns(:issue_decorator)
  end

  test "should refresh the page when update issue failed" do
    patch_with_permission :update, id: @issue.sequence_id, issue: {subject: '', status_id: 1, tracker_id: 1}
    assert_not_nil assigns(:issue_decorator)
    assert_response :unprocessable_entity
  end

  test "should destroy issue" do
    assert_difference('Issue.count', -1) do
      delete_with_permission :destroy, id: @issue.sequence_id, format: :js
    end
    assert_response :success
  end

  test "should get toolbox for issues when user is allowed to" do
    get_with_permission :toolbox, ids: [@issue], format: :js

    assert_response :success
    assert_template "js_templates/toolbox"
  end

  test "should edit issues with toolbox" do
    allow_user_to('change_category', 'issues')
    assert_nil @issue.category_id
    get_with_permission :index
    post_with_permission :toolbox, ids: [@issue.sequence_id], value: {category_id: "1", version_id: ""}, format: :js
    @issue.reload
    assert_equal 1, @issue.category_id
    assert_response :success
    assert_template "index"
  end

  test "should delete issues with toolbox" do
    get_with_permission :index
    post_with_permission :toolbox, delete_ids: [@issue.sequence_id], format: :js
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
    post_with_permission :add_predecessor, id: @issue.sequence_id, issue: {predecessor_id: @issue_not_owned.sequence_id}, format: :js
    @issue.reload
    assert_equal @issue_not_owned.id, @issue.predecessor_id
    assert_response :success
    assert_template "add_predecessor"
  end

  test "should delete issue predecessor" do
    post_with_permission :add_predecessor, id: @issue.sequence_id, issue: {predecessor_id: @issue_not_owned.sequence_id}, format: :js
    @issue.reload
    assert_equal @issue_not_owned.id, @issue.predecessor_id
    delete_with_permission :del_predecessor, id: @issue.sequence_id, format: :js
    @issue.reload
    assert_nil @issue.predecessor_id
    assert_response :success
    assert_template "add_predecessor"
  end

  test "should apply custom query" do
    query = create_custom_query
    get_with_permission :apply_custom_query, query_id: query.slug

    assert_not_empty session[:issues][@project.slug][:sql_filter]
    assert_not_empty session[:issues][@project.slug][:json_filter]

    expectation = JSON.parse("{\"assigned_to\"=>{\"operator\"=>\"equal\", \"value\"=>[\"7\"]}}".gsub('=>', ':'))
    assert_equal expectation, session[:issues][@project.slug][:json_filter]
  end

  test "should apply new filter" do
    get_with_permission :index, filters_list: ["status"], filter: {assigned_to: {"operator" => "equal", "value" => ["7"]}}, type: 'filter'

    assert_not_empty session[:issues][@project.slug][:sql_filter]
    assert_not_empty session[:issues][@project.slug][:json_filter]

    expectation = JSON.parse("{\"assigned_to\"=>{\"operator\"=>\"equal\", \"value\"=>[\"7\"]}}".gsub('=>', ':'))
    assert_equal expectation, session[:issues][@project.slug][:json_filter]
  end

  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of issues" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new issue" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create issue" do
    should_get_403_on(:_post, :create, id: @issue)
  end

  test "should get a 403 error when user is not allowed to edit issue" do
    should_get_403_on(:_get, :edit, id: @issue)
  end

  test "should get a 403 error when user is not allowed to edit not owned issue" do
    should_get_403_on(:get_with_permission, :edit, id: @issue_not_owned)
  end

  test "should get a 403 error when user is not allowed to view issue" do
    should_get_403_on(:_get, :show, id: @issue)
  end

  test "should get a 403 error when user is not allowed to update issue" do
    should_get_403_on(:_patch, :update, id: @issue)
  end

  test "should get a 403 error when user is not allowed to update not owned issue" do
    should_get_403_on(:patch_with_permission, :update, id: @issue_not_owned)
  end

  test "should get a 403 error when user is not allowed to destroy issue" do
    should_get_403_on(:_delete, :destroy, id: @issue, format: :js)
  end

  test "should get a 403 error when user is not allowed to destroy not owned issue" do
    should_get_403_on(:delete_with_permission, :destroy, id: @issue_not_owned)
  end

  test "should get a 403 error when user is not allowed to get toolbox issue" do
    should_get_403_on(:_get, :toolbox, ids: [@issue], format: :js)
  end

  test "should get a 403 error when user is not allowed to post toolbox issue" do
    should_get_403_on(:_post, :toolbox, ids: [@issue], format: :js)
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

  test "should get a 403  error when user is not allowed to apply custom queries" do
    query = create_custom_query
    should_get_403_on(:_get, :apply_custom_query, query_id: query.slug)
  end

  private
  def create_custom_query
    attributes = {name: "Parker Ferry issues", description: "", is_public: "0",
                  is_for_all: "0", object_type: "Issue"}
    filters = {"assigned_to" => {"operator" => "equal", "value" => ["7"]}}
    query = Query.create_query(attributes, @project, filters)
    query.save
    query
  end
end
