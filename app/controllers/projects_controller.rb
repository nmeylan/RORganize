class ProjectsController < ApplicationController
  before_filter :find_project, :except => [:index, :new, :create, :destroy, :archive, :filter, :overview, :show]
  before_filter :find_project_with_associations, :only => [:overview, :show]
  before_filter :check_permission, :except => [:create, :load_journal_activity, :filter, :activity_filter]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller], params[:action]) }
  before_filter { |c| c.top_menu_item('projects') }
  helper VersionsHelper
  #GET /project/:project_id
  #Project overview
  def overview
    respond_to do |format|
      format.html { render :action => 'overview'}
    end
  end

  def show
    overview
  end

  #GET/project/:project_id/activity
  def activity
    if session['project_activities_filter'].nil?
      session['project_activities_filter'] = [Time.now.to_date.months_ago(1), 'tm']
    end
    activities_ary = @project.activities(session['project_activities_filter'])
    @issue_activities = activities_ary[0]
    @activities = activities_ary[1]
    respond_to do |format|
      format.html
      format.js { respond_to_js :action => 'activity' }
    end
  end

  def load_journal_activity
    @journals = Journal.eager_load([:details, :user]).where(:journalized_type => 'Issue', :journalized_id => params[:item_id]).where('DATE(`journals`.`created_at`) = ?', params[:date])
    respond_to do |format|
      format.html
      format.js { respond_to_js }
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

  def activity_filter
    date = Time.now.to_date
    filter_type = {
        'tm' => date.months_ago(1),
        'lsm' => date.months_ago(6),
        'ltm' => date.months_ago(3),
        'ty' => date.prev_year,
        'all' => 'all'
    }
    #    session stock conditions and filter_code
    session['project_activities_filter'] = [filter_type[params[:type]], params[:type]]
    activity
  end

  #GET /projects/
  def index
    if session['project_selection_filter'].nil?
      session['project_selection_filter'] = 'all'
    end
    @projects = current_user.owned_projects(session['project_selection_filter']).decorate(context: {allow_to_star: false})
    respond_to do |format|
      format.html { render :action => 'index' }
      format.js { respond_to_js :action => 'index'}
    end
  end

  def filter
    unless params[:filter].nil?
      session['project_selection_filter'] = params[:filter]
    end
    index
  end

  private

  def project_params
    params.require(:project).permit(Project.permit_attributes)
  end

  def find_project_with_associations
    @project = Project.eager_load(:attachments, members: [:user, :role]).where(slug: params[:project_id])[0].decorate
  end


end
