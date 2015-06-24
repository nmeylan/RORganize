# Author: Nicolas Meylan
# Date: 27 oct. 2012
# Encoding: UTF-8
# File: trackers_controller.rb

class TrackersController < ApplicationController
  include RichController

  before_action :find_tracker, only: [:show, :edit, :update, :destroy, :change_position]
  before_action :check_permission
  before_action { |c| c.menu_context :admin_menu }
  before_action { |c| c.menu_item(params[:controller]) }
  before_action { |c| c.top_menu_item('administration') }

  #Get /administration/trackers
  def index
    @trackers_decorator = Tracker.paginated(@sessions[:current_page], @sessions[:per_page], order('trackers.name')).decorate
    if request.xhr?
      render json: {list: @trackers_decorator.display_collection}
    else
      render :index
    end
  end

  #GET /administration/trackers/new
  def new
    @tracker = Tracker.new
    respond_to do |format|
      format.html
    end
  end

  #POST /administration/trackers/new
  def create
    @tracker = Tracker.new(tracker_params)
    generic_create_callback(@tracker, trackers_path)
  end

  #GET /administration/trackers/edit/:id
  def edit
    respond_to do |format|
      format.html
    end
  end

  #PUT /administration/trackers/edit/:id
  def update
    @tracker.attributes = tracker_params
    generic_update_callback(@tracker, trackers_path)
  end

  #DELETE /administration/roles/:id
  def destroy
    simple_js_callback(@tracker.destroy, :delete, @tracker, {id: params[:id]})
  end

  def change_position
    saved = @tracker.change_position(params[:operator])
    @trackers_decorator = Tracker.paginated(@sessions[:current_page], @sessions[:per_page], 'trackers.position').decorate(context: {project: @project})
    simple_js_callback(saved, :update, @tracker, list: @trackers_decorator.display_collection)
  end

  private
  def tracker_params
    params.require(:tracker).permit(Tracker.permit_attributes)
  end

  def find_tracker
    @tracker = Tracker.find(params[:id])
    @tracker_decorator = @tracker.decorate(context: {project: @project})
  end
end

