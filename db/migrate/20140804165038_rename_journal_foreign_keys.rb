class RenameJournalForeignKeys < ActiveRecord::Migration
  def up
    rename_column :journals, :journalized_id, :journalizable_id
    rename_column :journals, :journalized_type, :journalizable_type
    rename_column :journals, :journalized_identifier, :journalizable_identifier
  end

  def down
    rename_column :journals, :journalizable_id, :journalized_id
    rename_column :journals, :journalizable_type, :journalized_type
    rename_column :journals, :journalizable_identifier, :journalized_identifier
  end
end
