# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: category.rb

class Category < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Journalizable
  #Class variables
  assign_journalizable_properties({name: 'Name'})
  #Relations
  belongs_to :project, :class_name => 'Project'
  has_many :issues, :class_name => 'Issue', :dependent => :nullify

  validates :name, :presence => true, :length => 2..20

  def self.permit_attributes
    [:name]
  end

  def caption
    self.name
  end

end
