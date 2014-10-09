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
    @version = Version.new(version_params)
    @version.project_id = @project.id
    respond_to do |format|
      if @version.save
        @project.versions << @version
        @project.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to versions_path }
        format.json { render :json => @version,
                             :status => :created, :location => @version }
      else
        format.html { render :new }
        format.json { render :json => @version.errors,
                             :status => :unprocessable_entity }
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
        format.html { redirect_to versions_path }
        format.json { render :json => @version,
                             :status => :created, :location => @version }
      elsif @version.changed? && @version.save
        flash[:notice] = t(:successful_update)
        format.html { redirect_to versions_path}
        format.json { render :json => @version,
                             :status => :created, :location => @version }
      else
        format.html { render :edit }
        format.json { render :json => @version.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @versions_decorator = @project.versions.decorate(context: {project: @project})
    success = @version.destroy
    respond_to do |format|
      format.js { respond_to_js :response_header => success ? :success : :failure,
                                :response_content => success ? t(:successful_deletion) : t(:failure_deletion),
                                :locals => {:id => params[:id]} }
    end
  end

  def show

  end

  def change_position
    saved = @version.change_position(@project, params[:operator])
    @versions_decorator = @project.versions.paginated(@sessions[:current_page], @sessions[:per_page], 'versions.position').decorate(context: {project: @project})
    respond_to do |format|
      if saved
        format.js { respond_to_js :response_header => :success, :response_content => t(:successful_update) }
      else
        format.js { respond_to_js :response_header => :failure, :response_content => t(:text_negative_position) }
      end
    end
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
