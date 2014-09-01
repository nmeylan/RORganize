# Author: Nicolas Meylan
# Date: 24.08.14
# Encoding: UTF-8
# File: issue_overview_hash.rb

class IssueOverviewHash
  attr_reader :content, :attributes

  def initialize(issues, attributes)
    @issues = issues
    @issues_count = issues.to_a.size
    @content = []
    @attributes = attributes
    build_object(@attributes) if @issues_count > 0
  end

  def build_object(args = [])
    if args.is_a? Array
      args.each do |attr_name| #O(4*n)
        @content << {attr_name => group_by(attr_name)}
      end
    elsif args.is_a? Hash
      args.each do |attr_name, _alias| #O(4*n)
        @content << {_alias => group_by(attr_name, _alias)}
      end
    end
    @content = @content.sort { |x, y| x.values[0].size <=> y.values[0].size }
  end

  def group_by(attr_name, _alias = nil)
    rows = {}
    @issues.each do |issue|

      if attr_name.eql?(:project) && _alias
        attr = issue.send(_alias)
        rows[issue.project_id] ||= {caption: issue.project.slug, id: attr.id, count: 0, project: issue.project}
        rows[issue.project_id][:count] += 1 if issue.open?
      else
        attr = issue.send(attr_name)
        rows[attr ? attr.id : -1] ||= {caption: attr ? attr.caption : na_label(attr_name), id: attr ? attr.id : 'NULL', count: 0, project: issue.project}
        rows[attr ? attr.id : -1][:count] += 1 if attr_name.eql?(:status) || issue.open?
      end
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