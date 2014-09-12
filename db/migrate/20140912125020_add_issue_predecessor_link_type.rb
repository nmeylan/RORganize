class AddIssuePredecessorLinkType < ActiveRecord::Migration
  def up
    #Link are :
    # 0 : start_end
    # 1 : start_start
    add_column :issues, :link_type, :integer, default: 0
  end

  def down
    remove_column :issues, :link_type
  end
end
