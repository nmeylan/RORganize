class RorganizeController < ApplicationController
  helper ProjectsHelper
  before_filter {|c| c.top_menu_item('home')}
  helper_method :sort_column, :sort_direction


  def index
    unless current_user.nil?
      order = sort_column + ' ' + sort_direction
      #Load favorites projects
      #Load favorites projects
      projects = current_user.starred_projects
      #Load latest assigned requests
      issues = current_user.latest_assigned_issues(order, 5)
      #Load latest activities
      activities =  current_user.latest_activities(5)
      respond_to do |format|
        format.html {render :action => 'index', :locals => {:issues => issues, :activities => activities, :projects => projects}}
        format.js do
          render :update do |page|
            page.replace 'issues_content', :partial => 'issues/list_per_project',:locals => {:issues => issues}
          end
        end
      end
    else
      redirect_to new_user_session_path
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
