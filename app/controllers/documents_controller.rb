# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: document_controller.rb
require 'shared/history'
class DocumentsController < ApplicationController
  before_filter :load_documents, locals: [:index]
  before_filter :find_document, only: [:show, :edit, :destroy, :update]
  before_filter :check_permission, locals: [:toolbox]
  include Rorganize::RichController
  include Rorganize::Filters::NotificationFilter
  include Rorganize::RichController::ToolboxCallback
  include Rorganize::RichController::ProjectContext

  def index
    respond_to do |format|
      format.html
      format.js { respond_to_js action: 'index' }
    end
  end

  def new
    @document_decorator = Document.new.decorate(context: {project: @project})
    @document_decorator.attachments.build
    respond_to do |format|
      format.html
    end
  end

  def create
    @document_decorator = @project.documents.build(document_params).decorate(context: {project: @project})
    respond_to do |format|
      if @document_decorator.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to document_path(@project.slug, @document_decorator.id) }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @document_decorator.attributes = document_params
    respond_to do |format|
      if !@document_decorator.changed? &&
          (document_params[:existing_attachment_attributes].nil? &&
              document_params[:new_attachment_attributes].nil?)
        format.html { redirect_to document_path(@project.slug, @document_decorator.id) }
      elsif @document_decorator.save && @document_decorator.save_attachments
        flash[:notice] = t(:successful_update)
        format.html { redirect_to document_path(@project.slug, @document_decorator.id) }
      else
        format.html { render :edit }
      end
    end
  end

  def show
    generic_show_callback(@document_decorator)
  end

  def destroy
    generic_destroy_callback(@document_decorator, documents_path)
  end

  #GET /project/:project_identifier/documents/toolbox
  def toolbox
    collection = Document.where(id: params[:ids]).eager_load(:version, :category)
    toolbox_callback(collection, Document, @project)
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
    @documents_decorator = Document.filter(filter, @project.id).paginated(@sessions[:current_page], @sessions[:per_page], order('documents.id'), [:version, :category, :attachments]).fetch_dependencies.decorate(context: {project: @project})
  end

  def document_params
    params.require(:document).permit(Document.permit_attributes)
  end

  def value_params
    params.require(:value).permit(Document.permit_bulk_edit_values)
  end

  def find_project
    @project = Project.includes(:attachments, :versions, :categories, :members).where(slug: params[:project_id])[0]
    gon.project_id = @project.slug
  rescue => e
    render_404
  end

  def find_document
    @document_decorator = Document.eager_load(:category, :version, :attachments).where(id: params[:id])[0]
    if @document_decorator
      @document_decorator = @document_decorator.decorate(context: {project: @project})
    else
      render_404
    end

  end

  alias :load_collection :load_documents


end
