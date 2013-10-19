# Author: Nicolas Meylan
# Date: 10 oct. 2012
# Encoding: UTF-8
# File: my_controller.rb

class MyController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user
  helper_method :sort_column, :sort_direction
  include ApplicationHelper

  def show
    order = sort_column + ' ' + sort_direction
    #Load favorites projects
    projects = current_user.starred_projects
    #Load latest assigned requests
    issues = Issue.select('issues.*')
    .where('issues.id IN (?)', Issue.select('issues.id').where('assigned_to_id = ?', current_user.id).limit(5).order('issues.id DESC'))
    .includes(:tracker, :project, :status => [:enumeration])
    .order(order)
    #Load latest activities
    activities = Journal.select('journals.*').where(:user_id => current_user.id).includes(:details, :project, :user, :journalized).limit(5).order('created_at DESC')
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
      if params[:user][:password].eql?(params[:user][:retype_password]) && @user.update_attributes(params[:user])

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
    member = members.select { |member| member.project_id.eql?(params[:star_project_id].to_i) }.first
    member.is_project_starred = !member.is_project_starred
    member.save
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace 'projects', :partial => 'projects/list', :locals => {:allow_to_star => true, :projects => current_user.projects}
          response.headers['flash-message'] = t(:successful_update)
        end }
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
      format.js {
        render :update do |page|
          page.replace 'projects', :partial => 'projects/list', :locals => {:allow_to_star => true, :projects => current_user.projects}
          response.headers['flash-message'] = t(:successful_update)
        end }
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
      format.js do
        render :update do |page|
          page.replace_html 'calendar', :partial => 'my/calendar'
        end
      end
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

end
