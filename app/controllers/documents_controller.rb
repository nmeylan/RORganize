# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: document_controller.rb
class DocumentsController < ApplicationController
  before_filter :find_project
  before_filter :check_permission, :except => [:download_attachment, :toolbox]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter {|c| c.top_menu_item("projects")}
  include ApplicationHelper
  include IssuesHelper
  include DocumentsHelper
  helper_method :sort_column, :sort_direction
  require 'will_paginate'
  def index
    filter
    params[:per_page] ?
      session['controller_documents_per_page'] = params[:per_page] :
      session['controller_documents_per_page'] = (session['controller_documents_per_page'] ?
        session['controller_documents_per_page'] :
        25)
    order = sort_column + " " + sort_direction
    filter = session[@project.identifier+'_controller_documents_filter']
    @documents = Document.paginated_documents(params[:page],
      session['controller_documents_per_page'],
      order,
      filter,
      @project.id)

    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace "documents_content", :partial => 'documents/list'
        end
      end
    end
  end

  def new
    @versions = @project.versions
    @categories = @project.categories
    @document = Document.new
    @document.attachments.build
    respond_to do |format|
      format.html
    end
  end

  def create
    @document = Document.new(params[:document])
    @document.project_id = @project.id
    @document.created_at = Time.now.to_formatted_s(:db)
    respond_to do |format|
      if @document.save
        flash[:notice] = t(:successful_creation)
        @journal = Journal.create(:user_id => current_user.id,
          :journalized_id => @document.id,
          :journalized_type => @document.class.to_s,
          :created_at => Time.now.to_formatted_s(:db),
          :notes => "",
          :action_type => "created",
          :project_id => @project.id)
        format.html {redirect_to :action => "show", :id => @document.id}
      else
        @versions = @project.versions
        @categories = @project.categories
        format.html {render :action => "new"}
      end
    end
  end

  def edit
    @document = Document.find(params[:id])
    @versions = @project.versions
    @categories = @project.categories
    respond_to do |format|
      format.html
    end
  end

  def update
    @document = Document.find(params[:id])
    @document.updated_at = Time.now.to_formatted_s(:db)
    unused_attributes = ['id', 'project_id']
    #Journal properties
    journalized_property = {
      'category_id' => t(:field_category),
      'version_id' => t(:field_version)}
    updated_attributes = updated_attributes(@document,params[:document])
    #Foreign key values
    fk_values = {
      'category_id' => Category,
      'version_id' => Version}
    respond_to do |format|
      if updated_attributes.empty? &&
          (params[:document][:existing_attachment_attributes].nil? &&
            params[:document][:new_attachment_attributes].nil?)
        format.html { redirect_to :action => 'show', :controller => 'documents', :id => @document.id}
      elsif @document.update_attributes(params[:document]) && @document.save_attachments
        updated_attrs = updated_attributes.delete_if{|attr, val| unused_attributes.include?(attr)}

        if updated_attrs.any?
          #Create journal
          @journal = Journal.create(:user_id => current_user.id,
            :journalized_id => @document.id,
            :journalized_type => @document.class.to_s,
            :created_at => Time.now.to_formatted_s(:db),
            :notes => '',
            :action_type => "updated",
            :project_id => @project.id)
          #Create an entry for the journal
          issues_journal_insertion(updated_attrs, @journal, journalized_property, fk_values)
        end
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'show', :controller => 'documents', :id => @document.id}
      else
        @versions = @project.versions
        @categories = @project.categories
        format.html {render :action => "new"}
      end
    end
  end

  def show
    @document = Document.find(params[:id], :include => [:category, :version, :attachments])
    @journal_created = Journal.includes(:user).where(:action_type => "created", :journalized_id => @document.id,:journalized_type => @document.class.to_s ).first
    @journals = Journal.find_all_by_journalized_type_and_journalized_id(@document.class.to_s, @document.id, :include => [:details])
  end

  #OTHERS PUBLIC METHODS
  def delete_attachment
    attachment = Attachment.find(params[:attachment_id])
    @document = Document.find(params[:id], :include => [:version,:category,:attachments])
    @document.attachments.delete_if{|attach| attach.id == attachment.id}
    if attachment.destroy
      respond_to do |format|
        format.html { redirect_to :action => 'show'}
        format.js do
          render :update do |page|
            page.replace_html('attachments', :partial => 'documents/show_attachments', :locals => {:attachments => @document.attachments})
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

  def destroy
    @document = Document.find(params[:id])
    @document.destroy
    @journal = Journal.create(:user_id => current_user.id,
      :journalized_id => @document.id,
      :journalized_type => @document.class.to_s,
      :notes => "",
      :action_type => "deleted",
      :project_id => @project.id)
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to documents_path}
      format.js do
        render :update do |page|
          page.redirect_to documents_path
        end
      end
    end
  end

  #GET /project/:project_identifier/documents/toolbox
  def toolbox
    #Displaying toolbox with GET request
    if !request.post?
      #loading toolbox
      @documents_toolbox = Document.find_all_by_id(params[:ids])
      #    Toolbox informations
      @versions = @project.versions.collect{|version| version.name} << 'None' #field that can include blank
      @categories = @project.categories.collect{|category| category.name} << 'None'
      #collecting informations from selected documents
      @actual_states = Hash.new{}
      @actual_states["version"] = @documents_toolbox.collect{|document| document.version.nil? ? 'None' : document.version.name}.uniq
      @actual_states["category"] = @documents_toolbox.collect{|document| document.category.nil? ? 'None' : document.category.name}.uniq
      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html 'documents_toolbox', :partial => 'documents/toolbox'
            page.replace 'delete_overlay', :partial => 'documents/delete_overlay', :locals => {:documents => @documents_toolbox}
          end
        end
      end
    elsif params[:delete_ids]
      #Multi delete
      documents = Document.find_all_by_id(params[:delete_ids])
      documents.each do |document|
        document.destroy
        Journal.create(:user_id => current_user.id,
          :journalized_id => document.id,
          :journalized_type => document.class.to_s,
          :notes => "",
          :action_type => "deleted",
          :project_id => @project.id)
      end
      render_index_js(t(:successful_deletion))
    else
      #Editing with toolbox
      @documents_toolbox = Document.find_all_by_id(params[:ids])
      attributes ={'version_id' => Version, 'category_id' => Category}
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
      unused_attributes = ['id','project_id', 'created_at', 'updated_at', 'description']
      journalized_property = {
        'category_id' => t(:field_category),
        'version_id' => t(:field_version)
      }
      fk_values = {'category_id' => Category, 'version_id' => Version}
      #      Documents update
      params[:value][attribute_name] = params[:value].values.first.id unless (params[:value].values.first.class.eql?(String))
      @documents_toolbox.each do |document|
        updated_attributes = updated_attributes(document,params[:value])
        #If value is an object, get id
        if updated_attributes.any? && document.update_attributes(params[:value]) && document.update_column('updated_at', Time.current().to_formatted_s(:db))
          #Changed will appear in journal
          updated_attrs = updated_attributes.delete_if{|attr, val| unused_attributes.include?(attr)}
          if updated_attrs.any?
            #Create journal
            @journal = Journal.create(:user_id => current_user.id,
              :journalized_id => document.id,
              :journalized_type => document.class.to_s,
              :created_at => Time.now.to_formatted_s(:db),
              :notes => '',
              :action_type => "updated",
              :project_id => @project.id)
            issues_journal_insertion(updated_attrs, @journal, journalized_property, fk_values)
          end
        end
      end
      render_index_js
    end
  end

  # For the construction of the filter form
  def filter
    @filters = {}
    @filters_list = []
    unused_attributes = ['Project','Description']
    attrs = Document.attributes_formalized_names.delete_if {|attribute| unused_attributes.include?(attribute)}
    attrs.each{|attribute| @filters_list << [attribute,attribute.gsub(/\s/,'_').downcase]}
    @hash_for_content = {}
    @hash_for_select = {}
    @hash_for_radio = Hash.new{|k,v| k[v] = []}
    @hash_for_radio["name"] = ["all","contains","not contains"]
    @hash_for_select["category"] = @project.categories.collect{|category| [category.name, category.id]}
    @hash_for_radio["category"] = ["all","equal","different"]
    @hash_for_radio["created"] = ["all","equal","superior","inferior","today"]
    @hash_for_select["version"] = @project.versions.collect{|version| [version.name, version.id]}
    @hash_for_select["version"] << ["Unplanned", "NULL"]
    @hash_for_radio["version"] = ["all","equal","different"]
    @hash_for_radio["updated"] = ["all","equal","superior","inferior","today"]
    #When page is reloading, user don't loose his filters
    filter_params = params[:filter].clone if params[:filter]
    if params[:type].eql?('filter') && params[:filter] && params[:filters_list] && params[:filters_list].any?
      filter = documents_filter(params[:filter], @project.id)
    elsif params[:commit]
      session[@project.identifier+'_controller_documents_filter'] = nil
      session[@project.identifier+'_controller_documents_filter_params'] = nil
    else
      #nothing.
    end
    session[@project.identifier+'_controller_documents_filter_params'] = filter_params if params[:type] && params[:type].eql?('filter')
    filter ? session[@project.identifier+'_controller_documents_filter'] = filter : session[@project.identifier+'_controller_documents_filter'] =
      (session[@project.identifier+'_controller_documents_filter'] ? session[@project.identifier+'_controller_documents_filter'] : "")
  end

  private
  def sort_column
    params[:sort] ?
      session['controller_documents_sort'] = params[:sort] :
      session['controller_documents_sort'] =
      (session['controller_documents_sort'] ?
        session['controller_documents_sort'] :
        'id')
    session['controller_documents_sort']
  end

  def sort_direction
    params[:direction] ?
      session['controller_documents_direction'] = params[:direction] :
      session['controller_documents_direction'] =
      (session['controller_documents_direction'] ?
        session['controller_documents_direction'] :
        'desc')
    session['controller_documents_direction']
  end

  def render_index_js(message = t(:successful_update))
    params[:per_page] ?
      session['controller_documents_per_page'] = params[:per_page] :
      session['controller_documents_per_page'] = (session['controller_documents_per_page'] ?
        session['controller_documents_per_page'] :
        25)
    order = sort_column + " " + sort_direction
    #    filter = session[@project.identifier+'_controller_documents_filter']
    filter = ""
    @documents = Document.paginated_documents(params[:page],
      session['controller_documents_per_page'],
      order,
      filter,
      @project.id)
    # Refresh list
    respond_to do |format|
      format.html{ redirect_to :action => 'index', :controller => 'documents'}
      format.js {render :update do |page|
          page.replace 'documents_content', :partial => 'documents/list'
          response.headers['flash-message'] = message
        end}
    end
  end
end
