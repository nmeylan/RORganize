require 'test_helper'

class TimeEntriesControllerTest < ActionController::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @issue = issues(:issues_001)
    @issue2 = issues(:issues_002)
    Date.stubs(:today).returns(Date.new(2012, 12, 20))
    @time_entry = TimeEntry.create(issue_id: @issue2.id, project_id: @issue2.project_id, spent_time: 4, spent_on: Date.new(2012, 12, 23), user_id: User.current.id)
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to new overlay without date parameters" do
    get_with_permission :fill_overlay, issue_id: @issue.id, format: :js
    assert_not_nil assigns(:time_entry)
    assert_equal Date.new(2012, 12, 20), assigns(:time_entry).spent_on
    assert_template 'time_entries/_log_issue_spent_time_form_content'
  end

  test "should access to new overlay with date parameters" do
    get_with_permission :fill_overlay, issue_id: @issue.id, spent_on: '2012-12-01', format: :js
    assert_not_nil assigns(:time_entry)
    assert_equal Date.new(2012, 12, 01), assigns(:time_entry).spent_on
    assert_template 'time_entries/_log_issue_spent_time_form_content'
  end

  test "should create time entry for issue" do
    assert_difference('TimeEntry.count') do
      post_with_permission :create, time_entry: {spent_on: "2015-01-30", spent_time: "3", comment: ""}, issue_id: @issue.id, format: :js
    end
    assert_not_nil @response['flash-message']
  end

  test "should not create time entry for issue when missing spent time" do
    assert_no_difference('TimeEntry.count') do
      post_with_permission :create, time_entry: {spent_on: "2015-01-30", spent_time: "", comment: ""}, issue_id: @issue.id, format: :js
    end
    assert_not_nil @response['flash-error-message']
  end

  test "should get a 404 when issue id is undefined for time entry creation" do
    assert_no_difference('TimeEntry.count') do
      post_with_permission :create, time_entry: {spent_on: "2015-01-30", spent_time: "", comment: ""}, issue_id: 666, format: :js
    end
    assert_not_nil @response['flash-error-message']
    assert_response :missing
  end

  test "should edit time entry" do
    get_with_permission :fill_overlay, issue_id: @issue2.id, spent_on: '2012-12-23', format: :js
    assert_not_nil assigns(:time_entry)
    assert_not_nil assigns(:time_entry).id
    assert_template 'time_entries/_log_issue_spent_time_form_content'
  end

  test "should get new form when editing an other date time entry" do
    get_with_permission :fill_overlay, issue_id: @issue2.id, spent_on: '2012-12-24', format: :js
    assert_not_nil assigns(:time_entry)
    assert_nil assigns(:time_entry).id
    assert_equal Date.new(2012, 12, 24), assigns(:time_entry).spent_on
    assert_template 'time_entries/_log_issue_spent_time_form_content'
  end

  test "should update time entry" do
    assert_equal 4, @time_entry.spent_time
    put_with_permission :update, time_entry: {spent_on: @time_entry.spent_on, spent_time: "3", comment: ""}, issue_id: @issue.id, id: @time_entry.id, format: :js
    @time_entry.reload
    assert_equal 3, @time_entry.spent_time
    assert_not_nil @response['flash-message']
  end

  test "should not update time entry when params are missing" do
    put_with_permission :update, time_entry: {spent_on: @time_entry.spent_on, spent_time: "", comment: ""}, issue_id: @issue.id, id: @time_entry.id, format: :js
    assert_not_nil @response['flash-error-message']
    put_with_permission :update, time_entry: {spent_on: "", spent_time: "3", comment: ""}, issue_id: @issue.id, id: @time_entry.id, format: :js
    assert_not_nil @response['flash-error-message']
  end

  test "should destroy a time entry" do
    assert_difference('TimeEntry.count', -1) do
      delete_with_permission :destroy, id: @time_entry.id, format: :js
    end
    assert_not_nil flash[:notice]
  end

  test "should not destroy an other user time entry" do
    User.stubs(:current).returns(users(:users_002))
    User.any_instance.stubs(:checked_permissions).returns({})
    assert_no_difference('TimeEntry.count', -1) do
      delete :destroy, id: @time_entry.id, format: :js
    end
    assert_not_nil flash[:alert]
  end
end
