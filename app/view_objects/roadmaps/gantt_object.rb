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
  attr_reader :json_data, :versions

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
      duration = version_duration(version)
      build_version_json(duration, issues, output_hash, version) if duration > 0
    end
    output_hash.to_json
  end

  def build_version_json(duration, issues, output_hash, version)
    output_hash[:data] << build_version_output(version, duration)
    issues_start_date = issues.select { |issue| issue.start_date }
    issues_no_start_date = issues.select { |issue| issue.start_date.nil? }
    build_issue_json(output_hash, issues_start_date, version)
    build_issue_json(output_hash, issues_no_start_date, version)
  end

  def version_duration(version)
    version.target_date ? (version.target_date - version.start_date) : (Date.today - version.start_date)
  end

  # @param [Version] version
  # @param [Hash] output_hash
  # @param [Array] issues.
  def build_issue_json(output_hash, issues, version)
    issues.sort_by(&:start_date).each do |issue|
      if issue_due_date_gte_start_date?(issue)
        output_hash[:data] << build_issue_output(issue, version, true)
      elsif @edition
        output_hash[:data] << build_issue_output(issue, version, false)
      end
      output_hash[:links] << build_link(issue) unless issue.predecessor_id.nil?
    end
  end

  def issue_due_date_gte_start_date?(issue)
    issue.start_date && issue.due_date && issue.due_date >= issue.start_date
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
            start_date: version.start_date,
            due_date_str: version.target_date ? version.target_date.strftime(DATE_FORMAT_STR) : '',
            start_date_str: version.start_date.strftime(DATE_FORMAT_STR)
        }
    }
  end

  def build_issue_output(issue, version, are_data_provided)
    start_date = issue_start_date(issue, version)
    due_date = issue_due_date(issue, version)
    caption = issue_caption(issue)
    {
        id: issue.sequence_id,
        start_date: start_date.strftime(DATE_FORMAT),
        text: caption,
        parent: "version_#{issue.version_id}",
        open: true,
        progress: issue.done / 100.0,
        duration: (due_date - start_date).to_i,
        context: {
            type: 'issue',
            link: link_to(caption, issue_path(@project, issue)),
            due_date: due_date,
            start_date: start_date,
            assigne: issue.assigned_to ? issue.assigned_to.caption : nil,
            due_date_str: due_date.strftime(DATE_FORMAT_STR),
            start_date_str: start_date.strftime(DATE_FORMAT_STR),
            are_data_provided: are_data_provided
        }
    }
  end

  def issue_start_date(issue, version)
    issue.start_date ? issue.start_date : version.start_date
  end

  def issue_caption(issue)
    issue.caption.length > 40 ? "#{issue.caption[0..40]}..." : issue.caption
  end

  def issue_due_date(issue, version)
    if issue.due_date
      issue.due_date
    else
      version.target_date ? version.target_date : Date.today
    end
  end

  def build_link(issue)
    predecessor_sequence_id = issue.predecessor ? issue.predecessor.sequence_id : nil
    {
        id: "#{predecessor_sequence_id}_#{issue.sequence_id}",
        source: predecessor_sequence_id,
        target: issue.sequence_id,
        type: issue.link_type
    }
  end
end