# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: IssueStatus.rb

class IssuesStatus < ActiveRecord::Base
  include Rorganize::SmartRecords

  has_and_belongs_to_many :roles, :class_name => 'Role'
  belongs_to :enumeration, :class_name => 'Enumeration', :dependent => :destroy
  has_many :issues, :class_name => 'Issue', :foreign_key => :status_id, :dependent => :nullify

  scope :fetch_dependencies, -> { eager_load(:enumeration) }

  def self.opened_statuses_id
    return IssuesStatus.where(:is_closed => false).pluck('id')
  end

  def self.permit_attributes
    [:is_closed, :default_done_ratio]
  end

  def caption
    self.enumeration.caption
  end

  def position
    self.enumeration.position
  end
  #Change position
  def change_position(operator)
    enumerations = Enumeration.where(opt: 'ISTS').order('position ASC')
    apply_change_position(enumerations, self.enumeration, operator)
  end

end

