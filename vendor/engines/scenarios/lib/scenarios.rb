require "scenarios/engine"
require 'rubygems'

module MyEngine
  class Engine < Rails::Engine
    initializer 'scenarios.init_scenario_engine' do |app|
      scenario_menu
    end

    def scenario_menu
      require Scenarios::Engine.root.join("..","..","..","lib","rorganize","menu_manager")
      I18n.load_path += Dir[Scenarios::Engine.root.join("..","..","..",'config', 'locales', '**', '*.{rb,yml}')]
      Rorganize::MenuManager.map :project_menu do |menu|
        #menu.add(menu_name, menu_label, menu_url, options)
        #If you have one menu item per controller
        #Id must be declare as following: menu_controller
        #If you have more than one item per controller
        #Id must be declare as following: menu_controller_action
        menu.add(:scenarios, I18n.t(:label_scenarios), {:controller => 'scenarios', :action => 'index'}, {:id => "menu_scenarios", :after => :requests})
      end
    end
  end
end