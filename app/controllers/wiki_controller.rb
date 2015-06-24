# Author: Nicolas Meylan
# Date: 19 mai 2013
# Encoding: UTF-8
# File: wikis_controller.rb

class WikiController < ApplicationController
  include WikiHelper
  include RichController
  include ProjectContext
  helper WikiPagesHelper

  before_action :find_wiki, except: [:create]
  before_action :check_permission, except: [:organize_pages]
  before_action :check_organize_pages_permission, only: [:organize_pages]

  def index
    respond_to do |format|
      format.html
    end
  end

  def destroy
    generic_destroy_callback(@wiki_decorator, project_wiki_index_path)
  end

  def create
    @wiki = @project.build_wiki
    @wiki.home_page = WikiPage.new
    respond_to do |format|
      if @wiki.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to project_wiki_index_path(@project.slug) }
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
    simple_js_callback(true, :update, @wiki_decorator.model)
  end

  private
  def check_organize_pages_permission
    unless User.current.allowed_to?('set_organization', 'Wiki', @project)
      render_403
    end
  end

  def find_wiki
    wiki = Wiki.eager_load([[pages: [:author, :sub_pages, :parent]], [home_page: :author]]).find_by_project_id(@project.id) || @project.wiki
    @wiki_decorator = wiki ? wiki.decorate(context: {project: @project}) : Wiki.new.decorate(context: {project: @project})
  end

  def pages_organization_params
    params.require(:pages_organization).permit!
  end
end
