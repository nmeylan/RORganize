# Author: Nicolas Meylan
# Date: 24.08.14
# Encoding: UTF-8
# File: issue_overview_hash.rb

class IssueOverviewHash
  attr_reader :content, :attributes

  def initialize(issues)
    @issues = issues
    @issues_count = issues.to_a.size
    @content = []
    @attributes = [:assigned_to, :status, :version, :category, :tracker, :author]
    build_object(@attributes) if @issues_count > 0
  end

  def build_object(args = [])
    args.each do |attr_name| #O(4*n)
      @content << {attr_name => group_by(attr_name)}
    end
    @content = @content.sort { |x, y| x.values[0].size <=> y.values[0].size }
  end

  def group_by(attr_name)
    rows = {}
    @issues.each do |issue|
      attr = issue.send(attr_name)
      rows[attr ? attr.id : -1] ||= {caption: attr ? attr.caption : na_label(attr_name), id: attr ? attr.id : 'NULL', count: 0}
      rows[attr ? attr.id : -1][:count] += 1
    end
    rows.values.map { |row| row[:percent] = ((row[:count].to_f / @issues_count) * 100).truncate; row }
  end

  def na_label(attr_name)
    if attr_name.eql?(:assigned_to)
      'Nobody'
    elsif attr_name.eql?(:version)
      'Unplanned'
    elsif attr_name.eql?(:category)
      'No category'
    else
      'NA'
    end
  end
end