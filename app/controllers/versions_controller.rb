# Author: Nicolas Meylan
# Date: 16 août 2012
# Encoding: UTF-8
# File: versions_controller.rb

class VersionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_project
  before_filter :check_permission
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item("settings") }
  include ApplicationHelper
  def index
    @versions = @project.versions.sort{|x, y| x.position <=> y.position}
    @max = @versions.count
    respond_to do |format|
      format.html
    end
  end

  def new
    @version = Version.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @version = Version.new(params[:version])
    @version.position = @project.versions.count + 1
    respond_to do |format|
      if @version.save
        @project.versions << @version
        @project.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'index', :controller => 'versions'}
        format.json  { render :json => @version,
          :status => :created, :location => @version}
      else
        format.html  { render :action => "new" }
        format.json  { render :json => @version.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @version = Version.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def update
    @version = Version.find(params[:id])
    @version.update_attributes(:name => params[:version][:name], :description => params[:version][:description], :target_date => params[:version][:target_date])
    respond_to do |format|
      if @version.save
        flash[:notice] = t(:successful_update)
        format.html { redirect_to :action => 'index', :controller => 'versions'}
        format.json  { render :json => @version,
          :status => :created, :location => @version}
      else
        format.html  { render :action => "edit" }
        format.json  { render :json => @version.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @versions = @project.versions
    @max = @versions.count
    @version = Version.find(params[:id])

    respond_to do |format|
      if @version.destroy
        dec_position_on_destroy
        format.html do
          flash[:notice] = t(:successful_deletion)
          redirect_to version_path
        end
        format.js do
          render :update do |page|
            page.replace 'versions_content', :partial => 'versions/list'
            response.headers['flash-message'] = t(:successful_deletion)
          end
        end
      else
        format.js do
          render :update do |page|
            page.replace 'versions_content', :partial => 'versions/list'
            response.headers['flash-error-message'] = t(:failure_deletion)
          end
        end
      end
    end
  end

  def show

  end

  def change_position
    @versions = @project.versions.sort{|x, y| x.position <=> y.position}
    @version = @versions.select{|version| version.id.eql?(params[:id].to_i)}.first
    @max = @versions.count
    position = @version.position
    respond_to do |format|
      if @version.position == 1 && params[:operator].eql?("dec") ||
          @version.position == @max && params[:operator].eql?("inc")
        @versions = @project.versions.sort{|x, y| x.position <=> y.position}
        format.js do
          render :update do |page|
            page.replace 'versions_content', :partial => 'versions/list'
            response.headers['flash-error-message'] = t(:text_negative_position)
          end
        end
      else
        if params[:operator].eql?("inc")
          o_version = @versions.select{|version| version.position.eql?(position + 1)}.first
          o_version.update_column(:position, position)
          @version.update_column(:position, position + 1)
        else
          o_version = @versions.select{|version| version.position.eql?(position - 1)}.first
          o_version.update_column(:position, position)
          @version.update_column(:position, position - 1)
        end
        @versions = @project.versions.sort{|x, y| x.position <=> y.position}
        format.js do
          render :update do |page|
            page.replace 'versions_content', :partial => 'versions/list'
            response.headers['flash-message'] = t(:successful_update)
          end
        end
      end
    end
  end

  #Private methods
  private
  def dec_position_on_destroy
    position = @version.position
    Version.update_all "position = position - 1", "position > #{position}"
  end
end
