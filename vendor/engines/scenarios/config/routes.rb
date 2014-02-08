Scenarios::Engine.routes.draw do

  match "projects/:project_id/scenarios/index", :controller => "scenarios", :action => "index"
  match "projects/:project_id/scenarios/:scenario_id/steps/:id/create_simple_issue", :controller => "steps", :action => "create_simple_issue"
  match "projects/:project_id/scenarios/:scenario_id/steps/:id/add_issues", :controller => "steps", :action => "add_issues"
  match "projects/:project_id/scenarios/:scenario_id/steps/:id/load_issues", :controller => "steps", :action => "load_issues"
  match "projects/:project_id/scenarios/:scenario_id/steps/load_all_issues", :controller => "steps", :action => "load_all_issues"
  scope "projects/:project_id/" do
    resources :scenarios
  end
  scope "projects/:project_id/scenarios/:scenario_id/" do
    resources :steps
  end
end
