# Author: Nicolas Meylan
# Date: 19 mai 2013
# Encoding: UTF-8
# File: wikis_controller.rb

class WikiController < ApplicationController
  before_filter :find_wiki, except: [:new, :create, :set_organization]
  before_filter :check_permission, :except => [:organize_pages]
  before_filter :check_organize_pages_permission, :only => [:organize_pages]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }
  include WikiHelper
  helper WikiPagesHelper

  def index
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
    @wiki.destroy
    flash[:notice] = t(:successful_deletion)
    respond_to do |format|
      format.html { redirect_to wiki_index_path }
      format.js { js_redirect_to wiki_index_path }
    end
  end

  def create
    @wiki = Wiki.new
    @wiki.project_id = @project.id
    @wiki.home_page = WikiPage.new
    respond_to do |format|
      if @wiki.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to wiki_index_path(@project.slug) }
      end
    end
  end

  def pages
    respond_to do |format|
      format.html {}
    end
  end


  def organize_pages
    respond_to do |format|
      format.html {}
    end
  end

  def set_organization
    Wiki.organize_pages(pages_organization_params)
    respond_to do |format|
      format.js { respond_to_js :action => :empty_action, :response_header => :success, :response_content => t(:successful_update) }
    end
  end

  private
  def check_organize_pages_permission
    unless User.current.allowed_to?('set_organization', 'Wiki', @project)
      render_403
    end
  end

  def find_wiki
    @wiki = Wiki.where(:project_id => @project.id).eager_load([[pages: [:author, :sub_pages, :parent]],  [home_page: :author]])[0]
    @wiki = @wiki ? @wiki.decorate(context: {project: @project}) : Wiki.new.decorate(context: {project: @project})
  end

  def pages_organization_params
    params.require(:pages_organization).permit!
  end
end
