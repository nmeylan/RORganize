# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: category.rb

class Category < RorganizeActiveRecord
  include Rorganize::AbstractModelCaption
  #Class variables
  assign_journalized_properties({'name' => 'Name'})
  assign_foreign_keys({})
  #Relations
  belongs_to :project, :class_name => 'Project'
  has_many :issues, :class_name => 'Issue', :dependent => :nullify
  has_many :journals, ->  {where :journalized_type => 'Category'}, :as => :journalized, :dependent => :destroy
  #Triggers
  after_create :create_journal 
  after_update :update_journal
  after_destroy :destroy_journal

  def self.permit_attributes
    [:name]
  end

  def caption
    self.name
  end
  
end
