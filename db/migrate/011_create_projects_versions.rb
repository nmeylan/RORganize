class CreateProjectsVersions < ActiveRecord::Migration
  def up
    create_table :projects_versions, :id => false do |t|
      t.integer :version_id
      t.integer :project_slug
      
    end
  end
 
  def down
    drop_table :projects_versions
  end
end