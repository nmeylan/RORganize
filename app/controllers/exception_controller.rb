# Author: Nicolas Meylan
# Date: 08.09.14
# Encoding: UTF-8
# File: exception_controller.rb

class ExceptionController < ApplicationController

  #Response
  respond_to :html, :xml, :json

  #Dependencies
  before_action :status

  #Layout
  layout :layout_status

  ####################
  #      Action      #
  ####################

  #Show
  def show
    case @status
      when 404
        render_404
      when 403
        render_403
      else
        render_500
    end
  end

  ####################
  #   Dependencies   #
  ####################

  protected

  #Info
  def status
    @exception = env['action_dispatch.exception']
    @status = ActionDispatch::ExceptionWrapper.new(env, @exception).status_code
    @response = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]
  end

  #Format
  def details
    @details ||= {}.tap do |h|
      I18n.with_options scope: [:exception, :show, @response], exception_name: @exception.class.name, exception_message: @exception.message do |i18n|
        h[:name] = i18n.t "#{@exception.class.name.underscore}.title", default: i18n.t(:title, default: @exception.class.name)
        h[:message] = i18n.t "#{@exception.class.name.underscore}.description", default: i18n.t(:description, default: @exception.message)
      end
    end
  end

  helper_method :details

  ####################
  #      Layout      #
  ####################

  private

  #Layout
  def layout_status
    'application'
  end

end