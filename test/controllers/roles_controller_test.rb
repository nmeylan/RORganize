require 'test_helper'
require 'test_utilities/record_not_found_tests'

class RolesControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @role = roles(:roles_001)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of roles" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:roles_decorator)
  end

  test "should access to new role" do
    get_with_permission :new
    assert_response :success
    assert_not_nil assigns(:role)
    assert_not_nil assigns(:roles)
    assert_not_nil assigns(:issues_statuses)
  end

  test "should create role" do
    assert_difference('Role.count') do
      post_with_permission :create, role: {name: 'New role'}
    end
    assert_not_empty flash[:notice]
    assert_redirected_to roles_path
  end

  test "should refresh the page when create role failed" do
    assert_no_difference('Role.count') do
      post_with_permission :create, role: {name: ''}
    end
    assert_not_nil assigns(:role)
    assert_not_nil assigns(:roles)
    assert_not_nil assigns(:issues_statuses)
    assert_response :unprocessable_entity
  end

  test "should edit role" do
    get_with_permission :edit, id: @role
    assert_response :success
    assert_not_nil assigns(:role)
    assert_not_nil assigns(:roles)
    assert_not_nil assigns(:issues_statuses)
  end

  test "should update role" do
    patch_with_permission :update, id: @role.id, role: {name: 'Change role name'}
    assert_not_empty flash[:notice]
    assert_redirected_to roles_path
  end

  test "should refresh the page when update role failed" do
    patch_with_permission :update, id: @role.id, role: {name: ''}
    assert_not_nil assigns(:role)
    assert_not_nil assigns(:roles)
    assert_not_nil assigns(:issues_statuses)
    assert_response :unprocessable_entity
  end

  test "should destroy role" do
    assert_difference('Role.count', -1) do
      delete_with_permission :destroy, id: @role, format: :js
    end
    assert_response :success
  end

  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of roles" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new role" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create role" do
    should_get_403_on(:_post, :create, id: @role.id)
  end

  test "should get a 403 error when user is not allowed to edit role" do
    should_get_403_on(:_get, :edit, id: @role.id)
  end

  test "should get a 403 error when user is not allowed to update role" do
    should_get_403_on(:_patch, :update, id: @role.id)
  end

  test "should get a 403 error when user is not allowed to destroy role" do
    should_get_403_on(:_delete, :destroy, id: @role.id)
  end

end
