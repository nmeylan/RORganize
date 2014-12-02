class AlterJournalsIdentifierLength < ActiveRecord::Migration
  def change
    change_column :journals, :journalizable_identifier, :string, length: 255
  end
end
