# Author: Nicolas Meylan
# Date: 2 févr. 2013
# Encoding: UTF-8
# File: roadmaps_controller.rb

require 'roadmaps/gantt_object'
require 'roadmap/roadmap_report'
class RoadmapsController < ApplicationController
  helper VersionsHelper
  include Rorganize::RichController::GanttCallbacks
  before_filter { |c| c.add_action_alias = {'version' => 'show'} }
  before_filter :check_permission, only: [:gantt, :manage_gantt, :show, :version]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }

  #GET/project/:project_id/roadmaps
  def show
    roadmap = RoadmapReport.new(@project_decorator)
    @version_decorator = roadmap.version_decorator
    old_versions = roadmap.old_versions
    respond_to do |format|
      format.html { render :index, locals: {old_versions: old_versions} }
    end
  end

  def version
    @version_decorator = Version.eager_load(issues: [:status, :tracker]).find_by_id(params[:id])
    if @version_decorator
      @version_decorator = @version_decorator.decorate

    else
      render_404
    end
  end


  def calendar
    @versions = @project_decorator.versions.order(:position)
    calendar = Version.define_calendar(@versions, params[:date])
    @versions_hash = calendar[:versions_hash]
    @date = calendar[:date]
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end


  private
  def find_project
    @project_decorator = Project.eager_load(:versions, :attachments).where(slug: params[:project_id])[0]
    if @project_decorator
      @project_decorator = @project_decorator.decorate
      @project = @project_decorator.model
    else
      render_404
    end
  end

end