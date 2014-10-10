class AddCommentsPermission < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Issues', action: 'comment', name: 'Add Comments (edit and delete own comments)', is_locked: true)
    Permission.create(controller: 'Wiki_pages', action: 'comment', name: 'Add Comments (edit and delete own comments)', is_locked: true)
    Permission.create(controller: 'Documents', action: 'comment', name: 'Add Comments (edit and delete own comments)', is_locked: true)

    Permission.create(controller: 'Comments', action: 'edit_comment_not_owner', name: 'Edit others comments', is_locked: true)
    Permission.create(controller: 'Comments', action: 'destroy_comment_not_owner', name: 'Delete others comments', is_locked: true)
  end

  def down
    Permission.delete_all(action: 'comment')
    Permission.delete_all(action: 'edit_comment_not_owner')
    Permission.delete_all(action: 'destroy_comment_not_owner')
  end
end
