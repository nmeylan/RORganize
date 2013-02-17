# Author: Nicolas Meylan
# Date: 8 déc. 2012
# Encoding: UTF-8
# File: scenarios.rb

class Step < ActiveRecord::Base
  has_and_belongs_to_many :issues, :class_name => 'Issue'
  belongs_to :scenario, :class_name => 'Scenario'

  validates :name, :scenario_id, :presence => true
end
