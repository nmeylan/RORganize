class ApplicationController < ActionController::Base
  protect_from_forgery
  helper Rorganize::MenuManager::MenuHelper
  helper Rorganize::PermissionManager::PermissionManagerHelper
  before_filter :authenticate, :smart_js_loader
  around_filter :set_current_user

  def menu_context(context)
    @menu_context ||= []
    @menu_context << context
  end

  def menu_item(controller, action = nil)
    @current_menu_item = 'menu_'
    @current_menu_item+= "#{controller}"
    if action
      @current_menu_item += "_#{action}"
    end
  end

  def top_menu_item(menu_name)
    @current_top_menu_item = 'menu_'
    @current_top_menu_item+= "#{menu_name}"

  end

  def authenticate
    if !user_signed_in?
      authenticate_user!
    end
  end

  def find_project
    @project = Project.includes(:attachments).find_by_slug(params[:project_id])
    render_404 if @project.nil?
  end

  def set_current_user
    unless current_user.nil?
      User.current = current_user
    end
    yield
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver
    User.current = nil
  end

  #Define for JavaScript files wich must be loaded
  def smart_js_loader
    gon.controller = params[:controller]
    gon.action = params[:action]
  end

  protected
  #Options : same as render method
  #Except response_header : :success, :failure
  # response_content : text
  def respond_to_js(options={})
    unless options[:action]
      options[:action] = params[:action]
    end
    message = options[:response_content] ? options[:response_content] : ''
    if options[:response_header].eql?(:success)
      response.headers['flash-message'] = message
    elsif options[:response_header].eql?(:failure)
      response.headers['flash-error-message'] = message
    end
    options[:action] = "js_templates/#{options[:action]}"
    options.except!(:response_header, :response_content)
    render options
  end

  def js_redirect_to(path)
    render js: %(window.location.href='#{path}') and return
  end
end
