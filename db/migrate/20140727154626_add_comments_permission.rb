class AddCommentsPermission < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Documents', :action => 'comment', :name => 'Add Comment (edit and delete own comment)')
    Permission.create(:controller => 'Issues', :action => 'comment', :name => 'Add Comment (edit and delete own comment)')
    Permission.create(:controller => 'WikiPages', :action => 'comment', :name => 'Add Comment (edit and delete own comment)')
    Permission.create(:controller => 'Documents', :action => 'edit_comment_not_owner', :name => 'Edit others comment')
    Permission.create(:controller => 'Issues', :action => 'edit_comment_not_owner', :name => 'Edit others comment')
    Permission.create(:controller => 'WikiPages', :action => 'edit_comment_not_owner', :name => 'Edit others comment')
    Permission.create(:controller => 'Documents', :action => 'destroy_comment_not_owner', :name => 'Delete others comment')
    Permission.create(:controller => 'Issues', :action => 'destroy_comment_not_owner', :name => 'Delete others comment')
    Permission.create(:controller => 'WikiPages', :action => 'destroy_comment_not_owner', :name => 'Delete others comment')
  end

  def down
    Permission.delete_all(:action => 'comment')
    Permission.delete_all(:action => 'edit_comment_not_owner')
    Permission.delete_all(:action => 'destroy_comment_not_owner')
  end
end
