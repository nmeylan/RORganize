# Author: Nicolas Meylan
# Date: 24.07.14
# Encoding: UTF-8
# File: activity_manager.rb
module Rorganize
  module ActivityManager
    #GET/project/:project_id/activity
    def init_activities_sessions
      @sessions[:activities] ||= {}
      @sessions[:activities][:types] ||= ['Issue']
      @sessions[:activities][:period] ||= 'THREE_DAYS'
      @sessions[:activities][:from_date] ||= Date.today
    end

    def selected_filters
      to = @sessions[:activities][:from_date]
      period = @sessions[:activities][:period]
      from = to.to_date - Journal::ACTIVITIES_PERIODS[period.to_sym]
      {types: Project::JOURNALIZABLE_ITEMS, selected_types: @sessions[:activities][:types], selected_period: period, selected_date: to, from_date: from}
    end

    def activity_filter
      if request.post? #filter submission
        types = params[:types] ? params[:types].keys : ['NIL']
        @sessions[:activities][:types] = types
        period = params[:period] ? params[:period] : 'ONE_DAY'
        @sessions[:activities][:period] = period
        date = params[:date] && !params[:date].empty? ? params[:date] : Date.today
        @sessions[:activities][:from_date] = date
      end
      activity
    end
  end

  def retrieve_activities(query)
    !@sessions[:activities][:types].include?('NIL') ? query : []
  end
end