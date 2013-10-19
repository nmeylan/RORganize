# Author: Nicolas Meylan
# Date: 2 févr. 2013
# Encoding: UTF-8
# File: roadmap_controller.rb


class RoadmapController < ApplicationController
  include RoadmapHelper
  before_filter :find_project
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter {|c| c.top_menu_item('projects')}
  #GET/project/:project_id/roadmap
  def index
    @versions = @project.versions.sort{|x,y| y.position <=> x.position}
    data = set_roadmap_content(@versions)

    respond_to do |format|
      format.html {render :action => 'index', :locals => {:versions_details => data}}
    end
  end


  def set_roadmap_content(versions)
    data = {}
    #related requests for each versions
    data['related_requests'] = Hash.new{|h,k| h[k] = []}
    #Request statement for each versions
    data['request_statements'] = Hash.new{|h, k| h[k] = []}
    #Request done percent
    data['request_done_percent'] = {}
    tmp_issues_ary = []
    tmp_closed_status = 0
    tmp_opened_status = 0
    tmp_done = 0
    versions.each do |version|
      version.issues.includes(:status, :tracker).each do |issue|
        #add issue
        tmp_issues_ary << issue
        issue.status.is_closed ? tmp_closed_status += 1 : tmp_opened_status += 1
        tmp_done += issue.done
      end
      data['related_requests'][version.id] = tmp_issues_ary
      data['request_statements'][version.id] = [tmp_closed_status, tmp_opened_status]
      if data['related_requests'][version.id].count != 0
        data['request_done_percent'][version.id] = (tmp_done / data['related_requests'][version.id].count).round
      else
        data['request_done_percent'][version.id] = 0
      end
      tmp_issues_ary = []
      tmp_closed_status = 0
      tmp_opened_status = 0
      tmp_done = 0
    end
    unplanned_issues = Issue.where(:version_id => nil, :project_id => @project.id).includes([:status, :tracker])
    unless unplanned_issues.empty?
      @versions << Version.new(:name => 'Unplanned')
      data['related_requests'][nil] = unplanned_issues
      data['related_requests'][nil].each {|issue| issue.status.is_closed ? tmp_closed_status += 1 : tmp_opened_status += 1
        tmp_done += issue.done}
      data['request_statements'][nil] = [tmp_closed_status, tmp_opened_status]
      data['request_done_percent'][nil] = (tmp_done / data['related_requests'][nil].count).round
    end
    return data
  end

  def calendar
    @versions = @project.versions.sort{|x,y| y.position <=> x.position}
    if params[:date]
      @date = params[:date].to_date
    else
      @date = Date.today
    end

    @versions_hash = {}
    @versions.each do |version|
      unless version.target_date.nil?
        @versions_hash[version.target_date.to_formatted_s(:db)] = version
      end
    end
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace_html 'calendar', :partial => 'roadmap/calendar'
        end
      end
    end
  end

  def gantt
    @data = Hash.new{|h,k| h[k] = []}
    versions = @project.versions
    versions.each do |version|
      @data[version] = version.issues.includes(:parent,:children)
    end
    @data = gantt_hash(@data)
  end

  def version_description
    description = Version.find(params[:id]).description
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace 'tooltip_content', :partial => 'roadmap/tooltip', :locals => {:description => description}
        end
      end
    end
  end
end