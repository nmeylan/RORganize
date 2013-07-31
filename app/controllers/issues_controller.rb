# Author: Nicolas Meylan
# Date: 8 juil. 2012
# Encoding: UTF-8
# File: issues_controller.rb

class IssuesController < ApplicationController
  before_filter :find_project
  before_filter :load_issues, :only => [:index]
  before_filter :check_permission, :except => [:save_checklist, :issue_description,:show_checklist_items,:toolbox, :download_attachment, :edit_note, :delete_note, :start_today]
  before_filter :check_not_owner_permission, :only => [:edit,:update, :destroy]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter {|c| c.top_menu_item("projects")}
  include ApplicationHelper
  include IssuesHelper
  helper_method :sort_column, :sort_direction
  require 'will_paginate'

  #RESTFULL CRUD Methods
  #GET /project/:project_identifier/issues
  def index
    filter
    find_custom_queries
    respond_to do |format|
      format.html { render "issues/index"}
      format.js do
        render :update do |page|
          page.replace "issues_content", :partial => 'issues/list'
          page.replace_html "save_query_button", :partial => 'issues/save_query_button'
        end
      end
    end
  end

  def show
    @issue = Issue.find(params[:id], :include => [:tracker,:version,:status,:assigned_to,:category,:attachments, :parent])
    journals = Journal.where(:journalized_type => "Issue", :journalized_id => @issue.id).includes([:details, :user])
    allowed_statuses = current_user.allowed_statuses(@project)
    done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
    @checklist_statuses = Enumeration.where(:opt => "CLIS")
    @checklist_items = ChecklistItem.where(:issue_id => @issue.id).includes([:enumeration])
    respond_to do |format|
      format.html {render :action => "show", 
        :locals => {:journals => journals, :done_ratio => done_ratio, :allowed_statuses => allowed_statuses}}
    end
  end
  #GET /project/:project_identifier/issues/new
  def new
    @issue = Issue.new
    @issue.attachments.build
    respond_to do |format|
      format.html { render :action => "new", :locals => {:form_content => form_content}}
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
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue}
        format.json  { render :json => @issue,
          :status => :created, :location => @issue}
      else
        @issue.errors.add(:due_date, 'format is invalid') unless date_valid?(params[:issue][:due_date])
        format.html  { render :action => "new", :locals => {:form_content => form_content}}
        format.json  { render :json => @issue.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #GET /project/:project_identifier/issues/:id/edit
  def edit
    respond_to do |format|
      format.html { render :action => "edit", :locals => {:form_content => form_content}}
    end
  end

  #PUT /project/:project_identifier/issues/:id
  def update
    @issue.attributes = params[:issue]
    @issue.notes = params[:notes]
    respond_to do |format|
      if(!@issue.changed? && (params[:notes].nil? || params[:notes].eql?('')) && (params[:issue][:existing_attachment_attributes].nil? && params[:issue][:new_attachment_attributes].nil?))
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue.id}
        format.json  { render :json => @issue,
          :status => :created, :location => @issue}
        #If attributes were updated
      elsif @issue.save && @issue.save_attachments
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue.id}
        format.json  { render :json => @issue,
          :status => :created, :location => @issue}
      else
        @allowed_statuses = current_user.allowed_statuses(@project)
        @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
        format.html  { render :action => "edit", :locals => {:form_content => form_content}}
        format.json  { render :json => @issue.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #DELETE /project/:project_identifier/issues/:id
  def destroy
    @issue.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to issues_path}
      format.js do
        render :update do |page|
          page.redirect_to issues_path
        end
      end
    end
  end

  #OTHERS PUBLIC METHODS
  def delete_attachment
    attachment = Attachment.find(params[:attachment_id])
    @issue = Issue.find(params[:id], :include => [:tracker,:version,:status,:assigned_to,:category,:attachments])
    @issue.attachments.delete_if{|attach| attach.id == attachment.id}
    if attachment.destroy
      respond_to do |format|
        format.html { redirect_to :action => 'show'}
        format.js do
          render :update do |page|
            page.replace_html('attachments', :partial => 'issues/show_attachments', :locals => {:attachments => @issue.attachments})
            response.headers['flash-message'] = t(:successful_deletion)
          end
        end
      end
    end
  end

  def download_attachment
    filename = params[:path]
    send_file(filename)
  end

  def start_today
    @issues = Issue.find(params[:ids])
    fail = 0
    @issues.each do |issue|
      issue.start_date = Date.current
      unless issue.save
        fail +=1
        @issue = issue
      end
    end
    respond_to do |format|
      format.html { redirect_to :action => 'show'}
      format.js do
        render :update do |page|
          if params[:context] && params[:context].eql?("toolbox")
            flash[:notice] = t(:successful_update)
            page.redirect_to :action => 'index'
          else
            if fail == 0
              flash[:notice] = t(:successful_update)
              page.redirect_to :action => 'show', :id => params[:ids]
            else
              response.headers['flash-error-message'] = @issue.errors.full_messages
            end
          end
        end
      end
    end
  end

  def issue_description
    description = Issue.find(params[:id]).description
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace 'tooltip_content', :partial => 'issues/tooltip', :locals => {:description => description}
        end
      end
    end
  end
  #Save checklist
  def save_checklist
    position = 1
    if params[:items]
      params[:items].each do |k,v|
        tmp = ChecklistItem.find_by_issue_id_and_name(params[:id], k)
        if tmp
          tmp.update_attributes(:enumeration_id => v, :position => position)
        else
          ChecklistItem.create(:enumeration_id => v, :issue_id => params[:id], :position => position, :name => k)
        end
        position += 1
      end
      ChecklistItem.delete_all(["name NOT IN (?) AND issue_id = ?",params[:items].keys, params[:id]])
    else
      ChecklistItem.delete_all(["issue_id = ?", params[:id]])
    end
    respond_to do |format|
      format.js { render :update do |page|
          @checklist_items = ChecklistItem.find_all_by_issue_id(params[:id], :include => [:enumeration])
          page.replace_html('ck_refresh', :partial => 'issues/show_checklist')
          response.headers['flash-message'] = t(:successful_update)
        end}
    end
  end

  def show_checklist_items
    respond_to do |format|
      format.js { render :update do |page|
          @checklist_items = ChecklistItem.find_all_by_issue_id(params[:id], :include => [:enumeration])
          page.replace_html('items', :partial => 'issues/show_checklist')
        end}
    end
  end
  #GET /project/:project_identifier/issues/toolbox
  def toolbox
    #Displaying toolbox with GET request
    if !request.post?
      #loading toolbox
      @issues_toolbox = Issue.where(:id => params[:ids]).includes(:version,  :assigned_to, :category, :status => [:enumeration])
      menu = toolbox_menu
      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html 'issues_toolbox', :partial => 'issues/toolbox', :locals => {:menu => menu}
            page.replace 'delete_overlay', :partial => 'issues/delete_overlay', :locals => {:issues => @issues_toolbox}
          end
        end
      end
    elsif params[:delete_ids]
      #Multi delete
      issues = Issue.find_all_by_id(params[:delete_ids])
      issues.each do |issue|
        if(issue.author_id.eql?(current_user.id) || current_user.allowed_to?("delete not owner",params[:controller],@project))
          issue.destroy
        end
      end
      render_index_js(t(:successful_deletion))
    else
      #Editing with toolbox
      @issues_toolbox = Issue.where(:id => params[:ids])
      attributes ={'assigned_to_id' => User, 'version_id' => Version, 'status_id' => IssuesStatus, 'category_id' => Category}
      attribute_name = ''
      attribute_value = ''
      params[:value].each do |attr_name,attr_value|
        unless attr_value.eql?('')
          attribute_name = attr_name
          if(attributes.keys.include?(attr_name))
            !attr_name.eql?('status_id') ?
              attribute_value = attributes[attr_name].find_by_name(attr_value) :
              attribute_value = attributes[attr_name].find_by_enumeration_id(Enumeration.find_by_name_and_opt(attr_value,'ISTS'))
          else
            attribute_value = attr_value
          end
        else
          #delete other parameters, that wasn't updated
          params[:value].reject!{|attr_name,attr_value| attr_value.eql?('')}
        end
      end
      
      params[:value][attribute_name] = attribute_value ? attribute_value : ''
     puts params[:value].inspect
      params[:value][attribute_name] = params[:value].values.first.id unless (params[:value].values.first.class.eql?(String))
      @issues_toolbox.each do |issue|
        puts params[:value].inspect
       issue.attributes = params[:value]
        if issue.changed?
          issue.save
        end
      end
      @issues_toolbox = nil
      render_index_js
    end
  end

  def apply_custom_query
    query = Query.find(params[:query_id])
    if query
      session[@project.slug+'_controller_issues_filter'] = query.stringify_query
      session[@project.slug+'_controller_issues_filter_params'] = eval(query.stringify_params)
    end
    load_issues
    index
  end

  def edit_note
    journal = Journal.find_by_id(params[:journal_id])
    @issue = Issue.find(params[:id])
    if journal && journal.user_id.eql?(current_user.id)
      respond_to do |format|
        format.js do
          render :update do |page|
            if journal.update_column(:notes, params[:notes])
              journals = Journal.where(:journalized_type => "Issue", :journalized_id => @issue.id).includes([:details, :user])
              page.replace_html 'history', :partial => "issues/history", :locals => {:journals => journals}
              response.headers['flash-message'] = t(:successful_update)
            else
              response.headers['flash-error_message'] = t(:failure_update)
            end
          end
        end
      end
    end
  end

  def delete_note
    journal = Journal.find_by_id(params[:journal_id])
    @issue = Issue.find(params[:journalized_id])
    if journal && journal.user_id.eql?(current_user.id)
      respond_to do |format|
        if journal.details.empty?
          journal.destroy
        else
          journal.update_column(:notes, "")
        end
        format.js do
          render :update do |page|
            journals = Journal.where(:journalized_type => "Issue", :journalized_id => @issue.id).includes([:details, :user])
            page.replace_html 'history', :partial => "issues/history", :locals => {:journals => journals}
            response.headers['flash-message'] = t(:successful_deletion)
          end
        end
      end
    end
  end

  def add_predecessor
    @issue = Issue.find(params[:id])
    @issue.predecessor_id = params[:issue][:predecessor_id]
    respond_to do |format|
      format.js do
        render :update do |page|
          if @issue.save            
            journals = Journal.where(:journalized_type => "Issue", :journalized_id => @issue.id).includes([:details, :user])
            page.replace_html 'history', :partial => "issues/history", :locals => {:journals => journals}
            page.replace_html 'predecessor', :partial => 'issues/predecessor'
            response.headers['flash-message'] = t(:successful_update)
          else
            response.headers['flash-error-message'] = @issue.errors.full_messages
          end
        end
      end
    end
  end

  def del_predecessor
    @issue = Issue.find(params[:id])
    @issue.predecessor_id = nil
    respond_to do |format|
      format.js do
        render :update do |page|
          if @issue.save
            journals = Journal.where(:journalized_type => "Issue", :journalized_id => @issue.id).includes([:details, :user])
            page.replace_html 'history', :partial => "issues/history", :locals => {:journals => journals}
            page.replace_html 'predecessor', :partial => 'issues/predecessor'
            response.headers['flash-message'] = t(:successful_deletion)
          else
            response.headers['flash-error-message'] = @issue.errors.full_messages
          end
        end
      end
    end
  end

  #Private methods
  private

  #Check if current user is owner of issue
  def check_issue_owner
    @issue = Issue.find_by_id(params[:id])
    return @issue.author_id.eql?(current_user.id)
  end

  def check_not_owner_permission
    if check_issue_owner
      return true
    else
      action = "#{find_action(params[:action].to_s)}_not_owner"
      unless current_user.allowed_to?(action,params[:controller],@project)
        render_403
      else
        return true
      end
    end
  end

  def sort_column
    params[:sort] ?
      session['controller_issues_sort'] = params[:sort] :
      session['controller_issues_sort'] =
      (session['controller_issues_sort'] ?
        session['controller_issues_sort'] :
        'id')
    session['controller_issues_sort']
  end

  def sort_direction
    params[:direction] ?
      session['controller_issues_direction'] = params[:direction] :
      session['controller_issues_direction'] =
      (session['controller_issues_direction'] ?
        session['controller_issues_direction'] :
        'desc')
    session['controller_issues_direction']
  end

  def render_index_js(message = t(:successful_update))
    load_issues
    # Refresh list
    respond_to do |format|
      format.html{ redirect_to :action => 'index', :controller => 'issues'}
      format.js {render :update do |page|
          page.replace 'issues_content', :partial => 'issues/list'
          response.headers['flash-message'] = message
        end}
    end
  end
  
  def filter
    filter_params = params[:filter].clone if params[:filter]
    if params[:type].eql?('filter') && params[:filter] && params[:filters_list] && params[:filters_list].any?
      filter = issues_filter(params[:filter], @project.id)
    elsif params[:commit]
      #filter SQL content
      session[@project.slug+'_controller_issues_filter'] = nil
      #filter DOM content
      session[@project.slug+'_controller_issues_filter_params'] = nil
    end
    #When page is reloading, user don't loose his filters
    if params[:type] && params[:type].eql?('filter')
      session[@project.slug+'_controller_issues_filter_params'] = filter_params 
    end
    filter ? 
      (session[@project.slug+'_controller_issues_filter'] = filter) : 
      session[@project.slug+'_controller_issues_filter'] =
      (session[@project.slug+'_controller_issues_filter'] ? 
        session[@project.slug+'_controller_issues_filter'] : "")
  end
  #Find custom queries
  def find_custom_queries
    @custom_queries = Query.find(:all,
      :conditions => ["(project_id = ? AND (author_id = ? OR is_public = ?)) OR
                          (is_for_all = ? AND (author_id = ? OR is_public = ?)) AND
                        object_type = ?",
        @project.id,
        current_user.id,
        true,
        true,
        current_user.id,
        true,
        Issue.to_s
      ])
  end
  
  def load_issues
    params[:per_page] ?
      session['controller_issues_per_page'] = params[:per_page] :
      session['controller_issues_per_page'] = (session['controller_issues_per_page'] ?
        session['controller_issues_per_page'] :
        25)
    order = sort_column + " " + sort_direction
    filter = session[@project.slug+'_controller_issues_filter']
    @issues = Issue.paginated_issues(params[:page],
      session['controller_issues_per_page'],
      order,
      filter,
      @project.id)
  end
  
  def form_content
    form_content = {}
    form_content["allowed_statuses"] = current_user.allowed_statuses(@project).collect{|status| [status.enumeration.name, status.id]}
    form_content["done_ratio"] = [0,10,20,30,40,50,60,70,80,90,100]
    form_content["members"] = @project.members.includes(:user).collect{|member| [member.user.name, member.user.id]}
    form_content["categories"] = @project.categories.collect{|category| [category.name, category.id]}
    form_content["trackers"] = @project.trackers.collect{|tracker| [tracker.name, tracker.id]}
    return form_content
  end
  
  def toolbox_menu
    menu = {}
    menu["allowed_statuses"] = current_user.allowed_statuses(@project).collect{|status| status.enumeration.name}
    menu["done_ratio"] = [0,10,20,30,40,50,60,70,80,90,100]
    menu["versions"] = @project.versions.collect{|version| version.name} << 'None' #field that can include blank
    menu["members"] = @project.members.collect{|member|member.user.name} << 'None'
    menu["categories"] = @project.categories.collect{|category| category.name} << 'None'
    #collecting informations from selected issues
    current_states = Hash.new{}
    current_states["member"] = @issues_toolbox.collect{|issue| issue.assigned_to.nil? ? 'None' : issue.assigned_to.name }.uniq
    current_states["version"] = @issues_toolbox.collect{|issue| issue.version.nil? ? 'None' : issue.version.name}.uniq
    current_states["status"] = @issues_toolbox.collect{|issue| issue.status.enumeration.name}.uniq
    current_states["done"] = @issues_toolbox.collect{|issue| issue.done}.uniq
    current_states["category"] = @issues_toolbox.collect{|issue| issue.category.nil? ? 'None' : issue.category.name}.uniq
    menu["current_states"] = current_states
    return menu
  end
end
