
require 'shared/activities'
class RorganizeController < ApplicationController
  helper ProjectsHelper
  helper IssuesHelper
  helper UsersHelper
  include Rorganize::ActivityManager
  before_filter {|c| c.top_menu_item('home')}
  helper_method :sort_column, :sort_direction


  def index
    unless current_user.nil?
      order = sort_column + ' ' + sort_direction
      #Load favorites projects
      #Load favorites projects
      projects = current_user.owned_projects('starred').decorate(context: {allow_to_star: false})
      #Load latest assigned requests
      issues = current_user.latest_assigned_issues(order, 5).decorate
      #Load latest activities
      activities =  current_user.latest_activities(5)
      respond_to do |format|
        format.html {render :action => 'index', :locals => {issues: issues, activities: activities, projects: projects}}
      end
    else
      redirect_to new_user_session_path
    end
  end

  def view_profile
    @user = User.eager_load([members: [:role, :project, assigned_issues: :status]]).find_by_slug(params[:user]).decorate
    init_activities_sessions
    activities_data = selected_filters
    if @sessions[:activities][:types].include?('NIL')
      @activities =  Activities.new([])
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
    render_404 if @user.nil?
  end

  def activity
    view_profile
  end

  def preview_markdown
    respond_to do |format|
      format.json {render json: markdown_to_html(params[:content])}
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
