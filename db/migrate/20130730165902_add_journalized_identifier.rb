class AddJournalizedIdentifier < ActiveRecord::Migration
  def up
    add_column :journals, :journalized_identifier, :string, :default => nil, :limit => 128
  end

  def down
    remove_column :journals, :journalized_identifier
  end
end
