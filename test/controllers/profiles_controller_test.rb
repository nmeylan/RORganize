# Author: Nicolas Meylan
# Date: 25.01.15 14:43
# Encoding: UTF-8
# File: profiles_controller_test.rb
require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to profile" do
    get :show
    assert_response :success
    assert_not_nil assigns(:user_decorator)
  end

  test "should view activities" do
    get :activity_filter, types: {"Issue"=>"1"}, date: "2015-01-22", period: "THREE_DAYS"
    assert_response :success
    assert_not_nil assigns(:user_decorator)
  end

  test "should get form to change password" do
    get :change_password
    assert_response :success
    assert_template 'change_password'
  end

  test "should post change password" do
    post :change_password, user: {password: 'qwertz', retype_password: 'qwertz'}
    assert_redirected_to profile_path
  end

  test "should refresh the page when password mismatch" do
    post :change_password, user: {password: 'qwertz', retype_password: 'azerty'}
    assert_response :success
    assert_template 'change_password'
  end

  test "should get form to change email" do
    get :change_email
    assert_response :success
    assert_template 'change_email'
  end

  test "should post change email and be redirected with a flash message when it changed" do
    post :change_email, user: {email: 'test_email@rorganize.org'}
    assert_redirected_to profile_path
    assert_not_empty flash[:notice]
  end

  test "should post change email and be redirected without a flash message when it has not changed" do
    post :change_email, user: {email: User.current.email}
    assert_redirected_to profile_path
    assert_nil flash[:notice]
  end

  test "should refresh the page when email is not valid" do
    post :change_email, user: {email: ''}
    assert_response :success
    assert_template 'change_email'

    post :change_email, user: {email: 'jb@atz.com'} #see fixture:email has been already taken
    assert_response :success
    assert_template 'change_email'
  end

  test "should get form to change avatar" do
    get :change_avatar
    assert_response :success
    assert_template 'change_avatar'
  end

  test "should post change avatar and be redirected to same page" do
    post :change_avatar, user: {avatar: fixture_file_upload("files/avatar.png",'image/png')}
    assert_redirected_to change_avatar_profile_path
  end

  test "should delete avatar" do
    User.any_instance.stubs(:delete_avatar).returns(nil)
    delete :delete_avatar, format: :js
    assert_response :success
  end

  test "should get all custom queries" do
    get :custom_queries
    assert_response :success
    assert_not_nil assigns(:queries_decorator)
  end

  test "should get all project where user is member" do
    get :projects
    assert_response :success
    assert_not_nil assigns(:projects_decorator)
  end

  test "should star project" do
    project = projects(:projects_002)
    assert_not project.starred?
    post :star_project, project_id: project.slug, format: :js
    project.reload
    assert project.starred?
    assert_equal "#{I18n.t(:text_project)} #{project.name} #{I18n.t(:successful_starred)}", @response.header["flash-message"]

    _post :star_project, project_id: project.slug, format: :js
    project.reload
    assert_not project.starred?
    assert_equal "#{I18n.t(:text_project)} #{project.name} #{I18n.t(:successful_unstarred)}", @response.header["flash-message"]
  end

  test "should star public project" do
    project_public = Project.create(name: 'Project public test', is_public: true, created_by: 666)
    project_public.members.delete_all
    member_project_public = User.current.member_for(project_public)

    assert_nil member_project_public

    _post :star_project, project_id: project_public.slug, format: :js

    project_public.reload

    assert project_public.starred?
    assert_equal "#{I18n.t(:text_project)} #{project_public.name} #{I18n.t(:successful_starred)}", @response.header["flash-message"]

    member_project_public = User.current.member_for(project_public)
    assert member_project_public
  end

  test "should get 404 when star a project that does not exists" do
    _post :star_project, project_id: 'undefined-project', format: :js
    assert_response :missing
    assert_not_nil @response.header["flash-error-message"]
    assert @response.header["flash-error-message"].start_with?('Seems')
  end

  test "should change project position" do
    project1 = projects(:projects_001)
    project2 = projects(:projects_002)
    project3 = projects(:projects_004)
    member_project1 = User.current.member_for(project1)
    member_project2 = User.current.member_for(project2)
    member_project3 = User.current.member_for(project3)
    assert_equal 1, member_project1.project_position
    assert_equal 0, member_project2.project_position
    assert_equal 2, member_project3.project_position
    post :save_project_position, ids: [project1.slug, project3.slug, project2.slug], format: :js

    member_project1.reload
    member_project2.reload
    member_project3.reload
    assert_response :success
    assert_equal 0, member_project1.project_position
    assert_equal 2, member_project2.project_position
    assert_equal 1, member_project3.project_position
  end

  test "should change project position with public project" do
    project_public = Project.create(name: 'Project public test', is_public: true, created_by: 666)
    project_public.members.delete_all
    project1 = projects(:projects_001)
    project2 = projects(:projects_002)
    project3 = projects(:projects_004)
    member_project1 = User.current.member_for(project1)
    member_project2 = User.current.member_for(project2)
    member_project3 = User.current.member_for(project3)
    member_project_public = User.current.member_for(project_public)
    assert_equal 1, member_project1.project_position
    assert_equal 0, member_project2.project_position
    assert_equal 2, member_project3.project_position
    assert_nil member_project_public
    post :save_project_position, ids: [project1.slug, project3.slug, project_public.slug, project2.slug], format: :js

    member_project1.reload
    member_project2.reload
    member_project3.reload
    member_project_public = User.current.member_for(project_public)
    assert_response :success
    assert_equal 0, member_project1.project_position
    assert_equal 3, member_project2.project_position
    assert_equal 1, member_project3.project_position
    assert_equal 2, member_project_public.project_position
  end

  test "should view spent time" do
    Date.stubs(:today).returns(Date.new(2012, 12, 01))
    get :spent_time
    assert_response :success
    assert_not_nil assigns(:date)
    assert_not_nil assigns(:time_entries)
    assert_equal Date.new(2012, 12, 01), assigns(:date)
    assert_template 'spent_time'
  end

  test "should view spent time for the given date" do
    get :spent_time, date: '2012-11-01'
    assert_response :success
    assert_not_nil assigns(:date)
    assert_not_nil assigns(:time_entries)
    assert_equal Date.new(2012, 11, 01), assigns(:date)
    assert_template 'spent_time'
  end

  test "should toggle acting as user and admin when user is admin" do
    assert_not User.current.act_as_admin?
    get :act_as
    assert User.current.act_as_admin?
  end

  test "should not be able to toggle acting as user and admin when user is not admin" do
    User.current.admin = false
    User.current.save
    assert_not User.current.act_as_admin?
    get :act_as
    assert_not User.current.act_as_admin?
    assert_response :forbidden
  end

  test "should access to notifications preferences" do
    get :notification_preferences
    assert_response :success
    assert_not_nil assigns(:preferences)
    assert_template 'notification_preferences'
  end

  test "should update notifications preferences" do
    assert_equal 0, User.current.preferences.size
    post :notification_preferences, preferences: {participant_in_app: 2, watcher_in_app: 0}
    User.current.reload
    assert_equal 2, User.current.preferences.size
    assert_redirected_to notification_preferences_profile_path
    assert_not_empty flash[:notice]
  end
end