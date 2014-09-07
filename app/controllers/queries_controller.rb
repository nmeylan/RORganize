# Author: Nicolas Meylan
# Date: 5 févr. 2013
# Encoding: UTF-8
# File: queries_controller.rb

class QueriesController < ApplicationController
  before_filter {|c| c.add_action_alias = {'new_project_query' => 'new'}}
  before_filter :find_project, only: [:create]
  before_filter :check_permission
  before_filter :check_query_permission, :only => [:show, :edit, :destroy, :update]
  before_filter { |c| c.top_menu_item('administration') }

  def index
    respond_to do |format|
      format.html
    end
  end

  def new_project_query
    find_project
    @query = Query.new
    @query.object_type = params[:query_type]
    respond_to do |format|
      format.js { respond_to_js :locals => {:new => true} }
    end
  end

  def create
    find_project
    @query = Query.new(query_params)
    @query.author_id = User.current.id
    @query.project_id = @project.id
    filter = @query.object_type.constantize.conditions_string(params[:filter])
    @query.stringify_query = filter
    @query.stringify_params = params[:filter].inspect
    success = @query.save

    respond_to do |format|
      format.js do
        if success
          case @query.object_type
            when 'Issue' then js_redirect_to(apply_custom_query_issues_path(@query.project.slug, @query.slug))
          end
        else
          respond_to_js :action => 'new_project_query', :locals => {:new => false, :success => success}, :response_header => :failure, :response_content => @query.errors.full_messages
        end
      end
    end

  end

  def show
    @query_decorator = @query.decorate
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def edit_query_filter
    @query = Query.find_by_slug(params[:query_id])
    filter = @query.object_type.constantize.conditions_string(params[:filter])
    @query.stringify_query = filter
    @query.stringify_params = params[:filter].inspect
    success = @query.save
    respond_to do |format|
      format.js do
        if success
          respond_to_js :action => 'do_nothing', :locals => {:new => false, :success => success}, :response_header => :success, :response_content => t(:successful_update)
        else
          respond_to_js :action => 'do_nothing', :locals => {:new => false, :success => success}, :response_header => :failure, :response_content => @query.errors.full_messages
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @query.update_attributes(query_params)
        format.html do
          flash[:notice] = t(:successful_update)
          redirect_to query_path(@query.id)
        end
      else
        format.html do
          render :action => 'edit', :controller => 'queries', :id => @query.id
        end
      end
    end
  end

  def destroy
    @query.destroy
    respond_to do |format|
      format.js do
        respond_to_js :response_header => :success, :response_content => t(:successful_deletion), :locals => {:id => @query.id}
      end
    end
  end

  private
  def find_project
    @project = Project.find_by_slug(params[:project_id])
    render_404 if @project.nil?
  end

  def check_query_permission
    @query = Query.find_by_id(params[:id])
    if (@query.is_public && !User.current.allowed_to?('public_queries', 'Queries', Project.find_by_slug(params[:project_id]))) ||
        (!@query.is_public && !@query.author_id.eql?(User.current.id))
      render_403
    end
  end

  def query_params
    params.require(:query).permit(Query.permit_attributes)
  end
end

