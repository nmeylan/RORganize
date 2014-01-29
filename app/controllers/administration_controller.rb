# Author: Nicolas Meylan
# Date: 25 sept. 2012
# Encoding: UTF-8
# File: administration_controller.rb

class AdministrationController < ApplicationController
  before_filter :check_queries_permission, :only => [:public_queries]
  before_filter :check_permission, :except => [:public_queries]
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller], params[:action]) }
  before_filter {|c| c.top_menu_item('administration')}
  include ApplicationHelper

  def index
    respond_to do |format|
      format.html
    end
  end

  def public_queries
    @queries = Query.where(['is_public = ? AND is_for_all = ?', true, true])
    respond_to do |format|
      format.html
    end
  end

  private
  def check_queries_permission
    unless current_user.allowed_to?(params[:action], 'Queries')
      render_403
    end
  end
end
