class ProjectController < ApplicationController
  helper :application
  include ApplicationHelper
  before_filter :find_project ,:except => [:new, :create, :destroy, :archive]
  before_filter :check_permission,:except => [:create,:load_journal_activity, :filter]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller], params[:action]) }
  before_filter {|c| c.top_menu_item('projects')}
  #GET /project/:project_id
  #Project overview
  def overview
    members = Member.where(:project_id => @project.id).includes([:role, :user])
    roles = Role.find(:all)
    members_hash = Hash.new{|h,k| h[k] = []}

    roles.each{|role| members_hash[role.name] = members.select{|member| member.role_id == role.id}}
    last_requests = Issue.where(:project_id => @project).order('id desc').limit(5)
    respond_to do |format|
      format.html {render :action => 'overview', :locals => {:members => members_hash, :last_requests => last_requests}}
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
    #Structure of the hash is
    # {:date => [journal]}
    @issue_activities = Hash.new{|hash, key| hash[key] = []}
    journals =(
      session['project_activities_filter'][0].eql?('all') ?
        Journal.where(:project_id => @project.id)
      .includes([:details, :user, :journalized])
      .order('created_at DESC') :
        Journal.where(['project_id = ? AND created_at > ?',@project.id, session['project_activities_filter'][0]])
      .includes([:details, :user, :journalized])
      .order('created_at DESC')
    )
    
    @activities = Hash.new{|hash, key| hash[key] = []}
    journals.each do |journal|
      if journal.journalized_type.eql?('Issue')
        @issue_activities[journal.created_at.to_formatted_s(:db).to_date.to_s] << journal
      else
        @activities[journal.created_at.to_date.to_s] << journal
      end
    end
    @issue_activities.values.each{|ary| ary.uniq!{|act| act.journalized_id}}
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace_html 'issues_activities', :partial => 'project/issues_activities'
          page.replace_html 'others_activities', :partial => 'project/activities'
        end
      end
    end
  end

  def load_journal_activity
    @issue = Issue.find(params[:issue_id], :include => [:tracker,:version,:status,:assigned_to,:category])
    @journals = Journal.find_all_by_journalized_type_and_journalized_id(@issue.class.to_s, @issue, :include => [:details])
    @journals.select!{|journal| journal.created_at.to_formatted_s(:db).to_date.to_s == params[:activity_date]}
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace_html 'issue_history', :partial => 'project/activity_history'
        end
      end
    end
  end


  #GET /project/new
  def new
    @project = Project.new
    @project.attachments.build
    respond_to do |format|
      format.html
    end
  end

  #POST /project/new
  def create
    @project = Project.new(params[:project])
    @project.created_by = current_user.id
    respond_to do |format|
      if @project.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'index', :controller => 'projects'}
        format.json  { render :json => @project,
          :status => :created, :location => @project }
      else
        format.html  { render :action => 'new' }
        format.json  { render :json => @project.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.destroy && Query.destroy_all(:project_id => @project.id, :is_for_all => false)
        flash[:notice] = t(:successful_deletion)
        format.html {redirect_to :root}
        format.js do
          render :update do |page|
            page.redirect_to :root
          end
        end
      else
        format.js do
          render :update do |page|
            response.headers['flash-error-message'] = t(:failure_deletion)
          end
        end
      end
    end
  end



  def archive
    @project = Project.find(params[:id])
    respond_to do |format|
      if @project.update_column(:is_archived, eval(params[:is_archived]))
        flash[:notice] = t(:successful_update)
        format.html {redirect_to :root}
        format.js do
          render :update do |page|
            page.redirect_to :root
          end
        end
      else
        format.js do
          render :update do |page|
            response.headers['flash-error-message'] = t(:failure_update)
          end
        end
      end
    end
  end

  def filter
    date = Time.now.to_date
    filter_type = {
      'tm' => date.months_ago(1),
      'lsm' => date.months_ago(6),
      'ltm' => date.months_ago(3),
      'ty' => date.prev_year(),
      'all' => 'all'
    }
    #    session stock conditions and filter_code
    session['project_activities_filter'] = [filter_type[params[:type]],params[:type]]
    activity
  end
  private

end
