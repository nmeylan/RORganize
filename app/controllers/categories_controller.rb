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
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to categories_path }
        format.json { render :json => @category,
                             :status => :created, :location => @category }
      else
        format.html { render :new }
        format.json { render :json => @category.errors,
                             :status => :unprocessable_entity }
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
        format.html { redirect_to categories_path}
      elsif @category.changed? && @category.save
        flash[:notice] = t(:successful_update)
        format.html { redirect_to categories_path }
        format.json { render :json => @category,
                             :status => :created, :location => @category }
      else
        format.html { render :edit}
        format.json { render :json => @category.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = t(:successful_deletion)
        redirect_to category_path
      end
      format.js { respond_to_js :locals => {:id => params[:id]}, :response_header => :success, :response_content => t(:successful_deletion) }
    end
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
