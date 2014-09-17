# Author: Nicolas Meylan
# Date: 8 juil. 2012
# Encoding: UTF-8
# File: issues_controller.rb
require 'shared/history'
require 'issues/issue_overview_hash'
class IssuesController < ApplicationController
  before_filter { |c| c.add_action_alias= {'overview' => 'index', 'apply_custom_query' => 'index'}}
  before_filter :find_project_with_depedencies, only: [:index, :new, :edit, :toolbox]
  before_filter :check_permission, :except => [:toolbox, :download_attachment, :start_today]
  before_filter :find_issue, only: [:edit, :update, :destroy]
  before_filter :check_not_owner_permission, :only => [:edit, :update, :destroy]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }
  include Rorganize::RichController
  require 'will_paginate'

  #RESTFULL CRUD Methods
  #GET /project/:project_identifier/issues
  def index
    filter
    load_issues
    find_custom_queries
    respond_to do |format|
      format.html { render 'issues/index' }
      format.js { respond_to_js }
    end
  end

  def show
    @issue_decorator = Issue.eager_load([:tracker, :version, :assigned_to, :category, :attachments, :parent, :author, status: :enumeration, comments: :author]).find_by_id(params[:id])
    if @issue_decorator.nil?
      render_404
    else
      @issue_decorator = @issue_decorator.decorate(context: {project: @project})
      respond_to do |format|
        format.html { render :action => 'show', :locals => {:history => History.new(Journal.issue_activities(@issue_decorator.id), @issue_decorator.comments)} }
      end
    end
  end

  #GET /project/:project_identifier/issues/new
  def new
    @issue_decorator = Issue.new.decorate(context: {project: @project})
    @issue_decorator.attachments.build
    respond_to do |format|
      format.html { render :action => 'new', :locals => {:form_content => form_content} }
    end
  end

  #POST/project/:project_identifier/issues/
  def create
    @issue_decorator = Issue.new(issue_params).decorate(context: {project: @project})
    @issue_decorator.created_at = Time.now.to_formatted_s(:db)
    @issue_decorator.updated_at = Time.now.to_formatted_s(:db)
    @issue_decorator.project_id = @project.id
    @issue_decorator.author_id = User.current.id
    respond_to do |format|
      if date_valid?(params[:issue][:due_date]) && @issue_decorator.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue_decorator }
        format.json { render :json => @issue_decorator,
                             :status => :created, :location => @issue_decorator }
      else
        @issue_decorator.errors.add(:due_date, 'format is invalid') unless date_valid?(params[:issue][:due_date])
        format.html { render :action => 'new', :locals => {:form_content => form_content} }
        format.json { render :json => @issue_decorator.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  #GET /project/:project_identifier/issues/:id/edit
  def edit
    respond_to do |format|
      format.html { render :action => 'edit', :locals => {:form_content => form_content} }
    end
  end

  #PUT /project/:project_identifier/issues/:id
  def update
    @issue_decorator.attributes = issue_params
    @issue_decorator.notes = params[:notes]
    respond_to do |format|
      if  !@issue_decorator.changed? && (params[:notes].nil? || params[:notes].eql?('')) && (issue_params[:existing_attachment_attributes].nil? && issue_params[:new_attachment_attributes].nil?)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue_decorator.id }
        format.json { render :json => @issue_decorator,
                             :status => :created, :location => @issue_decorator }
        #If attributes were updated
      elsif @issue_decorator.save && @issue_decorator.save_attachments
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue_decorator.id }
        format.json { render :json => @issue_decorator,
                             :status => :created, :location => @issue_decorator }
      else
        @allowed_statuses = User.current.allowed_statuses(@project)
        @done_ratio = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        format.html { render :action => 'edit', :locals => {:form_content => form_content} }
        format.json { render :json => @issue_decorator.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  #DELETE /project/:project_identifier/issues/:id
  def destroy
    @issue_decorator.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to issues_path }
      format.js { js_redirect_to issues_path }
    end
  end

  #OTHERS PUBLIC METHODS
  def delete_attachment
    attachment = Attachment.find(params[:id])
    if attachment.destroy
      respond_to do |format|
        format.html { redirect_to :action => 'show' }
        format.js { respond_to_js :response_header => :success, :response_content => t(:successful_deletion), :locals => {:id => attachment.id} }
      end
    end
  end

  def download_attachment
    attachment = Attachment.find_by_id(params[:id])
    send_file(attachment.file.url)
  end

  def start_today
    @issue_decorator = Issue.find_by_id(params[:id]).decorate(context: {project: @project})
    @issue_decorator.start_date = Date.current

    respond_to do |format|
      format.html { redirect_to :action => 'show' }
      format.js do
        if @issue_decorator.save
          flash[:notice] = t(:successful_update)
        else
          flash[:alert] = @issue_decorator.errors.full_messages
        end
        js_redirect_to(issue_path(@project.slug, @issue_decorator.id))
      end
    end
  end


  #GET /project/:project_identifier/issues/toolbox
  def toolbox
    #Displaying toolbox with GET request
    if !request.post?
      #loading toolbox
      @issues_toolbox = Issue.where(:id => params[:ids]).eager_load(:version, :assigned_to, :category, :status => [:enumeration])
      respond_to do |format|
        format.js { respond_to_js :locals => {:issues => @issues_toolbox} }
      end
    elsif params[:delete_ids]
      #Multi delete
      Issue.bulk_delete(params[:delete_ids])
      load_issues
      respond_to do |format|
        format.js { respond_to_js :action => :index, :response_header => :success, :response_content => t(:successful_deletion) }
      end
    else
      if User.current.allowed_to?('edit', 'issues', @project)
        #Editing with toolbox
        Issue.bulk_edit(params[:ids], value_params)
        load_issues
        respond_to do |format|
          format.js { respond_to_js :action => :index, :response_header => :success, :response_content => t(:successful_update) }
        end
      else
        render_403
      end
    end
  end

  def apply_custom_query
    query = Query.friendly.find(params[:query_id])
    if query
      @sessions[@project.slug][:sql_filter] = query.stringify_query
      @sessions[@project.slug][:json_filter] = eval(query.stringify_params)
    end
    index
  end

  def add_predecessor
    set_predecessor(params[:issue][:predecessor_id])
  end

  def del_predecessor
    set_predecessor(nil)
  end

  def overview
    tracker_report = Issue.group_opened_by_attr(@project.id, 'trackers', :tracker)
    version_report = Issue.group_opened_by_attr(@project.id, 'versions', :version)
    category_report =  Issue.group_opened_by_attr(@project.id, 'categories', :category)
    author_report =  Issue.group_opened_by_attr(@project.id, 'users', :author)
    assigned_to_report = Issue.group_opened_by_attr(@project.id, 'users', :assigned_to)
    status_report = Issue.group_by_status(@project.id)
   overview_object = IssueOverviewHash.new({tracker: tracker_report, versions: version_report, category: category_report, author: author_report, assigned_to: assigned_to_report, status: status_report}, @project.issues.count)
    respond_to do |format|
      format.html { render action: :overview, locals: {overview: overview_object} }
    end
  end

  #Private methods
  private
  def set_predecessor(predecessor_id)
    @issue_decorator = Issue.find(params[:id]).decorate(context: {project: @project})
    result = @issue_decorator.set_predecessor(predecessor_id)
    respond_to do |format|
      format.js do
        respond_to_js :action => 'add_predecessor', :locals => {:journals => History.new(result[:journals]), :success => result[:saved]}, :response_header => result[:saved] ? :success : :failure, :response_content => result[:saved] ? t(:successful_update) : @issue_decorator.errors.full_messages
      end
    end
  end

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
    @issues_decorator = Issue.filter(filter, @project.id).paginated(@sessions[:current_page], @sessions[:per_page], order('issues.id')).fetch_dependencies.decorate(context: {project: @project})
  end

  def form_content
    form_content = {}
    form_content['allowed_statuses'] = User.current.allowed_statuses(@project).collect { |status| [status.enumeration.name, status.id] }
    form_content['done_ratio'] = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    form_content['members'] = @project.real_members.collect { |member| [member.user.name, member.user.id]}
    form_content['categories'] = @project.categories.collect { |category| [category.name, category.id] }
    form_content['trackers'] = @project.trackers.collect { |tracker| [tracker.name, tracker.id] }
    form_content
  end

  def issue_params
    params.require(:issue).permit(Issue.permit_attributes)
  end

  def value_params
    params.require(:value).permit(Issue.permit_bulk_edit_values)
  end

  def find_project_with_depedencies
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


end
