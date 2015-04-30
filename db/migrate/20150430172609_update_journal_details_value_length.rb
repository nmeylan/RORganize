class UpdateJournalDetailsValueLength < ActiveRecord::Migration
  def change
    change_column :journal_details, :old_value, :text
    change_column :journal_details, :value, :text
  end
end
