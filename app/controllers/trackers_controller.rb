# Author: Nicolas Meylan
# Date: 27 oct. 2012
# Encoding: UTF-8
# File: trackers_controller.rb

class TrackersController < ApplicationController
  include Rorganize::RichController
  before_filter :check_permission
  before_filter { |c| c.menu_context :admin_menu }
  before_filter { |c| c.menu_item(params[:controller])}
  before_filter {|c| c.top_menu_item('administration')}

  #Get /administration/trackers
  def index
    @trackers_decorator = Tracker.paginated(@sessions[:current_page], @sessions[:per_page], order('trackers.name')).decorate
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
    respond_to do |format|
      if @tracker.save
        flash[:notice] = t(:successful_creation)
        format.html {redirect_to :action => 'index'}
      else
        format.html  { render :action => 'new' }
        format.json  { render :json => @tracker.errors,
          :status => :unprocessable_entity }
      end
    end
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
    respond_to do |format|
      if @tracker.update_attributes(tracker_params)
        flash[:notice] = t(:successful_update)
        format.html {redirect_to :action => 'index'}
      else
        format.html {render :action => 'edit'}
      end
    end
  end

  #DELETE /administration/roles/:id
  def destroy
    @tracker = Tracker.find_by_id(params[:id])
    @tracker.destroy
    @trackers = Tracker.select('*')
    respond_to do |format|
      format.html {redirect_to :action => 'index'}
      format.js {respond_to_js :response_header => :success, :response_content => t(:successful_deletion), :locals => { :id => @tracker.id}}
    end
  end

  private
  def tracker_params
    params.require(:tracker).permit(Tracker.permit_attributes)
  end
end

