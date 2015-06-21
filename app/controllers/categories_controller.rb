# Author: Nicolas Meylan
# Date: 16 août 2012
# Encoding: UTF-8
# File: categories_controller.rb

class CategoriesController < ApplicationController
  include RichController

  before_action :find_category, only: [:edit, :update, :destroy]
  before_action :check_permission
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item('settings') }
  before_action { |c| c.top_menu_item('projects') }

  def index
    @categories_decorator = @project.categories.paginated(@sessions[:current_page], @sessions[:per_page], order('categories.name')).decorate(context: {project: @project})
    if request.xhr?
      render json: {list: @categories_decorator.display_collection}
    else
      render :index
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
    generic_create_callback(@category, project_categories_path)
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @category.attributes = (category_params)
    generic_update_callback(@category, project_categories_path)
  end

  def destroy
    simple_js_callback(@category.destroy, :delete, @category, id: "category-#{params[:id]}")
  end

  private
  def category_params
    params.require(:category).permit(Category.permit_attributes)
  end

  def find_category
    @category = @project.categories.find(params[:id])
  end
end
