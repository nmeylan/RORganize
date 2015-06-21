# Author: Nicolas Meylan
# Date: 6 avr. 2013
# Encoding: UTF-8
# File: document_controller.rb
require 'shared/history'
class DocumentsController < ApplicationController
  include RichController
  include AttachableCallbacks
  include Rorganize::Filters::NotificationFilter
  include ToolboxCallback
  include ProjectContext
  include CustomQueriesCallback

  before_action :find_document, only: [:show, :edit, :destroy, :update]
  before_action :check_permission

  def index
    filter(Document)
    load_documents
    find_custom_queries
    if request.xhr?
      render json: index_json_response
    else
      render :index
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
    generic_create_callback(@document_decorator, -> { project_document_path(@project.slug, @document_decorator) })
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @document_decorator.attributes = document_params
    update_attachable_callback(@document_decorator, project_document_path(@project.slug, @document_decorator), document_params)
  end

  def show
    generic_show_callback({history: History.new(Journal.journalizable_activities(@document_decorator, 'Document'), @document_decorator.comments)})
  end

  def destroy
    generic_destroy_callback(@document_decorator, project_documents_path)
  end

  #GET /project/:project_identifier/documents/toolbox
  def toolbox
    collection = @project.documents.where(sequence_id: params[:ids]).eager_load(:version, :category)
    toolbox_callback(collection, Document, @project)
  end

  private

  def load_documents
    @documents_decorator = load_paginated_collection(Document, 'documents.sequence_id')
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
    @project = Project.includes(:attachments, :versions, :categories, :members).find_by!(slug: params[:project_id])
    gon.project_id = @project.slug
  end

  def find_document
    @document_decorator = @project.documents.eager_load(:category, :version, :attachments).find_by_sequence_id!(params[:id])
    @document_decorator = @document_decorator.decorate(context: {project: @project})
  end

  def index_json_response
    {
        list: @documents_decorator.display_collection,
        filter: view_context.filter_tag('document', Document.filtered_attributes, project_documents_path(@project.slug, query_id: params[:query_id]), true,
                           {user: User.current, project: @project, filter_content: session[controller_name][@project.slug][:json_filter], type: 'Document'}),
        countEntries: @documents_decorator.display_total_entries
    }
  end

  alias :load_collection :load_documents


end
