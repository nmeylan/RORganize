# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: document_controller.rb
class DocumentsController < ApplicationController
  before_filter :find_project
  before_filter :load_documents, :only => [:index]
  before_filter :check_permission, :except => [:download_attachment, :toolbox]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter {|c| c.top_menu_item('projects')}
  include ApplicationHelper
  include DocumentsHelper
  helper_method :sort_column, :sort_direction
  require 'will_paginate'
  def index
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace 'documents_content', :partial => 'documents/list'
        end
      end
    end
  end

  def new
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
        format.html {redirect_to :action => 'show', :id => @document.id}
      else
        format.html {render :action => 'new'
        }
      end
    end
  end

  def edit
    @document = Document.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    @document = Document.find(params[:id])
    @document.attributes= params[:document]
    respond_to do |format|
      if !@document.changed? &&
          (params[:document][:existing_attachment_attributes].nil? &&
            params[:document][:new_attachment_attributes].nil?)
        format.html { redirect_to document_path(@project.slug,@document.id)}
      elsif @document.save && @document.save_attachments
        flash[:notice] = t(:successful_update)
        format.html { redirect_to document_path(@project.slug,@document.id)}
      else
        format.html {render :action => 'new'
        }
      end
    end
  end

  def show
    @document = Document.find(params[:id], :include => [:category, :version, :attachments])
    journal_created = Journal.includes(:user).where(:action_type => 'created', :journalized_id => @document.id,:journalized_type => @document.class.to_s ).first
    journals = Journal.find_all_by_journalized_type_and_journalized_id(@document.class.to_s, @document.id, :include => [:details, :user])
    respond_to do |format|
      format.html {render :action => 'show', :locals => {:journals => journals, :journal_created => journal_created}}
    end
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
      @documents_toolbox = Document.where(:id => params[:ids]).includes(:version, :category)
      menu = toolbox_menu
      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace_html 'documents_toolbox', :partial => 'documents/toolbox', :locals => {:menu => menu}
            page.replace 'delete_overlay', :partial => 'documents/delete_overlay', :locals => {:documents => @documents_toolbox}
          end
        end
      end
    elsif params[:delete_ids]
      #Multi delete
      documents = Document.where(:id => params[:delete_ids])
      documents.each do |document|
        document.destroy
      end
      render_index_js(t(:successful_deletion))
    else
      #Editing with toolbox
      @documents_toolbox = Document.where(:id => params[:ids])
      attributes ={'version_id' => Version, 'category_id' => Category}
      attribute_name = ''
      attribute_value = ''
      params[:value].each do |k,v|
        if v.eql?('')
          #delete other parameters, that wasn't updated
          params[:value].reject! { |k, v| v.eql?('') }
        else
          attribute_name = k
          if (attributes.keys.include?(k))
            !k.eql?('status_id') ?
                attribute_value = attributes[k].find_by_name(v) :
                attribute_value = attributes[k].find_by_enumeration_id(Enumeration.find_by_name_and_opt(v, 'ISTS'))
          else
            attribute_value = v
          end
        end
      end
      params[:value][attribute_name] = attribute_value ? attribute_value : ''
      #      Documents update
      params[:value][attribute_name] = params[:value].values.first.id unless (params[:value].values.first.class.eql?(String))
      @documents_toolbox.each do |document|
        puts params[:value].inspect
        document.attributes = params[:value]
        if document.changed?
          document.save
        end
      end
      @documents_toolbox = nil
      render_index_js
    end
  end

  def filter
    filter_params = params[:filter].clone if params[:filter]
    if params[:type].eql?('filter') && params[:filter] && params[:filters_list] && params[:filters_list].any?
      filter = documents_filter(params[:filter], @project.id)
    elsif params[:commit]
      #filter SQL content
      session[@project.slug+'_controller_documents_filter'] = nil
      #filter DOM content
      session[@project.slug+'_controller_documents_filter_params'] = nil
    end
    #When page is reloading, user don't loose his filters
    if params[:type] && params[:type].eql?('filter')
      session[@project.slug+'_controller_documents_filter_params'] = filter_params
    end
    filter ? 
      (session[@project.slug+'_controller_documents_filter'] = filter) : 
      session[@project.slug+'_controller_documents_filter'] =
      (session[@project.slug+'_controller_documents_filter'] ? 
        session[@project.slug+'_controller_documents_filter'] : '')
  end

  private
 
  def sort_column
    params[:sort] ?
      (session['controller_documents_sort'] = params[:sort]) :
      session['controller_documents_sort'] =
      (session['controller_documents_sort'] ?
        session['controller_documents_sort'] :
        'id')
    session['controller_documents_sort']
  end

  def sort_direction
    params[:direction] ?
      (session['controller_documents_direction'] = params[:direction]) :
      session['controller_documents_direction'] =
      (session['controller_documents_direction'] ?
        session['controller_documents_direction'] :
        'desc')
    session['controller_documents_direction']
  end

  def render_index_js(message = t(:successful_update))
    load_documents
    respond_to do |format|
      format.html{ redirect_to :action => 'index', :controller => 'documents'}
      format.js {render :update do |page|
          page.replace 'documents_content', :partial => 'documents/list'
          response.headers['flash-message'] = message
        end}
    end
  end
  
  def toolbox_menu
    menu = {}
    # Toolbox menu content
    menu['versions'] = @project.versions.collect{|version| version.name} << 'None' #field that can include blank
    menu['categories'] = @project.categories.collect{|category| category.name} << 'None'
    #documents current states for each fields
    current_states = Hash.new{}
    current_states['version'] = @documents_toolbox.collect{|document| document.version.nil? ? 'None' : document.version.name}.uniq
    current_states['category'] = @documents_toolbox.collect{|document| document.category.nil? ? 'None' : document.category.name}.uniq
    menu['current_states'] = current_states
    return menu
  end
  
  def load_documents
    filter
    params[:per_page] ?
      session['controller_documents_per_page'] = params[:per_page] :
      session['controller_documents_per_page'] = (session['controller_documents_per_page'] ?
        session['controller_documents_per_page'] :
        25)
    order = sort_column + ' ' + sort_direction
    filter = session[@project.slug+'_controller_documents_filter']
    @documents = Document.paginated_documents(params[:page],
      session['controller_documents_per_page'],
      order,
      filter,
      @project.id)
  end
end
