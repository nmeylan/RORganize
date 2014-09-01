# Author: Nicolas Meylan
# Date: 26.08.14
# Encoding: UTF-8
# File: gantt_object.rb

class GanttObject
  include ActionView::Helpers
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers
  require 'json'

  DATE_FORMAT = '%d-%m-%Y'
  DATE_FORMAT_STR = '%-d %b.'
  attr_reader :json_data

  def initialize(versions, project, edition = false)
    @versions = versions
    @project = project
    @edition = edition
    @versions_hash = build_version_hash
    @json_data = build_json
  end

  def build_version_hash
    data = Hash.new { |h, k| h[k] = [] }
    @versions.each do |version|
      data[version] = version.issues
    end
    data
  end

  def build_json
    output_hash = {data: [], links: []}
    @versions_hash.each do |version, issues|
      duration = version.target_date ? (version.target_date - version.start_date) : (Date.today - version.start_date)
      if duration > 0
        output_hash[:data] << build_version_output(version, duration)
        issues.each do |issue|
          if issue.start_date && issue.due_date && issue.due_date >= issue.start_date
            output_hash[:data] << build_issue_output(issue, version, true)
          elsif @edition
            output_hash[:data] << build_issue_output(issue, version, false)
          end
          output_hash[:links] << build_link(issue) unless issue.predecessor_id.nil?
        end
      end
    end
    output_hash.to_json
  end

  def build_version_output(version, duration)
    {
        id: "version_#{version.id}",
        start_date: version.start_date.strftime(DATE_FORMAT),
        text: version.caption,
        parent: 0,
        open: true,
        duration: duration.to_i,
        context: {
            type: 'version',
            due_date: version.target_date,
            due_date_str: version.target_date ? version.target_date.strftime(DATE_FORMAT_STR) : '',
            start_date_str: version.start_date.strftime(DATE_FORMAT_STR)
        }
    }
  end

  def build_issue_output(issue, version, are_data_provided)
    start_date = issue.start_date ? issue.start_date : version.start_date
    due_date = issue.due_date ? issue.due_date : (version.target_date ? version.target_date : Date.today)
    {
        id: issue.id,
        start_date: start_date.strftime(DATE_FORMAT),
        text: issue.tracker.caption + ' #'+ issue.id.to_s,
        parent: "version_#{issue.version_id}",
        open: true,
        progress: issue.done / 100.0,
        duration: (due_date - start_date).to_i,
        context: {
            type: 'issue',
            link: link_to(issue.tracker.caption + ' #'+ issue.id.to_s, issue_path(@project, issue.id)),
            due_date: due_date,
            assigne: issue.assigned_to ? issue.assigned_to.caption : nil,
            due_date_str: due_date.strftime(DATE_FORMAT_STR),
            start_date_str: start_date.strftime(DATE_FORMAT_STR),
            are_data_provided: are_data_provided
        }
    }
  end

  def build_link(issue)
    {
        id: "#{issue.predecessor_id}_#{issue.id}",
        source: issue.predecessor_id,
        target: issue.id,
        type: 0
    }
  end
end