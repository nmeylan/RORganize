require 'test_helper'
require 'test_utilities/record_not_found_tests'

class PermissionsControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @permission = permissions(:permissions_001)
    @role = roles(:roles_002)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of permission" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:roles)
  end

  test "should access to new permission" do
    get_with_permission :new
    assert_response :success
    assert_not_nil assigns(:permission_decorator)
  end

  test "should create permission" do
    assert_difference('Permission.count', 2) do
      post_with_permission :create, permission: {controller: 'Projects', action: 'test_permission', name: 'This is a test permission'}
    end
    assert_not_empty flash[:notice]
    assert_redirected_to permissions_path
  end

  test "should not create permission when parameters are missings" do
    assert_difference('Permission.count', 1) do
      post_with_permission :create, permission: {controller: 'Projects', action: '', name: 'This is a test permission'}
    end
    assert_not_nil assigns(:permission_decorator)
    assert_response :unprocessable_entity
  end

  test "should edit permission" do
    get_with_permission :edit, id: @permission
    assert_response :success
    assert_not_nil assigns(:permission_decorator)
  end

  test "should update permission" do
    assert_equal 'Create issues', @permission.name
    patch_with_permission :update, id: @permission, permission: {name: 'Create many issues'}
    @permission.reload
    assert_equal 'Create many issues', @permission.name
    assert_not_empty flash[:notice]
    assert_redirected_to permissions_path
  end

  test "should not update permission when parameters are missings" do
    assert_equal 'Create issues', @permission.name
    patch_with_permission :update, id: @permission, permission: {controller: 'Projects', action: '', name: 'Create many issues'}
    @permission.reload
    assert_equal 'Create issues', @permission.name
    assert_not_nil assigns(:permission_decorator)
    assert_response :unprocessable_entity
  end

  test "should destroy permissions" do
    delete_with_permission :destroy, id: @permission, format: :js
    assert_raise(ActiveRecord::RecordNotFound) {@permission.reload}
    assert_response :success
  end

  test "should get all permissions for the given role" do
    get_with_permission :list, role_name: @role.name
    assert_response :success
    assert_not_nil assigns(:permissions_decorator)
  end

  test "should update all permission for the given role" do
    allow_user_to('list')
    assert_difference(-> {@role.reload; @role.permissions.size}, 1) do
      _post :update_permissions, role_name: @role.name, permissions: {@permission.name => @permission.id}
    end
    assert_not_empty flash[:notice]
    assert_redirected_to permissions_path
  end

  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of permissions" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new permission" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create permission" do
    should_get_403_on(:_post, :create, id: @permission.id)
  end

  test "should get a 403 error when user is not allowed to edit permission" do
    should_get_403_on(:_get, :edit, id: @permission.id)
  end

  test "should get a 403 error when user is not allowed to destroy permission" do
    should_get_403_on(:_delete, :destroy, id: @permission.id, format: :js)
  end

  test "should get a 403 error when user is not allowed to get all permission" do
    should_get_403_on(:_get, :list, role_name: @role.name)
  end

  test "should get a 403 error when user is not allowed to update all permission" do
    should_get_403_on(:_post, :update_permissions, role_name: @role.name, permissions: {@permission.name => @permission.id})
  end

end
