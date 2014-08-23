# Author: Nicolas Meylan
# Date: 24.08.14
# Encoding: UTF-8
# File: issue_overview_hash.rb

class IssueOverviewHash
  attr_reader :content
  def initialize(issues, assigned_to, status, versions, categories)
    @issues_count = issues
    @content = Hash.new { |h, k| h[k] = {} }
    build_object(assigned_to, status, versions, categories)
  end

  def build_object(assigned_to, status, versions, categories)
    @content[:assigned_to] = assigned_to.inject({}) { |r, s| r.merge!({s[0] => s[1]}) }
    @content[:status] = status.inject({}) { |r, s| r.merge!({s[0] => s[1]}) }
    @content[:versions] = versions.inject({}) { |r, s| r.merge!({s[0] => s[1]}) }
    @content[:categories] = categories.inject({}) { |r, s| r.merge!({s[0] => s[1]}) }
  end
end