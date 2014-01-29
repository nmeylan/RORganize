# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: issue.rb

class Issue < RorganizeActiveRecord
  #Class variables
  assign_journalized_properties({'status_id' => 'Status',
                                 'category_id' => 'Category',
                                 'assigned_to_id' => 'Assigned to',
                                 'tracker_id' => 'Tracker',
                                 'due_date' => 'Due date',
                                 'start_date' => 'Start date',
                                 'done' => 'Done',
                                 'estimated_time' => 'Estimated time',
                                 'version_id' => 'Version',
                                 'predecessor_id' => 'Predecessor'})
  assign_foreign_keys({'status_id' => IssuesStatus,
                       'category_id' => Category,
                       'assigned_to_id' => User,
                       'tracker_id' => Tracker,
                       'version_id' => Version})
  assign_journalized_icon('')
  attr_accessor :notes
  #Relations
  belongs_to :project, :class_name => 'Project'
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
  belongs_to :version, :class_name => 'Version', :foreign_key => 'version_id'
  belongs_to :tracker, :class_name => 'Tracker'
  belongs_to :status, :class_name => 'IssuesStatus'
  belongs_to :category, :class_name => 'Category'
  has_many :children, :foreign_key => 'predecessor_id', :class_name => 'Issue'
  belongs_to :parent, :foreign_key => 'predecessor_id', :class_name => 'Issue'
  has_many :checklist_items, :class_name => 'ChecklistItem', :dependent => :destroy
  has_many :attachments, :foreign_key => 'object_id', :conditions => {:object_type => self.to_s}, :dependent => :destroy
  has_many :journals, :as => :journalized, :conditions => {:journalized_type => self.to_s}, :dependent => :destroy
  has_many :time_entries, :dependent => :destroy

  #triggers
  before_save :set_done_ratio
  before_update :set_done_ratio, :set_due_date
  after_update :save_attachments, :update_journal
  after_create :create_journal
  after_destroy :destroy_journal
  #Validators
  validates_associated :attachments

  validates :subject, :tracker_id, :status_id, :presence => true
  validate :validate_start_date, :validate_predecessor
  #  validates :due_date, :format =>
  def self.paginated_issues(page, per_page, order, filter, project_id)
    paginate(:page => page,
             :include => [:tracker, :version, :assigned_to, :category, :status => [:enumeration]],
             :conditions => filter+" issues.project_id = #{project_id}",
             :per_page => per_page,
             :order => order)

  end

  #Assigned open requests on any open project
  def self.current_user_assigned_issues(order)
    return Issue.includes([:tracker, :version, :assigned_to, :category, :status => [:enumeration]])
    .where(:assigned_to_id => User.current.id, :status_id => IssuesStatus.opened_statuses_id, :project_id => Project.opened_projects_id)
    .order(order)

  end

  #Created open requests on any open project
  def self.current_user_submitted_issues(order)
    return Issue.includes([:tracker, :version, :assigned_to, :category, :status => [:enumeration]])
    .where(:author_id => User.current.id, :status_id => IssuesStatus.opened_statuses_id, :project_id => Project.opened_projects_id)
    .order(order)

  end

  #Attributes name without id
  def self.attributes_formalized_names
    names = []
    Issue.attribute_names.each { |attribute| !attribute.eql?('id') ? names << attribute.gsub(/_id/, '').gsub(/id/, '').gsub(/_/, ' ').capitalize : '' }
    return names
  end

  #  Custom validator
  def validate_start_date
    if !((self.due_date && self.start_date) ? self.start_date <= self.due_date : true)
      errors.add(:start_date, 'must be inferior than due date')
    end
  end

  def validate_predecessor
    if !self.predecessor_id.nil?
      issue = Issue.find(self.predecessor_id)
      if !issue.nil? && !issue.project_id.eql?(self.project_id) || issue.nil?
        errors.add(:predecessor, 'not exist in this project')
      elsif !issue.nil? && issue.id.eql?(self.id)
        errors.add(:predecessor, "can't be self")
      elsif !issue.nil? && self.children.include?(issue)
        errors.add(:predecessor, 'is already a child')
      end
    end
  rescue
    errors.add(:predecessor, 'not found')
  end

  #ATTACHMENT METHODS
  def new_attachment_attributes=(attachment_attributes)
    attachment_attributes.each do |attributes|
      attributes['object_type'] = 'Issue'
      attachments.build(attributes)
    end
  end

  def existing_attachment_attributes=(attachment_attributes)
    attachments.reject(&:new_record?).each do |attachment|
      attributes = attachment_attributes[attachment.id.to_s]
      if attributes
        attachment.attributes = attributes
      else
        attachment.delete
      end
    end
  end

  def save_attachments
    attachments.each do |attachment|
      attachment.save(:validation => false)
    end
  end

  #Return a hash with the content requiered for the filter's construction
  #Can define 2 type of filters:
  #Radio : with values : all - equal/contains - different/not contains
  #Select : for attributes which only defined values : e.g : version => [1,2,3]
  def self.filter_content_hash(project)
    content_hash = {}
    members = project.members.includes(:user)
    content_hash['hash_for_select'] = {}
    content_hash['hash_for_radio'] = Hash.new { |k, v| k[v] = [] }
    content_hash['hash_for_select']['assigned'] = members.collect { |member| [member.user.name, member.user.id] }
    content_hash['hash_for_radio']['assigned'] = %w(all equal different)
    content_hash['hash_for_select']['assigned'] << %w(Nobody NULL)
    content_hash['hash_for_select']['author'] = members.collect { |member| [member.user.name, member.user.id] }
    content_hash['hash_for_radio']['author'] = %w(all equal different)
    content_hash['hash_for_select']['category'] = project.categories.collect { |category| [category.name, category.id] }
    content_hash['hash_for_radio']['category'] = %w(all equal different)
    content_hash['hash_for_radio']['created'] = %w(all equal superior inferior today)
    content_hash['hash_for_radio']['done'] = %w(all equal superior inferior)
    content_hash['hash_for_select']['done'] = [[0, 0], [10, 10], [20, 20], [30, 30], [40, 40], [50, 50], [60, 60], [70, 70], [80, 80], [90, 90], [100, 100]]
    content_hash['hash_for_radio']['due_date'] = %w(all equal superior inferior today)
    content_hash['hash_for_select']['status'] = IssuesStatus.select('*').includes(:enumeration).collect { |status| [status.enumeration.name, status.id] }
    content_hash['hash_for_radio']['status'] = %w(all equal different open close)
    content_hash['hash_for_radio']['start'] = %w(all equal superior inferior today)
    content_hash['hash_for_radio']['subject'] = ['all', 'contains', 'not contains']
    content_hash['hash_for_select']['tracker'] = project.trackers.collect { |tracker| [tracker.name, tracker.id] }
    content_hash['hash_for_radio']['tracker'] = %w(all equal different)
    content_hash['hash_for_select']['version'] = project.versions.collect { |version| [version.name, version.id] }
    content_hash['hash_for_select']['version'] << %w(Unplanned NULL)
    content_hash['hash_for_radio']['version'] = %w(all equal different)
    content_hash['hash_for_radio']['updated'] = %w(all equal superior inferior today)
    return content_hash
  end

  #Return an array with all attribute that can be filtered
  def self.filtered_attributes
    filtered_attributes = []
    unused_attributes = ['Project', 'Description', 'Estimated time', 'Predecessor', 'Checklist items count', 'Attachments count']
    attrs = Issue.attributes_formalized_names.delete_if { |attribute| unused_attributes.include?(attribute) }
    attrs.each { |attribute| filtered_attributes << [attribute, attribute.gsub(/\s/, '_').downcase] }
    return filtered_attributes
  end

  def self.display_issue_object(issue_id)
    object = {}
    object[:issue] = Issue.find(issue_id, :joins => [:tracker, :status], :include => [:version, :assigned_to, :category, :attachments, :parent])
    object[:journals] = Journal.where(:journalized_type => 'Issue', :journalized_id => issue_id).includes([:details, :user])
    object[:allowed_statuses] = User.current.allowed_statuses(object[:issue].project)
    object[:done_ratio] = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    object[:checklist_statuses] = Enumeration.where(:opt => 'CLIS')
    object[:checklist_items] = ChecklistItem.where(:issue_id => issue_id).includes([:enumeration])
    object
  end

  def set_predecessor(predecessor_id)
    self.predecessor_id = predecessor_id
    saved = self.save
    journals = Journal.where(:journalized_type => 'Issue', :journalized_id => self.id).includes([:details, :user])
    {:saved => saved, :journals => journals}
  end

  #Get toolbox menu for issue class.
  def self.toolbox_menu(project, issues)
    menu = {}
    menu['allowed_statuses'] = User.current.allowed_statuses(project).collect { |status| status }
    menu['done_ratio'] = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    menu['versions'] = project.versions.collect { |version| version }
    menu['members'] = project.members.joins(:user).collect { |member| member.user }
    menu['categories'] = project.categories.collect { |category| category }
    #collecting informations from selected issues
    current_states = Hash.new {}
    current_states['member'] = issues.collect { |issue| issue.assigned_to }.uniq
    current_states['version'] = issues.collect { |issue| issue.version }.uniq
    current_states['status'] = issues.collect { |issue| issue.status }.uniq
    current_states['done'] = issues.collect { |issue| issue.done }.uniq
    current_states['category'] = issues.collect { |issue| issue.category }.uniq
    menu['current_states'] = current_states
    menu
  end

  def self.bulk_edit(issue_ids, value_param)
    issues_toolbox = Issue.where(:id => issue_ids).includes(:tracker, :version, :assigned_to, :category, :status => [:enumeration])
    #As form send all attributes, we drop all attributes except th filled one.
    value_param.delete_if { |k, v| v.eql?('') }
    key = value_param.keys[0]
    value = value_param.values[0]
    if value.eql?('-1')
      value_param[key] = nil
    end
    Issue.transaction do
      issues_toolbox.each do |issue|
        issue.attributes = value_param
        if issue.changed?
          issue.save
        end
      end
    end
  end

  def self.bulk_delete(issue_ids)
    issues = Issue.find_all_by_id(issue_ids)
    Issue.transaction do
      issues.each do |issue|
        if issue.author_id.eql?(User.current.id) || User.current.allowed_to?('delete not owner', 'Issue', @project)
          issue.destroy
        end
      end
    end
  end


  private
  def set_done_ratio
    done_ratio = self.status.default_done_ratio
    if done_ratio != 0 && !self.done_changed?
      self.done = done_ratio
    end
  end

  def set_due_date
    if self.version && !self.version.target_date.nil? && self.version_id_changed?
      self.due_date = self.version.target_date
    end
  end
end

