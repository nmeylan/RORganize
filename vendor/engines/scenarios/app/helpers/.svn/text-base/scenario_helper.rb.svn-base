module ScenarioHelper
  module ProjectHelper
    def project_menu_tabs
      super.insert(4, {:name => t(:label_scenarios), :action => 'index', :controller => 'scenarios',
        :path =>{ :controller => 'scenarios', :action => 'index', :project_id => @project.slug}, :class => 'item_border'})
    end


  end
  include ProjectHelper
end
