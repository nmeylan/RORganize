# Author: Nicolas
# Date: 21/09/13
# Encoding: UTF-8
# File: ${FILE_NAME}
class TimeEntriesController < ApplicationController
  include GenericCallbacks

  def fill_overlay
    issue_id = params[:issue_id]
    date = params[:spent_on] ? params[:spent_on] : Time.now.to_date
    @time_entry = TimeEntry.find_by_issue_id_and_user_id_and_spent_on(issue_id, User.current.id, date)
    @time_entry ? edit : new
  rescue
    new
  end

  def new
    @time_entry = TimeEntry.new
    @time_entry.spent_on = params[:spent_on] ? params[:spent_on] : Date.today
    respond_to do |format|
      format.js do
        respond_to_js locals: {issue_id: params[:issue_id]}
      end
    end
  end

  def create
    issue = @project.issues.find_by!(sequence_id: params[:issue_id])
    @time_entry = issue.time_entries.build(time_entry_params)
    @time_entry.project = issue.project
    @time_entry.user = User.current
    saved = @time_entry.save
    js_callback(saved, [t(:successful_time_entry_creation), @time_entry.errors.full_messages], 'entries_operations', {success: saved})
  end

  def edit
    respond_to do |format|
      format.js do
        respond_to_js locals: {issue_id: params[:issue_id]}
      end
    end
  end

  def update
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.attributes = time_entry_params
    saved = @time_entry.save
    js_callback(saved, [t(:successful_time_entry_update), @time_entry.errors.full_messages], 'entries_operations', {success: saved})
  end

  def destroy
    @time_entry = TimeEntry.find(params[:id])
    trusted = @time_entry && @time_entry.user_id.eql?(User.current.id)
    success = trusted && @time_entry.destroy
    respond_to do |format|
      format.js do
        js_redirect_to url_for(controller: :profiles, action: :spent_time, id: User.current.slug, date: params[:date])
        destroy_message_selection(success, trusted)
      end
    end
  end

  def destroy_message_selection(success, trusted)
    if trusted
      success ? flash[:notice] = t(:successful_deletion) : flash[:alert] = t(:failure_deletion)
    else
      flash[:alert] = t(:text_time_entry_not_owner_deletion)
    end
  end

  private
  def time_entry_params
    params.require(:time_entry).permit(TimeEntry.permit_attributes)
  end
end