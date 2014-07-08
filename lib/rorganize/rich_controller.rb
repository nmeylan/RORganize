# Author: Nicolas Meylan
# Date: 21/06/2014
# Encoding: UTF-8
# File: rich_controller.rb
# This allow controller to provide more actions as : bulk_edition or filters

module Rorganize
  module RichController
    # Klazz : type of the filtered content, e.g : Issue
    #Criterias : HASH criteria, e.g : {"subject"=>{"operator"=>"contains", "value"=>"test"}}
    #Filter type : are content filtered? then value is filter (to filter content) or all (to display all result)
    #Filter lists : Array of filters, e.g ["subject"] (used for the combobox)
    #Commit : is a new filter is submit?
    # session_json : serialized dom filter in json
    # session_sql : sql filter
    #Return : An array (size 2), first index -> sql filter, second index -> HASH criteria
    def apply_filter(klazz, params, session_json, session_sql)
      criteria = params[:filter]
      filter_type = params[:type]
      filters_list = params[:filters_list]
      commit = params[:commit]
      if criteria
        filter_params = criteria.clone
        filter_params.delete_if { |_, filter| filter['operator'].eql?('all') }
      else
        filter_params = nil
      end
      filter = nil
      if filter_type.eql?('filter') && criteria && filters_list && filters_list.any?
        filter = klazz.conditions_string(criteria)
      elsif commit
        #filter SQL content
        session_sql = nil
        #filter DOM content
        session_json = nil
      end
      #When page is reloading, user don't loose his filters
      if filter_type && filter_type.eql?('filter')
        session_json = filter_params
      end
      if filter
        session_sql = filter
      elsif !session_sql
        session_sql = ''
      end
      [session_json, session_sql]
    end

    def load_controller_list
      controllers = Rails.application.routes.routes.collect { |route| route.defaults[:controller] }
      unused_controller = %w(rorganize profiles)
      controllers = controllers.uniq!.select { |controller_name| controller_name && !controller_name.match(/.*\/.*/) && !unused_controller.include?(controller_name) }
      controllers.collect do |controller|
        controller.capitalize
      end
    end

  end
end