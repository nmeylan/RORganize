# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: category.rb

class Category < RorganizeActiveRecord
  #Class variables
  assign_journalized_properties({'name' => 'Name'})
  assign_foreign_keys({})
   assign_journalized_icon('/assets/activity_package.png')
  #Relations
  belongs_to :project, :class_name => 'Project'
  has_many :issues, :class_name => 'Issue', :dependent => :nullify
  has_many :journals, :as => :journalized, :conditions => {:journalized_type => self.to_s}, :dependent => :destroy
  #Triggers
  after_create :create_journal 
  after_update :update_journal
  after_destroy :destroy_journal
  
end
