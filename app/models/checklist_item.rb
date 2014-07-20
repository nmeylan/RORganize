# Author: Nicolas Meylan
# Date: 6 août 2012
# Encoding: UTF-8
# File: checklist_item.rb

class ChecklistItem < ActiveRecord::Base
  include Rorganize::SmartRecords

  belongs_to :issue, :class_name => 'Issue', :counter_cache => true
  belongs_to :enumeration, :class_name => 'Enumeration'

  def self.save_items(items, issue_id)
    position = 1
    if items
      items.each do |k, v|
        tmp = ChecklistItem.find_by_issue_id_and_name(issue_id, k)
        if tmp
          tmp.update_attributes(:enumeration_id => v, :position => position)
        else
          ChecklistItem.create(:enumeration_id => v, :issue_id => issue_id, :position => position, :name => k)
        end
        position += 1
      end
      ChecklistItem.delete_all(['name NOT IN (?) AND issue_id = ?', items.keys, issue_id])
    else
      ChecklistItem.delete_all(['issue_id = ?', issue_id])
    end
  end

  def caption
    self.name
  end
end
