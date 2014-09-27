# Author: Nicolas Meylan
# Date: 10 oct. 2012
# Encoding: UTF-8
# File: profiles_controller.rb

require 'shared/activities'
class ProfilesController < ApplicationController
  include Rorganize::RichController
  before_filter :authenticate_user!
  before_filter :find_user
  before_filter :set_pagination, only: [:custom_queries]
  helper_method :sort_column, :sort_direction
  helper ProjectsHelper
  helper IssuesHelper
  helper QueriesHelper
  helper UsersHelper
  include Rorganize::Managers::ActivityManager

  def show
    @user_decorator = User.eager_load([members: [:role, :project, assigned_issues: :status]]).find_by_slug(User.current.slug).decorate
    init_activities_sessions
    activities_data = selected_filters
    if @sessions[:activities][:types].include?('NIL')
      @activities = Activities.new([])
    else
      activities_types = @sessions[:activities][:types]
      activities_period = @sessions[:activities][:period]
      from_date = @sessions[:activities][:from_date]
      @activities = Activities.new(@user.activities(activities_types, activities_period, from_date), @user.comments(activities_types, activities_period, from_date))
    end
    respond_to do |format|
      format.html { render :action => 'show', locals: activities_data }
      format.js { respond_to_js action: 'activity', locals: activities_data }
    end
  end

  def activity
    show
  end

  def change_password
    if request.post?
      if user_params[:password].eql?(user_params[:retype_password]) && @user.update_attributes(password: user_params[:password])
        respond_to do |format|
          flash[:notice] = t(:successful_creation)
          format.html { redirect_to :action => 'show', :id => @user.slug }
        end
      else
        @user.errors.add(:passwords, ': do not match')
        respond_to do |format|
          format.html
        end
      end
    else
      respond_to do |format|
        format.html {}
      end
    end
  end

  def custom_queries
    @queries_decorator = Query.created_by(@user).eager_load(:user).paginated(@sessions[:current_page], @sessions[:per_page], order('queries.name')).decorate(context: {queries_url: custom_queries_profile_path, action_name: 'custom_queries'})
    respond_to do |format|
      format.html {}
      format.js { respond_to_js }
    end
  end

  def projects
    @projects_decorator = @user.owned_projects(nil).decorate(context: {allow_to_star: true})
    respond_to do |format|
      format.html { render :action => 'projects' }
    end
  end

  def star_project
    members = @user.members
    member = members.select { |member| member.project.slug.eql?(params[:project_id]) }.first
    project = Project.find_by_slug(params[:project_id])
    if member.nil? && project.is_public
      non_member_role = Role.find_by_name('Non member')
      member = Member.create({project_id: project.id, user_id: User.current.id, role_id: non_member_role.id})
    end
    member.is_project_starred = !member.is_project_starred
    member.save
    message = "#{t(:text_project)} #{member.project.name} #{member.is_project_starred ? t(:successful_starred) : t(:successful_unstarred)}"
    respond_to do |format|
      format.js { respond_to_js :response_header => :success, :response_content => message, :locals => {id: params[:project_id], is_starred: member.is_project_starred} }
    end
  end

  def save_project_position
    members = @user.members.includes(:project)
    project_ids = params[:ids]
    member_project_slug = members.map { |member| member.project.slug }
    diff = project_ids - member_project_slug
    if diff.any?
      non_member_projects = Project.where(slug: diff)
      non_member_role = Role.find_by_name('Non member')
      non_member_projects.each do |project|
        members << Member.create({project_id: project.id, user_id: User.current.id, role_id: non_member_role.id}) if project.is_public
      end
    end
    members.each do |member|
      member.project_position = project_ids.index(member.project.slug)
      member.save
    end
    respond_to do |format|
      format.js { respond_to_js :action => 'do_nothing', :response_header => :success, :response_content => t(:successful_update) }
    end
  end

  def spent_time
    if params[:date]
      @date = params[:date].to_date
    else
      @date = Date.today
    end
    time_entries = @user.time_entries_for_month(@date.year, @date.month)
    @time_entries = Hash.new { |h, k| h[k] = [] }
    time_entries.each do |time_entry|
      @time_entries[time_entry.spent_on] << time_entry
    end
    respond_to do |format|
      format.html
      format.js { respond_to_js }
    end
  end

  #OTHER METHODS
  def act_as
    session['act_as'].eql?('User') ? session['act_as'] = 'Admin' : session['act_as'] = 'User'
    @user.act_as_admin(session['act_as'])
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def notification_preferences
    @keys = Preference.notification_keys

    if request.post?
      Preference.delete_all(key: @keys.values, user_id: @user.id)
      if params[:preferences]
        params[:preferences].values.each do |preference_key|
          @user.preferences << Preference.new(key: preference_key.to_i, boolean_value: true)
        end
      end
      @user.save
      respond_to do |format|
        flash[:notice] = t(:successful_preferences)
        format.html { redirect_to action: 'notification_preferences' }
      end
    end
    @preferences = @user.preferences.where(key: @keys.values)

  end

  private
  def find_user
    @user = User.find(User.current.id)
    render_404 if @user.nil?
  end

  def user_params
    params.require(:user).permit(User.permit_attributes)
  end


end
