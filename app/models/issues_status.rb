# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: IssueStatus.rb

class IssuesStatus < ActiveRecord::Base
  has_and_belongs_to_many :roles, :class_name => 'Role'
  belongs_to :enumeration, :class_name => 'Enumeration', :dependent => :destroy
  has_many :issues, :class_name => 'Issue', :foreign_key => :status_id, :dependent => :nullify
  after_destroy :dec_position_on_destroy

  def self.opened_statuses_id
    return IssuesStatus.select('id').where(:is_closed => false).collect { |status| status.id }
  end

  def self.permit_attributes
    [:is_closed, :default_done_ratio]
  end

  #Change position
  def change_position(operator)
    old_issues_statuses = IssuesStatus.includes(:enumeration).order('enumerations.position')
    status = old_issues_statuses.select { |status| status.id.eql?(self.id) }.first
    max = old_issues_statuses.count
    saved = false
    position = status.enumeration.position
    if status.enumeration.position == 1 && operator.eql?('dec') ||
        status.enumeration.position == max && operator.eql?('inc')
    else
      if operator.eql?('inc')
        o_status = old_issues_statuses.select { |stat| stat.enumeration.position.eql?(position + 1) }.first
        o_status.enumeration.update_column(:position, position)
        status.enumeration.update_column(:position, position + 1)
      else
        o_status = old_issues_statuses.select { |stat| stat.enumeration.position.eql?(position - 1) }.first
        o_status.enumeration.update_column(:position, position)
        status.enumeration.update_column(:position, position - 1)
      end
      saved = true
    end
    saved
  end

  def dec_position_on_destroy
    position = self.enumeration.position
    Enumeration.update_all 'position = position - 1', "position > #{position} AND opt = 'ISTS'"
  end
end

