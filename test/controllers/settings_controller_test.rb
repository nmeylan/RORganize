require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
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

  test "should access to index of settings" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:project_decorator)
    assert_not_nil assigns(:trackers_decorator)
  end

  test "should update project information" do
    assert_equal 2, @project.trackers.count
    put_with_permission :update, project: {name: 'New project name', is_public: 1, description: "A simple description"}, trackers: {}, id: "update_project_informations"

    @project.reload
    assert_equal 0, @project.trackers.count
    assert_equal 'New project name', @project.name
    assert @project.is_public, 'Project is private'

    assert_redirected_to settings_path(@project.slug)
  end

  test "should refresh the page when update project failed" do
    put_with_permission :update, project: {name: '', is_public: 1, description: "A simple description"},
                        trackers: {}, id: "update_project_informations"
    @project.reload

    assert_not_nil assigns(:project_decorator)
    assert_not_nil assigns(:trackers_decorator)
    assert_response :unprocessable_entity
  end

  test "should access to project public queries" do
    allow_user_to('index', 'queries')
    _get :public_queries
    assert_response :success
    assert_not_nil assigns(:queries_decorator)
  end

  test "should destroy project attachment" do
    attachment = Attachment.new(name: 'File test', file_file_name: 'file_test.png',
                                attachable_id: @project.id, attachable_type: 'Project')
    @project.attachments << attachment
    @project.save
    assert_equal 1, @project.attachments.count

    _delete :delete_attachment, id: attachment.id, format: :js
    @project.reload
    assert_equal 0, @project.attachments.count
    assert_response :success
  end

  test "should access to project modules" do
    get_with_permission :modules
    assert_response :success
    assert_not_nil assigns(:modules)
  end

  test "should enable modules" do
    post_with_permission :modules, modules: {name: ["projects-activity-activity", "roadmaps-show-roadmaps"]}
    @project.reload
    assert_equal 2, @project.enabled_modules.count
    assert_response :success
    assert_not_nil assigns(:modules)
  end

  # Forbidden actions
  test "should get a 403 error when user is not allowed to access to index of settings" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to access to modules" do
    should_get_403_on(:_put, :modules)
  end

  test "should get a 403 error when user is not allowed to access to queries" do
    should_get_403_on(:_get, :public_queries)
  end
end