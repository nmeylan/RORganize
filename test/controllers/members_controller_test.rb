require 'test_helper'
require 'test_utilities/record_not_found_tests'

class MembersControllerTest < ActionController::TestCase
  include Rorganize::RecordNotFoundTests
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @user = User.create(name: 'Steve Doe', login: 'stdoe', admin: 0, email: 'steve.doe@example.com', password: 'qwertz')
    @user1 = User.create(name: 'John Doe', login: 'jdoe', admin: 0, email: 'john.doe@example.com', password: 'qwertz')
    @role = roles(:roles_002)
    @member = Member.create(user_id: @user.id, project_id: @project.id, role_id: @role.id)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to index of members" do
    get_with_permission :index
    assert_response :success
    assert_not_nil assigns(:members_decorator)
  end

  test "should access to new member" do
    get_with_permission :new, format: :js
    assert_response :success
    assert_not_nil assigns(:member)
    assert_template 'new'
  end

  test "should create member" do
    allow_user_to('add_member')
    assert_difference('Member.count') do
      post_with_permission :create, member: {user_id: @user1.id, role_id: @role.id}, format: :js
    end
    assert_not_empty @response.header["flash-message"]
    assert_template 'new'
  end

  test "should update member" do
    allow_user_to('change_role')
    patch_with_permission :change_role, member_id: @member.id, value: 1, format: :js
    assert_not_empty @response.header["flash-message"]
    assert_template 'change_role'
  end

  test "should not update member when user can not change role" do
    allow_user_to('add_member')
    member = Member.create(project_id: @project.id, role_id: 3, user_id: @user1.id)
    patch_with_permission :change_role, member_id: member.id, value: 1, format: :js
    member.reload
    assert_equal 3, member.role.id
    assert_response :forbidden
  end

  test "should destroy member" do
    assert_difference('Member.count', -1) do
      delete_with_permission :destroy, id: @member, format: :js
    end
    assert_response :success
  end

  # Action Forbidden
  test "should get a 403 error when user is not allowed to access index of members" do
    should_get_403_on(:_get, :index)
  end

  test "should get a 403 error when user is not allowed to new member" do
    should_get_403_on(:_get, :new)
  end

  test "should get a 403 error when user is not allowed to create member" do
    should_get_403_on(:_post, :create, user: @user1.id, role: @role.id, format: :js)
  end

  test "should get a 403 error when user is not allowed to update member" do
    should_get_403_on(:_patch, :change_role, member_id: @member.id, value: 1, format: :js)
  end

  test "should get a 403 error when user is not allowed to destroy member" do
    should_get_403_on(:_delete, :destroy, id: @member.id)
  end

end
