# Author: Nicolas Meylan
# Date: 2 févr. 2013
# Encoding: UTF-8
# File: roadmaps_controller.rb

require 'roadmaps/gantt_object'
class RoadmapsController < ApplicationController
  helper VersionsHelper
  before_filter { |c| c.add_action_alias = {'version' => 'show'} }
  before_filter :check_permission, only: [:gantt, :manage_gantt, :show, :version]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller]) }
  before_filter { |c| c.top_menu_item('projects') }

  #GET/project/:project_id/roadmaps
  def show
    @version_decorator = @project_decorator.current_versions.eager_load(issues: [:status, :tracker]).order(:position).decorate
    unplanned = Version.new(name: 'Unplanned')
    unplanned.issues << Issue.where(project_id: @project_decorator.id, version_id: nil).eager_load(:status, :tracker)
    unplanned.project = @project_decorator.model
    @version_decorator.to_a << unplanned.decorate
    old_versions = @project_decorator.old_versions.decorate
    respond_to do |format|
      format.html { render :index, locals: {old_versions: old_versions} }
    end
  end

  def version
    @version_decorator = Version.eager_load(issues: [:status, :tracker]).find_by_id(params[:id])
    if @version_decorator
      @version_decorator = @version_decorator.decorate

    else
      render_404
    end
  end


  def calendar
    @versions = @project_decorator.versions.order(:position)
    calendar = Version.define_calendar(@versions, params[:date])
    @versions_hash = calendar[:versions_hash]
    @date = calendar[:date]
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  def gantt
    gantt_initialize_sessions
    if params[:value]
      @sessions[@project.slug][:gantt][:versions] = params[:value]
    end
    if params[:mode]
      @sessions[@project.slug][:gantt][:edition] = params[:mode].eql?('edition')
    end
    versions = gantt_load_versions
    @gantt_object = GanttObject.new(versions, @project_decorator, @sessions[@project.slug][:gantt][:edition])
    gon.Gantt_JSON = @gantt_object.json_data
    respond_to do |format|
      format.html { render :gantt, locals: {versions: @project_decorator.versions, selected_versions: versions} }
      format.js { respond_to_js action: 'gantt', locals: {json_data: @gantt_object.json_data, save: false} }
    end
  end

  def manage_gantt
    if request.post?
      errors = persist_gantt(params[:gantt])
      versions = gantt_load_versions
      @gantt_object = GanttObject.new(versions, @project_decorator, @sessions[@project.slug][:gantt][:edition])
      message = errors && errors.any? ? errors : t(:successful_update)
      header = errors && errors.any? ? :failure : :success
      respond_to do |format|
        format.js { respond_to_js action: 'gantt', response_header: header, response_content: message, locals: {json_data: @gantt_object.json_data, save: true} }
      end
    else
      if params[:mode] && params[:mode].eql?('edition')
        @sessions[@project.slug][:gantt][:edition] = true
        versions = gantt_load_versions
        @gantt_object = GanttObject.new(versions, @project_decorator, @sessions[@project.slug][:gantt][:edition])
        respond_to do |format|
          format.js { respond_to_js action: 'gantt', locals: {json_data: @gantt_object.json_data, save: false} }
        end
      else
        gantt
      end

    end
  end

  private
  def find_project
    @project_decorator = Project.eager_load(:versions, :attachments).where(slug: params[:project_id])[0]
    if @project_decorator
      @project_decorator = @project_decorator.decorate
      @project = @project_decorator.model
    else
      render_404
    end
  end

  def gantt_initialize_sessions
    @sessions[@project.slug] ||= {}
    @sessions[@project.slug][:gantt] ||= {}
    @sessions[@project.slug][:gantt][:edition] ||= false
  end

  def gantt_load_versions
    if @sessions[@project.slug][:gantt][:versions]
      Version.includes(issues: [:parent, :children, :tracker, :assigned_to, :status]).where(id: @sessions[@project.slug][:gantt][:versions])
    else
      @project_decorator.versions.includes(issues: [:parent, :children, :tracker, :assigned_to, :status]).where('versions.is_done = false')
    end
  end

  def persist_gantt(gantt)
    version_changes = {}
    issue_changes = {}
    if gantt[:data]
      gantt[:data].each do |_, task|
        if task[:id].start_with?('version')
          version_changes[task[:id].split('_').last] = {start_date: task[:start_date], target_date: task[:context][:due_date]}
        else
          issue_changes[task[:id]] = {start_date: task[:start_date], due_date: task[:context][:due_date]}
        end
      end
    end
    if gantt[:links]
      gantt[:links].each do |_, link|
        unless link[:source].start_with?('version') || link[:target].start_with?('version')
          issue_changes[link[:target]] = issue_changes[link[:target]] ? issue_changes[link[:target]].merge({predecessor_id: link[:source], link_type: link[:type]}) : {predecessor_id: link[:source], link_type: link[:type]}
        end
      end
    end
    Version.gantt_edit(version_changes)
    Issue.gantt_edit(issue_changes)
  end

end