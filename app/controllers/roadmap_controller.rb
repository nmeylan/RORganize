# Author: Nicolas Meylan
# Date: 2 févr. 2013
# Encoding: UTF-8
# File: roadmap_controller.rb


class RoadmapController < ApplicationController
  include RoadmapHelper
  before_filter :authenticate_user!
  before_filter :find_project
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  #GET/project/:project_id/roadmap
  def index
    @versions = @project.versions.sort{|x,y| y.position <=> x.position}


    set_roadmap_content(@versions)

    respond_to do |format|
      format.html
    end
  end


  def set_roadmap_content(versions)
    #related requests for each versions
    @related_requests = Hash.new{|h,k| h[k] = []}
    #Request statement for each versions
    @request_statements = Hash.new{|h, k| h[k] = []}
    #Request done percent
    @request_done_percent = {}
    tmp_issues_ary = []
    tmp_closed_status = 0
    tmp_opened_status = 0
    tmp_done = 0
    versions.each do |version|
      version.issues.each do |issue|
        #add issue
        tmp_issues_ary << issue
        issue.status.is_closed ? tmp_closed_status += 1 : tmp_opened_status += 1
        tmp_done += issue.done
      end
      @related_requests[version.id] = tmp_issues_ary
      @request_statements[version.id] = [tmp_closed_status, tmp_opened_status]
      if @related_requests[version.id].count != 0
        @request_done_percent[version.id] = (tmp_done / @related_requests[version.id].count).round
      else
        @request_done_percent[version.id] = 0
      end
      tmp_issues_ary = []
      tmp_closed_status = 0
      tmp_opened_status = 0
      tmp_done = 0
    end
    unplanned_issues = Issue.find_all_by_version_id_and_project_id(nil, @project.id, :include =>[:status, :tracker])
    unless unplanned_issues.empty?
    @versions << Version.new(:name => "Unplanned")
    @related_requests[nil] = unplanned_issues
    @related_requests[nil].each {|issue| issue.status.is_closed ? tmp_closed_status += 1 : tmp_opened_status += 1
      tmp_done += issue.done}
    @request_statements[nil] = [tmp_closed_status, tmp_opened_status]
    @request_done_percent[nil] = (tmp_done / @related_requests[nil].count).round
    end
  end
end