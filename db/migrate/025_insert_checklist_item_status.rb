# Author: Nicolas Meylan
# Date: 6 août 2012
# Encoding: UTF-8
# File: 025_insert_checklist_item_status.rb

class InsertChecklistItemStatus < ActiveRecord::Migration
  def up
    Enumeration.create(opt: 'CLIS', name: 'New', position: 1)
    Enumeration.create(opt: 'CLIS', name: 'Started', position: 2)
    Enumeration.create(opt: 'CLIS', name: 'Finish', position: 3)
  end

  def down
    Enumeration.delete_all(opt: 'CLIS')
  end
end
