# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: home_page_report.rb

class HomePageReport
  attr_reader :content

  def initialize
    projects_decorator = User.current.owned_projects('starred').decorate(context: {allow_to_star: false})
    overview_object_assigned = overview_issue_report(:assigned_to, :assigned_to_id)
    overview_object_submitted = overview_issue_report(:author, :author_id)
    @content = {projects_decorator: projects_decorator,
     overview_object_assigned: overview_object_assigned,
     overview_object_submitted: overview_object_submitted}
  end

  def overview_issue_report(report_name, attr_name)
    group = Issue.group_opened_by_project("issues.#{attr_name.to_s}", "#{attr_name.to_s} = #{User.current.id}")
    IssueOverviewHash.new({report_name => group }, Issue.where(attr_name => User.current.id).count, true)
  end
end