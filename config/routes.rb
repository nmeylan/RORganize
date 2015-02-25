RORganize::Application.routes.draw do


  get 'rorganize/:action', controller: 'rorganize'
  post 'rorganize/:action', controller: 'rorganize'

  resources :projects, except: [:edit, :update] do
    collection do
      post 'filter', path: ':filter'
      get 'overview', path: ':project_id/overview'
      get 'activity', path: ':project_id/activity'
      post 'activity_filter', path: ':project_id/activity_filter'
      get 'load_journal_activity', path: ':project_id/load_journal_activity/:item_id/:date'
      post 'archive', path: 'archive/:id'
      post 'activity_filter', path: ':project_id/activity_filter/:type'
      get 'members', path: ':project_id/members'
      get 'issues_completion', path: ':project_id/issues_completion'
    end
  end

  resources :comments, except: [:new, :index] do

  end
  scope 'projects/:project_id/:watchable_type/:watchable_id' do
    resources :watchers, only: [:index] do
      collection do
        post 'toggle'
      end
    end
  end
  scope 'administration/' do
    resources :users do
      collection do
        post 'register', path: 'register'
      end
    end
    resources :permissions, except: [:show] do
      collection do
        get 'list', path: ':role_name/list'
        post 'update_permissions', path: ':role_name/update_permissions'
      end
    end
    resources :roles, except: [:show]
    resources :trackers, except: [:show] do
      collection do
        post 'change_position'
      end
    end
    resources :issues_statuses, except: [:show] do
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
        delete 'delete_attachment', path: 'delete_attachment/:id'
        get 'download_attachment', path: 'download_attachment/:id'
        post 'edit_note', path: 'edit_note/:note_id'
        delete 'delete_note', path: 'delete_note/:note_id'
        get 'apply_custom_query', path: 'filter/:query_id'
        post 'add_predecessor', path: ':id/add_predecessor'
        delete 'del_predecessor', path: ':id/del_predecessor'
        get 'overview'
      end
    end
    resources :documents do
      collection do
        delete 'delete_attachment', path: 'delete_attachment/:id'
        get 'download_attachment', path: 'download_attachment/:id'
        get 'apply_custom_query', path: 'filter/:query_id'
        get 'toolbox'
        post 'toolbox'
      end
    end
    resource :roadmap, only: [:show] do
      collection do
        get 'gantt'
        post 'manage_gantt'
        get 'manage_gantt'
        get 'version', path: 'version/:id'
      end
    end
    resources :wiki, except: [:new, :show] do
      collection do
        get 'pages'
        get 'organize_pages'
        put 'set_organization'
      end
    end
    resources :wiki_pages, except: [:index] do
      collection do
        get 'new_home_page'
        get 'new_sub_page', path: ':id/new_sub_page'
      end
    end
    resources :settings, only: [:index, :update] do
      collection do
        post 'update_project_informations'
        get 'public_queries', path: 'queries'
        delete 'delete_attachment', path: 'delete_attachment/:id'
        get 'modules'
        post 'modules'
      end
    end
  end
  resources :queries, except: [:new] do
    collection do
      get 'new_project_query', path: 'new_project_query/:project_id/:query_type'
      put 'edit_query_filter', path: 'edit_query_filter/:query_id'
    end
  end
  scope 'projects/:project_id/settings/' do
    resources :versions, except: [:show] do
      collection do
        post 'change_position'
      end
    end
    resources :categories, except: [:show]
    resources :members, except: [:show, :edit, :update] do
      collection do
        post 'change_role', path: 'change_role/:member_id'

      end
    end
  end

  resources :administration do

  end

  resources :notifications, only: [:destroy, :index] do
    collection do
      delete 'destroy_all_for_project', path: 'destroy_all_for_project/:project_slug'
    end
  end

  resource :profile, only: [:show], path: 'my-account' do
    collection do
      get 'act_as'
      post 'change_password'
      get 'change_password'
      post 'change_email'
      get 'change_email'
      get 'change_avatar'
      post 'change_avatar'
      delete 'delete_avatar'
      get 'custom_queries'
      get 'projects'
      post 'activity_filter', path: 'activity_filter'
      get 'activities'
      get 'spent_time'
      post 'star_project', path: 'star_project/:project_id'
      post 'save_project_position'
      get 'notification_preferences'
      post 'notification_preferences'
    end
  end

  resources :time_entries, except: [:show, :index] do
    collection do
      get 'fill_overlay', path: 'fill_overlay/:issue_id'
      get 'fill_overlay', path: 'fill_overlay/:issue_id/:spent_on', as: 'fill_overlay_with_date'
    end
  end

  get '/projects', controller: :projects, action: :index
  get ':user', controller: 'rorganize', action: 'view_profile', as: 'view_profile'

  #MOUNT PLUGINS
  # mount AgileBoard::Engine => '/', as: 'agile_boards_route'
  mount Peek::Railtie => '/peek' if defined?(Peek)

  root to: 'rorganize#index'

  devise_for :users
end
