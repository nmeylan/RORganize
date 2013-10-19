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
        render :update do |page|
          page.replace_html 'spent_time_overlay_form', :partial => 'time_entries/log_issue_spent_time_form', :locals => {:issue_id => params[:issue_id]}
        end
      end
    end
  end

  def create
    @time_entry = TimeEntry.new(params[:time_entry])
    issue = Issue.find_by_id(params[:issue_id])
    @time_entry.issue_id = issue.id
    @time_entry.project_id = issue.project_id
    @time_entry.user_id = current_user.id
    respond_to do |format|
      format.js do
        render :update do |page|
          if @time_entry.save
            page << "jQuery('#spent_time_overlay').overlay().close()";
            response.headers['flash-message'] = t(:successful_time_entry_creation)
          else
            response.headers['flash-error-message'] = @time_entry.errors.full_messages
          end
        end
      end
    end
  end

  def edit
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'spent_time_overlay_form', :partial => 'time_entries/log_issue_spent_time_form', :locals => {:issue_id => params[:issue_id]}
        end
      end
    end
  end

  def update
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.attributes = params[:time_entry]
    respond_to do |format|
      format.js do
        render :update do |page|
          if @time_entry.save
            page << "jQuery('#spent_time_overlay').overlay().close()";
            response.headers['flash-message'] = t(:successful_time_entry_update)
          else
            response.headers['flash-error-message'] = @time_entry.errors.full_messages
          end
        end
      end
    end
  end

  def destroy
    @time_entry = TimeEntry.find(params[:id])
    respond_to do |format|
      format.js do
        render :update do |page|
          if @time_entry && @time_entry.user_id.eql?(current_user.id)
            if @time_entry.destroy
              page.redirect_to url_for(:controller => :my, :action => :my_spent_time, :id => current_user.slug, :date => params[:date])
              response.headers['flash-message'] = t(:successful_deletion)
            else
              response.headers['flash-error-message'] = t(:failure_deletion)
            end
          else
            response.headers['flash-error-message'] = t(:text_time_entry_not_owner_deletion)
          end
        end
      end
    end
  end
end