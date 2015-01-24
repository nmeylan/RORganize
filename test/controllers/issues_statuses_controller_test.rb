require 'test_helper'
require 'test_utilities/record_not_found_tests'

class IssuesStatusesControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @status = IssuesStatus.create_status('TEST_STATUS', default_done_ratio: 0, is_closed: 0, color: '#566643')
    @status1 = IssuesStatus.create_status('TEST_STATUS1', default_done_ratio: 0, is_closed: 0, color: '#566643')
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of statuses" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:issues_statuses_decorator)
  end

  test "should access to new status" do
    get_with_permission :new
    assert_response :success
  end

  test "should create status" do
    assert_difference('IssuesStatus.count') do
      post_with_permission :create, enumeration: {name: "New status"}, issues_status: {default_done_ratio: "", color: "#6cc644", is_closed: "0"}
    end
    assert_not_empty flash[:notice]
    assert_redirected_to issues_statuses_path
  end

  test "should refresh the page when create status failed" do
    assert_no_difference('IssuesStatus.count') do
      post_with_permission :create, enumeration: {name: ""}, issues_status: {default_done_ratio: "", color: "#6cc644", is_closed: "0"}
    end
    assert_not_nil assigns(:status)
    assert_response :unprocessable_entity
  end

  test "should edit status" do
    get_with_permission :edit, id: @status
    assert_response :success
  end

  test "should update status" do
    patch_with_permission :update, id: @status, enumeration: {name: "Change status"}, issues_status: {default_done_ratio: "", color: "#6cc644", is_closed: "0"}
    assert_not_empty flash[:notice]
    assert_redirected_to issues_statuses_path
  end

  test "should refresh the page when update status failed" do
    patch_with_permission :update, id: @status, enumeration: {name: ""}, issues_status: {default_done_ratio: "", color: "#6cc644", is_closed: "0"}
    assert_not_nil assigns(:status)
    assert_response :unprocessable_entity
  end

  test "should destroy status" do
    assert_difference('IssuesStatus.count', -1) do
      delete_with_permission :destroy, id: @status, format: :js
    end
    assert_response :success
  end

  test "should change status position" do
    assert_difference(-> () {@status1.reload; @status1.position}, -1) do
      post_with_permission :change_position, id: @status1.id, operator: 'dec', format: :js
    end
    assert_response :success
  end

  test "should not change status position when position is out of bounds" do
    assert_no_difference(-> () {@status1.reload; @status1.position}) do
      post_with_permission :change_position, id: @status1.id, operator: 'inc', format: :js
    end
    assert_response :success
    assert_not_nil @response.header["flash-error-message"]
  end

  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of statuses" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new status" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create status" do
    should_get_403_on(:_post, :create, id: @status.id)
  end

  test "should get a 403 error when user is not allowed to edit status" do
    should_get_403_on(:_get, :edit, id: @status.id)
  end
  test "should get a 403 error when user is not allowed to update status" do
    should_get_403_on(:_patch, :update, id: @status.id)
  end

  test "should get a 403 error when user is not allowed to destroy status" do
    should_get_403_on(:_delete, :destroy, id: @status.id, format: :js)
  end

  test "should get a 403 error when user is not allowed to change status position" do
    should_get_403_on(:_post, :change_position, id: @status1.id, operator: 'dec', format: :js)
  end
end
