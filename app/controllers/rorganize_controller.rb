class RorganizeController < ApplicationController
  include ApplicationHelper
  before_filter {|c| c.top_menu_item("home")}
  helper_method :sort_column, :sort_direction
  def index
    unless current_user.nil?
      order = sort_column + " " + sort_direction
      #Load favorites projects
      members= current_user.members.includes(:project => [:attachments]).select{|member| member.is_project_starred}
      #Load latest assigned requests
      issues = Issue.select("issues.*")
      .where("issues.id IN (?)",Issue.select("issues.id").where("assigned_to_id = ?", current_user.id).limit(5).order("issues.id DESC"))
      .includes(:tracker, :project,:status => [:enumeration])
      .order(order)
      #Load latest activities
      activities = Journal.select("journals.*").where(:user_id => current_user.id).includes(:details, :project, :user, :journalized).limit(5).order("created_at DESC")
      respond_to do |format|
        format.html {render :action => "index", :locals => {:issues => issues, :activities => activities, :members => members}}
        format.js do
          render :update do |page|
            page.replace "issues_content", :partial => 'issues/list_per_project'
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
