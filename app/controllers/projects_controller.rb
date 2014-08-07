require 'shared/activities'
class ProjectsController < ApplicationController
  before_filter :find_project, :except => [:index, :new, :create, :destroy, :archive, :filter, :overview, :show]
  before_filter :find_project_with_associations, :only => [:overview, :show]
  before_filter :check_permission, :except => [:create, :filter, :activity_filter, :members]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller], params[:action]) }
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
      @activities = Activities.new(@project.activities(activities_types, activities_period, from_date),@project.comments(activities_types, activities_period, from_date))
    end
    respond_to do |format|
      format.html { render action: 'activity', locals: locals }
      format.js { respond_to_js action: 'activity', locals: locals }
    end
  end


  #GET /project/new
  def new
    @project = Project.new.decorate
    @project.attachments.build
    respond_to do |format|
      format.html
    end
  end

  #POST /project/new
  def create
    @project = Project.new(project_params).decorate
    @project.created_by = current_user.id
    respond_to do |format|
      if @project.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'index', :controller => 'projects' }
        format.json { render :json => @project,
                             :status => :created, :location => @project }
      else
        format.html { render :action => 'new' }
        format.json { render :json => @project.errors,
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
    @projects = current_user.owned_projects(session['project_selection_filter']).decorate(context: {allow_to_star: false})
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
    members = User.joins(:members).where('members.project_id' => @project.id).pluck('users.slug')
    respond_to do |format|
      format.json { render json: members}
    end
  end

  private

  def project_params
    params.require(:project).permit(Project.permit_attributes)
  end

  def find_project_with_associations
    id = params[:project_id] ? params[:project_id] : params[:id]
    @project = Project.eager_load(:attachments, members: [:user, :role]).where(slug: id)[0].decorate
  end


end
