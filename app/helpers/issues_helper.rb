module IssuesHelper
  #Insert updated attributes in journal detail
  def issues_journal_insertion(updated_attrs, journal, journalized_property, foreign_key_value = {})
    #Remove attributes that won't be considarate in journal update
    #    updated_attrs = updated_attributes.delete_if{|attr, val| unused_attributes.include?(attr)}
    updated_attrs.each do |attribute, old_new_value|
      if foreign_key_value[attribute]
        if foreign_key_value[attribute].eql?(IssuesStatus)
          old_value = foreign_key_value[attribute].find(old_new_value[0]).enumeration.name
          new_value = foreign_key_value[attribute].find(old_new_value[1]).enumeration.name
        else
          old_value = old_new_value[0] && !foreign_key_value[attribute].nil? ? foreign_key_value[attribute].select(:name).where(:id => old_new_value[0]).first.name : nil
          new_value = old_new_value[1] && !old_new_value[1].eql?("") ? foreign_key_value[attribute].select(:name).where(:id => old_new_value[1]).first.name : ''
        end
      else
        old_value = old_new_value[0]
        new_value = old_new_value[1]
      end
      JournalDetail.create(:journal_id => journal.id,
        :property => journalized_property[attribute],
        :property_key => attribute,
        :old_value => old_value,
        :value => new_value)
    end
  end
  #For following filter: e.g: Assigned with 3 radio button (All, equal, different) and 1 combo
  def generics_filter_simple_select(name, options_for_radio, options_for_select, multiple = true, size = nil,label = nil)
    label ||= name.capitalize
    size ||= "cbb-large"
    tr = ""
    radio_str = generics_filter_radio_button(name,options_for_radio)
    select_str = ""
    select_str += "<div class='autocomplete-combobox nosearch no-padding_left no-height'>"
    select_str += select_tag("filter[#{name}][value][]",options_for_select(options_for_select), :class => 'chzn-select '+size, :id => name+'_list', :multiple => multiple)
    select_str += "</div>"
    tr += "<tr class='#{name}'>"
    tr += "<td class='label'>#{label}</td>"
    tr += "<td class='radio'>#{radio_str}</td>"
    tr += "<td id='td-#{name}' class='value'>#{select_str}</td>"
  end
  #For filters that require data from text field: e.g subject
  def generics_filter_text_field(name,options_for_radio, label = nil)
    label ||= name.capitalize
    tr = ""
    radio_str = generics_filter_radio_button(name,options_for_radio)
    field_str = text_field_tag("filter[#{name}][value]",'',{:size => 80})
    tr += "<tr class='#{name}'>"
    tr += "<td class='label'>#{label}</td>"
    tr += "<td class='radio'>#{radio_str}</td>"
    tr += "<td id='td-#{name}' class='value'>#{field_str}</td>"
  end
  #For filters that require data from date field: e.g created_at
  def generics_filter_date_field(name,options_for_radio, label = nil)
    label ||= name.capitalize
    tr = ""
    radio_str = generics_filter_radio_button(name,options_for_radio)
    field_str = text_field_tag("filter[#{name}][value]",'',{:size => 6, :id => 'calendar_'+name, :class => 'calendar'})
    tr += "<tr class='#{name}'>"
    tr += "<td class='label'>#{label}</td>"
    tr += "<td class='radio'>#{radio_str}</td>"
    tr += "<td id='td-#{name}' class='value'>#{field_str}</td>"
    # tr += javascript_tag("jQuery('#calendar_#{name}').datepicker({dateFormat: 'yy-mm-dd'});")
  end
  #Filters' operator
  def generics_filter_radio_button(name,ary)
    radio_str = ""
    ary.each do |v|
      if v.eql?('all')
        radio_str += "<input align='center' class='#{name}' id='#{name}_#{v}' checked='checked' name='filter[#{name}][operator]' type='radio' value='#{v}'>#{v.capitalize}"
      else
        radio_str += "<input align='center' class='#{name}' id='#{name}_#{v}' name='filter[#{name}][operator]' type='radio' value='#{v}'>#{v.capitalize}"
      end
    end
    return radio_str
  end

  def generics_form_to_json
    form_hash = {}
    form_hash['assigned_to'] = generics_filter_simple_select("assigned_to",@hash_for_radio["assigned"],@hash_for_select["assigned"],true,nil,"Assigned to")
    form_hash['author'] = generics_filter_simple_select("author",@hash_for_radio["author"],@hash_for_select["author"], "Author")
    form_hash['category'] = generics_filter_simple_select("category",@hash_for_radio["category"],@hash_for_select["category"])
    form_hash['created_at'] = generics_filter_date_field("created_at",@hash_for_radio["created"])
    form_hash['done'] = generics_filter_simple_select("done",@hash_for_radio["done"],@hash_for_select["done"],false,"cbb-small")
    form_hash['due_date'] = generics_filter_date_field("due_date",@hash_for_radio["due_date"],"Due date")
    form_hash['status'] = generics_filter_simple_select("status",@hash_for_radio["status"],@hash_for_select["status"], "Status")
    form_hash['subject'] = generics_filter_text_field("subject",@hash_for_radio["subject"],"Subject")
    form_hash['tracker'] = generics_filter_simple_select("tracker",@hash_for_radio["tracker"],@hash_for_select["tracker"], "Tracker")
    form_hash['version'] = generics_filter_simple_select("version",@hash_for_radio["version"],@hash_for_select["version"], "Version")
    form_hash['updated_at'] = generics_filter_date_field("updated_at",@hash_for_radio["updated"],"Updated")
    form_hash.each{|k,v| v.gsub(/"/,"'").gsub(/\n/,"")}
    return form_hash.to_json
  end

  def issues_filter(hash, project_id)
    query_str = ""
    operators = {'equal' => '<=>', 'different' => '<>', 'superior' => '>=', 'inferior' => '<=', 'contains' => 'LIKE', 'not contains' => 'NOT LIKE','today' => '<=>', 'open' => '<=>', 'close' => '<=>'}
    null_operators = {'different' => "IS NOT", 'equal' => "IS"}
    #Specific link between query if there different velu for a same attributes: e.g status_id <> 4 AND status_id <> 3
    #but status_id = 4 OR status_id = 3
    link_between_query = {['equal','open','close'] => 'OR', ['different', 'superior', 'inferior', 'contains', 'not contains'] => 'AND'}
    #attributes from db: get real attribute name to build query
    attributes = {'assigned_to' => 'assigned_to_id',
      'author' => 'author_id',
      'category' => 'category_id',
      'created_at' => 'created_at',
      'done' => 'done',
      'due_date' => 'due_date',
      'status' => 'status_id',
      'subject' => 'subject',
      'tracker' => 'tracker_id',
      'version' => 'version_id',
      'updated_at' => 'updated_at'
    }
    #operators that are not remove even if value is nil or empty
    operators_without_value = ['open','close', 'today']
    hash.delete_if{|k,v| v["operator"].eql?('all') ||(!operators_without_value.include?(v["operator"]) && (v["value"].nil? || v["value"].eql?('')))}
    hash.each do |k,v|
      if v["operator"].eql?("open")
        v["value"] = IssuesStatus.find_all_by_is_closed(0).collect{|status| status.id}
      elsif v["operator"].eql?("close")
        v["value"] = IssuesStatus.find_all_by_is_closed(1).collect{|status| status.id}
      end
    end
    date_attributes = ['created_at','updated_at','due_date']
    link = ""
    inc_condition_item_ary = 0 #
    inc_condition_items = 0 #
    hash.each do |k,v|
      link_between_query.each_key{|key| link = link_between_query[key] if key.include?(v['operator'])}
      if date_attributes.include?(k) #if attribute is a date, apply a specific mysql function to convert a datetime format to date format.
        inc_condition_items += 1
        if v["operator"].eql?('today') #if user use "today" radio button we use the current date.
          # Add an "AND" at the end of the string if there any other conditions for the query
          query_str += "DATE_FORMAT(#{attributes[k]},'%Y-%m-%d') #{operators[v["operator"]]} '#{Date.today.to_s}' #{'AND' if inc_condition_items != hash.size} "
        else
          # Add an "AND" at the end of the string if there any other conditions for the query
          query_str += "DATE_FORMAT(#{attributes[k]},'%Y-%m-%d') #{operators[v["operator"]]} '#{v['value']}' #{'AND' if inc_condition_items != hash.size} "
        end
      elsif v['value'].class.eql?(Array) #if values are contains in an ary
        if v['value'].size > 1 #if ary contains more than 1 value
          inc_condition_items += 1
          v['value'].each do |value|
            inc_condition_item_ary += 1
            #If it's  the first item from the ary we add (.
            #If it's the last item from the ary we don't put a link and we add ).
            #If we use "different" operator we add an OR condition to get items which value is NULL.
            #Certains operators needs specific link.
            if value.eql?('NULL')
              operator = null_operators[v["operator"]]
            else
              operator = operators[v["operator"]]
            end
            query_str += "#{'(' if inc_condition_item_ary == 1}"
            query_str += "#{attributes[k]} #{operator} #{value} "
            query_str += "#{link if inc_condition_item_ary != v['value'].size} "
            query_str += "#{'OR '+attributes[k].to_s+' IS NULL' if inc_condition_item_ary == v['value'].size && v["operator"].eql?('different') && !value.eql?('NULL')}"
            query_str += "#{')' if inc_condition_item_ary == v['value'].size} "
            query_str += "#{'AND' if inc_condition_item_ary == v['value'].size && inc_condition_items != hash.size} "
          end
        else #if ary contains less than 1 value
          if v['value'].first.eql?('NULL')
            operator = null_operators[v["operator"]]
          else
            operator = operators[v["operator"]]
          end
          inc_condition_items += 1
          query_str += "(#{attributes[k]} #{operator} #{v['value'].first} "
          query_str += "#{'OR '+attributes[k].to_s+' IS NULL' if v["operator"].eql?('different') && !v['value'].first.eql?('NULL')}) "
          query_str += "#{'AND' if inc_condition_items != hash.size} "
        end
      else #if attribute has an uniq value
        inc_condition_items += 1
        query_str += "#{attributes[k]} #{operators[v["operator"]]} '%#{v['value']}%' #{'AND' if inc_condition_items != hash.size} "
      end
      inc_condition_item_ary = 0
    end
    #    query_str += "#{'AND' if hash.size != 0} issues.project_id = #{project_id}"
    query_str += "#{'AND' if hash.size != 0}"
    return query_str
  end

end
