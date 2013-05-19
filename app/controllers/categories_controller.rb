# Author: Nicolas Meylan
# Date: 16 août 2012
# Encoding: UTF-8
# File: categories_controller.rb

class CategoriesController < ApplicationController
  before_filter :find_project
  before_filter :check_permission
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item("settings") }
  before_filter {|c| c.top_menu_item("projects")}
  include ApplicationHelper

  def index
    @categories = @project.categories
    respond_to do |format|
      format.html
    end
  end

  def new
    @category = Category.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @category = Category.new(params[:category])
    respond_to do |format|
      if @category.save
        @project.categories << @category
        @project.save
        @journal = Journal.create(:user_id => current_user.id,
          :journalized_id => @category.id,
          :journalized_type => @category.class.to_s,
          :notes => '',
          :action_type => "created",
          :project_id => @project.id)
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'index', :controller => 'categories'}
        format.json  { render :json => @category,
          :status => :created, :location => @category}
      else
        format.html  { render :action => "new" }
        format.json  { render :json => @category.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @category = Category.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    @category = Category.find(params[:id])
    journalized_property = {'name' => "name"}
    updated_attributes = updated_attributes(@category,params[:category])
    respond_to do |format|
      if updated_attributes.empty?
        format.html { redirect_to :action => 'index', :controller => 'categories'}
      elsif updated_attributes.any? && @category.update_attributes(params[:category])
        @journal = Journal.create(:user_id => current_user.id,
          :journalized_id => @category.id,
          :journalized_type => @category.class.to_s,
          :notes => '',
          :action_type => "updated",
          :project_id => @project.id)
        journal_insertion(updated_attributes, @journal, journalized_property)
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'index', :controller => 'categories'}
        format.json  { render :json => @category,
          :status => :created, :location => @category}
      else
        format.html  { render :action => "edit" }
        format.json  { render :json => @category.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @categories = @project.categories
    @category = Category.find(params[:id])
    @category.destroy
    @journal = Journal.create(:user_id => current_user.id,
      :journalized_id => @category.id,
      :journalized_type => @category.class.to_s,
      :notes => '',
      :action_type => "deleted",
      :project_id => @project.id)
    respond_to do |format|
      format.html do
        flash[:notice] = t(:successful_deletion)
        redirect_to category_path
      end
      format.js do
        render :update do |page|
          page.replace 'categories_content', :partial => 'categories/list'
          response.headers['flash-message'] = t(:successful_deletion)
        end
      end
    end
  end

  def show

  end


end
