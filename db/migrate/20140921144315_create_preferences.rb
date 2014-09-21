class CreatePreferences < ActiveRecord::Migration
  def up
    create_table :preferences do |t|
      t.integer :enumeration_id #the key
      t.boolean :boolean_value, default: false #the value
      t.string :string_value #the value
      t.integer :user_id
    end

  end
  
  def down
    drop_table :preferences

  end
end
