# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: overview_report.rb

class OverviewReport
  attr_reader :content
  def initialize(project_id)
    tracker_report = Issue.group_opened_by_attr(project_id, 'trackers', :tracker)
    version_report = Issue.group_opened_by_attr(project_id, 'versions', :version)
    category_report = Issue.group_opened_by_attr(project_id, 'categories', :category)
    author_report = Issue.group_opened_by_attr(project_id, 'users', :author)
    assigned_to_report = Issue.group_opened_by_attr(project_id, 'users', :assigned_to)
    status_report = Issue.group_by_status(project_id)
    @content = {assigned_to: assigned_to_report, author: author_report,
     category: category_report, status: status_report, tracker: tracker_report,
     version: version_report}
  end
end