class CreateAttachments < ActiveRecord::Migration
  def up
    create_table :attachments do |t|
      t.integer :object_id
      t.string :name, limit: 255
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at
      t.string :object_type, limit: 255
    end
  end

  def down
    drop_table :attachments
  end
end