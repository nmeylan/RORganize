# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: document_controller.rb
require 'shared/history'
class DocumentsController < ApplicationController
  before_filter :find_document, only: [:show, :edit, :destroy, :update]
  before_filter :check_permission, locals: [:toolbox]
  include Rorganize::RichController
  include Rorganize::RichController::AttachableCallbacks
  include Rorganize::Filters::NotificationFilter
  include Rorganize::RichController::ToolboxCallback
  include Rorganize::RichController::ProjectContext
  include Rorganize::RichController::CustomQueriesCallback

  def index
    filter(Document)
    load_documents
    find_custom_queries
    generic_index_callback
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
    generic_create_callback(@document_decorator, -> { document_path(@project.slug, @document_decorator.id) })
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @document_decorator.attributes = document_params
    update_attachable_callback(@document_decorator, document_path(@project.slug, @document_decorator.id), document_params)
  end

  def show
    generic_show_callback({history: History.new(Journal.document_activities(@document_decorator.id), @document_decorator.comments)})
  end

  def destroy
    generic_destroy_callback(@document_decorator, documents_path)
  end

  #GET /project/:project_identifier/documents/toolbox
  def toolbox
    collection = Document.where(id: params[:ids]).eager_load(:version, :category)
    toolbox_callback(collection, Document, @project)
  end

  private

  def load_documents
    @documents_decorator = Document.paginated_documents(@sessions[:current_page], @sessions[:per_page], order('documents.id'), gon_filter_initialize, @project.id).decorate(context: {project: @project, query: @query})
  end

  #Find custom queries
  def find_custom_queries
    super(Document.to_s)
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
