RORganize::Application.routes.draw do


  get 'rorganize/:action', :controller => 'rorganize'
  resources :projects do
    collection do
      post 'filter', :path => ':filter'
      get 'overview', :path => ':project_id/overview'
      get 'activity', :path => ':project_id/activity'
      get 'load_journal_activity', :path => ':project_id/load_journal_activity/:item_id/:date'
      post 'archive', :path => 'archive/:id'
      post 'activity_filter', :path => ':project_id/activity_filter/:type'
    end
  end
  scope 'administration/' do
    resources :users
    resources :permissions do
      collection do
        get 'list', :path => ':role_name/list'
        post 'update_permissions', :path => ':role_name/update_permissions'
      end
    end
    resources :roles
    resources :trackers
    resources :issues_statuses do
      collection do
        post 'change_position'
      end
    end
  end
  scope 'projects/:project_id/' do
    resources :issues do
      collection do
        get 'toolbox'
        post 'toolbox'
        get 'show_checklist_items', :path => 'show_checklist_items/:id'
        get 'issue_description', :path => 'issue_description/:id'
        delete 'delete_attachment', :path => 'delete_attachment/:id'
        get 'download_attachment'
        post 'save_checklist'
        get 'checklist'
        post 'edit_note', :path => 'edit_note/:note_id'
        post 'start_today', :path => 'start_today/:id'
        delete 'delete_note', :path => 'delete_note/:note_id'
        get 'apply_custom_query', :path => 'filter/:query_id'
        post 'add_predecessor', :path => ':id/add_predecessor'
        delete 'del_predecessor', :path => ':id/del_predecessor'
      end
    end
    resources :documents do
      collection do
        delete 'delete_attachment', :path => 'delete_attachment/:id'
        get 'download_attachment'
        get 'toolbox'
        post 'toolbox'
      end
    end
    resources :roadmap do
      collection do
        get 'calendar'
        get 'version_description', :path => 'version_description/:id'
        get 'gantt'
      end
    end
    resources :wiki do
      collection do
        get 'pages'
        get 'organize_pages'
        put 'set_organization'
      end
    end
    resources :wiki_pages do
      collection do
        get 'new_home_page'
        get 'new_sub_page', :path => ':id/new_sub_page'
      end
    end
    resources :settings, :except => 'show' do
      collection do
        post 'update_project_informations'
        get 'public_queries', :path => 'queries'
        delete 'delete_attachment', :path => 'delete_attachment/:id'
        get 'modules'
        post 'modules'
      end
    end
  end
  resources :queries do
    collection do
      get 'new_project_query', :path => 'new_project_query/:project_id/:query_type'
      put 'edit_query_filter', :path => 'edit_query_filter/:query_id'
    end
  end
  scope 'projects/:project_id/settings/' do
    resources :versions do
      collection do
        post 'change_position'
      end
    end
    resources :categories
    resources :members, :except => 'show' do
      collection do
        post 'change_role', :path => 'change_role/:member_id'

      end
    end
  end

  resources :administration do
    collection do
      get 'public_queries', :path => 'queries'
    end
  end
  resources :my do
    collection do
      get 'act_as'
      post 'change_password', :path => ':id/change_password'
      get 'change_password', :path => ':id/change_password'
      get 'custom_queries', :path => ':id/custom_queries'
      get 'my_projects', :path => ':id/my_projects'
      get 'my_assigned_requests', :path => ':id/my_assigned_requests'
      get 'my_submitted_requests', :path => ':id/my_submitted_requests'
      get 'my_activities', :path => ':id/my_activities'
      get 'my_spent_time', :path => ':id/my_spent_time'
      post 'star_project', :path => 'star_project/:project_id'
      post 'save_project_position'
    end
  end

  resources :coworkers do
    collection do
      get 'display_activities', :path => 'display_activities/:id'
    end
  end

  resources :time_entries do
    collection do
      get 'fill_overlay', :path => 'fill_overlay/:issue_id'
      get 'fill_overlay', :path => 'fill_overlay/:issue_id/:spent_on', :as => 'fill_overlay_with_date'
    end
  end

  get '/projects', :controller => :projects, :action => :index

  #MOUNT PLUGINS
  mount Scenarios::Engine => '/', :as => 'scenarios_route' #/scenarios

  get 'projects/:project_id/scenarios/:action', :controller => 'scenarios'

  root :to => 'rorganize#index'

  devise_for :users
end
