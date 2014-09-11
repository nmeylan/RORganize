class AddCommentsCounterCache < ActiveRecord::Migration
  def up
    add_column :issues, :comments_count, :integer, :default => 0
    add_column :documents, :comments_count, :integer, :default => 0

    sub = 'SELECT coalesce(count(c.id),0) FROM comments c WHERE i.id = c.commentable_id GROUP BY i.id'
    sql = "UPDATE issues i set i.comments_count=(#{sub})"
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    ActiveRecord::Base.connection.execute(sql)
    ActiveRecord::Base.connection.execute('UPDATE issues i SET i.comments_count = 0 WHERE i.comments_count IS NULL')
    sql = "UPDATE documents i set i.comments_count=(#{sub})"
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    ActiveRecord::Base.connection.execute(sql)
    ActiveRecord::Base.connection.execute('UPDATE documents i SET i.comments_count = 0 WHERE i.comments_count IS NULL')
  end

  def down
    remove_column :issues, :comments_count
    remove_column :documents, :comments_count

  end
end
