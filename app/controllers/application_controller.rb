require 'rorganize/anonymous_user'
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :application
  include ApplicationHelper
  helper Rorganize::Managers::MenuManager::MenuHelper
  helper Rorganize::Managers::PermissionManager::PermissionManagerHelper
  helper Rorganize::Managers::ModuleManager::ModuleManagerHelper
  include Rorganize::SecurityFilter
  helper_method :sort_column, :sort_direction
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :authenticate unless RORganize::Application.config.rorganize_anonymous_access
  before_filter :smart_js_loader, :set_sessions
  around_filter :set_current_user
  after_filter :set_sessions

  def peek_enabled?
    Rails.env.eql?('development')
  end

  #Define which menu it concern (:project_menu, :admin_menu)
  def menu_context(context)
    @menu_context ||= []
    @menu_context << context
  end

  #Define which is the active(or selected) menu
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
    if !user_signed_in? && !RORganize::Application.config.rorganize_anonymous_access
      authenticate_user!
    end
  end

  def set_sessions
    session[controller_name.to_sym] ||= {}
    @sessions = session[controller_name.to_sym]
  end

  def set_current_user
    if current_user.nil?
      User.current = AnonymousUser.instance
    else
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
    unless options[:action].eql?('do_nothing')
      options[:action] = "js_templates/#{options[:action]}"
    else
      options[:action] = "../layouts/js_templates/#{options[:action]}"
    end
    options.except!(:response_header, :response_content)
    render options
  end

  def js_redirect_to(path)
    render js: %(window.location.href='#{path}') and return
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << User.permit_attributes
  end
end
