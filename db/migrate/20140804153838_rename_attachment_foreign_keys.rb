class RenameAttachmentForeignKeys < ActiveRecord::Migration
  def up
    rename_column :attachments, :object_id, :attachable_id
    rename_column :attachments, :object_type, :attachable_type
  end

  def down
    rename_column :attachments, :attachable_id, :object_id
    rename_column :attachments, :attachable_type, :object_type
  end
end
