# Author: Nicolas Meylan
# Date: 2 févr. 2013
# Encoding: UTF-8
# File: roadmaps_controller.rb

require 'roadmaps/gantt_object'
require 'roadmap/roadmap_report'
class RoadmapsController < ApplicationController
  helper VersionsHelper
  include Rorganize::RichController::GanttCallbacks

  before_action { |c| c.add_action_alias = {'version' => 'show'} }
  before_action :check_permission, only: [:gantt, :manage_gantt, :show, :version]
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item(params[:controller]) }
  before_action { |c| c.top_menu_item('projects') }

  #GET/project/:project_id/roadmaps
  def show
    roadmap = RoadmapReport.new(@project_decorator)
    @versions_decorator = roadmap.versions_decorator
    old_versions = roadmap.old_versions
    respond_to do |format|
      format.html { render :index, locals: {old_versions: old_versions} }
    end
  end

  def version
    @version_decorator = Version.eager_load(issues: [:status, :tracker]).find_by!(id: params[:id], project_id: @project.id).decorate
  end

  private
  def find_project
    @project = Project.eager_load(:versions, :attachments).find_by!(slug: params[:project_id])
    @project_decorator = @project.decorate
  end
end