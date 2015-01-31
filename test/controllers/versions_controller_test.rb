require 'test_helper'
require 'test_utilities/record_not_found_tests'

class VersionsControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @version = Version.create(name: 'Test version', description: '', start_date: '2012-12-01', target_date: '', project_id: @project.id)
    @version1 = Version.create(name: 'Test version 2', description: '', start_date: '2012-12-20', target_date: '', project_id: @project.id)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of versions" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:versions_decorator)
  end

  test "should access to new version" do
    get_with_permission :new
    assert_response :success
  end

  test "should create version" do
    assert_difference('Version.count') do
      post_with_permission :create, version: {name: 'New version test', start_date: '2012-12-01', target_date: ''}
    end
    assert_not_empty flash[:notice]
    assert_redirected_to versions_path
  end

  test "should refresh the page when create version failed" do
    assert_no_difference('Version.count') do
      post_with_permission :create, version: {name: 'New version test', start_date: '', target_date: ''}
    end
    assert_response :unprocessable_entity
    assert_not_nil assigns(:version)
  end

  test "should edit version" do
    get_with_permission :edit, id: @version
    assert_response :success
  end

  test "should update version" do
    patch_with_permission :update, id: @version, version: {name: 'Edited version name', start_date: '2012-12-01', target_date: ''}
    assert_not_empty flash[:notice]
    assert_redirected_to versions_path
  end

  test "should refresh the page when update version failed" do
    patch_with_permission :update, id: @version, version: {name: '', start_date: '2012-12-01', target_date: ''}
    assert_not_nil assigns(:version)
    assert_response :unprocessable_entity
  end

  test "should destroy version" do
    assert_difference('Version.count', -1) do
      delete_with_permission :destroy, id: @version, format: :js
    end
    assert_response :success
  end

  test "should change version position" do
    assert_difference(-> () {@version1.reload; @version1.position}, -1) do
      post_with_permission :change_position, id: @version1.id, operator: 'dec', format: :js
    end
    assert_response :success
  end

  test "should not change version position when position is out of bounds" do
    assert_no_difference(-> () {@version1.reload; @version1.position}) do
      post_with_permission :change_position, id: @version1.id, operator: 'inc', format: :js
    end
    assert_response :success
    assert_not_nil @response.header["flash-error-message"]
  end

  test "should get a 404 error when user change position of an undefined version" do
    should_get_404_on(:post_with_permission, :change_position, id: 666695, operator: 'dec', format: :js)
  end
  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of versions" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new version" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create version" do
    should_get_403_on(:_post, :create, id: @version.id)
  end

  test "should get a 403 error when user is not allowed to edit version" do
    should_get_403_on(:_get, :edit, id: @version.id)
  end
  test "should get a 403 error when user is not allowed to update version" do
    should_get_403_on(:_patch, :update, id: @version.id)
  end

  test "should get a 403 error when user is not allowed to destroy version" do
    should_get_403_on(:_delete, :destroy, id: @version.id, format: :js)
  end

  test "should get a 403 error when user is not allowed to change version position" do
    should_get_403_on(:_post, :change_position, id: @version1.id, operator: 'dec', format: :js)
  end
end
