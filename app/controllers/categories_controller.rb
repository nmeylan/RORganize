# Author: Nicolas Meylan
# Date: 16 août 2012
# Encoding: UTF-8
# File: categories_controller.rb

class CategoriesController < ApplicationController
  before_filter :find_project
  before_filter :find_category, only: [:edit, :update, :destroy]
  before_filter :check_permission
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('settings') }
  before_filter { |c| c.top_menu_item('projects') }
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
    respond_to do |format|
      if @category.save
        success_generic_create_callback(format, categories_path)
      else
        error_generic_create_callback(format, @category)
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @category.attributes = (category_params)
    respond_to do |format|
      if !@category.changed?
        success_generic_update_callback(format, categories_path, false)
      elsif @category.changed? && @category.save
        success_generic_update_callback(format, categories_path)
      else
        error_generic_update_callback(format, @category)
      end
    end
  end

  def destroy
    @category.destroy
    simple_js_callback(@category.destroy, :delete, {id: params[:id]})
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
