require 'shared/activities'
class ProjectsController < ApplicationController
  helper VersionsHelper
  helper TrackersHelper
  include ActivityCallback
  include GenericCallbacks

  before_action { |c| c.add_action_alias = {'show' => 'overview'} }
  before_action :find_project, only: [:archive, :destroy, :overview, :show, :activity, :activity_filter, :members, :issues_completion]
  before_action :find_trackers, only: [:new, :create]
  before_action :check_permission, except: [:index, :filter, :members, :activity_filter, :issues_completion]
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item(params[:controller], params[:action].eql?('show') ? 'overview' : params[:action]) }
  before_action { |c| c.top_menu_item('projects') }
  #GET /project/:project_id
  #Project overview
  def overview
    respond_to do |format|
      format.html { render :overview }
    end
  end

  def show
    overview
  end

  def activity
    init_activities_sessions
    locals = selected_filters
    load_activities(@project_decorator)
    activity_callback(locals)
  end


  #GET /project/new
  def new
    @project_decorator = Project.new.decorate
    @project_decorator.attachments.build
    respond_to do |format|
      format.html
    end
  end

  #POST /project/new
  def create
    @project_decorator = Project.new(project_params).decorate
    generic_create_callback(@project_decorator, -> { overview_projects_path(@project_decorator.slug) })
  end

  def destroy
    #Todo add check
    success = @project.destroy && Query.destroy_all(project_id: @project.id, is_for_all: false)
    archive_destroy_callback(success)
  end


  def archive
    #Todo add check
    success = @project.update_column(:is_archived, !@project.is_archived)
    archive_destroy_callback(success, false)
  end

  #GET /projects/
  def index
    if session['project_selection_filter'].nil?
      session['project_selection_filter'] = 'all'
    end
    @projects_decorator = User.current.owned_projects(session['project_selection_filter']).decorate(context: {allow_to_star: true})
    generic_index_callback
  end

  def filter
    unless params[:filter].nil?
      session['project_selection_filter'] = params[:filter]
    end
    index
  end

  def members
    members = User.joins(:members).where('members.project_id' => @project_decorator.id).where('members.role_id <> ?', Role.non_member.id).pluck('users.slug')
    respond_to do |format|
      format.json { render json: members }
    end
  end

  def issues_completion
    issues = Issue.joins(:status).where(project_id: @project_decorator.id).order('issues.sequence_id ASC').pluck('issues.sequence_id, issues.subject')
    respond_to do |format|
      format.json { render json: issues }
    end
  end

  private
  def archive_destroy_callback(success, destroy = true)
    flash[:notice] = destroy ? t(:successful_deletion) : t(:successful_update)
    respond_to do |format|
      format.html { redirect_to :root }
      format.js do
        if success
          js_redirect_to url_for(:root)
        else
          respond_to_js action: :empty_action, response_header: :failure, response_content: t(:failure_update)
        end
      end
    end
  end

  def project_params
    params.require(:project).permit(Project.permit_attributes)
  end

  def find_project
    id = params[:id] ? params[:id] : params[:project_id]
    @project_decorator = Project.includes(:attachments, members: [:role, user: :avatar]).find_by!(slug: id).decorate
    @project = @project_decorator.model
  end

  def find_trackers
    @trackers_decorator = Tracker.all.decorate(context: {checked_ids: Tracker.where(name: ['Bug', 'Task']).collect(&:id)})
  end
end
