class DropWikiPageUselessPermission < ActiveRecord::Migration
  def up
    Permission.delete_all(controller: 'Wiki_pages', action: 'comment')
  end

  def down

  end
end
