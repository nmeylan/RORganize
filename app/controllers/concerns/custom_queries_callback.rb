module CustomQueriesCallback

  def gon_filter_initialize
    gon.DOM_filter = view_context.generics_form_to_json
    gon.DOM_persisted_filter = @sessions[@project.slug][:json_filter].to_json
    @sessions[@project.slug][:sql_filter]
  end

  def apply_custom_query
    @query = Query.find_by_slug(params[:query_id])
    if @query
      @sessions[@project.slug] ||= {}
      @sessions[@project.slug][:sql_filter] = @query.stringify_query
      @sessions[@project.slug][:json_filter] = JSON.parse(@query.stringify_params.gsub('=>', ':'))
    end
    index
  end

  def filter(klazz)
    @sessions[@project.slug] ||= {}
    apply_filter(klazz, params, @sessions[@project.slug])
  end

  def find_custom_queries(type)
    @custom_queries_decorator = Query.available_for(User.current, @project.id, type).decorate
  end

  # Klazz : type of the filtered content, e.g : Issue
  #Criteria : HASH criteria, e.g : {"subject"=>{"operator"=>"contains", "value"=>"test"}}
  #Filter type : are content filtered? then value is filter (to filter content) or all (to display all result)
  #Filter lists : Array of filters, e.g ["subject"] (used for the combobox)
  #Commit : is a new filter is submit?
  # session_json : serialized dom filter in json
  # session_sql : sql filter
  #Return : An array (size 2), first index -> sql filter, second index -> HASH criteria
  def apply_filter(klazz, params, sessions)
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
      sessions[:sql_filter] = nil
      #filter DOM content
      sessions[:json_filter] = nil
    end
    #When page is reloading, user don't loose his filters
    if filter_type && filter_type.eql?('filter')
      sessions[:json_filter] = filter_params
    end
    if filter
      sessions[:sql_filter] = filter
    elsif !sessions[:sql_filter]
      sessions[:sql_filter] = ''
    end
  end

end