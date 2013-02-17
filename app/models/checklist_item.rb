# Author: Nicolas Meylan
# Date: 6 août 2012
# Encoding: UTF-8
# File: checklist_item.rb

class ChecklistItem < ActiveRecord::Base
  belongs_to :issue, :class_name => 'Issue'
  belongs_to :enumeration, :class_name => 'Enumeration'
end
