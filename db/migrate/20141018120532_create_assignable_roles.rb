class CreateAssignableRoles < ActiveRecord::Migration
  def change
    create_table :assignable_roles do |t|
      t.integer :role_id
      t.integer :assignable_by_role_id
    end
  end
end
