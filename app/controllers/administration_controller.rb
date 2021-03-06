# Author: Nicolas Meylan
# Date: 25 sept. 2012
# Encoding: UTF-8
# File: administration_controller.rb

class AdministrationController < ApplicationController
  before_action :check_permission
  before_action { |c| c.menu_context :admin_menu }
  before_action { |c| c.menu_item(params[:controller], params[:action]) }
  before_action { |c| c.top_menu_item('administration') }

  helper QueriesHelper

  def index
    respond_to do |format|
      format.html
    end
  end

end
