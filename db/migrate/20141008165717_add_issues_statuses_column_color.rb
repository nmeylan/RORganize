class AddIssuesStatusesColumnColor < ActiveRecord::Migration
  def change
    add_column :issues_statuses, :color, :string

    IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'New')).update_attribute(:color, '#6cc644')
    IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Redo')).update_attribute(:color, '#6cc644')
    IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'In progress')).update_attribute(:color, '#fbca04')
    IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Fixed to test')).update_attribute(:color, '#fbca04')
    IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Not satisfying')).update_attribute(:color, '#fbca04')
    IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Closed')).update_attribute(:color, '#bd2c00')
    IssuesStatus.find_by_enumeration_id(Enumeration.find_by_opt_and_name('ISTS', 'Tested to be delivered')).update_attribute(:color, '#bd2c00')
  end
end
