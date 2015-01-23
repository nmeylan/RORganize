# Author: Nicolas Meylan
# Date: 8 juil. 2012
# Encoding: UTF-8
# File: issues_controller.rb
require 'shared/history'
require 'issues/overview_report'
require 'issues/form_content'
require 'issues/issue_overview_hash'
class IssuesController < ApplicationController
  before_action { |c| c.add_action_alias= {'overview' => 'index', 'apply_custom_query' => 'index'} }
  before_action :find_project_with_dependencies, only: [:index, :new, :create, :update, :edit, :toolbox, :apply_custom_query]
  before_action :check_permission, except: [:toolbox]
  before_action :find_issue, only: [:edit, :update, :destroy, :show]
  before_action :check_not_owner_permission, only: [:edit, :update, :destroy]
  include Rorganize::RichController
  include Rorganize::RichController::ToolboxCallback
  include Rorganize::Filters::NotificationFilter
  include Rorganize::RichController::ProjectContext
  include Rorganize::RichController::GanttCallbacks
  include Rorganize::RichController::AttachableCallbacks
  include Rorganize::RichController::CustomQueriesCallback

  #RESTFULL CRUD Methods
  #GET /project/:project_identifier/issues
  def index
    session_list_type
    filter(Issue)
    load_issues
    find_custom_queries
    respond_to do |format|
      format.html { render :index }
      format.js { respond_to_js }
    end
  end

  def show
    @issue_decorator = @issue_decorator.decorate(context: {project: @project})
    generic_show_callback({history: History.new(Journal.journalizable_activities(@issue_decorator.id, 'Issue'), @issue_decorator.comments)})
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
    generic_create_callback(@issue_decorator, -> { issue_path(@project.slug, @issue_decorator.id) }, {form_content: FormContent.new(@project).content})
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
    update_attachable_callback(@issue_decorator, issue_path(@project.slug, @issue_decorator.id), issue_params, {form_content: FormContent.new(@project).content})
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

  #Find custom queries
  def find_custom_queries
    super(Issue.to_s)
  end

  def load_issues
    @issues_decorator = load_paginated_collection(Issue, 'issues.id')
  end

  def session_list_type
    @sessions[:list_type] ||= :overview
    @sessions[:list_type] = params[:list_type].to_sym if params[:list_type]
  end

  def issue_params
    params.require(:issue).permit(Issue.permit_attributes)
  end

  def value_params
    params.require(:value).permit(Issue.permit_bulk_edit_values)
  end

  def find_project_with_dependencies
    @project = Project.includes(:attachments, :versions, :categories, :trackers, members: :user).find_by!(slug: params[:project_id])
    gon.project_id = @project.slug
  end

  def find_issue
    @issue_decorator = Issue.eager_load([:tracker, :version, :assigned_to, :category, :attachments,
                                         :parent, :author, status: :enumeration, comments: :author])
                           .find_by!(id: params[:id], project_id: @project.id)
    @issue_decorator = @issue_decorator.decorate(context: {project: @project})
  end

  alias :load_collection :load_issues


end
