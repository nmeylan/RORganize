require 'test_helper'
require 'test_utilities/record_not_found_tests'

class UsersControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @user = users(:users_001)
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of users" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:users_decorator)
  end

  test "should access to new user" do
    get_with_permission :new
    assert_response :success
    assert_not_nil assigns(:user)
  end

  test "should create user" do
    assert_difference('User.count') do
      post_with_permission :create, user: {login: "testlogin", "name"=>"Test Case", "email"=>"testcase@example.com", "password"=>"qwertz", "admin"=>"0"}
    end
    assert_not_empty flash[:notice]
    assert_not_nil assigns(:user)
    assert_redirected_to user_path(assigns(:user).slug)
  end

  test "should refresh the page when create user failed" do
    assert_no_difference('User.count') do
      post_with_permission :create, user: {login: "testlogin", "name"=>"Test Case", "email"=>"testcase@example.com", "password"=>"", "admin"=>"0"}
    end
    assert_not_nil assigns(:user)
    assert_response :unprocessable_entity
  end

  test "should edit user" do
    get_with_permission :edit, id: @user.slug
    assert_response :success
    assert_not_nil assigns(:user)
  end

  test "should update user" do
    patch_with_permission :update, id: @user, user: {login: "testlogin", "name"=>"Test Case renamed", "email"=>"testcase@example.com", "password"=>"qwertz", "admin"=>"0"}
    assert_not_empty flash[:notice]
    assert_redirected_to user_path(assigns(:user).slug)
  end

  test "should view user" do
    get_with_permission :show, id: @user.slug
    assert_response :success
    assert_not_nil assigns(:user_decorator)
  end

  test "should refresh the page when update category failed" do
    patch_with_permission :update, id: @user.slug, user: {login: "testlogin", "name"=>"", "email"=>"testcase@example.com", "password"=>"qwertz", "admin"=>"0"}
    assert_not_nil assigns(:user)
    assert_response :unprocessable_entity
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete_with_permission :destroy, id: @user.slug, format: :js
    end
    assert_response :success
  end

  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of users" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new user" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create user" do
    should_get_403_on(:_post, :create, id: @user.slug)
  end

  test "should get a 403 error when user is not allowed to edit user" do
    should_get_403_on(:_get, :edit, id: @user.slug)
  end

  test "should get a 403 error when user is not allowed to view user" do
    should_get_403_on(:_get, :show, id: @user.slug)
  end

  test "should get a 403 error when user is not allowed to update user" do
    should_get_403_on(:_patch, :update, id: @user.slug)
  end

  test "should get a 403 error when user is not allowed to destroy user" do
    should_get_403_on(:_delete, :destroy, id: @user.slug, format: :js)
  end
end
