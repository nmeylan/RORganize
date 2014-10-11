# Author: Nicolas Meylan
# Date: 8 juil. 2012
# Encoding: UTF-8
# File: issues_controller.rb
require 'shared/history'
require 'issues/overview_report'
require 'issues/form_content'
require 'issues/issue_overview_hash'
class IssuesController < ApplicationController
  before_filter { |c| c.add_action_alias= {'overview' => 'index', 'apply_custom_query' => 'index'} }
  before_filter :find_project_with_dependencies, only: [:index, :new, :create, :update, :edit, :toolbox, :apply_custom_query]
  before_filter :check_permission, except: [:toolbox]
  before_filter :find_issue, only: [:edit, :update, :destroy]
  before_filter :check_not_owner_permission, only: [:edit, :update, :destroy]
  include Rorganize::RichController
  include Rorganize::RichController::ToolboxCallback
  include Rorganize::Filters::NotificationFilter
  include Rorganize::RichController::ProjectContext
  include Rorganize::RichController::GanttCallbacks
  require 'will_paginate'

  #RESTFULL CRUD Methods
  #GET /project/:project_identifier/issues
  def index
    filter
    load_issues
    find_custom_queries
    respond_to do |format|
      format.html { render :index }
      format.js { respond_to_js }
    end
  end

  def show
    @issue_decorator = Issue.eager_load([:tracker, :version, :assigned_to, :category, :attachments, :parent, :author, status: :enumeration, comments: :author]).find_by_id(params[:id])
    if @issue_decorator.nil?
      render_404
    else
      @issue_decorator = @issue_decorator.decorate(context: {project: @project})
      generic_show_callback(@issue_decorator)
    end
  end

  #GET /project/:project_identifier/issues/new
  def new
    @issue_decorator = Issue.new.decorate(context: {project: @project})
    @issue_decorator.attachments.build
    respond_to do |format|
      format.html { render :new, locals: {form_content: FormContent.new(@project).content} }
    end
  end

  #POST/project/:project_identifier/issues/
  def create
    @issue_decorator = @project.issues.build(issue_params).decorate(context: {project: @project})
    @issue_decorator.author = User.current
    respond_to do |format|
      if @issue_decorator.save
        success_generic_create_callback(format, issue_path(@project.slug, @issue_decorator.id))
      else
        error_generic_create_callback(format, @issue_decorator, {form_content: FormContent.new(@project).content})
      end
    end
  end

  #GET /project/:project_identifier/issues/:id/edit
  def edit
    respond_to do |format|
      format.html { render :edit, locals: {form_content: FormContent.new(@project).content} }
    end
  end

  #PUT /project/:project_identifier/issues/:id
  def update
    @issue_decorator.attributes = issue_params
    respond_to do |format|
      if  !@issue_decorator.changed? && !any_attachement_uploaded?
        success_generic_update_callback(format, issue_path(@project.slug, @issue_decorator.id), false)
        #If attributes were updated
      elsif @issue_decorator.save && @issue_decorator.save_attachments
        success_generic_update_callback(format, issue_path(@project.slug, @issue_decorator.id))
      else
        error_generic_update_callback(format, @issue_decorator, {form_content: FormContent.new(@project).content})
      end
    end
  end



  #DELETE /project/:project_identifier/issues/:id
  def destroy
    generic_destroy_callback(@issue_decorator, issues_path)
  end


  #GET /project/:project_identifier/issues/toolbox
  def toolbox
    collection = Issue.where(id: params[:ids]).eager_load(:version, :assigned_to, :category, status: [:enumeration])
    toolbox_callback(collection, Issue, @project)
  end

  def apply_custom_query
    query = Query.find_by_slug(params[:query_id])
    if query
      @sessions[@project.slug][:sql_filter] = query.stringify_query
      @sessions[@project.slug][:json_filter] = JSON.parse(query.stringify_params.gsub('=>', ':'))
    end
    index
  end



  def overview
    overview_report = OverviewReport.new(@project.id)
    overview_object = IssueOverviewHash.new(overview_report.content, @project.issues.count)
    respond_to do |format|
      format.html { render :overview, locals: {overview: overview_object} }
    end
  end

  #Private methods
  private
  #Check if current user is owner of issue
  def check_owner
    @issue_decorator.author_id.eql?(User.current.id)
  end

  def filter
    @sessions[@project.slug] ||= {}
    apply_filter(Issue, params, @sessions[@project.slug])
  end

  #Find custom queries
  def find_custom_queries
    @custom_queries_decorator = Query.available_for(User.current, @project.id).decorate
  end

  def load_issues
    gon.DOM_filter = view_context.issues_generics_form_to_json
    gon.DOM_persisted_filter = @sessions[@project.slug][:json_filter].to_json
    filter = @sessions[@project.slug][:sql_filter]
    @issues_decorator = Issue.filter(filter, @project.id).paginated(@sessions[:current_page], @sessions[:per_page], order('issues.id'), [:tracker, :version, :assigned_to, :category, :project, :attachments, :author, status: [:enumeration]]).decorate(context: {project: @project})
  end

  def issue_params
    params.require(:issue).permit(Issue.permit_attributes)
  end

  def value_params
    params.require(:value).permit(Issue.permit_bulk_edit_values)
  end

  def find_project_with_dependencies
    @project = Project.includes(:attachments, :versions, :categories, :trackers, members: :user).where(slug: params[:project_id])[0]
    gon.project_id = @project.slug
  rescue => e
    render_404
  end

  def find_issue
    @issue_decorator = Issue.eager_load(:attachments).where(id: params[:id])[0]
    if @issue_decorator
      @issue_decorator = @issue_decorator.decorate(context: {project: @project})
    else
      render_404
    end
  end

  def any_attachement_uploaded?
    issue_params[:existing_attachment_attributes] || issue_params[:new_attachment_attributes]
  end

  alias :load_collection :load_issues


end
