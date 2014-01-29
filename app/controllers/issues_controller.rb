# Author: Nicolas Meylan
# Date: 8 juil. 2012
# Encoding: UTF-8
# File: issues_controller.rb

class IssuesController < ApplicationController
  before_filter :find_project
  before_filter :check_permission, :except => [:save_checklist, :issue_description, :show_checklist_items, :toolbox, :download_attachment, :edit_note, :delete_note, :start_today]
  before_filter :check_not_owner_permission, :only => [:edit, :update, :destroy]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }
  include ApplicationHelper
  include IssuesHelper
  helper_method :sort_column, :sort_direction
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
    display_issue_object = Issue.display_issue_object(params[:id])
    @issue = display_issue_object[:issue]
    @checklist_statuses = display_issue_object[:checklist_statuses]
    gon.checklist_statuses = @checklist_statuses.to_json
    respond_to do |format|
      format.html { render :action => 'show', :locals => {:journals => display_issue_object[:journals], :done_ratio => display_issue_object[:done_ratio], :allowed_statuses => display_issue_object[:allowed_statuses], :checklist_items => display_issue_object[:checklist_items]} }
    end
  end

  #GET /project/:project_identifier/issues/new
  def new
    @issue = Issue.new
    @issue.attachments.build
    respond_to do |format|
      format.html { render :action => 'new', :locals => {:form_content => form_content} }
    end
  end

  #POST/project/:project_identifier/issues/
  def create
    @issue = Issue.new(params[:issue])
    @issue.created_at = Time.now.to_formatted_s(:db)
    @issue.updated_at = Time.now.to_formatted_s(:db)
    @issue.project_id = @project.id
    @issue.author_id = current_user.id
    respond_to do |format|
      if date_valid?(params[:issue][:due_date]) && @issue.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue }
        format.json { render :json => @issue,
                             :status => :created, :location => @issue }
      else
        @issue.errors.add(:due_date, 'format is invalid') unless date_valid?(params[:issue][:due_date])
        format.html { render :action => 'new', :locals => {:form_content => form_content} }
        format.json { render :json => @issue.errors,
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
    @issue.attributes = params[:issue]
    @issue.notes = params[:notes]
    respond_to do |format|
      if  !@issue.changed? && (params[:notes].nil? || params[:notes].eql?('')) && (params[:issue][:existing_attachment_attributes].nil? && params[:issue][:new_attachment_attributes].nil?)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue.id }
        format.json { render :json => @issue,
                             :status => :created, :location => @issue }
        #If attributes were updated
      elsif @issue.save && @issue.save_attachments
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue.id }
        format.json { render :json => @issue,
                             :status => :created, :location => @issue }
      else
        @allowed_statuses = current_user.allowed_statuses(@project)
        @done_ratio = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        format.html { render :action => 'edit', :locals => {:form_content => form_content} }
        format.json { render :json => @issue.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  #DELETE /project/:project_identifier/issues/:id
  def destroy
    @issue.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to issues_path }
      format.js {js_redirect_to issues_path}
    end
  end

  #OTHERS PUBLIC METHODS
  def delete_attachment
    attachment = Attachment.find(params[:id])
    if attachment.destroy
      respond_to do |format|
        format.html { redirect_to :action => 'show' }
        format.js {respond_to_js :response_header => :success, :response_content => t(:successful_deletion), :locals =>{:id => attachment.id}}
      end
    end
  end

  def download_attachment
    filename = params[:path]
    send_file(filename)
  end

  def start_today
    @issue = Issue.find_by_id(params[:id])
    @issue.start_date = Date.current

    respond_to do |format|
      format.html { redirect_to :action => 'show' }
      format.js do
        if @issue.save
          flash[:notice] = t(:successful_update)
        else
          flash[:alert] = @issue.errors.full_messages
        end
        js_redirect_to(issue_path(@project.slug, @issue.id))
      end
    end
  end

  def issue_description
    description = Issue.find(params[:id]).description
    respond_to do |format|
      format.js { respond_to_js :locals => {:description => description} }
    end
  end

  #Save checklist
  def save_checklist
    ChecklistItem.save_items(params[:items], params[:id])
    respond_to do |format|
      format.js { respond_to_js :response_header => :success, :response_content => t(:successful_update), :locals => {:checklist_items => ChecklistItem.find_all_by_issue_id(params[:id], :include => [:enumeration])} }
    end
  end

  def show_checklist_items
    respond_to do |format|
      format.js { respond_to_js :locals => {:checklist_items => ChecklistItem.find_all_by_issue_id(params[:id], :include => [:enumeration])} }
    end
  end

  #GET /project/:project_identifier/issues/toolbox
  def toolbox
    #Displaying toolbox with GET request
    if !request.post?
      #loading toolbox
      @issues_toolbox = Issue.where(:id => params[:ids]).includes(:version, :assigned_to, :category, :status => [:enumeration])
      menu = Issue.toolbox_menu(@project, @issues_toolbox)
      respond_to do |format|
        format.js { respond_to_js :locals => {:menu => menu, :issues => @issues_toolbox} }
      end
    elsif params[:delete_ids]
      #Multi delete
      Issue.bulk_delete(params[:delete_ids])
      load_issues
      respond_to do |format|
        format.js { respond_to_js :action => :index, :response_header => :success, :response_content => t(:successful_deletion) }
      end
    else
      #Editing with toolbox
      Issue.bulk_edit(params[:ids], params[:value])
      load_issues
      respond_to do |format|
        format.js { respond_to_js :action => :index, :response_header => :success, :response_content => t(:successful_update) }
      end
    end
  end

  def apply_custom_query
    query = Query.find(params[:query_id])
    if query
      session[@project.slug+'_controller_issues_filter'] = query.stringify_query
      session[@project.slug+'_controller_issues_filter_params'] = eval(query.stringify_params)
    end
    index
  end

  def edit_note
    edit_result = Journal.edit_note(params[:journal_id],current_user.id, params[:notes])
      respond_to do |format|
        format.js do
          respond_to_js :action => 'update_journal', :locals => {:journals => edit_result[:journals]}, :response_header => edit_result[:saved] ? :success : :failure, :response_content => edit_result[:saved] ? t(:successful_update) : t(:failure_update)
          end
      end
  end

  def delete_note
    delete_result = Journal.delete_note(params[:note_id],current_user.id)
      respond_to do |format|
        format.js do
          respond_to_js :action => 'update_journal', :locals => {:journals => delete_result[:journals]}, :response_header => delete_result[:destroyed] ? :success : :failure , :response_content =>  delete_result[:destroyed] ? t(:successful_deletion) : t(:failure_deletion)
        end
      end
  end

  def add_predecessor
    set_predecessor(params[:issue][:predecessor_id])
  end

  def del_predecessor
    set_predecessor(nil)
  end

  #Private methods
  private
  def set_predecessor(predecessor_id)
    @issue = Issue.find(params[:id])
    result = @issue.set_predecessor(predecessor_id)
    respond_to do |format|
      format.js do
        respond_to_js :action => "add_predecessor", :locals => {:journals => result[:journals], :success => result[:saved]}, :response_header => result[:saved] ? :success : :failure, :response_content => result[:saved] ? t(:successful_update) : @issue.errors.full_messages
      end
    end
  end

  #Check if current user is owner of issue
  def check_issue_owner
    @issue = Issue.find_by_id(params[:id])
    @issue.author_id.eql?(current_user.id)
  end

  def check_not_owner_permission
    if check_issue_owner
      true
    else
      action = "#{find_action(params[:action].to_s)}_not_owner"
      if current_user.allowed_to?(action, params[:controller], @project)
        return true
      else
        render_403
      end
    end
  end

  def sort_column
    session['controller_issues_sort'] = params[:sort] ? params[:sort] : (session['controller_issues_sort'] ? session['controller_issues_sort'] :'id')
  end

  def sort_direction
    session['controller_issues_direction'] = params[:direction] ? params[:direction] : (session['controller_issues_direction'] ? session['controller_issues_direction'] :'desc')
  end

  def filter
    filter_params = params[:filter] ? params[:filter].clone : nil
    filter = nil
    if params[:type].eql?('filter') && params[:filter] && params[:filters_list] && params[:filters_list].any?
      filter = issues_filter(params[:filter], @project.id)
    elsif params[:commit]
      #filter SQL content
      session["#{@project.slug}_controller_issues_filter"] = nil
      #filter DOM content
      session["#{@project.slug}_controller_issues_filter_params"] = nil
    end
    #When page is reloading, user don't loose his filters
    if params[:type] && params[:type].eql?('filter')
      session["#{@project.slug}_controller_issues_filter_params"] = filter_params
    end
    session["#{@project.slug}_controller_issues_filter"] = filter ? filter : (session["#{@project.slug}_controller_issues_filter"] ? session["#{@project.slug}_controller_issues_filter"] : '')
  end

  #Find custom queries
  def find_custom_queries
    @custom_queries = Query.issues_queries(@project_id)
  end

  def load_issues
    gon.DOM_filter = view_context.issues_generics_form_to_json
    gon.DOM_persisted_filter = session["#{@project.slug}_controller_issues_filter_params"].to_json
    session['controller_issues_per_page'] = params[:per_page] ? params[:per_page] : (session['controller_issues_per_page'] ? session['controller_issues_per_page'] : 25)
    order = sort_column + ' ' + sort_direction
    filter = session["#{@project.slug}_controller_issues_filter"]
    @issues = Issue.paginated_issues(params[:page], session['controller_issues_per_page'],order, filter, @project.id)
  end

  def form_content
    form_content = {}
    form_content['allowed_statuses'] = current_user.allowed_statuses(@project).collect { |status| [status.enumeration.name, status.id] }
    form_content['done_ratio'] = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    form_content['members'] = @project.members.includes(:user).collect { |member| [member.user.name, member.user.id] }
    form_content['categories'] = @project.categories.collect { |category| [category.name, category.id] }
    form_content['trackers'] = @project.trackers.collect { |tracker| [tracker.name, tracker.id] }
    form_content
  end


end
