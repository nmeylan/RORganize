require 'rorganize/anonymous_user'
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :application
  include ApplicationHelper
  helper Rorganize::Managers::MenuManager::MenuHelper
  helper Rorganize::Managers::PermissionManager::PermissionManagerHelper
  helper Rorganize::Managers::ModuleManager::ModuleManagerHelper
  include Rorganize::Filters::SecurityFilter
  helper_method :sort_column, :sort_direction
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate unless RORganize::Application.config.rorganize_anonymous_access
  before_action :smart_js_loader, :set_sessions
  around_filter :set_current_user
  before_action :set_sessions


  rescue_from ActiveRecord::RecordNotFound do |exception|
    set_current_user { render_404 }
  end

  rescue_from ActionController::RoutingError do |exception|
   if exception.message.eql?('Forbidden')
     set_current_user { render_403 }
   end
  end

  def peek_enabled?
    Rails.env.eql?('development')
  end

  #Define which menu it concerns (:project_menu, :admin_menu)
  def menu_context(context)
    @menu_context ||= []
    @menu_context << context
  end

  #Define which is the active(or selected) menu
  def menu_item(controller, action = nil)
    @current_menu_item = 'menu-'
    @current_menu_item+= "#{controller.tr('_', '-')}"
    if action
      @current_menu_item += "-#{action}"
    end
  end

  def top_menu_item(menu_name)
    @current_top_menu_item = 'menu-'
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
      set_current_user_act_as
    end
    yield
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver
    User.current = nil
  end

  def set_current_user_act_as
    if User.current
      User.current.act_as_admin(session['act_as'])
    end
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
    if options[:action].eql?('do_nothing')
      options[:action] = "../layouts/js_templates/#{options[:action]}"
    else
      options[:action] = "js_templates/#{options[:action]}"
    end
    options.except!(:response_header, :response_content)
    render options
  end

  def js_redirect_to(path)
    render js: %(window.location.href='#{path}') and return
  end

  def status_response(status, *values)
    status = status ? :success : :failure
    options = values.extract_options!
    message = options[:message] ? options[:message] : ''
    if status.eql?(:success)
      response.headers['flash-message'] = message
    elsif status.eql?(:failure)
      response.headers['flash-error-message'] = message
    end
    {header: status, message: message}
  end

  def class_name_to_controller_name(class_name)
    i = 0
    class_name.pluralize.gsub(/([A-Z])/) { |occurrence| i += 1; i == 1 ? occurrence : '_'+occurrence }
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << User.permit_attributes
  end
end
