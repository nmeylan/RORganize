class RorganizeController < ApplicationController
  helper ProjectsHelper
  helper IssuesHelper
  helper UsersHelper
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
    @user = User.eager_load([members: [:role, :project, :assigned_issues]]).find_by_slug(params[:user]).decorate
    render_404 if @user.nil?
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
