# Author: Nicolas Meylan
# Date: 14 juil. 2012
# Encoding: UTF-8
# File: category.rb

class Category < ActiveRecord::Base
  has_many :issues, :class_name => 'Issue', :dependent => :nullify
  belongs_to :project, :class_name => 'Project'
  has_many :journals, :as => :journalized, :conditions => {:journalized_type => self.to_s}, :dependent => :destroy
  
end
