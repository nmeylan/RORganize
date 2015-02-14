# Author: Nicolas Meylan
# Date: 24.07.14
# Encoding: UTF-8
# File: activity_callback.rb
module Rorganize
  module RichController
    module ActivityCallback
      #GET/project/:project_id/activity
      def init_activities_sessions
        @sessions[:activities] ||= {}
        @sessions[:activities][:types] ||= ['Issue']
        @sessions[:activities][:period] ||= 'THREE_DAYS'
        @sessions[:activities][:from_date] ||= Date.today
      end

      def load_activities(model)
        if @sessions[:activities][:types].include?('NIL')
          @activities = Activities.new([])
        else
          activities_types = @sessions[:activities][:types]
          activities_period = @sessions[:activities][:period]
          from_date = @sessions[:activities][:from_date]
          @activities = Activities.new(model.activities(activities_types, activities_period, from_date),
                                       model.comments_for(activities_types, activities_period, from_date))
        end
      end

      def selected_filters
        to = @sessions[:activities][:from_date]
        period = @sessions[:activities][:period]
        from = to.to_date - Journal::ACTIVITIES_PERIODS[period.to_sym]
        {types: Project.journalizable_items, selected_types: @sessions[:activities][:types], selected_period: period, selected_date: to, from_date: from}
      end

      def activity_filter
        if request.post? #filter submission
          @sessions[:activities] ||= {}
          types = params[:types] ? params[:types].keys : ['NIL']
          @sessions[:activities][:types] = types
          period = params[:period] ? params[:period] : 'ONE_DAY'
          @sessions[:activities][:period] = period
          date = params[:date] && !params[:date].empty? ? params[:date] : Date.today
          @sessions[:activities][:from_date] = date
        end
        activity
      end

      def activity_callback(locals, render = :activity)
        respond_to do |format|
          format.html { render render, locals: locals }
          format.js { respond_to_js action: 'activity', locals: locals }
        end
      end
    end

    def retrieve_activities(query)
      !@sessions[:activities][:types].include?('NIL') ? query : []
    end
  end
end