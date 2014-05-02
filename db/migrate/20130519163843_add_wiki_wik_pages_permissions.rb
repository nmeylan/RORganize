class AddWikiWikPagesPermissions < ActiveRecord::Migration
  def up
    Permission.create(:controller => 'Wiki', :action => 'index', :name => 'View wiki', :is_locked => true)
    Permission.create(:controller => 'Wiki', :action => 'new', :name => 'Create wiki', :is_locked => true)
    Permission.create(:controller => 'Wiki', :action => 'destroy', :name => 'Destroy wiki', :is_locked => true)
    Permission.create(:controller => 'Wiki', :action => 'set_organization', :name => 'Organize wiki pages', :is_locked => true)
    Permission.create(:controller => 'Wiki', :action => 'pages', :name => 'View wiki pages', :is_locked => true)
    Permission.create(:controller => 'Wiki_pages', :action => 'new', :name => 'Create wiki page', :is_locked => true)
    Permission.create(:controller => 'Wiki_pages', :action => 'show', :name => 'View wiki page', :is_locked => true)
    Permission.create(:controller => 'Wiki_pages', :action => 'edit', :name => 'Edit wiki page', :is_locked => true)
    Permission.create(:controller => 'Wiki_pages', :action => 'edit_not_owner', :name => 'Edit wiki page when not owner', :is_locked => true)
    Permission.create(:controller => 'Wiki_pages', :action => 'destroy', :name => 'Delete wiki page', :is_locked => true)
    Permission.create(:controller => 'Wiki_pages', :action => 'destroy_not_owner', :name => 'Destroy wiki page when not owner', :is_locked => true)
    Permission.create(:controller => 'Wiki_pages', :action => 'comment', :name => 'Comment wiki page', :is_locked => true)
  end

  def down
    Permission.delete_all(:controller => 'Wiki', :action => 'index', :name => 'View wiki', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki', :action => 'pages', :name => 'View wiki pages', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki', :action => 'new', :name => 'Create wiki', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki', :action => 'destroy', :name => 'Destroy wiki', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki', :action => 'set_organization', :name => 'Organize wiki pages', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki_pages', :action => 'new', :name => 'Create wiki page', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki_pages', :action => 'show', :name => 'View wiki page', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki_pages', :action => 'edit', :name => 'Edit wiki page', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki_pages', :action => 'edit_not_owner', :name => 'Edit wiki page when not owner', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki_pages', :action => 'destroy', :name => 'Delete wiki page', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki_pages', :action => 'destroy_not_owner', :name => 'Destroy wiki page when not owner', :is_locked => true)
    Permission.delete_all(:controller => 'Wiki_pages', :action => 'comment', :name => 'Comment wiki page', :is_locked => true)
  end
end
