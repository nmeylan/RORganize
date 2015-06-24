# Author: Nicolas Meylan
# Date: 16 août 2012
# Encoding: UTF-8
# File: versions_controller.rb

class VersionsController < ApplicationController
  include RichController
  before_action :find_version, only: [:edit, :update, :destroy, :change_position]
  before_action :check_permission
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item('settings') }
  before_action { |c| c.top_menu_item('projects') }

  def index
    @versions_decorator = @project.versions.paginated(@sessions[:current_page], @sessions[:per_page], 'versions.position').decorate(context: {project: @project})
    if request.xhr?
      render json: {list: @versions_decorator.display_collection}
    else
      render :index
    end
  end

  def new
    @version = Version.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @version = @project.versions.build(version_params)
    generic_create_callback(@version, project_versions_path)
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @version.attributes= version_params
    generic_update_callback(@version, project_versions_path)
  end

  def destroy
    simple_js_callback(@version.destroy, :delete, @version, id: params[:id])
  end

  def change_position
    saved = @version.change_position(params[:operator])
    @versions_decorator = @project.versions.paginated(@sessions[:current_page], @sessions[:per_page], 'versions.position').decorate(context: {project: @project})
    simple_js_callback(saved, :update, @version, list: @versions_decorator.display_collection)
  end


  private
  def version_params
    params.require(:version).permit(Version.permit_attributes)
  end

  def find_version
    @version = @project.versions.find(params[:id])
    @version_decorator = @version.decorate(context: {project: @project})
  end


end
