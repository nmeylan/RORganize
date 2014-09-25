class Version < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Journalizable
  extend Rorganize::Managers::BulkEditManager
  #Class variables
  assign_journalizable_properties({name: 'Name', target_date: 'Due date', start_date: 'Start date'})
  #Relations
  belongs_to :project, :class_name => 'Project'
  has_many :issues, :class_name => 'Issue', :dependent => :nullify
  validates :name, :presence => true, :length => 2..20
  validates :start_date, :presence => true
  validate :validate_start_date
  include IssuesHelper
  #Triggers
  before_create :inc_position
  after_update :update_issues_due_date
  after_destroy :dec_position_on_destroy

  def self.permit_attributes
    [:name, :target_date, :description, :start_date, :is_done]
  end

  def caption
    self.name
  end

  def closed?
    !self.target_date.nil? && (self.target_date && self.target_date < Date.today)
  end

  # The rule for issue start and due date is :
  # Version.start_date <= Issue.start_date < Issue.due_date <= Version.due_date
  # So when issue's version is changing we have to update issue start and due date to respect the previous rule.
  def update_issues_due_date
    issues = Issue.where(:version_id => self.id).eager_load(:version)
    issue_changes = {due_date: [], start_date: []}
    issues.each do |issue|
      issue = issue.set_start_and_due_date(true)
      issue_changes[:due_date] << issue unless issue.changes[:due_date].nil?
      issue_changes[:start_date] << issue unless issue.changes[:start_date].nil?
    end
    merged_issues = issue_changes[:due_date] | issue_changes[:start_date]
    if merged_issues.any?
      Issue.where(id: issue_changes[:due_date].collect{|issue| issue.id}).update_all(due_date: self.target_date)
      Issue.where(id: issue_changes[:start_date].collect{|issue| issue.id}).update_all(start_date: self.start_date)
      Issue.journal_update_creation(merged_issues, self.project, User.current.id, 'Issue')
    end
  end

  #  Custom validator
  def validate_start_date
    if !((self.target_date && self.start_date) ? self.start_date <= self.target_date : true)
      errors.add(:start_date, 'must be inferior than due date')
    end
  end

  def inc_position
    count = self.project.versions.count
    self.position = count + 1
  end

  def dec_position_on_destroy
    position = self.position
    Version.where("position > #{position} AND project_id = #{self.project_id}").update_all('position = position - 1')
  end

  # @param [Numeric] project_id : the id of the project.
  # @param [String] condition :the condition.
  # @return [Array] an array with de the following structure : [[version_id, number of closed issues, number of opened issues, progress percent of issue], [..]...]
  def self.overviews(project_id, condition = nil)
    condition ||= '1 = 1'
    #This request return : [version_id, number of opened request, number of closed request, total progress percent]
    Version.joins('RIGHT OUTER JOIN `issues` ON `issues`.`version_id` = `versions`.`id` INNER JOIN `issues_statuses` ON `issues_statuses`.`id` = `issues`.`status_id`').group('versions.id').where(%Q(#{condition} AND issues.project_id = #{project_id})).pluck('versions.id, SUM(case when issues_statuses.is_closed = 0 then 1 else 0 end) Opened, SUM(case when issues_statuses.is_closed = 1 then 1 else 0 end) Closed, (SUM(issues.done) / Count(*)) Percent')
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
      data[version] = version.issues.eager_load(:parent, :children)
    end
    data
  end

  def self.gantt_edit(hash)
    Version.transaction do
      hash.each do |k, v|
        version = Version.find_by_id(k)
        if version
          version.attributes = v
          if version.changed?
            version.save
          end
        end
      end
    end
  end

  def change_position(project, operator)
    versions = project.versions.order(:position)
    apply_change_position(versions, self, operator)
  end
end
