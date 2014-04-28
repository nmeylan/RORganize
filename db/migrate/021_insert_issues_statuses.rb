# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: 020_insert_issues_statuses.rb

class InsertIssuesStatuses < ActiveRecord::Migration
  def up
    IssuesStatus.create(:is_closed => false, :default_done_ratio => 0, :enumeration_id => 1)
    IssuesStatus.create(:is_closed => false, :default_done_ratio => 0, :enumeration_id => 2)
    IssuesStatus.create(:is_closed => true, :default_done_ratio => 100, :enumeration_id => 3)
    IssuesStatus.create(:is_closed => false, :default_done_ratio => 100, :enumeration_id => 4)
    IssuesStatus.create(:is_closed => false, :default_done_ratio => 100, :enumeration_id => 5)
    IssuesStatus.create(:is_closed => false, :default_done_ratio => 50, :enumeration_id => 6)
    IssuesStatus.create(:is_closed => false, :default_done_ratio => 0, :enumeration_id => 7)

    project_manager = Role.find_by_name('Project Manager')
    team_member = Role.find_by_name('Team Member')
    engagement_manager = Role.find_by_name('Engagement manager')
    issues_statuses = IssuesStatus.where(enumeration_id: Enumeration.find_all_by_opt('ISTS'))

    project_manager.issues_statuses = issues_statuses
    project_manager.save
    engagement_manager.issues_statuses = issues_statuses
    engagement_manager.save
    team_member.issues_statuses = IssuesStatus.where(enumeration_id: Enumeration.find_all_by_opt_and_name('ISTS',['New','In progress','Fixed to test']))
    team_member.save
  end

  def down
    IssuesStatus.delete(1)
    IssuesStatus.delete(2)
    IssuesStatus.delete(3)
    IssuesStatus.delete(4)
    IssuesStatus.delete(5)
    IssuesStatus.delete(6)
    IssuesStatus.delete(7)
  end
end
