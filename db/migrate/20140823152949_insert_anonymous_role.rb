class InsertAnonymousRole < ActiveRecord::Migration
  def up
    Role.create({name: 'Anonymous', position: Role.all.count + 1})
  end

  def down
    Role.delete_all(name: 'Anonymous')
  end
end
