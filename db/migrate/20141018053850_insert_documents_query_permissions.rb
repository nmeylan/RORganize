class InsertDocumentsQueryPermissions < ActiveRecord::Migration
  def change
    Permission.create(controller: 'Documents', action: 'apply_custom_query', name: 'Use custom Queries')
  end
end
