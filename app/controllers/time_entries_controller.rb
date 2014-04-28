# Author: Nicolas
# Date: 21/09/13
# Encoding: UTF-8
# File: ${FILE_NAME}
class TimeEntriesController < ApplicationController

  def fill_overlay
    issue_id = params[:issue_id]
    date = params[:spent_on] ? params[:spent_on] : Time.now.to_date
    @time_entry = TimeEntry.find_by_issue_id_and_user_id_and_spent_on(issue_id, current_user.id, date)
    @time_entry ? edit : new
  rescue
    new
  end

  def new
    @time_entry = TimeEntry.new
    @time_entry.spent_on = params[:spent_on] ? params[:spent_on] : Time.now.to_date
    respond_to do |format|
      format.js do
        respond_to_js :locals => {:issue_id => params[:issue_id]}
      end
    end
  end

  def create
    @time_entry = TimeEntry.new(time_entry_params)
    issue = Issue.find_by_id(params[:issue_id])
    @time_entry.issue_id = issue.id
    @time_entry.project_id = issue.project_id
    @time_entry.user_id = current_user.id
    saved = @time_entry.save
    respond_to do |format|
      format.js do
        respond_to_js :action => 'entries_operations', :locals => {:success => saved}, :response_header => saved ? :success : :failure, :response_content => saved ? t(:successful_time_entry_creation) : @time_entry.errors.full_messages
      end
    end
  end

  def edit
    respond_to do |format|
      format.js do
        respond_to_js :locals => {:issue_id => params[:issue_id]}
      end
    end
  end

  def update
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.attributes = time_entry_params
    saved = @time_entry.save
    respond_to do |format|
      format.js do
        respond_to_js :action => 'entries_operations', :locals => {:success => saved}, :response_header => saved ? :success : :failure, :response_content => saved ? t(:successful_time_entry_update) : @time_entry.errors.full_messages
      end
    end
  end

  def destroy
    @time_entry = TimeEntry.find(params[:id])
    trusted = @time_entry && @time_entry.user_id.eql?(current_user.id)
    success = trusted && @time_entry.destroy
    respond_to do |format|
      format.js do
        js_redirect_to url_for(:controller => :my, :action => :my_spent_time, :id => current_user.slug, :date => params[:date])
        trusted ? (success ? flash[:notice] = t(:successful_deletion):  flash[:alert] = t(:failure_deletion)) : flash[:alert] = t(:text_time_entry_not_owner_deletion)
      end
    end
  end

  private
  def time_entry_params
    params.require(:time_entry).permit(TimeEntry.permit_attributes)
  end
end