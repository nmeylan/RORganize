# Author: Nicolas Meylan
# Date: 8 mai 2013
# Encoding: UTF-8
# File: coworkers_controller.rb

class CoworkersController < ApplicationController
  
  before_filter :check_permission, :except => [:index]
  before_filter {|c| c.top_menu_item("coworkers")}
  include ApplicationHelper

  def index
    @coworkers = Hash.new{|h,k| h[k] = []}
    current_user.members.includes(:project,:role).each do |member|
      if current_user.allowed_to?('display_activities', "Coworkers", member.project)
        @coworkers[member.project.name] = member.project.members.delete_if{|member| member.user_id.eql?(current_user.id)}
      end
    end
    respond_to do |format|
      format.html
    end
  end

  def display_activities
    if params[:getAct].eql?("true")
      @coworker = Member.find(params[:id])
      @activities = Journal.select("journals.*")
      .where(:user_id => @coworker.user_id, :project_id => @coworker.project_id)
      .includes(:details, :project, :user, :journalized)
      .order("created_at DESC")
    end

    respond_to do |format|
      format.html
      format.js{
        render :update do |page|
          page.replace "coworker_activities", :partial => "coworkers/activities"
        end
      }
    end
  end

end
