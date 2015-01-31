require 'test_helper'
require 'test_utilities/record_not_found_tests'

class TrackersControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @tracker = trackers(:trackers_001)
    @tracker1 = trackers(:trackers_002)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of trackers" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:trackers_decorator)
  end

  test "should access to new tracker" do
    get_with_permission :new
    assert_response :success
  end

  test "should create tracker" do
    assert_difference('Tracker.count') do
      post_with_permission :create, tracker: {name: 'New name'}
    end
    assert_not_empty flash[:notice]
    assert_redirected_to trackers_path
  end

  test "should refresh the page when create tracker failed" do
    assert_no_difference('Tracker.count') do
      post_with_permission :create, tracker: {name: ''}
    end
    assert_not_nil assigns(:tracker)
    assert_response :unprocessable_entity
  end

  test "should edit tracker" do
    get_with_permission :edit, id: @tracker
    assert_response :success
  end

  test "should update tracker" do
    patch_with_permission :update, id: @tracker, tracker: {name: 'New name'}
    assert_not_empty flash[:notice]
    assert_redirected_to trackers_path
  end

  test "should refresh the page when update tracker failed" do
    patch_with_permission :update, id: @tracker, tracker: {name: ''}
    assert_not_nil assigns(:tracker)
    assert_response :unprocessable_entity
  end

  test "should destroy tracker" do
    assert_difference('Tracker.count', -1) do
      delete_with_permission :destroy, id: @tracker, format: :js
    end
    assert_response :success
  end

  test "should change tracker position" do
    assert_difference(-> () {@tracker1.reload; @tracker1.position}, -1) do
      post_with_permission :change_position, id: @tracker1.id, operator: 'dec', format: :js
    end
    assert_response :success
  end

  test "should not change tracker position when position is out of bounds" do
    assert_no_difference(-> () {@tracker1.reload; @tracker1.position}) do
      post_with_permission :change_position, id: @tracker1.id, operator: 'inc', format: :js
    end
    assert_response :success
    assert_not_nil @response.header["flash-error-message"]
  end

  test "should get a 404 error when user change position of an undefined tracker" do
    should_get_404_on(:post_with_permission, :change_position, id: 666695, operator: 'dec', format: :js)
  end
  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of trackers" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new tracker" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create tracker" do
    should_get_403_on(:_post, :create, id: @tracker.id)
  end

  test "should get a 403 error when user is not allowed to edit tracker" do
    should_get_403_on(:_get, :edit, id: @tracker.id)
  end
  test "should get a 403 error when user is not allowed to update tracker" do
    should_get_403_on(:_patch, :update, id: @tracker.id)
  end

  test "should get a 403 error when user is not allowed to destroy tracker" do
    should_get_403_on(:_delete, :destroy, id: @tracker.id, format: :js)
  end

  test "should get a 403 error when user is not allowed to change tracker position" do
    should_get_403_on(:_post, :change_position, id: @tracker1.id, operator: 'dec', format: :js)
  end

end
