# Author: Nicolas Meylan
# Date: 27 oct. 2012
# Encoding: UTF-8
# File: trackers_controller.rb

class TrackersController < ApplicationController
  include Rorganize::RichController
  before_filter :check_permission
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('administration') }

  #Get /administration/trackers
  def index
    @trackers_decorator = Tracker.paginated(@sessions[:current_page],@sessions[:per_page], order('trackers.name')).decorate
    respond_to do |format|
      format.html
      format.js { respond_to_js }
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
    @tracker = Tracker.find_by_id(params[:id])
    respond_to do |format|
      format.html
    end
  end

  #PUT /administration/trackers/edit/:id
  def update
    @tracker = Tracker.find_by_id(params[:id])
    @tracker.attributes = tracker_params
    generic_update_callback(@tracker, trackers_path)
  end

  #DELETE /administration/roles/:id
  def destroy
    @tracker = Tracker.find_by_id(params[:id])
    simple_js_callback(@tracker.destroy, :delete, {id: params[:id]})
  end

  private
  def tracker_params
    params.require(:tracker).permit(Tracker.permit_attributes)
  end
end

