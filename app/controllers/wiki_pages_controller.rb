# Author: Nicolas Meylan
# Date: 19 mai 2013
# Encoding: UTF-8
# File: wiki_pages_controller.rb

class WikiPagesController < ApplicationController
  before_filter :check_permission, :except => [:new_home_page, :new_sub_page]
  before_filter :check_new_permission, :only => [:new_home_page, :new_sub_page]
  before_filter :check_not_owner_permission, :only => [:edit,:update, :destroy]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('wiki')}
  before_filter {|c| c.top_menu_item('projects')}
  before_filter :find_project
  before_filter :find_wiki
  include ApplicationHelper
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
    @wiki_page = WikiPage.new(params[:wiki_page])
    wiki = @wiki
    @wiki_page.wiki_id = wiki.id
    @wiki_page.author_id = current_user.id
    if params[:wiki_page][:parent_id]
      @wiki_page.parent_id = WikiPage.find_by_slug(params[:wiki_page][:parent_id]).id
    end
    respond_to do |format|
      if @wiki_page.save
        if  params[:wiki] && params[:wiki][:home_page] && wiki.home_page_id.nil?
          wiki.home_page_id = @wiki_page.id
          if wiki.save
            flash[:notice] = t(:successful_creation)
            format.html { redirect_to wiki_page_path(@project.slug,@wiki_page.slug)}
          else
            format.html {render :action => 'new_home_page'
            }
          end
        end
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to wiki_page_path(@project.slug,@wiki_page.slug)}
      else
        if params[:wiki] && params[:wiki][:home_page]
          format.html {render :action => 'new_home_page'
          }
        else
          format.html {render :action => 'new'
          }
        end
      end
    end
  end
  
  def show
    @wiki_page = WikiPage.joins(:sub_pages).includes(:sub_pages).find_by_slug(params[:id])
    @wiki_page ||= WikiPage.find_by_slug(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def edit
   @wiki_page = WikiPage.find_by_slug(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def update
   @wiki_page = WikiPage.find_by_slug(params[:id])
   @wiki_page.attributes=params[:wiki_page]
    respond_to do |format|
      if !@wiki_page.changed?
        format.html { redirect_to wiki_page_path(@project.slug,@wiki_page.slug)}
      elsif @wiki_page.changed? && @wiki_page.save
        flash[:notice] = t(:successful_update)
        format.html { redirect_to wiki_page_path(@project.slug,@wiki_page.slug)}
      else
        format.html { render :action => 'edit'}
      end
    end
  end
  
  def destroy
    @wiki_page = WikiPage.find_by_slug(params[:id])
    respond_to do |format|
      if @wiki_page.destroy
        flash[:notice] = t(:successful_deletion)
        format.js do
          render :update do |page|
            page.redirect_to pages_wiki_index_path(@project.slug)
          end
        end
      else
        
      end
    end
  end
  
  private
  def find_wiki
    @wiki = Wiki.find_by_project_id(@project.id)
    render_404 if @wiki.nil?
  end
  
  def new_form
    @wiki_page = WikiPage.new
    respond_to do |format|
      format.html
    end
  end
  
  def check_new_permission
     unless current_user.allowed_to?('new', 'Wiki_pages', @project)
      render_403
    end
  end
  
  def check_page_owner
    @wiki_page = WikiPage.find_by_slug(params[:id])
    return @wiki_page.author_id.eql?(current_user.id)
  end
  
  def check_not_owner_permission
    if check_page_owner
      return true
    else
      action = "#{find_action(params[:action].to_s)}_not_owner"
      if current_user.allowed_to?(action, params[:controller], @project)
        return true
      else
        render_403
      end
    end
  end
end
