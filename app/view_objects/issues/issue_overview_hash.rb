# Author: Nicolas Meylan
# Date: 24.08.14
# Encoding: UTF-8
# File: issue_overview_hash.rb

class IssueOverviewHash
  attr_reader :content, :attributes
  # @param [Hash] reports an array of selected_data. Structure : {attr_name : [[attr.id, attr.name, count(issues), project.slug]]}
  def initialize(reports, issues_count, group_by_project = false)
    @reports = reports
    @issues_count = issues_count
    @group_by_project = group_by_project
    @content = []
    build_object
  end

  def build_object
    @reports.each do |report_name, report|
      @content << {report_name => group_by(report_name, report)}
    end
    @content = @content.sort { |x, y| x.values[0].size <=> y.values[0].size }
  end

  def group_by(report_name, report)
    rows = {}
    report.each do |row|
      if @group_by_project
        id = row[1]
        rows[id] =  {caption: row[2] ? row[2] : na_label(report_name), id: row[0], count: row[3], project: row[4]}
      else
        id = row[0] ? row[0] : -1
        rows[id] =  {caption: row[1] ? row[1] : na_label(report_name), id: !id.eql?(-1) ? id : 'NULL', count: row[2], project: row[3]}
      end

    end
    rows.values.map { |row| row[:percent] = ((row[:count].to_f / @issues_count) * 100).truncate; row }
  end

  def na_label(report_name)
    if report_name.eql?(:assigned_to)
      'Nobody'
    elsif report_name.eql?(:version)
      'Unplanned'
    elsif report_name.eql?(:category)
      'No category'
    else
      'NA'
    end
  end
end