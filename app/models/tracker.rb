# Author: Nicolas Meylan
# Date: 13 juil. 2012
# Encoding: UTF-8
# File: tracker.rb

class Tracker < ActiveRecord::Base
  include SmartRecords

  has_and_belongs_to_many :projects, class_name: 'Project'
  has_many :issues, class_name: 'Issue', dependent: :nullify

  before_create :set_initial_position
  after_destroy :dec_position_on_destroy

  validates :name, presence: true, uniqueness: true, length: 2..50

  def caption
    self.name
  end

  def set_initial_position
    count = Tracker.count
    self.position = count + 1
  end

  def self.permit_attributes
    [:name]
  end


  #Change position
  def change_position(operator)
    apply_change_position(Tracker.all, self, operator)
  end

  def dec_position_on_destroy
    position = self.position
    Tracker.where("position > ?", position).update_all('position = position - 1')
  end
end
