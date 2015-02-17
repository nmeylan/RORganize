# Author: Nicolas Meylan
# Date: 13 août 2012
# Encoding: UTF-8
# File: settings_controller.rb

class SettingsController < ApplicationController
  helper QueriesHelper
  helper TrackersHelper
  include Rorganize::Managers::ModuleManager::ModuleManagerHelper
  include Rorganize::RichController

  before_action { |c| c.add_action_alias= {'update' => 'update_project_informations'} }

  before_action :set_pagination, only: [:public_queries]
  before_action :check_queries_permission, only: [:public_queries]
  before_action :check_permission, except: [:public_queries, :delete_attachment]
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item(params[:controller]) }
  before_action { |c| c.top_menu_item('projects') }

  #GET project/:project_identifier/settings/
  def index
    load_form_data
    respond_to do |format|
      format.html
    end
  end

  #POST project/:project_identifier/settings/
  def update
    @project.update_info(project_params, params[:trackers])
    respond_to do |format|
      if @project.errors.messages.empty?
        success_generic_update_callback(format, settings_path(@project.slug), true)
      else
        @project.reload
        load_form_data
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def public_queries
    @queries_decorator = Query.public_queries(@project.id).eager_load(:user)
                             .paginated(@sessions[:current_page], @sessions[:per_page], order('queries.name'))
                             .decorate(context: {queries_url: public_queries_settings_path(@project.slug), action_name: 'public_queries'})
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  def delete_attachment
    attachment = Attachment.find_by!(id: params[:id], attachable_id: @project.id, attachable_type: 'Project')
    if attachment.destroy
      @project.attachments.clear
      @project.attachments.build
      @project_decorator = @project.decorate
      respond_to do |format|
        format.js { respond_to_js response_header: :success, response_content: t(:successful_deletion) }
      end
    end
  end

  def modules
    if request.post?
      @project.enable_modules(params['modules']['name'])
    end
    always_enabled = Rorganize::Managers::ModuleManager.always_enabled_module
    @modules = Rorganize::Managers::ModuleManager.panel(:project).modules.delete_if do |mod|
      always_enabled.any? { |modules| modules[:controller].eql?(mod.controller) && modules[:action].eql?(mod.action) }
    end
    enabled_modules = @project.enabled_modules.collect { |mod| mod.name }
    respond_to do |format|
      format.html { render :modules, locals: {enabled_modules: enabled_modules} }
    end
  end

  #Private methods
  private

  def check_queries_permission
    unless User.current.allowed_to?('index', 'Queries', @project)
      render_403
    end
  end

  def project_params
    params.require(:project).permit(Project.permit_attributes)
  end

  def load_form_data
    tracker_ids = @project.trackers.collect { |tracker| tracker.id }
    if @project.attachments.empty?
      @project.attachments.build
    end
    @project_decorator = @project.decorate
    @trackers_decorator = Tracker.all.decorate(context: {checked_ids: tracker_ids})
  end
end