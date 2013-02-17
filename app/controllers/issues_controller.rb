# Author: Nicolas Meylan
# Date: 8 juil. 2012
# Encoding: UTF-8
# File: issues_controller.rb

class IssuesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_project
  before_filter :check_permission, :except => [:save_checklist, :issue_description,:show_checklist_items,:toolbox, :download_attachment]
  before_filter :check_not_owner_permission, :only => [:edit,:update, :destroy]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  include ApplicationHelper
  include IssuesHelper
  helper_method :sort_column, :sort_direction
  require 'will_paginate'

  #RESTFULL CRUD Methods
  #GET /project/:project_identifier/issues
  def index
    filter
    find_custom_queries
    params[:per_page] ?
      session['controller_issues_per_page'] = params[:per_page] :
      session['controller_issues_per_page'] = (session['controller_issues_per_page'] ?
        session['controller_issues_per_page'] :
        25)
    order = sort_column + " " + sort_direction
    filter = session[@project.identifier+'_controller_issues_filter']
    @issues = Issue.paginated_issues(params[:page],
      session['controller_issues_per_page'],
      order,
      filter,
      @project.id)

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
    @issue = Issue.find(params[:id], :include => [:tracker,:version,:status,:assigned_to,:category,:attachments])
    @journals = Journal.find_all_by_journalized_type_and_journalized_id(@issue.class.to_s, @issue, :include => [:details])
    @allowed_statuses = current_user.members.select{|member| member.project_id == @project.id}.first.role.issues_statuses
    @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
    @checklist_statuses = Enumeration.find_all_by_opt("CLIS")
    @checklist_items = ChecklistItem.find_all_by_issue_id(@issue, :include => [:enumeration])
    respond_to do |format|
      format.html
    end
  end
  #GET /project/:project_identifier/issues/new
  def new
    @issue = Issue.new
    @issue.attachments.build
    #TODO: admin allowed_statuses
    @allowed_statuses = current_user.members.select{|member| member.project_id == @project.id}.first.role.issues_statuses
    @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
    respond_to do |format|
      format.html
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
        @allowed_statuses = current_user.members.select{|member| member.project_id == @project.id}.first.role.issues_statuses
        @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
        format.html  { render :action => "new" }
        format.json  { render :json => @issue.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #GET /project/:project_identifier/issues/:id/edit
  def edit
    #TODO: admin allowed_statuses
    @allowed_statuses = current_user.members.select{|member| member.project_id == @project.id}.first.role.issues_statuses
    @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
    respond_to do |format|
      format.html
    end
  end

  #PUT /project/:project_identifier/issues/:id
  def update
    #Attributes that won't be considarate in journal update
    unused_attributes = ['id','author_id', 'project_id', 'created_at', 'updated_at', 'description','subject']
    #Journal properties
    journalized_property = {'status_id' => t(:field_status),
      'category_id' => t(:field_category),
      'assigned_to_id' => t(:field_assigned_to),
      'tracker_id' => t(:field_tracker),
      'due_date' => t(:field_due_date),
      'done' => t(:field_done),
      'estimated_time' => t(:field_estimated_time),
      'version_id' => t(:field_version)}
    updated_attributes = updated_attributes(@issue,params[:issue])
    #Foreign key values
    fk_values = {'status_id' => IssuesStatus,
      'category_id' => Category,
      'assigned_to_id' => User,
      'tracker_id' => Tracker,
      'version_id' => Version}
    params[:issue][:updated_at] = Time.now.to_formatted_s(:db)
    respond_to do |format|
      #If 0 attributes were updated
      if updated_attributes.empty? &&
          (params[:notes].nil? || params[:notes].eql?('')) &&
          (params[:issue][:existing_attachment_attributes].nil? &&
            params[:issue][:new_attachment_attributes].nil?)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue}
        format.json  { render :json => @issue,
          :status => :created, :location => @issue}
        #If attributes were updated
      elsif @issue.update_attributes(params[:issue]) &&
          (params[:issue][:existing_attachment_attributes].nil? &&
            params[:issue][:new_attachment_attributes].nil?)
        updated_attrs = updated_attributes.delete_if{|attr, val| unused_attributes.include?(attr)}
        if updated_attrs.any?
          #Create journal
          @journal = Journal.create(:user_id => current_user.id,
            :journalized_id => @issue.id,
            :journalized_type => @issue.class.to_s,
            :created_at => params[:issue][:updated_at],
            :notes => params[:notes] ? params[:notes] : '')
          #Create an entry for the journal
          issues_journal_insertion(updated_attrs, @journal, journalized_property, fk_values)
        end
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue}
        format.json  { render :json => @issue,
          :status => :created, :location => @issue}
        #If attachment exist (updated or created)
      elsif params[:issue][:existing_attachment_attributes] || params[:issue][:new_attachment_attributes]
        @issue.save
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'show', :controller => 'issues', :id => @issue}
        format.json  { render :json => @issue,
          :status => :created, :location => @issue}
      else
        @allowed_statuses = current_user.members.select{|member| member.project_id == @project.id}.first.role.issues_statuses
        @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
        format.html  { render :action => "new" }
        format.json  { render :json => @issue.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  #DELETE /project/:project_identifier/issues/:id
  def destroy
    @issue.destroy
    journal_creation_on_delete(@issue, @issue.subject, 'Delete',property_key = nil)
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
  #filling the tooltip
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
    if !request.post?
      #loading toolbox
      @issues_toolbox = Issue.find_all_by_id(params[:ids])
      #    Toolbox informations
      @allowed_statuses = current_user.members.select{|member| member.project_id == @project.id}.first.role.issues_statuses.collect{|status| status.enumeration.name}
      @done_ratio = [0,10,20,30,40,50,60,70,80,90,100]
      @versions = @project.versions.collect{|version| version.name} << 'None' #field that can include blank
      @members = @project.members.collect{|member|member.user.name}
      @categories = @project.categories.collect{|category| category.name} << 'None'
      #collecting informations from selected issues
      @actual_states = Hash.new{}
      @actual_states["member"] = @issues_toolbox.collect{|issue| issue.assigned_to.name if !issue.assigned_to.nil?}.uniq
      @actual_states["version"] = @issues_toolbox.collect{|issue| issue.version.nil? ? 'None' : issue.version.name}.uniq
      @actual_states["status"] = @issues_toolbox.collect{|issue| issue.status.enumeration.name}.uniq
      @actual_states["done"] = @issues_toolbox.collect{|issue| issue.done}.uniq
      @actual_states["category"] = @issues_toolbox.collect{|issue| issue.category.nil? ? 'None' : issue.category.name}.uniq
      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html 'issues_toolbox', :partial => 'issues/toolbox'
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
      @issues_toolbox = Issue.find_all_by_id(params[:ids])
      attributes ={'assigned_to_id' => User, 'version_id' => Version, 'status_id' => IssuesStatus, 'category_id' => Category}
      attribute_name = ''
      attribute_value = ''
      params[:value].each do |k,v|
        unless v.eql?('')
          attribute_name = k
          if(attributes.keys.include?(k))
            !k.eql?('status_id') ?
              attribute_value = attributes[k].find_by_name(v) :
              attribute_value = attributes[k].find_by_enumeration_id(Enumeration.find_by_name_and_opt(v,'ISTS'))
          else
            attribute_value = v
          end
        else
          #delete other parameters, that wasn't updated
          params[:value].reject!{|k,v| v.eql?('')}
        end
      end
      params[:value][attribute_name] = attribute_value ? attribute_value : ''
      # Journal settings
      unused_attributes = ['id','author_id', 'project_id', 'created_at', 'updated_at', 'description']
      journalized_property = {'status_id' => t(:field_status),
        'category_id' => t(:field_category),
        'assigned_to_id' => t(:field_assigned_to),
        'tracker_id' => t(:field_tracker),
        'due_date' => t(:field_due_date),
        'done' => t(:field_done),
        'estimated_time' => t(:field_estimated_time),
        'version_id' => t(:field_version)
      }
      fk_values = {'status_id' => IssuesStatus, 'category_id' => Category, 'assigned_to_id' => User, 'tracker_id' => Tracker,'version_id' => Version}
      #      Issues update
      params[:value][attribute_name] = params[:value].values.first.id unless (params[:value].values.first.class.eql?(String))
      @issues_toolbox.each do |issue|
        updated_attributes = updated_attributes(issue,params[:value].clone)
        #If value is an object, get id
        if updated_attributes.any? && issue.update_attributes(params[:value].clone) && issue.update_column('updated_at', Time.current().to_formatted_s(:db))
          updated_attrs = updated_attributes.delete_if{|attr, val| unused_attributes.include?(attr)}
          if updated_attrs.any?
            #Create journal
            @journal = Journal.create(:user_id => current_user.id,
              :journalized_id => issue.id,
              :journalized_type => issue.class.to_s,
              :created_at => Time.now.to_formatted_s(:db),
              :notes => params[:notes] ? params[:notes] : '')
            issues_journal_insertion(updated_attrs, @journal, journalized_property, fk_values)
          end
        end
      end
      render_index_js
    end
  end

  def apply_custom_query
    query = Query.find(params[:query_id])
    if query
      session[@project.identifier+'_controller_issues_filter'] = query.stringify_query
      session[@project.identifier+'_controller_issues_filter_params'] = eval(query.stringify_params)
    end
    index
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
      action = params[:action].to_s+" not owner"
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
    params[:per_page] ?
      session['controller_issues_per_page'] = params[:per_page] :
      session['controller_issues_per_page'] =
      (session['controller_issues_per_page'] ?
        session['controller_issues_per_page'] :
        25)
    order = sort_column + " " + sort_direction
    filter = session[@project.identifier+'_controller_issues_filter']
    @issues = Issue.paginated_issues(params[:page],
      session['controller_issues_per_page'],
      order,
      filter,
      @project.id)
    # Refresh list
    respond_to do |format|
      format.html{ redirect_to :action => 'index', :controller => 'issues'}
      format.js {render :update do |page|
          page.replace 'issues_content', :partial => 'issues/list'
          response.headers['flash-message'] = message
        end}
    end
  end
  # For the construction of the filter form
  def filter
    @filters = {}
    @filters_list = []
    unused_attributes = ['Project','Description','Estimated time']
    attrs = Issue.attributes_formalized_names.delete_if {|attribute| unused_attributes.include?(attribute)}
    attrs.each{|attribute| @filters_list << [attribute,attribute.gsub(/\s/,'_').downcase]}
    @hash_for_content = {}
    @hash_for_select = {}
    @hash_for_radio = Hash.new{|k,v| k[v] = []}
    @hash_for_select["assigned"] = @project.members.collect{|member| [member.user.name, member.user.id]}
    @hash_for_radio["assigned"] = ["all","equal","different"]
    @hash_for_select["assigned"] << ["Nobody", "NULL"]
    @hash_for_select["author"] = @project.members.collect{|member| [member.user.name, member.user.id]}
    @hash_for_radio["author"] = ["all","equal","different"]
    @hash_for_select["category"] = @project.categories.collect{|category| [category.name, category.id]}
    @hash_for_radio["category"] = ["all","equal","different"]
    @hash_for_radio["created"] = ["all","equal","superior","inferior","today"]
    @hash_for_radio["done"] = ["all","equal","superior","inferior","finished"]
    @hash_for_select["done"] = [[0,0],[10,10],[20,20],[30,30],[40,40],[50,50],[60,60],[70,70],[80,80],[90,90],[100,100]]
    @hash_for_radio["due_date"] = ["all","equal","superior","inferior","today"]
    @hash_for_select["status"] = IssuesStatus.find(:all).collect{|status| [status.enumeration.name, status.id]}
    @hash_for_radio["status"] = ["all","equal","different","open","close"]
    @hash_for_radio["subject"] = ["all","contains","not contains"]
    @hash_for_select["tracker"] = @project.trackers.collect{|tracker| [tracker.name, tracker.id]}
    @hash_for_radio["tracker"] = ["all","equal","different"]
    @hash_for_select["version"] = @project.versions.collect{|version| [version.name, version.id]}
    @hash_for_select["version"] << ["Unplanned", "NULL"]
    @hash_for_radio["version"] = ["all","equal","different"]
    @hash_for_radio["updated"] = ["all","equal","superior","inferior","today"]
    #When page is reloading, user don't loose his filters
    filter_params = params[:filter].clone if params[:filter]
    if params[:type].eql?('filter') && params[:filter] && params[:filters_list] && params[:filters_list].any?
      filter = issues_filter(params[:filter], @project.id)
    elsif params[:commit]
      session[@project.identifier+'_controller_issues_filter'] = nil
      session[@project.identifier+'_controller_issues_filter_params'] = nil
    else
      #nothing.
    end
    session[@project.identifier+'_controller_issues_filter_params'] = filter_params if params[:type] && params[:type].eql?('filter')
    filter ? session[@project.identifier+'_controller_issues_filter'] = filter : session[@project.identifier+'_controller_issues_filter'] =
      (session[@project.identifier+'_controller_issues_filter'] ? session[@project.identifier+'_controller_issues_filter'] : "")
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
end
