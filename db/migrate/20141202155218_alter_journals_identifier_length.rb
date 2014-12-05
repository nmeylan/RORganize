class AlterJournalsIdentifierLength < ActiveRecord::Migration
  def up
    change_column :journals, :journalizable_identifier, :string, length: 255
  end

  def down
    change_column :journals, :journalizable_identifier, :string, length: 255
  end
end
