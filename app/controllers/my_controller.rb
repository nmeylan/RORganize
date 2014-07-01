# Author: Nicolas Meylan
# Date: 10 oct. 2012
# Encoding: UTF-8
# File: my_controller.rb

class MyController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user
  helper_method :sort_column, :sort_direction
  include MyHelper

  def show
    order = sort_column + ' ' + sort_direction
    #Load favorites projects
    projects = current_user.starred_projects
    #Load latest assigned requests
    issues = current_user.latest_assigned_issues(order, 5)
    #Load latest activities
    activities =  current_user.latest_activities(5)
    respond_to do |format|
      format.html { render :action => 'show', :locals => {:issues => issues, :activities => activities, :projects => projects} }
      format.js do
        render :update do |page|
          page.replace 'issues_content', :partial => 'issues/list_per_project', :locals => {:issues => issues}
        end
      end
    end
  end

  def my_assigned_requests
    order = sort_column + ' ' + sort_direction
    issues = Issue.current_user_assigned_issues(order)
    respond_to do |format|
      format.html { render :action => 'my_assigned_requests', :locals => {:issues => issues} }
    end
  end

  def my_activities

  end

  def my_submitted_requests
    order = sort_column + ' ' + sort_direction
    issues = Issue.current_user_submitted_issues(order)
    respond_to do |format|
      format.html { render :action => 'my_submitted_requests', :locals => {:issues => issues} }
    end
  end

  def change_password
    if request.post?
      if user_params[:password].eql?(user_params[:retype_password]) && @user.update_attributes(password: user_params[:password])
        respond_to do |format|
          flash[:notice] = t(:successful_creation)
          format.html { redirect_to :action => 'show', :id => @user.slug }
        end
      else
        @user.errors.add(:passwords, ': do not match')
        respond_to do |format|
          format.html
        end
      end
    else
      respond_to do |format|
        format.html {}
      end
    end
  end

  def custom_queries
    @queries = Query.where(['author_id = ? AND is_public = ?', current_user.id, false])
    respond_to do |format|
      format.html {}
    end
  end

  def my_projects
    respond_to do |format|
      format.html { render :action => 'my_projects', :locals => {:projects => current_user.projects} }
    end
  end

  def star_project
    members= current_user.members
    member = members.select { |member| member.project_id.eql?(params[:project_id].to_i) }.first
    member.is_project_starred = !member.is_project_starred
    member.save
    message = "#{t(:text_project)} #{member.project.name} #{member.is_project_starred ? t(:successful_starred) : t(:successful_unstarred )}"
    respond_to do |format|
      format.js {respond_to_js :response_header => :success, :response_content => message, :locals => {id: params[:project_id], is_starred: member.is_project_starred}}
    end
  end

  def save_project_position
    members= current_user.members
    project_ids = params[:ids]
    members.each do |member|
      member.project_position = project_ids.index(member.project_id.to_s)
      member.save
    end
    respond_to do |format|
      format.js {respond_to_js :action => 'do_nothing', :response_header => :success, :response_content => t(:successful_update)}
    end
  end

  def my_spent_time
    if params[:date]
      @date = params[:date].to_date
    else
      @date = Date.today
    end
    time_entries = current_user.time_entries_for_month(@date.year, @date.month)
    @time_entries = Hash.new{|h, k| h[k] = []}
    time_entries.each do |time_entry|
      @time_entries[time_entry.spent_on] << time_entry
    end
    respond_to do |format|
      format.html
      format.js {respond_to_js}
    end
  end

  #OTHER METHODS
  def act_as
    session['act_as'].eql?('User') ? session['act_as'] = 'Admin' : session['act_as'] = 'User'
    current_user.act_as_admin(session['act_as'])
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  private
  def find_user
    @user = User.find(current_user.id)
    render_404 if @user.nil?
  end

  private
  def sort_column
    params[:sort] ? params[:sort] : 'issues.id'
  end

  def sort_direction
    params[:direction] ? params[:direction] : 'DESC'
  end

  def user_params
    params.require(:user).permit(User.permit_attributes)
  end

end
