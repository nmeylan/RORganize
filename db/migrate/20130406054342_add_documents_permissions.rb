class AddDocumentsPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Documents', action: 'index', name: 'View documents', is_locked: true)
    Permission.create(controller: 'Documents', action: 'new', name: 'Create documents', is_locked: true)
    Permission.create(controller: 'Documents', action: 'edit', name: 'Edit documents', is_locked: true)
    Permission.create(controller: 'Documents', action: 'destroy', name: 'Delete documents', is_locked: true)
    Permission.create(controller: 'Documents', action: 'show', name: 'View document', is_locked: true)
    Permission.create(controller: 'Documents', action: 'delete_attachment', name: 'Delete attachments', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'Documents', action: 'index', name: 'View documents')
    Permission.delete_all(controller: 'Documents', action: 'new', name: 'Create documents')
    Permission.delete_all(controller: 'Documents', action: 'edit', name: 'Edit documents')
    Permission.delete_all(controller: 'Documents', action: 'destroy', name: 'Delete documents')
    Permission.delete_all(controller: 'Documents', action: 'show', name: 'View document')
    Permission.delete_all(controller: 'Documents', action: 'delete_attachment', name: 'Add or delete attachments')
  end
end
