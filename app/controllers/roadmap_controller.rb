# Author: Nicolas Meylan
# Date: 2 févr. 2013
# Encoding: UTF-8
# File: roadmap_controller.rb


class RoadmapController < ApplicationController
  include RoadmapHelper
  before_filter :find_project
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }
  #GET/project/:project_id/roadmap
  def index
    @versions = @project.versions.order(:position)
    data = Version.define_roadmap(@versions, @project.id)
    respond_to do |format|
      format.html { render :action => 'index', :locals => {:versions_details => data} }
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
    @data = gantt_hash(Version.define_gantt_data(@project))
    gon.Gantt_XML = @data
  end

  def version_description
    description = Version.find(params[:id]).description
    respond_to do |format|
      format.js { respond_to_js :locals => {:description => description} }
    end
  end
end