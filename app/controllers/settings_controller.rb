# Author: Nicolas Meylan
# Date: 13 août 2012
# Encoding: UTF-8
# File: settings_controller.rb

class SettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_project
  before_filter :check_queries_permission, :only => [:public_queries]
  before_filter :check_permission, :except => [:public_queries]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  include ApplicationHelper
  #GET project/:project_identifier/settings/
  def index
    @tracker_ids = @project.trackers.collect{|tracker| tracker.id}
    @trackers = Tracker.all
    respond_to do |format|
      format.html
    end
  end

  #POST project/:project_identifier/settings/
  #POST project/:project_identifier/settings/
  def update
    @project.update_attributes(:name => params[:project][:name], :description => params[:project][:description], :identifier => params[:project][:identifier])
    tracker_ids = params[:trackers].values
    trackers = Tracker.find_all_by_id(tracker_ids)
    @project.trackers.clear
    tracker_ids.each do |id|
      tracker = trackers.select{|track| track.id == id.to_i }
      @project.trackers << tracker
    end
    respond_to do |format|
      flash[:notice] = t(:successful_update)
      format.html { redirect_to :controller => 'settings', :action => 'index', :project_id => @project.identifier }
    end
  end

  def public_queries
    @queries = Query.find(:all,
      :conditions => ["project_id = ? AND is_public = ? AND is_for_all = ?", @project.id, true, false])
    respond_to do |format|
      format.html
    end
  end
  #Private methods
  private
 
  def check_queries_permission
    unless current_user.allowed_to?(params[:action], 'Queries', @project)
      render_403
    end
  end

end