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
  helper QueriesHelper
  include Rorganize::ModuleManager::ModuleManagerHelper
  #GET project/:project_identifier/settings/
  def index
    @tracker_ids = @project.trackers.collect{|tracker| tracker.id}
    if @project.attachments.empty?
      @project.attachments.build
    end
    @project = @project.decorate
    @trackers = Tracker.all
    respond_to do |format|
      format.html
    end
  end

  #POST project/:project_identifier/settings/
  #POST project/:project_identifier/settings/
  def update
   @project.update_info(project_params, params[:trackers])
    respond_to do |format|
      flash[:notice] = t(:successful_update)
      format.html { redirect_to :controller => 'settings', :action => 'index', :project_id => @project.slug }
    end
  end

  def public_queries
    @queries = Query.public_queries(@project.id).decorate
    respond_to do |format|
      format.html
    end
  end

  def delete_attachment
    attachment = Attachment.find(params[:id])
    @project.attachments.delete_if{|attach| attach.id == attachment.id}
    if attachment.destroy
      @project.attachments.build
      respond_to do |format|
        format.html { redirect_to :action => 'index', :controller => 'settings'}
        format.js {respond_to_js :response_header => :success, :response_content => t(:successful_deletion)}
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
    unless current_user.allowed_to?('index', 'Queries', @project)
      render_403
    end
  end

  def project_params
    params.require(:project).permit(Project.permit_attributes)
  end

end