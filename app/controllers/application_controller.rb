class ApplicationController < ActionController::Base
  protect_from_forgery
  helper Rorganize::MenuManager::MenuHelper

  def menu_context(context)
    @menu_context ||= []
    @menu_context << context
  end

  def menu_item(controller, action = nil)
    @current_menu_item = "menu_"
    @current_menu_item+= "#{controller}"
    if action
      @current_menu_item += "_#{action}"
    end
  end

  def find_project
    @project = Project.find_by_identifier(params[:project_id])
    render_404 if @project.nil?
  end
end
