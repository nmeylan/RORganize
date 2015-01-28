require 'test_helper'

class RoadmapsControllerTest < ActionController::TestCase
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @project = projects(:projects_001)
    @version = versions(:versions_001)
    @issue = Issue.create(tracker_id: 1, subject: 'Issue parent', description: '', status_id: '1', project_id: @project.id, version_id: @version.id)
    @issue1 = Issue.create(tracker_id: 1, subject: 'Issue child', description: '', status_id: '1', project_id: @project.id, version_id: @version.id)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  test "should access to road map" do
    get_with_permission :show
    assert_response :success
    assert_not_nil assigns(:versions_decorator)
  end

  test "should view a single version overview" do
    allow_user_to('show')
    _get :version, id: @version.id
    assert_response :success
    assert_not_nil assigns(:version_decorator)
  end

  test "should access to gantt chart" do
    get_with_permission :gantt
    assert_response :success
    assert_not_nil assigns(:gantt_object)
  end

  test "should switch gantt mode from view to edition" do
    get_with_permission :gantt, mode: 'edition'
    assert_response :success
    assert_not_nil assigns(:gantt_object)
    assert session[:roadmaps][@project.slug][:gantt][:edition]
  end

  test "should switch gantt mode from edition to view" do
    get_with_permission :gantt, mode: 'edition'
    assert session[:roadmaps][@project.slug][:gantt][:edition]

    get_with_permission :gantt, mode: 'view'
    assert_not session[:roadmaps][@project.slug][:gantt][:edition]
    assert_response :success
    assert_not_nil assigns(:gantt_object)
  end

  test "should switch gantt mode from edition to view from manage gantt view" do
    get_with_permission :manage_gantt, mode: 'edition', format: :js
    assert session[:roadmaps][@project.slug][:gantt][:edition]

    get_with_permission :gantt, mode: 'view'
    assert_not session[:roadmaps][@project.slug][:gantt][:edition]
    assert_response :success
    assert_not_nil assigns(:gantt_object)
  end

  test "should load gantt only for given versions" do
    get_with_permission :gantt, value: ['1', '2']

    assert_response :success
    assert_not_nil assigns(:gantt_object)

    assert_match_array Version.where(id: ['1', '2']), assigns(:gantt_object).versions
  end

  test "should manage gantt dates" do
    assert_nil @issue.start_date
    post_with_permission :manage_gantt, gantt_manage_dates_params_hash

    @issue.reload

    assert_equal Date.new(2012, 9, 19), @issue.start_date
    assert_equal Date.new(2012, 9, 29), @issue.due_date

    assert_response :success
    assert_not_nil @response['flash-message']
  end

  test "should manage gantt links" do
    assert_nil @issue1.predecessor_id
    post_with_permission :manage_gantt, gantt_manage_links_params_hash

    @issue1.reload
    @issue.reload

    assert_equal Date.new(2012, 9, 15), @issue.start_date
    assert_equal Date.new(2012, 9, 30), @issue.due_date

    assert_equal Date.new(2012, 9, 19), @issue1.start_date
    assert_equal Date.new(2012, 9, 29), @issue1.due_date

    assert_equal @issue, @issue1.parent

    assert_response :success
    assert_not_nil @response['flash-message']
  end

  test "should manage gantt links even if issue is not checked to changes" do
    assert_nil @issue1.predecessor_id
    post_with_permission :manage_gantt, gantt_manage_links_params_hash_bis

    @issue1.reload
    @issue.reload

    assert_equal Date.new(2012, 9, 15), @issue.start_date
    assert_equal Date.new(2012, 9, 30), @issue.due_date

    assert_nil @issue1.start_date
    assert_nil @issue1.due_date

    assert_equal @issue, @issue1.parent

    assert_response :success
    assert_not_nil @response['flash-message']
  end

  test "manage versions date should change issues dates" do
    post_with_permission :manage_gantt, gantt_manage_version_dates_params_hash
    @issue.reload
    @version.reload

    assert_equal Date.new(2012, 9, 19), @version.start_date
    assert_equal Date.new(2012, 9, 29), @version.target_date
    assert_equal Date.new(2012, 9, 19), @issue.start_date
    assert_equal Date.new(2012, 9, 29), @issue.due_date

    assert_response :success
    assert_not_nil @response['flash-message']
  end


  private
  def gantt_manage_dates_params_hash
    {
        gantt:
            {
                data: {
                    0 => {
                        id: @issue.id.to_s,
                        start_date: "19-09-2012 00:00",
                        parent: @version.name,
                        context: {
                            due_date: "29-09-2012 00:00"
                        }
                    }
                }
            },
        project_id: @project.slug,
        format: :js
    }
  end

  def gantt_manage_links_params_hash
    {
        gantt:
            {
                data: {
                    0 => {
                        id: @issue1.id.to_s,
                        start_date: "19-09-2012 00:00",
                        parent: @version.name,
                        context: {
                            due_date: "29-09-2012 00:00"
                        }
                    },
                    1 => {
                        id: @issue.id.to_s,
                        start_date: "15-09-2012 00:00",
                        parent: @version.name,
                        context: {
                            due_date: "30-09-2012 00:00"
                        }
                    }
                },
                links: {
                    0 => {
                        source: @issue.id.to_s,
                        target: @issue1.id.to_s,
                        type: "1"
                    }
                }
            },
        project_id: @project.slug,
        format: :js
    }
  end

  def gantt_manage_links_params_hash_bis
    {
        gantt:
            {
                data: {
                    0 => {
                        id: @issue.id.to_s,
                        start_date: "15-09-2012 00:00",
                        parent: @version.name,
                        context: {
                            due_date: "30-09-2012 00:00"
                        }
                    }
                },
                links: {
                    0 => {
                        source: @issue.id.to_s,
                        target: @issue1.id.to_s,
                        type: "1"
                    }
                }
            },
        project_id: @project.slug,
        format: :js
    }
  end

  def gantt_manage_version_dates_params_hash
    {
        gantt:
            {
                data: {
                    0 => {
                        id: "version_#{@version.id}",
                        start_date: "19-09-2012 00:00",
                        parent: "0",
                        context: {
                            due_date: "29-09-2012 00:00"
                        }
                    }
                }
            },
        project_id: @project.slug,
        format: :js
    }
  end

end
