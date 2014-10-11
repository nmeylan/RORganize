require 'shared/activities'
require 'issues/issue_overview_hash'
require 'rorganize/home_page_report'
class RorganizeController < ApplicationController
  helper ProjectsHelper
  helper IssuesHelper
  helper UsersHelper
  include Rorganize::Managers::ActivityManager
  include Rorganize::RichController::TaskListCallback

  before_filter { |c| c.top_menu_item('home') }
  helper_method :sort_column, :sort_direction


  def index
    respond_to do |format|
      if current_user.nil?
        format.html { render :index }
      else
        format.html { render :index, locals: HomePageReport.new.content }
      end
    end
  end

  def view_profile
    @user_decorator = User.eager_load([members: [:role, :project, assigned_issues: :status]]).find_by_slug(params[:user])
    if @user_decorator
      @user_decorator = @user_decorator.decorate
      init_activities_sessions
      activities_data = selected_filters

      load_activities(@user_decorator)
      activity_callback(activities_data, :view_profile)
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

  def error_404
    render_404
  end

  private
  def sort_column
    params[:sort] ? params[:sort] : 'issues.id'
  end

  def sort_direction
    params[:direction] ? params[:direction] : 'DESC'
  end

end
