# Author: Nicolas Meylan
# Date: 2 févr. 2013
# Encoding: UTF-8
# File: roadmaps_controller.rb

require 'roadmaps/gantt_object'
class RoadmapsController < ApplicationController
  helper VersionsHelper
  include RoadmapsHelper
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }
  #GET/project/:project_id/roadmaps
  def show
    @versions = Version.where(project_id: @project.id).order(:position).decorate
    @versions.to_a << Version.new(name: 'Unplanned').decorate
    respond_to do |format|
      format.html { render :action => 'index'}
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
  @gantt_object = GanttObject.new(@project.versions.eager_load(issues: [:parent, :children, :tracker, :assigned_to, :status]), @project)
    gon.Gantt_JSON = @gantt_object.json_data
  end

  private
  def find_project
    @project = Project.eager_load(:versions, :attachments).where(slug: params[:project_id])[0].decorate
  end

end