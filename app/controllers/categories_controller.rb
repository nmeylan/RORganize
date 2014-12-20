# Author: Nicolas Meylan
# Date: 16 août 2012
# Encoding: UTF-8
# File: categories_controller.rb

class CategoriesController < ApplicationController
  before_action :find_project
  before_action :find_category, only: [:edit, :update, :destroy]
  before_action :check_permission
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item('settings') }
  before_action { |c| c.top_menu_item('projects') }
  include Rorganize::RichController

  def index
    @categories_decorator = @project.categories.paginated(@sessions[:current_page], @sessions[:per_page], order('categories.name')).decorate(context: {project: @project})
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  def new
    @category = Category.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @category = @project.categories.build(category_params)
    generic_create_callback(@category, categories_path)
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @category.attributes = (category_params)
    generic_update_callback(@category, categories_path)
  end

  def destroy
    @category.destroy
    simple_js_callback(@category.destroy, :delete, @category, {id: params[:id]})
  end

  private
  def category_params
    params.require(:category).permit(Category.permit_attributes)
  end

  def find_category
    @category = Category.find_by_id(params[:id])
    unless @category
      render_404
    end
  end
end
