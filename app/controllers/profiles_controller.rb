# Author: Nicolas Meylan
# Date: 10 oct. 2012
# Encoding: UTF-8
# File: profiles_controller.rb

class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user
  helper_method :sort_column, :sort_direction
  helper ProjectsHelper
  helper IssuesHelper
  helper QueriesHelper

  def show
    order = sort_column + ' ' + sort_direction
    #Load favorites projects
    projects = @user.owned_projects('starred').decorate(context: {allow_to_star: false})
    #Load latest assigned requests
    issues = @user.latest_assigned_issues(order, 5).decorate
    #Load latest activities
    activities =  @user.latest_activities(5)
    respond_to do |format|
      format.html { render :action => 'show', :locals => {issues: issues, activities: activities, projects: projects} }
    end
  end

  def assigned_requests
    order = sort_column + ' ' + sort_direction
    issues = Issue.user_assigned_issues(@user, order).decorate
    respond_to do |format|
      format.html { render :action => 'assigned_requests', :locals => {:issues => issues} }
    end
  end

  def activities

  end

  def submitted_requests
    order = sort_column + ' ' + sort_direction
    issues = Issue.user_submitted_issues(@user, order).decorate
    respond_to do |format|
      format.html { render :action => 'submitted_requests', :locals => {:issues => issues} }
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
    @queries = Query.where(['author_id = ? AND is_public = ?', @user.id, false]).decorate
    respond_to do |format|
      format.html {}
    end
  end

  def projects
    @projects = @user.owned_projects(nil).decorate(context: {allow_to_star: true})
    respond_to do |format|
      format.html { render :action => 'projects' }
    end
  end

  def star_project
    members= @user.members
    member = members.select { |member| member.project_id.eql?(params[:project_id].to_i) }.first
    member.is_project_starred = !member.is_project_starred
    member.save
    message = "#{t(:text_project)} #{member.project.name} #{member.is_project_starred ? t(:successful_starred) : t(:successful_unstarred )}"
    respond_to do |format|
      format.js {respond_to_js :response_header => :success, :response_content => message, :locals => {id: params[:project_id], is_starred: member.is_project_starred}}
    end
  end

  def save_project_position
    members= @user.members
    project_ids = params[:ids]
    members.each do |member|
      member.project_position = project_ids.index(member.project_id.to_s)
      member.save
    end
    respond_to do |format|
      format.js {respond_to_js :action => 'do_nothing', :response_header => :success, :response_content => t(:successful_update)}
    end
  end

  def spent_time
    if params[:date]
      @date = params[:date].to_date
    else
      @date = Date.today
    end
    time_entries = @user.time_entries_for_month(@date.year, @date.month)
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
    @user.act_as_admin(session['act_as'])
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
