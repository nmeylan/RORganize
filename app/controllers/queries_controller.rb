# Author: Nicolas Meylan
# Date: 5 févr. 2013
# Encoding: UTF-8
# File: queries_controller.rb

class QueriesController < ApplicationController
  #  before_filter :find_project
  before_filter :check_permission
  before_filter :check_query_permission, :only => [:show, :edit, :destroy, :update]
  include ApplicationHelper
  def index
    respond_to do |format|
      format.html
    end
  end

  def new
    find_project
    @query = Query.new
    @query.object_type = params[:object_type]
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace_html "form_content", :partial => "queries/form"
        end
      end
    end
  end

  def create
    find_project
    @query = Query.new(params[:query])
    @query.author_id = current_user.id
    @query.project_id = @project.id
    @query.stringify_query = session[@project.identifier+'_controller_issues_filter']
    @query.stringify_params = session[@project.identifier+'_controller_issues_filter_params'].inspect
    if @query.save
      find_custom_queries
      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html "custom_queries", :partial => "issues/custom_queries"
            response.headers['flash-message'] = t(:successful_creation)
          end
        end
      end
    else
      respond_to do |format|
        format.js do
          render :update do |page|
            response.headers['flash-error-message'] = @query.errors.full_messages
          end
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    respond_to do |format|
      if @query.update_attributes(params[:query])
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
    @queries = Query.find_all_by_id(params[:queries])
    @query.destroy
    @queries.reject!{ |item| item.id.eql?(@query.id )}
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace "queries_content", :partial => "queries/list"
          response.headers['flash-message'] = t(:successful_deletion)
        end
      end
    end
  end

  private
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
    render_404 if @project.nil?
  end

  def find_custom_queries
    @custom_queries = Query.find(:all,
      :conditions => ["(project_id = ? AND (author_id = ? OR is_public = ?))
        OR (is_for_all = ? AND (author_id = ? OR is_public = ?))",
        @project.id,
        current_user.id,
        true,
        true,
        current_user.id,
        true
      ])
  end

  def check_query_permission
    @query = Query.find_by_id(params[:id])
    if (@query.is_public && !current_user.allowed_to?('public_queries','Queries',@project)) ||
        (!@query.is_public && !@query.author_id.eql?(current_user.id))
      render_403
    end
  end
end

