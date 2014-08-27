# Author: Nicolas Meylan
# Date: 2 févr. 2013
# Encoding: UTF-8
# File: roadmaps_controller.rb

require 'roadmaps/gantt_object'
class RoadmapsController < ApplicationController
  helper VersionsHelper
  include RoadmapsHelper
  before_filter :check_permission, only: [:gantt, :show]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }

  #GET/project/:project_id/roadmaps
  def show
    @versions = Version.where(project_id: @project.id).order(:position).decorate
    @versions.to_a << Version.new(name: 'Unplanned').decorate
    respond_to do |format|
      format.html { render :action => 'index' }
    end
  end


  def calendar
    @versions = @project.versions.order(:position)
    calendar = Version.define_calendar(@versions, params[:date])
    @versions_hash = calendar[:versions_hash]
    @date = calendar[:date]
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  def gantt
    @sessions[:gantt] ||= {}
    @sessions[:gantt][:edition] ||= false
    if params[:value]
      @sessions[:gantt][:versions] = params[:value]
    end
    versions = @sessions[:gantt][:versions] ? Version.eager_load(issues: [:parent, :children, :tracker, :assigned_to, :status]).where(id: @sessions[:gantt][:versions]) : @project.versions.eager_load(issues: [:parent, :children, :tracker, :assigned_to, :status]).to_a.select { |version| !version.is_done }
    if params[:mode]
      @sessions[:gantt][:edition] = params[:mode].eql?('edition')
    end
    @gantt_object = GanttObject.new(versions, @project, @sessions[:gantt][:edition])
    gon.Gantt_JSON = @gantt_object.json_data
    respond_to do |format|
      format.html { render action: 'gantt', locals: {versions: @project.versions, selected_versions: versions} }
      format.js { respond_to_js action: 'gantt', locals: {json_data: @gantt_object.json_data} }
    end
  end

  def manage_gantt
    if request.post?
    else
      if params[:mode] && params[:mode].eql?('edition')
        @sessions[:gantt][:edition] = true
        versions = @sessions[:gantt][:versions] ? Version.eager_load(issues: [:parent, :children, :tracker, :assigned_to, :status]).where(id: @sessions[:gantt][:versions]) : @project.versions.eager_load(issues: [:parent, :children, :tracker, :assigned_to, :status]).to_a.select { |version| !version.is_done }
        @gantt_object = GanttObject.new(versions, @project, @sessions[:gantt][:edition])
        respond_to do |format|
          format.js { respond_to_js action: 'gantt', locals: {json_data: @gantt_object.json_data} }
        end
      else
        gantt
      end

    end
  end

  private
  def find_project
    @project = Project.eager_load(:versions, :attachments).where(slug: params[:project_id])[0].decorate
  end

end