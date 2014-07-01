# Author: Nicolas Meylan
# Date: 8 mai 2013
# Encoding: UTF-8
# File: coworkers_controller.rb

class CoworkersController < ApplicationController
  before_filter :check_permission, :except => [:index]
  before_filter {|c| c.top_menu_item('coworkers')}

  def index
    @coworkers = current_user.coworkers_per_project
    respond_to do |format|
      format.html {}
    end
  end

  def display_activities
    if params[:getAct].eql?('true')
      @coworker = Member.find_by_id(params[:id])
    end

    respond_to do |format|
      format.html
      format.js{ respond_to_js :locals => {:activities => @coworker.activities} }
    end
  end

end
