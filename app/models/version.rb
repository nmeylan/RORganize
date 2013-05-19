class Version < ActiveRecord::Base
  #  after_update :update_issues_due_date
  has_and_belongs_to_many :projects, :class_name => 'Project'
  has_many :issues, :class_name => 'Issue', :include => [:status,:tracker, :parent, :children], :dependent => :nullify
  has_many :journals, :as => :journalized, :conditions => {:journalized_type => self.to_s}, :dependent => :destroy
  validates :name, :presence => true, :length => 2..20
  validates :start_date, :presence => true
  include IssuesHelper

  def update_issues_due_date
    issues = Issue.find_all_by_version_id(self.id)
    issues.each do |issue|
      if issue.due_date >= self.target_date && issue.due_date.nil
        journal = Journal.create(:user_id => User.current.id,
          :journalized_id => issue.id,
          :journalized_type => issue.class.to_s,
          :created_at => Time.now.to_formatted_s(:db),
          :notes => '',
          :action_type => "updated",
          :project_id => issue.project.id)
        #Create an entry for the journal
        issues_journal_insertion({'due_date' => [issue.due_date, self.target_date]}, journal, {'due_date' => "Due date"}, {})
        issue.update_column('due_date', self.target_date)
      end
    end
  end
end
