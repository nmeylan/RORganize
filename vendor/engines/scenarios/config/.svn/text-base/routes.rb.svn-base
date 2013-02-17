Scenarios::Engine.routes.draw do

  match "project/:project_id/scenarios/index", :controller => "scenarios", :action => "index"
  match "project/:project_id/scenarios/:scenario_id/steps/:id/create_simple_issue", :controller => "steps", :action => "create_simple_issue"
  match "project/:project_id/scenarios/:scenario_id/steps/:id/add_issues", :controller => "steps", :action => "add_issues"
  match "project/:project_id/scenarios/:scenario_id/steps/:id/load_issues", :controller => "steps", :action => "load_issues"
  match "project/:project_id/scenarios/:scenario_id/steps/load_all_issues", :controller => "steps", :action => "load_all_issues"
  scope "project/:project_id/" do
    resources :scenarios
  end
  scope "project/:project_id/scenarios/:scenario_id/" do
    resources :steps
  end
end
