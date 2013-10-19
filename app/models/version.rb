class Version < RorganizeActiveRecord
  #Class variables
  assign_journalized_properties({'name' => 'Name',
      'target_date' => 'Due date', 'start_date' => 'Start date'})
  assign_foreign_keys({})
  assign_journalized_icon('/assets/activity_ticket_go.png')
  #Relations
  belongs_to :project, :class_name => 'Project'
  has_many :issues, :class_name => 'Issue', :dependent => :nullify
  has_many :journals, :as => :journalized, :conditions => {:journalized_type => self.to_s}, :dependent => :destroy
  validates :name, :presence => true, :length => 2..20
  validates :start_date, :presence => true
  validate :validate_start_date
  include IssuesHelper
  #Triggers
  after_create :create_journal 
  after_update :update_journal,:update_issues_due_date
  after_destroy :destroy_journal, :dec_position_on_destroy
  def update_issues_due_date
    issues = Issue.find_all_by_version_id(self.id)
    issues.each do |issue|
      if issue.due_date >= self.target_date && issue.due_date.nil
        journal = Journal.create(:user_id => User.current.id,
          :journalized_id => issue.id,
          :journalized_type => issue.class.to_s,
          :created_at => Time.now.to_formatted_s(:db),
          :notes => '',
          :action_type => 'updated',
          :project_id => issue.project.id)
        #Create an entry for the journal
        #noinspection RubyStringKeysInHashInspection
        issues_journal_insertion({'due_date' => [issue.due_date, self.target_date]}, journal, {'due_date' => 'Due date'}, {})
        issue.update_column('due_date', self.target_date)
      end
    end
  end
  #  Custom validator
  def validate_start_date
    if !((self.target_date && self.start_date) ? self.start_date <= self.target_date : true)
      errors.add(:start_date, 'must be inferior than due date')
    end
  end
  
  def dec_position_on_destroy
    position = self.position
    Version.update_all 'position = position - 1', "position > #{position}"
  end
end
