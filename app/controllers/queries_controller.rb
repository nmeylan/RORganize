# Author: Nicolas Meylan
# Date: 5 févr. 2013
# Encoding: UTF-8
# File: queries_controller.rb

class QueriesController < ApplicationController
  include Rorganize::RichController
  before_action { |c| c.add_action_alias = {'new_project_query' => 'new'} }
  before_action :set_pagination, only: [:index]
  before_action :find_project, only: [:create]
  before_action :check_permission, except: [:edit_query_filter]
  before_action :check_query_permission, only: [:show, :edit, :destroy, :update, :edit_query_filter]
  before_action { |c| c.top_menu_item('administration') }

  def index
    self.menu_context :admin_menu
    self.menu_item(params[:controller], params[:action])
    @queries_decorator = Query.where('is_public = ? AND is_for_all = ?', true, true).eager_load(:user).paginated(@sessions[:current_page], @sessions[:per_page], order('queries.name')).decorate(context: {queries_url: queries_path, action_name: 'index'})
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  def new_project_query
    find_project
    @query = Query.new
    @query.object_type = params[:query_type]
    respond_to do |format|
      format.js { respond_to_js locals: {new: true} }
    end
  end

  def create
    find_project
    @query = Query.create_query(query_params, @project, params[:filter])
    success = @query.save
    respond_to do |format|
      format.js do
        if success
          case @query.object_type
            when 'Issue' then
              js_redirect_to(apply_custom_query_issues_path(@query.project.slug, @query.slug))
            when 'Document' then
              js_redirect_to(apply_custom_query_documents_path(@query.project.slug, @query.slug))
          end
        else
          respond_to_js action: 'new_project_query', locals: {new: false, success: success},
                        response_header: :failure, response_content: @query.errors.full_messages,
                        status: :unprocessable_entity
        end
      end
    end

  end

  def show
    @query_decorator = @query.decorate
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def edit_query_filter
    @query = Query.find_by!(slug: params[:query_id])
    filter = @query.object_type.constantize.conditions_string(params[:filter])
    @query.stringify_query = filter
    @query.stringify_params = params[:filter].inspect
    success = @query.save
    respond_to do |format|
      format.js do
        if success
          respond_to_js action: 'do_nothing', locals: {new: false, success: success},
                        response_header: :success, response_content: t(:successful_update)
        else
          respond_to_js action: 'do_nothing', locals: {new: false, success: success},
                        response_header: :failure, response_content: @query.errors.full_messages
        end
      end
    end
  end

  def update
    @query.attributes = (query_params)
    generic_update_callback(@query, query_path(@query))
  end

  def destroy
    @query.destroy
    respond_to do |format|
      format.js do
        respond_to_js response_header: :success, response_content: t(:successful_deletion), locals: {id: @query.id}
      end
    end
  end

  private
  def find_project
    @project = Project.find_by!(slug: params[:project_id])
  end

  def check_query_permission
    @query = params[:id] ? Query.find(params[:id]) : Query.find_by!(slug: params[:query_id])
    if (@query.is_public && !User.current.allowed_to?('public_queries', 'Queries', Project.find_by_slug(params[:project_id]))) ||
        (!@query.is_public && !@query.author_id.eql?(User.current.id))
      render_403
    end
  end

  def query_params
    params.require(:query).permit(Query.permit_attributes)
  end
end

