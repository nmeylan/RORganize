class InsertNonMemberRole < ActiveRecord::Migration
  def up
    Role.create({name: 'Non member', position: Role.all.count + 1})
  end

  def down
    Role.delete_all(name: 'Non member')
  end
end
