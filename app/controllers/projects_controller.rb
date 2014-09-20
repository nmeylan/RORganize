require 'shared/activities'
class ProjectsController < ApplicationController
  before_filter { |c| c.add_action_alias = {'show' => 'overview'}}
  before_filter :find_project, :only => [:overview, :show, :activity, :activity_filter, :members, :issues_completion]
  before_filter :check_permission, :except => [:index, :filter, :members, :activity_filter, :issues_completion]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller], params[:action].eql?('show') ? 'overview' : params[:action]) }
  before_filter { |c| c.top_menu_item('projects') }
  helper VersionsHelper
  include Rorganize::ActivityManager
  #GET /project/:project_id
  #Project overview
  def overview
    respond_to do |format|
      format.html { render :action => 'overview' }
    end
  end

  def show
    overview
  end

  def activity
    init_activities_sessions
    locals = selected_filters
    if @sessions[:activities][:types].include?('NIL')
      @activities =  Activities.new([])
    else
      activities_types = @sessions[:activities][:types]
      activities_period = @sessions[:activities][:period]
      from_date = @sessions[:activities][:from_date]
      @activities = Activities.new(@project_decorator.activities(activities_types, activities_period, from_date), @project_decorator.comments(activities_types, activities_period, from_date))
    end
    respond_to do |format|
      format.html { render action: 'activity', locals: locals }
      format.js { respond_to_js action: 'activity', locals: locals }
    end
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
    @project_decorator.created_by = User.current.id
    respond_to do |format|
      if @project_decorator.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'overview', :controller => 'projects', project_id: @project_decorator.slug }
        format.json { render :json => @project_decorator,
                             :status => :created, :location => @project_decorator }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @project_decorator.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    #Todo add check
    @project = Project.find(params[:id])
    success = @project.destroy && Query.destroy_all(:project_id => @project.id, :is_for_all => false)
    respond_to do |format|
      flash[:notice] = t(:successful_deletion)
      format.html { redirect_to :root }
      format.js do
        if success
          flash[:notice] = t(:successful_update)
          js_redirect_to url_for(:root)
        else
          respond_to_js :action => :empty_action, :response_header => :failure, :response_content => t(:failure_update)
        end
      end
    end
  end


  def archive
    #Todo add check
    @project = Project.find(params[:id])
    success = @project.update_column(:is_archived, !@project.is_archived)
    respond_to do |format|
      format.html { redirect_to :root }
      format.js do
        if success
          flash[:notice] = t(:successful_update)
          js_redirect_to url_for(:root)
        else
          respond_to_js :action => :empty_action, :response_header => :failure, :response_content => t(:failure_update)
        end
      end
    end
  end

  #GET /projects/
  def index
    if session['project_selection_filter'].nil?
      session['project_selection_filter'] = 'all'
    end
    @projects_decorator = User.current.owned_projects(session['project_selection_filter']).decorate(context: {allow_to_star: true})
    respond_to do |format|
      format.html { render :action => 'index' }
      format.js { respond_to_js :action => 'index' }
    end
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
      format.json { render json: members}
    end
  end
  def issues_completion
    issues = Issue.joins(:status).where(project_id: @project_decorator.id).order('issues.id ASC').pluck('issues.id, issues.subject')
    respond_to do |format|
      format.json { render json: issues}
    end
  end

  private

  def project_params
    params.require(:project).permit(Project.permit_attributes)
  end

  def find_project
    id = action_name.eql?('show') ? params[:id] : params[:project_id]
    @project_decorator = Project.includes(:attachments, members: [:role,user: :avatar]).where(slug: id)[0]
    if @project_decorator
      @project_decorator = @project_decorator.decorate
      @project = @project_decorator.model
    else
      render_404
    end
  end


end
