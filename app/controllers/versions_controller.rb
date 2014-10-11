# Author: Nicolas Meylan
# Date: 16 août 2012
# Encoding: UTF-8
# File: versions_controller.rb

class VersionsController < ApplicationController
  include Rorganize::RichController
  before_filter :find_version, only: [:show, :edit, :update, :destroy, :change_position]
  before_filter :check_permission
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('settings') }
  before_filter { |c| c.top_menu_item('projects') }

  def index
    @versions_decorator = @project.versions.paginated(@sessions[:current_page], @sessions[:per_page], 'versions.position').decorate(context: {project: @project})
    respond_to do |format|
      format.html
      format.js { respond_to_js }
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
    respond_to do |format|
      if @version.save
        success_generic_create_callback(format, versions_path)
      else
        error_generic_create_callback(format, @user)
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @version.attributes= version_params
    respond_to do |format|
      if !@version.changed?
        success_generic_update_callback(format, versions_path, false)
      elsif @version.changed? && @version.save
        success_generic_update_callback(format, versions_path)
      else
        error_generic_update_callback(format, @version)
      end
    end
  end

  def destroy
    @versions_decorator = @project.versions.decorate(context: {project: @project})
    success = @version.destroy
    respond_to do |format|
      format.js { respond_to_js response_header: success ? :success : :failure,
                                response_content: success ? t(:successful_deletion) : t(:failure_deletion),
                                locals: {id: params[:id]} }
    end
  end

  def show

  end

  def change_position
    saved = @version.change_position(@project, params[:operator])
    @versions_decorator = @project.versions.paginated(@sessions[:current_page], @sessions[:per_page], 'versions.position').decorate(context: {project: @project})
    generic_repond_js(saved)
  end



  private
  def version_params
    params.require(:version).permit(Version.permit_attributes)
  end

  def find_version
    @version = Version.find_by_id(params[:id])
    if @version
      @version_decorator = @version.decorate(context: {project: @project})
    else
      render_404
    end
  end


end
