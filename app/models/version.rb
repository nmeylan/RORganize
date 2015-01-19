class Version < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Journalizable
  extend Rorganize::Models::BulkEditable
  #Class variables
  exclude_attributes_from_journal(:description, :position)
  #Relations
  belongs_to :project, class_name: 'Project'
  has_many :issues, class_name: 'Issue', dependent: :nullify
  validates :name, presence: true, length: 2..20
  validates :start_date, presence: true
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
    self.target_date && self.target_date < Date.today
  end

  def issues_count
    self.issues.count
  end

  # The rule for issue start and due date is :
  # Version.start_date <= Issue.start_date < Issue.due_date <= Version.due_date
  # So when issue's version is changing we have to update issue start and due date to respect the previous rule.
  # see https://github.com/nmeylan/RORganize/wiki/User-guide---Update-version-dates
  def update_issues_due_date
    issues = Issue.where(version_id: self.id)
    Issue.bulk_set_start_and_due_date(issues.collect(&:id), self, nil)
  end

  #  Custom validator
  def validate_start_date
    if self.target_date && self.start_date && self.start_date >= self.target_date
      errors.add(:start_date, 'must be inferior than due date')
    end
  end

  def inc_position
    count = self.project.versions.count
    self.position = count + 1
  end

  def dec_position_on_destroy
    position = self.position
    Version.where("position > ? AND project_id = ? ", position, self.project_id).update_all('position = position - 1')
  end

  # This method return an overview of versions for the the given project.
  # @param [Numeric] project_id : the id of the project.
  # @param [String] condition : an extra condition clause.
  # @return [Array] an array with de the following structure :
  # [[version_id, number of opened issues, number of closed issues, progress percent of issue], [..]...]
  def self.overviews(project_id, condition = nil)
    condition ||= '1 = 1'
    #This request return : [version_id, number of opened request, number of closed request, total progress percent]
    Version.joins('RIGHT OUTER JOIN `issues` ON `issues`.`version_id` = `versions`.`id`' \
                  'INNER JOIN `issues_statuses` ON `issues_statuses`.`id` = `issues`.`status_id`')
        .group('versions.id')
        .where(%Q(#{condition} AND issues.project_id = #{project_id}))
        .pluck('versions.id, ' \
                'SUM(case when issues_statuses.is_closed = 0 then 1 else 0 end) Opened, '\
                'SUM(case when issues_statuses.is_closed = 1 then 1 else 0 end) Closed, ' \
                '(SUM(issues.done) / Count(*)) Percent')
  end


  # @param [Hash] version_id_attributes_changed_hash
  def self.gantt_edit(version_id_attributes_changed_hash)
    Version.transaction do
      version_id_attributes_changed_hash.each do |version_id, attribute_name_value_hash|
        version = Version.find_by_id(version_id)
        if version
          version.attributes = attribute_name_value_hash
          if version.changed?
            version.save
          end
        end
      end
    end
  end

  # @param [String] operator : 'dec' or 'inc'.
  def change_position(operator)
    project = self.project
    versions = project.versions.order(:position)
    apply_change_position(versions, self, operator)
  end
end
