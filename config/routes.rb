ProjectManager::Application.routes.draw do
  devise_for :users

  match "rorganize/:action", :controller => 'rorganize'
  match 'projects', :to => 'projects#index', :via => :get

  scope "administration/" do
    resources :users
    resources :permissions do
      collection do
        get "list", :path => ":role_name/list"
        post "update_permissions", :path => ":role_name/update_permissions"
      end
    end
    resources :roles
    resources :trackers
    resources :issues_statuses do
      collection do
        post "change_position"
      end
    end
  end
  scope "project/:project_id/" do
    resources :issues do
      collection do
        get 'toolbox'
        post 'toolbox'
        get 'show_checklist_items'
        get 'issue_description'
        delete 'delete_attachment'
        get 'download_attachment'
        post 'save_checklist'
        post 'edit_note', :path => ":id/edit_note"
        post 'start_today'
        delete 'delete_note'
        get 'apply_custom_query', :path => "filter/:query_id"
        post 'add_predecessor', :path => ":id/add_predecessor"
        delete 'del_predecessor', :path => ":id/del_predecessor"
      end
    end
    resources :documents do
      collection do
        delete 'delete_attachment'
        get 'download_attachment'
        get 'toolbox'
        post 'toolbox'
      end
    end
    resources :roadmap do
      collection do
        get 'calendar'
        get 'version_description'
        get 'gantt'
      end
    end

    resources :settings, :except => "show" do
      collection do
        post "update_project_informations"
        get "public_queries", :path => "queries"
        delete 'delete_attachment'
        get "modules"
        post "modules"
      end
    end
  end
  resources :queries do

  end
  scope "project/:project_id/settings/" do
    resources :versions do
      collection do
        post "change_position"
      end
    end
    resources :categories
    resources :members, :except => "show" do
      collection do
        get "change_role"
        post "change_role"

      end
    end
  end

  resources :project do
    collection do
      get "overview", :path => ":project_id/overview"
      get "activity", :path => ":project_id/activity"
      get "load_journal_activity"
      post "archive", :path => "archive/:id"
      post "filter", :path => ":project_id/acitivity_filter"
    end
  end

  resources :administration do
    collection do
      get "public_queries", :path => "queries"
    end
  end
  resources :my do
    collection do
      get 'act_as'
      post 'change_password', :path => ':id/change_password'
      get 'change_password', :path => ':id/change_password'
      get 'custom_queries', :path => ':id/custom_queries'
      get 'my_projects', :path => ':id/my_projects'
      post "star_project"
      post "save_project_position"
    end
  end

  resources :coworkers do
    collection do
      get 'display_activities'
    end
  end
  #MOUNT PLUGINS
  mount Scenarios::Engine => "/", :as => "scenarios_route" #/scenarios

  match 'project/:project_id/scenarios/:action', :controller => 'scenarios'

  root :to => 'Rorganize#index'
end
