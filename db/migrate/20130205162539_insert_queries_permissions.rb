class InsertQueriesPermissions < ActiveRecord::Migration
  def up
    #Permissions for Queries
    Permission.create(controller: 'Queries', action: 'new', name: 'Create Queries')
    Permission.create(controller: 'Queries', action: 'public_queries', name: 'Create/Edit/Delete Public Queries')
    Permission.create(controller: 'Queries', action: 'index', name: 'View Queries')
    Permission.create(controller: 'Queries', action: 'show', name: 'View Query')
    Permission.create(controller: 'Queries', action: 'edit', name: 'Edit Queries')
    Permission.create(controller: 'Queries', action: 'destroy', name: 'Delete Queries')
    Permission.create(controller: 'Issues', action: 'apply_custom_query', name: 'Use custom Queries')
  end

  def down
    #Permissions for Queries
    Permission.delete_all(controller: 'Queries', action: 'new', name: 'Create Queries')
    Permission.delete_all(controller: 'Queries', action: 'public_queries', name: 'Create/Edit/Delete Public Queries')
    Permission.delete_all(controller: 'Queries', action: 'index', name: 'View Queries')
    Permission.delete_all(controller: 'Queries', action: 'show', name: 'View Query')
    Permission.delete_all(controller: 'Queries', action: 'edit', name: 'Edit Queries')
    Permission.delete_all(controller: 'Queries', action: 'destroy', name: 'Delete Queries')
    Permission.delete_all(controller: 'Issues', action: 'apply_custom_query', name: 'Use custom Queries')
  end
end
