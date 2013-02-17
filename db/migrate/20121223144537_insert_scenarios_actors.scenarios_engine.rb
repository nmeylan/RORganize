# This migration comes from scenarios_engine (originally 3)
class InsertScenariosActors < ActiveRecord::Migration
  def up
    Enumeration.create(:opt => 'SCAC', :name => 'Administrator', :position => 1)
    Enumeration.create(:opt => 'SCAC', :name => 'User', :position => 2)
  end

  def down
    Enumeration.delete_all(:opt => 'SCAC', :name => 'Administrator', :position => 1)
    Enumeration.delete_all(:opt => 'SCAC', :name => 'User', :position => 2)
  end
end