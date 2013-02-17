class Version < ActiveRecord::Base
  after_update :update_issues_due_date
  has_and_belongs_to_many :projects, :class_name => 'Project'
  has_many :issues, :class_name => 'Issue', :include => [:status,:tracker], :dependent => :nullify
  validates :name, :presence => true, :length => 2..20

  def update_issues_due_date
    issues = Issue.find_all_by_version_id(self.id)
    issues.each{|issue| issue.update_column('due_date', self.target_date)}
  end
end
