require 'shared/activities'
require 'issues/issue_overview_hash'
class RorganizeController < ApplicationController
  helper ProjectsHelper
  helper IssuesHelper
  helper UsersHelper
  include Rorganize::ActivityManager
  before_filter { |c| c.top_menu_item('home') }
  helper_method :sort_column, :sort_direction


  def index
    respond_to do |format|
      if current_user.nil?
        format.html { render :action => 'index' }
      else
        projects = User.current.owned_projects('starred').decorate(context: {allow_to_star: false})
        overview_object_assigned = IssueOverviewHash.new(Issue.where(assigned_to_id: User.current.id).fetch_dependencies, {project: :assigned_to})
        overview_object_submitted = IssueOverviewHash.new(Issue.where(author_id: User.current.id).fetch_dependencies, {project: :author})
        format.html { render action: 'index', locals: {projects: projects, overview_object_assigned: overview_object_assigned, overview_object_submitted: overview_object_submitted} }
      end
    end
  end

  def view_profile
    @user = User.eager_load([members: [:role, :project, assigned_issues: :status]]).find_by_slug(params[:user])
    if @user
      @user = @user.decorate
      init_activities_sessions
      activities_data = selected_filters
      if @sessions[:activities][:types].include?('NIL')
        @activities = Activities.new([])
      else
        activities_types = @sessions[:activities][:types]
        activities_period = @sessions[:activities][:period]
        from_date = @sessions[:activities][:from_date]
        @activities = Activities.new(@user.activities(activities_types, activities_period, from_date), @user.comments(activities_types, activities_period, from_date))
      end
      respond_to do |format|
        format.html { render :action => 'view_profile', locals: activities_data }
        format.js { respond_to_js action: 'activity', locals: activities_data }
      end
    else
      render_404
    end
  end

  def activity
    view_profile
  end

  def preview_markdown
    respond_to do |format|
      format.json { render json: markdown_to_html(params[:content]) }
    end
  end

  def about
    respond_to do |format|
      format.html
    end
  end

  private
  def sort_column
    params[:sort] ? params[:sort] : 'issues.id'
  end

  def sort_direction
    params[:direction] ? params[:direction] : 'DESC'
  end

  def load_activities

  end
end
