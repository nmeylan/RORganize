require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to projects" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects_decorator)
  end

  test "should view project from show action" do
    allow_user_to('overview')
    get :show, id: 'rorganize'
    assert_response :success
    assert_not_nil assigns(:project_decorator)
  end

  test "should view project from overview action" do
    get_with_permission :overview, project_id: 'rorganize'
    assert_response :success
    assert_not_nil assigns(:project_decorator)
  end

  test "should get 404 on view project from show action" do
    allow_user_to('overview')
    should_get_404_on(:get, :show, id: 'no-project-found')
  end

  test "should get 404 on view project from overview action" do
    allow_user_to('overview')
    should_get_404_on(:get, :overview, project_id: 'no-project-found')
  end

  test "should view activities" do
    get_with_permission :activity
    assert_response :success
    assert_not_nil assigns(:activities)
  end

  test "should filter activities" do
    get_with_permission :activity_filter, types: {"Issue" => "1"}, date: "2015-01-22", period: "THREE_DAYS"
    assert_response :success
    assert_not_nil assigns(:activities)
  end

  test "should access to new project" do
    get_with_permission :new
    assert_response :success
    assert_not_nil assigns(:project_decorator)
  end

  test "should create project" do
    assert_difference('Project.count') do
      post_with_permission :create, project: {name: 'New test project'}, trackers: {}
    end
    assert_not_empty flash[:notice]
    assert_not_nil assigns(:project_decorator)
    assert_redirected_to overview_projects_path('new-test-project')
  end

  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete_with_permission :destroy, id: @project.slug, format: :js
    end
    assert_response :success
  end

  test "should archive project" do
    assert_not @project.is_archived
    post_with_permission :archive, id: @project.slug, format: :js
    @project.reload
    assert @project.is_archived
    assert_response :success
  end

  test "should filter projects" do
    post :filter, filter: 'opened'
    assert_response :success
    assert_not_nil assigns(:projects_decorator)
  end

  test "should get all member into a json" do
    get :members, project_id: @project.slug, format: :json
    assert_response :success

  end

  test "should get all issues into a json" do
    get :issues_completion, project_id: @project.slug, format: :json
    assert_response :success
  end

  # Forbidden
  test "should get a 403 error when user is not allowed to new project" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create project" do
    should_get_403_on(:_post, :create)
  end

  test "should get a 403 error when user is not allowed to destroy project" do
    should_get_403_on(:_delete, :destroy, id: @project.slug, format: :js)
  end

  test "should get a 403 error when user is not allowed to archive project" do
    should_get_403_on(:_post, :archive, id: @project.slug, format: :js)
  end

  test "should get a 403 error when user is not allowed to access to activity" do
    should_get_403_on(:_get, :activity)
  end

  test "should get a 403 error when user is not allowed to view activity from show" do
    should_get_403_on(:_get, :show, id: @project.slug)
  end

  test "should get a 403 error when user is not allowed to view activity from overview" do
    should_get_403_on(:_get, :overview)
  end
end
