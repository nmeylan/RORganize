# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: document_controller.rb
require 'shared/history'
class DocumentsController < ApplicationController
  before_filter :load_documents, :only => [:index]
  before_filter :check_permission, :except => [:download_attachment, :toolbox]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }
  include Rorganize::RichController

  def index
    respond_to do |format|
      format.html
      format.js { respond_to_js action: 'index' }
    end
  end

  def new
    @document = Document.new.decorate(context: {project: @project})
    @document.attachments.build
    respond_to do |format|
      format.html
    end
  end

  def create
    @document = Document.new(document_params).decorate(context: {project: @project})
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
    @document = Document.find(params[:id]).decorate(context: {project: @project})
    respond_to do |format|
      format.html
    end
  end

  def update
    @document = Document.find(params[:id]).decorate(context: {project: @project})
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
        format.html { render :action => 'edit' }
      end
    end
  end

  def show
    #this always return 1 result. Don't use .first(AR method) because it generate two query (due to ActiveRecord::FinderMethods::apply_join_dependency(..))
    @document = Document.eager_load(:category, :version, :attachments).where(id: params[:id])[0].decorate(context: {project: @project})
    respond_to do |format|
      format.html { render :action => 'show', :locals => {:history => History.new(Journal.document_activities(@document.id), @document.comments)} }
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
    if !request.post? && params[:ids]
      #loading toolbox
      @documents_toolbox = Document.where(:id => params[:ids]).eager_load(:version, :category)
      respond_to do |format|
        format.js { respond_to_js :locals => {:documents => @documents_toolbox} }
      end
    elsif !request.post?
      load_documents
      index
    elsif params[:delete_ids]
      #Multi delete
      Document.destroy_all(:id => params[:delete_ids])
      respond_to do |format|
        load_documents
        format.js { respond_to_js :action => :index, :response_header => :success, :response_content => t(:successful_deletion) }
      end
    else
      if User.current.allowed_to?('edit', 'documents', @project)
        Document.bulk_edit(params[:ids], value_params)
        respond_to do |format|
          load_documents
          format.js { respond_to_js :action => :index, :response_header => :success, :response_content => t(:successful_update) }
        end
      end
    end
  end

  def filter
    @sessions[@project.slug] ||= {}
    apply_filter(Document, params, @sessions[@project.slug])
  end

  private

  def load_documents
    filter
    gon.DOM_filter = view_context.documents_generics_form_to_json
    gon.DOM_persisted_filter = @sessions[@project.slug][:json_filter].to_json
    filter = @sessions[@project.slug][:sql_filter]
    @documents = Document.filter(filter, @project.id).paginated(@sessions[:current_page], @sessions[:per_page], order('documents.id')).fetch_dependencies.decorate(context: {project: @project})
  end

  def document_params
    params.require(:document).permit(Document.permit_attributes)
  end

  def value_params
    params.require(:value).permit(Document.permit_bulk_edit_values)
  end

  def find_project
    @project = Project.eager_load(:attachments, :versions, :categories, :members).where(slug: params[:project_id])[0]
    gon.project_id = @project.slug
  rescue => e
    render_404
  end


end
