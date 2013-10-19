# Author: Nicolas Meylan
# Date: 19 mai 2013
# Encoding: UTF-8
# File: wikis_controller.rb

class WikiController < ApplicationController
  before_filter :find_project
  before_filter :check_permission, :except => [:organize_pages]
  before_filter :check_organize_pages_permission, :only => [:organize_pages]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller])}
  before_filter {|c| c.top_menu_item('projects')}
  include ApplicationHelper
  
  def index
    @wiki = Wiki.where(:project_id => @project.id).includes(:home_page).first
    respond_to do |format|
      format.html
    end
  end

  def new
    @wiki = Wiki.new
    respond_to do |format|
      format.html
    end
  end
  
  def show
    index
  end
  
  def destroy
    @wiki = Wiki.find(params[:id])
    @wiki.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to wiki_index_path}
      format.js do
        render :update do |page|
          page.redirect_to wiki_index_path
        end
      end
    end
  end

  def create
    @wiki = Wiki.new
    @wiki.project_id = @project.id
    respond_to do |format|
      if @wiki.save
        flash[:notice] = t(:successful_creation)
        format.html {redirect_to wiki_index_path(@project.slug)}
      end
    end
  end
  
  def pages
    @wiki_pages = WikiPage.select('*').where(:wiki_id => Wiki.find_by_project_id(@project.id), :parent_id => nil)
    respond_to do |format|
      format.html {}
    end
  end
 
  
  def organize_pages
    @wiki_pages = WikiPage.select('*').where(:wiki_id => Wiki.find_by_project_id(@project.id), :parent_id => nil)
    respond_to do |format|
      format.html {}
    end
  end
  
  def set_organization
    page_ids = params[:pages_organization].keys
    @wiki_pages = WikiPage.select('*').where(:id => page_ids)
    parent = nil
    @wiki_pages.each do |page|
      parent = params[:pages_organization][page.id.to_s][:parent_id]
      if parent.eql?('null')
        params[:pages_organization][page.id.to_s][:parent_id] = nil
      end
      page.update_attributes(params[:pages_organization][page.id.to_s])
    end
    respond_to do |format|
      format.js do
        render :update do |page|
          response.headers['flash-message'] = t(:successful_update)
        end
      end
    end
  end
  
  private
  def check_organize_pages_permission
     unless current_user.allowed_to?('set_organization', 'Wiki', @project)
      render_403
    end
  end
end
