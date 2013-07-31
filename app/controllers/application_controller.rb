class ApplicationController < ActionController::Base
  protect_from_forgery
  helper Rorganize::MenuManager::MenuHelper
  helper Rorganize::PermissionManager::PermissionManagerHelper
  before_filter :authenticate_user!, :set_current_user
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

  def top_menu_item(menu_name)
    @current_top_menu_item = "menu_"
    @current_top_menu_item+= "#{menu_name}"

  end

  def find_project
    @project = Project.find_by_slug(params[:project_id])
    render_404 if @project.nil?
  end
  
  def set_current_user
    User.current = current_user
  end
end
