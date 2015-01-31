require 'test_helper'

class WatchersControllerTest < ActionController::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @issue = issues(:issues_001)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should watch an issue" do
    allow_user_to('watch', 'issues')
    watch_issue
  end


  test "should unwatch an issue" do
    allow_user_to('watch', 'issues')
    watch_issue
    #Unwatch
    destroy_issue_watcher
  end

  test "should watch project" do
    allow_user_to('watch', 'projects')
    watch_project
  end

  test "should watch project then unwatch issue" do
    allow_user_to('watch', 'projects')
    allow_user_to('watch', 'issues')

    watch_project
    unwatch_issue
  end

  test "should watch project then unwatch issue then watch it again" do
    allow_user_to('watch', 'projects')
    allow_user_to('watch', 'issues')

    watch_project
    unwatch_issue
    watch_issue
  end

  # 1. Watch an issue
  # 2. Watch the project that contains the issue
  # 3. Unwatch the issue
  test "should watch an issue then watch the project then unwatch issue" do
    allow_user_to('watch', 'projects')
    allow_user_to('watch', 'issues')

    watch_issue
    watch_project
    unwatch_issue
  end

  # 1. Watch an issue
  # 2. Watch the project that contains the issue
  # 3. Unwatch the issue
  # 4. Unwatch the project
  # 5. Watch the issue
  test "should watch an issue then watch the project then unwatch issue then unwatch project then watch issue again" do
    allow_user_to('watch', 'projects')
    allow_user_to('watch', 'issues')

    watch_issue
    watch_project
    unwatch_issue
    destroy_project_watcher
    watch_issue
  end

  # Forbidden actions
  test "should get a 403 error when user is not allowed to watch issue" do
    should_get_403_on(:_post, :toggle, watchable_id: @issue.id, watchable_type: 'Issue', format: :js)
  end

  test "should get a 403 error when user is not allowed to watch project" do
    should_get_403_on(:_post, :toggle, watchable_id: @project.id, watchable_type: 'Project', format: :js)
  end

  private
  def watch_issue
    # Watch
    _post :toggle, watchable_id: @issue.id, watchable_type: 'Issue', format: :js
    watcher = assigns(:watcher)
    assert_not_nil watcher
    assert_not watcher.is_unwatch
    assert_not_nil @response['flash-message']
    assert_equal I18n.t(:successful_watched), @response['flash-message']
    watcher
  end

  def watch_project
    # Watch
    _post :toggle, watchable_id: @project.id, watchable_type: 'Project', format: :js
    watcher = assigns(:watcher)
    assert_not_nil watcher
    assert_not watcher.is_unwatch
    assert_equal I18n.t(:successful_watched), @response['flash-message']
    watcher
  end

  def destroy_issue_watcher
    _post :toggle, watchable_id: @issue.id, watchable_type: 'Issue', format: :js
    watcher = Watcher.find_by_watchable_id_and_watchable_type_and_user_id(@issue.id, 'Issue', User.current.id)
    assert_equal I18n.t(:successful_unwatched), @response['flash-message']
    assert_nil watcher
  end

  def destroy_project_watcher
    _post :toggle, watchable_id: @project.id, watchable_type: 'Project', format: :js
    watcher = Watcher.find_by_watchable_id_and_watchable_type_and_user_id(@project.id, 'Project', User.current.id)
    assert_equal I18n.t(:successful_unwatched), @response['flash-message']
    assert_nil watcher
  end

  def unwatch_issue
    _post :toggle, watchable_id: @issue.id, watchable_type: 'Issue', format: :js
    watcher = Watcher.find_by_watchable_id_and_watchable_type_and_user_id(@issue.id, 'Issue', User.current.id)
    assert_not_nil watcher
    assert_equal 'Issue', watcher.watchable_type
    assert watcher.is_unwatch
    assert_equal I18n.t(:successful_unwatched), @response['flash-message']
    watcher
  end
end
