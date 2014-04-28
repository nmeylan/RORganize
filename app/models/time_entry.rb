# Author: Nicolas
# Date: 21/09/13
# Encoding: UTF-8
# File: time_entries.rb
class TimeEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  belongs_to :project

  #Validators
   validates :spent_on, :spent_time, :project_id, :issue_id, :presence => true

  #Methods
  def self.permit_attributes
    [:spent_on, :spent_time, :comment]
  end

end