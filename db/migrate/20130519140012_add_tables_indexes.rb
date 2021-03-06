class AddTablesIndexes < ActiveRecord::Migration
  def up
    add_index :attachments, :object_id
    add_index :categories, :project_id
    add_index :checklist_items, :enumeration_id
    add_index :checklist_items, :issue_id
    add_index :documents, :version_id
    add_index :documents, :project_id
    add_index :documents, :category_id
    add_index :enabled_modules, :project_id
    add_index :issues, :author_id
    add_index :issues, :assigned_to_id
    add_index :issues, :project_id
    add_index :issues, :tracker_id
    add_index :issues, :version_id
    add_index :issues, :category_id
    add_index :issues, :predecessor_id
    add_index :issues_statuses, :enumeration_id
    add_index :issues_statuses_roles, :role_id
    add_index :issues_statuses_roles, :issues_status_id
    add_index :journals, :user_id
    add_index :journals, :project_id
    add_index :members, :project_id
    add_index :members, :user_id
    add_index :members, :role_id
    add_index :permissions_roles, :role_id
    add_index :permissions_roles, :permission_id
    add_index :projects_trackers, :tracker_id
    add_index :projects_trackers, :project_id
    add_index :projects_versions, :project_id
    add_index :projects_versions, :version_id
    add_index :queries, :author_id
    add_index :queries, :project_id
  end

  def down
    remove_index :attachments, :object_id
    remove_index :categories, :project_id
    remove_index :checklist_items, :enumeration_id
    remove_index :checklist_items, :issue_id
    remove_index :documents, :version_id
    remove_index :documents, :project_id
    remove_index :documents, :category_id
    remove_index :enabled_modules, :project_id
    remove_index :issues, :author_id
    remove_index :issues, :assigned_to_id
    remove_index :issues, :project_id
    remove_index :issues, :tracker_id
    remove_index :issues, :version_id
    remove_index :issues, :category_id
    remove_index :issues, :predecessor_id
    remove_index :issues_statuses, :enumeration_id
    remove_index :issues_statuses_roles, :role_id
    remove_index :issues_statuses_roles, :issues_status_id
    remove_index :journals, :user_id
    remove_index :journals, :project_id
    remove_index :members, :project_id
    remove_index :members, :user_id
    remove_index :members, :role_id
    remove_index :permissions_roles, :role_id
    remove_index :permissions_roles, :permission_id
    remove_index :projects_trackers, :tracker_id
    remove_index :projects_trackers, :project_id
    remove_index :projects_versions, :project_id
    remove_index :projects_versions, :version_id
    remove_index :queries, :author_id
    remove_index :queries, :project_id
  end
end
