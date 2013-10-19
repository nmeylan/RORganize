# Author: Nicolas Meylan
# Date: 13 août 2012
# Encoding: UTF-8
# File: settings_controller.rb

class SettingsController < ApplicationController
  before_filter :find_project
  before_filter :check_queries_permission, :only => [:public_queries]
  before_filter :check_permission, :except => [:public_queries, :delete_attachment, :update]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter {|c| c.top_menu_item('projects')}
  include ApplicationHelper
  include Rorganize::ModuleManager::ModuleManagerHelper
  #GET project/:project_identifier/settings/
  def index
    @tracker_ids = @project.trackers.collect{|tracker| tracker.id}
    if @project.attachments.empty?
      @project.attachments.build
    end
    @trackers = Tracker.all
    respond_to do |format|
      format.html
    end
  end

  #POST project/:project_identifier/settings/
  #POST project/:project_identifier/settings/
  def update
    @project.update_attributes(params[:project])

    tracker_ids = params[:trackers].values
    trackers = Tracker.where(:id => tracker_ids)
    @project.trackers.clear
    tracker_ids.each do |id|
      tracker = trackers.select{|track| track.id == id.to_i }
      @project.trackers << tracker
    end
    respond_to do |format|
      flash[:notice] = t(:successful_update)
      format.html { redirect_to :controller => 'settings', :action => 'index', :project_id => @project.slug }
    end
  end

  def public_queries
    @queries = Query.find(:all,
      :conditions => ['project_id = ? AND is_public = ? AND is_for_all = ?', @project.id, true, false])
    respond_to do |format|
      format.html
    end
  end

  def delete_attachment
    attachment = Attachment.find(params[:attachment_id])
    @project.attachments.delete_if{|attach| attach.id == attachment.id}
    if attachment.destroy
      @project.attachments.build
      respond_to do |format|
        format.html { redirect_to :action => 'index', :controller => 'settings'
        }
        format.js do
          render :update do |page|
            page.replace_html('attachments', :partial => 'project/show_attachments', :locals => {:attachments => @project.attachments})
            response.headers['flash-message'] = t(:successful_deletion)
          end
        end
      end
    end
  end

  def modules
    if request.post?
      @project.enabled_modules.clear
      params['modules']['name'].each do |mod|
        ary = mod.split('_')
        m = EnabledModule.new(:controller => ary[0], :action => ary[1], :name => ary[2])
        @project.enabled_modules << m
      end
      @project.save
      reload_enabled_module(@project.id)
    end
    @modules = Rorganize::ModuleManager.modules(:project).module_items
    @checked_modules = @project.enabled_modules.collect{|mod| mod.name}
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