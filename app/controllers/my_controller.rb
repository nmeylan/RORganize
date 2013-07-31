# Author: Nicolas Meylan
# Date: 10 oct. 2012
# Encoding: UTF-8
# File: my_controller.rb

class MyController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user
  include ApplicationHelper
  def show
    @issues = Issue.where(:assigned_to_id => @user.id).includes([:tracker,:version,:assigned_to,:category, :status => [:enumeration]]).limit(5).order('id DESC')
    respond_to do |format|
      format.html
    end
  end

  def change_password
    if request.post?
      if params[:user][:password].eql?(params[:user][:retype_password]) && @user.update_attributes(params[:user])

        respond_to do |format|
          flash[:notice] = t(:successful_creation)
          format.html {redirect_to :action => "show", :id => @user.slug}
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
    @queries = Query.where(["author_id = ? AND is_public = ?", current_user.id, false])
    respond_to do |format|
      format.html {}
    end
  end

  def my_projects
    @members= current_user.members.includes(:project => [:attachments])
    respond_to do |format|
      format.html
    end
  end

  def star_project
    @members= current_user.members
    @member = @members.select{|member| member.project_id.eql?(params[:star_project_id].to_i)}.first
    @member.is_project_starred = !@member.is_project_starred
    @member.save
    respond_to do |format|
      format.js{
        render :update do |page|
          page.replace 'projects', :partial => 'projects/list', :locals => {:allow_to_star => true}
        end}
    end
  end

  def save_project_position
    @members= current_user.members
    project_ids = params[:ids]
    @members.each do |member|
      member.project_position = project_ids.index(member.project_id.to_s)
      member.save
    end
    respond_to do |format|
      format.js{
        render :update do |page|
          page.replace 'projects', :partial => 'projects/list', :locals => {:allow_to_star => true}
        end}
    end
  end

  #OTHER METHODS
  def act_as
    session["act_as"].eql?("User") ? session["act_as"] = "Admin" : session["act_as"] = "User"
    current_user.act_as_admin(session["act_as"])
    respond_to do |format|
      format.html {redirect_to :back}
    end
  end
  private
  def find_user
    @user = User.find(params[:id])
    render_404 if @user.nil?
  end

  def sort_column
    params[:sort] ? session['controller_issues_sort'] = params[:sort] : session['controller_issues_sort'] = (session['controller_issues_sort'] ? session['controller_issues_sort'] : 'id')
    session['controller_issues_sort']
  end

  def sort_direction
    params[:direction] ? session['controller_issues_direction'] = params[:direction] : session['controller_issues_direction'] = (session['controller_issues_direction'] ? session['controller_issues_direction'] : 'desc')
    session['controller_issues_direction']
  end

end
