class AddIssuesStatusesColumnColor < ActiveRecord::Migration
  def change
    add_column :issues_statuses, :color, :string

    issue_status = IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'New'))
    issue_status.update_attribute(:color, '#6cc644') unless issue_status.nil?

    issue_status = IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Redo'))
    issue_status.update_attribute(:color, '#6cc644') unless issue_status.nil?

    issue_status = IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'In progress'))
    issue_status.update_attribute(:color, '#fbca04') unless issue_status.nil?

    issue_status = IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Fixed to test'))
    issue_status.update_attribute(:color, '#fbca04') unless issue_status.nil?

    issue_status = IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Not satisfying'))
    issue_status.update_attribute(:color, '#fbca04') unless issue_status.nil?

    issue_status = IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Closed'))
    issue_status.update_attribute(:color, '#bd2c00') unless issue_status.nil?

    issue_status = IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Tested to be delivered'))
    issue_status.update_attribute(:color, '#bd2c00') unless issue_status.nil?
  end
end
