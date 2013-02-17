class ProjectManagerController < ApplicationController
  before_filter :find_project
  include ApplicationHelper
  def index
    @changelogs = Changelog.find_all_by_project_id(@project_m, :include => [:version, :enumeration])
    respond_to do |format|
      format.html
    end
  end

  def about
    respond_to do |format|
      format.html
    end
  end

  private
  def find_project
    @project_m = Project.find_by_identifier('RORganize')
    render_404 if @project_m.nil?
  end
end
