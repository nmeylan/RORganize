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
  after_update :update_journal, :update_issues_due_date
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

  def self.define_roadmap(versions, project_id)
    data = {}
    #related requests for each versions
    data['related_requests'] = Hash.new { |h, k| h[k] = [] }
    #Request statement for each versions
    data['request_statements'] = Hash.new { |h, k| h[k] = [] }
    #Request done percent
    data['request_done_percent'] = {}
    tmp_issues_ary = []
    tmp_closed_status = 0
    tmp_opened_status = 0
    tmp_done = 0
    versions.each do |version|
      version.issues.includes(:status, :tracker).each do |issue|
        #add issue
        tmp_issues_ary << issue
        issue.status.is_closed ? tmp_closed_status += 1 : tmp_opened_status += 1
        tmp_done += issue.done
      end
      data['related_requests'][version.id] = tmp_issues_ary
      data['request_statements'][version.id] = [tmp_closed_status, tmp_opened_status]
      if data['related_requests'][version.id].count != 0
        data['request_done_percent'][version.id] = (tmp_done / data['related_requests'][version.id].count).round
      else
        data['request_done_percent'][version.id] = 0
      end
      tmp_issues_ary = []
      tmp_closed_status = 0
      tmp_opened_status = 0
      tmp_done = 0
    end
    unplanned_issues = Issue.where(:version_id => nil, :project_id => project_id).includes([:status, :tracker])
    unless unplanned_issues.empty?
      versions << Version.new(:name => 'Unplanned')
      data['related_requests'][nil] = unplanned_issues
      data['related_requests'][nil].each { |issue| issue.status.is_closed ? tmp_closed_status += 1 : tmp_opened_status += 1
      tmp_done += issue.done }
      data['request_statements'][nil] = [tmp_closed_status, tmp_opened_status]
      data['request_done_percent'][nil] = (tmp_done / data['related_requests'][nil].count).round
    end
    data
  end

  def self.define_calendar(versions, date)
    if date
      date = date.to_date
    else
      date = Date.today
    end
    versions_hash = {}
    versions.each do |version|
      unless version.target_date.nil?
        versions_hash[version.target_date.to_formatted_s(:db)] = version
      end
    end
    {:versions_hash => versions_hash, :date => date}
  end

  def self.define_gantt_data(project)
    data = Hash.new { |h, k| h[k] = [] }
    versions = project.versions
    versions.each do |version|
      data[version] = version.issues.includes(:parent, :children)
    end
    data
  end

  def change_position(project, operator)
    versions = project.versions.sort{|x, y| x.position <=> y.position}
    version = versions.select{|version| version.id.eql?(self.id)}.first
    max = versions.count
    position = version.position
    saved = false
      if version.position == 1 && operator.eql?('dec') ||
          version.position == max && operator.eql?('inc')
      else
        if operator.eql?('inc')
          o_version = versions.select{|v| v.position.eql?(position + 1)}.first
          o_version.update_column(:position, position)
          version.update_column(:position, position + 1)
        else
          o_version = versions.select{|v| v.position.eql?(position - 1)}.first
          o_version.update_column(:position, position)
          version.update_column(:position, position - 1)
        end
       saved = true
      end
    saved
  end
end
