# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: document_controller.rb
class DocumentsController < ApplicationController
  before_filter :find_project, except: [:index, :new, :edit, :toolbox]
  before_filter :find_project_with_associations, only: [:index, :new, :edit, :toolbox]
  before_filter :load_documents, :only => [:index]
  before_filter :check_permission, :except => [:download_attachment, :toolbox]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }
  include DocumentsHelper
  include Rorganize::RichController
  helper_method :sort_column, :sort_direction
  require 'will_paginate'

  def index
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  def new
    @document = Document.new.decorate
    @document.attachments.build
    respond_to do |format|
      format.html
    end
  end

  def create
    @document = Document.new(document_params).decorate
    @document.project_id = @project.id
    @document.created_at = Time.now.to_formatted_s(:db)
    respond_to do |format|
      if @document.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'show', :id => @document.id }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    @document = Document.find(params[:id]).decorate
    respond_to do |format|
      format.html
    end
  end

  def update
    @document = Document.find(params[:id]).decorate
    @document.attributes = document_params
    respond_to do |format|
      if !@document.changed? &&
          (document_params[:existing_attachment_attributes].nil? &&
              document_params[:new_attachment_attributes].nil?)
        format.html { redirect_to document_path(@project.slug, @document.id) }
      elsif @document.save && @document.save_attachments
        flash[:notice] = t(:successful_update)
        format.html { redirect_to document_path(@project.slug, @document.id) }
      else
        format.html { render :action => 'edit'}
      end
    end
  end

  def show
    #this always return 1 result. Don't use .first(AR method) because it generate two query (due to ActiveRecord::FinderMethods::apply_join_dependency(..))
    @document = Document.eager_load(:category, :version, :attachments).where(id: params[:id])[0].decorate
    respond_to do |format|
      format.html { render :action => 'show', :locals => {:journals => @document.activities} }
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

  def destroy
    @document = Document.find(params[:id])
    @document.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to documents_path }
      format.js { js_redirect_to documents_path }
    end
  end

  #GET /project/:project_identifier/documents/toolbox
  def toolbox
    #Displaying toolbox with GET request
      if !request.post?
        #loading toolbox
        @documents_toolbox = Document.where(:id => params[:ids]).eager_load(:version, :category)
        respond_to do |format|
          format.js { respond_to_js :locals => {:documents => @documents_toolbox} }
        end
      elsif params[:delete_ids]
        #Multi delete
        Document.destroy_all(:id => params[:delete_ids])
        respond_to do |format|
          load_documents
          format.js { respond_to_js :action => :index, :response_header => :success, :response_content => t(:successful_deletion) }
        end
      else
        Document.bulk_edit(params[:ids], value_params)
        respond_to do |format|
          load_documents
          format.js { respond_to_js :action => :index, :response_header => :success, :response_content => t(:successful_update) }
        end
    end
  end

  def filter
    session_json = "#{@project.slug}_controller_documents_filter_params"
    session_sql = "#{@project.slug}_controller_documents_filter"
    session[session_json], session[session_sql] = apply_filter(Document, params, session[session_json], session[session_sql])
  end

  private

  def sort_column
    session['controller_documents_sort'] = params[:sort] ? params[:sort] :(session['controller_documents_sort'] ? session['controller_documents_sort'] : 'documents.id')
  end

  def sort_direction
   session['controller_documents_direction'] = params[:direction] ? params[:direction] :(session['controller_documents_direction'] ? session['controller_documents_direction'] : 'desc')
  end

  def load_documents
    filter
    gon.DOM_filter = view_context.documents_generics_form_to_json
    gon.DOM_persisted_filter = session["#{@project.slug}_controller_documents_filter_params"].to_json
    session['controller_documents_per_page'] = params[:per_page] ?  params[:per_page] :  (session['controller_documents_per_page'] ? session['controller_documents_per_page'] : 25)
    order = sort_column + ' ' + sort_direction
    filter = session["#{@project.slug}_controller_documents_filter"]
    @documents = Document.paginated_documents(params[:page], session['controller_documents_per_page'],order, filter, @project.id).decorate(context: {project: @project})
  end

  def document_params
    params.require(:document).permit(Document.permit_attributes)
  end

  def value_params
    params.require(:value).permit(Document.permit_bulk_edit_values)
  end

  def find_project_with_associations
    @project = Project.eager_load(:attachments, :versions, :categories, :members).where(slug: params[:project_id])[0]
  end
end
