# Author: Nicolas Meylan
# Date: 19 mai 2013
# Encoding: UTF-8
# File: wiki_pages_controller.rb

class WikiPagesController < ApplicationController
  helper WikiHelper
  include GenericCallbacks

  before_action :find_page, only: [:show, :edit, :update, :destroy]
  before_action :find_wiki
  before_action :check_permission, except: [:new_home_page, :new_sub_page]
  before_action :check_new_permission, only: [:new_home_page, :new_sub_page]
  before_action :check_not_owner_permission, only: [:edit, :update, :destroy]
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item('wiki') }
  before_action { |c| c.top_menu_item('projects') }

  def new
    new_form
  end

  def new_home_page
    new_form
  end

  def new_sub_page
    new_form
  end

  def create
    @wiki_page_decorator, wiki, page_success, home_page_success = WikiPage.page_creation(@project.id, wiki_page_params, params)
    @wiki_page_decorator = @wiki_page_decorator.decorate
    respond_to do |format|
      if page_success
        home_page_creation(wiki, format, home_page_success)
        success_generic_create_callback(format, project_wiki_page_path(@project.slug, @wiki_page_decorator.slug))
      else
        if params[:wiki] && params[:wiki][:home_page]
          format.html { render :new_home_page, status: :unprocessable_entity }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end
  end

  def home_page_creation(wiki, format, home_page_success)
    if  params[:wiki] && params[:wiki][:home_page] && wiki.home_page_id.nil?
      if home_page_success
        success_generic_create_callback(format, project_wiki_page_path(@project.slug, @wiki_page_decorator.slug))
      else
        format.html { render :new_home_page }
      end
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @wiki_page_decorator.attributes = wiki_page_params
    generic_update_callback(@wiki_page_decorator, project_wiki_page_path(@project.slug, @wiki_page_decorator.slug))
  end

  def destroy
    generic_destroy_callback(@wiki_page_decorator, pages_project_wiki_index_path(@project.slug))
  end

  private
  def new_form
    @wiki_page_decorator = WikiPage.new.decorate
    respond_to do |format|
      format.html
    end
  end

  def check_new_permission
    unless User.current.allowed_to?('new', 'Wiki_pages', @project)
      render_403
    end
  end

  def find_page
    @wiki_page_decorator = WikiPage.eager_load(:sub_pages, :author).find_by_slug!(params[:id]).decorate(context: {project: @project})
  end

  def check_owner
    @wiki_page_decorator.author_id.eql?(User.current.id)
  end

  def wiki_page_params
    params.require(:wiki_page).permit(WikiPage.permit_attributes)
  end

  def find_wiki
    wiki = Wiki.eager_load([[pages: [:author, :sub_pages, :parent]], [home_page: :author]]).find_by_project_id(@project.id)
    @wiki_decorator = wiki ? wiki.decorate(context: {project: @project}) : Wiki.new.decorate(context: {project: @project})
  end
end
