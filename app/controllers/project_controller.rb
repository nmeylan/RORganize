class ProjectController < ApplicationController
  helper :application
  include ApplicationHelper
  before_filter :authenticate_user!
  before_filter :find_project ,:except => [:new, :create]
  before_filter :check_permission,:except => [:create,:load_journal_activity]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item(params[:controller], params[:action]) }
  #GET /project/:project_id
  #Project overview
  def overview
    members = Member.find_all_by_project_id(@project, :include => [:role, :user])
    roles = Role.find(:all)
    @members_hash = Hash.new{|h,k| h[k] = []}

    roles.each{|role| @members_hash[role.name] = members.select{|member| member.role_id == role.id}}
    @last_request = Issue.find(:all, :conditions => {:project_id => @project}, :order => 'id desc', :limit => 5)
    respond_to do |format|
      format.html
    end
  end

  def show
    overview
  end
  #GET/project/:project_id/activity
  def activity
    #Structure of the hash is
    # {:date => {:created => [issue, issue...], :updated => [...]}, :date => ...}
    @issues_activity = Hash.new{|hash, key| hash[key] = Hash.new{|h,k| h[k] = []}}
    issues = Issue.find_all_by_project_id(@project,
      :include => [:tracker,:author],
      :order => "created_at DESC")
    issue_ids = issues.collect{|issue| issue.id}
    journals = Journal.find_all_by_journalized_type_and_journalized_id('Issue',
      issue_ids,
      :include => [:details],
      :order => "created_at DESC")
    #for each issues
    issues.each do |issue|
      i = 0
      deleted_journal = []
      #for each journals
      journals.each do |journal|
        #If journalized item id == issue id. Means that issue were updated
        if(issue.id.eql?(journal.journalized_id))
          #Collect journal for this issue
          @issues_activity[journal.created_at.to_date.to_s]["updated"] << issue
          deleted_journal << journal
        end
        i += 1
      end
      #Remove previous issue's journals in the array
      journals -= deleted_journal
      @issues_activity[issue.created_at.to_date.to_s]["created"] << issue
    end
    
    respond_to do |format|
      format.html
    end
  end

  def load_journal_activity
    @issue = Issue.find(params[:issue_id], :include => [:tracker,:version,:status,:assigned_to,:category])
    @journals = Journal.find_all_by_journalized_type_and_journalized_id(@issue.class.to_s, @issue, :include => [:details])
    @journals.select!{|journal| journal.created_at.to_date.to_s == params[:activity_date]}
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.replace_html "issue_history", :partial => 'project/activity_history'
        end
      end
    end
  end


  #GET /project/new
  def new
    @project = Project.new
    respond_to do |format|
      format.html
    end
  end

  #POST /project/new
  def create
    @project = Project.new(params[:project])
    respond_to do |format|
      if @project.save
        flash[:notice] = t(:successful_creation)
        format.html { redirect_to :action => 'index', :controller => 'projects'}
        format.json  { render :json => @project,
          :status => :created, :location => @project }
      else
        format.html  { render :action => "new" }
        format.json  { render :json => @project.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  private

end
