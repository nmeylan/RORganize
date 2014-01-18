module ApplicationHelper
  #  require 'Date'
  def sidebar_content?
    content_for?(:sidebar)
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html.erb", :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def render_403
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/403.html.erb", :status => :forbidden }
      format.xml  { head :forbidden }
      format.any  { head :forbidden }
    end
  end

  def date_valid?(date, format='%Y-%m-%d')
    if date.eql?('') || date.nil?
      return true
    end
    begin
      Date.strptime(date,format)
      return true
    rescue
      return false
    end
  end
  #Here are define basic action into hash
  def find_action(action)
    basic_actions = {'update' => 'edit', 'create' => 'new'}
    if basic_actions.keys.include?(action)
      return basic_actions[action]
    else
      return action
    end
  end

  def check_permission
    unless current_user.allowed_to?(find_action(params[:action]),params[:controller],@project)
      render_403
    end
  end

  def error_messages(object)
    if object.any?
      error_explanation = ''
      errors = ''
      error_explanation += "<script type='text/javascript'>"
      errors += '<ul>'
      object.each do |error|
        errors += '<li>'+error+'</li>'
      end
      errors += '</ul>'
      error_explanation += "error_explanation(\""+errors+"\");"
      error_explanation += '</script>'
      object.clear
      return error_explanation.to_s
    end
  end
  #Return updated attributes
  def updated_attributes(object, parameter)
    #{attribute_name => [old_value, new_value],...}
    attr_updated = Hash.new{|k,v| v = []}

    attributes_names = object.attributes.keys
    #For each attributes compare differences between old object and new parameters
    attributes_names.each do |name|
      if !object[name].to_s.eql?(parameter[name].to_s) && !parameter[name].nil?
        attr_updated[name] = [object[name], parameter[name]]
      end
    end
    return attr_updated
  end

  def decimal_zero_removing(decimal)
    removed_zero = decimal.gsub(/^*[.][0]$/,'')
    return removed_zero ? removed_zero : decimal
  end

  def textile_to_html(text)
    t = RedCloth.new <<EOD
#{text}
EOD
    return t.to_html
  end
  

  def set_toolbar(id)
    javascript_tag(
      "jQuery(document).ready(function() {
        jQuery('##{id}').markItUp(mySettings);
      });")
  end

  def sortable(column, title = nil, default_action = nil)
    default_action ||= 'index'
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, {:sort => column, :direction => direction, :action => default_action}, {:class => css_class, :remote => true}
  end

  #generic journal detail insertion
  def journal_insertion(updated_attributes, journal, journalized_property)
    updated_attrs = updated_attributes
    updated_attrs.each do |attribute, old_new_value|
      old_value = old_new_value[0]
      new_value = old_new_value[1]
      JournalDetail.create(:journal_id => journal.id,
        :property => journalized_property[attribute],
        :property_key => attribute,
        :old_value => old_value,
        :value => new_value)
    end
  end

  def history_detail_render(detail)
    history_str = ''
    if detail.old_value && (detail.value.nil? || detail.value.eql?(''))
      history_str += "<li><b>#{detail.property}</b> <b>#{detail.old_value.to_s}</b> #{t(:text_deleted)}</li>"
    elsif detail.old_value && detail.value
      history_str += "<li><b>#{detail.property}</b> #{t(:text_changed)} #{t(:text_from)} <b>#{detail.old_value.to_s}</b> #{t(:text_to)} <b>#{detail.value.to_s}</b></li>"
    else
      history_str += "<li><b>#{detail.property}</b> #{t(:text_set_at)} <b>#{detail.value.to_s}</b></li>"
    end
    return history_str
  end
  #generic journal renderer
  def history_render(journals, show = true)#If come from show action
    history_str = ''
    count_journal = 0
    #    puts journals.inspect
    journals.each do |journal|
      user = (journal.user ? journal.user.name : t(:label_unknown))
      if !journal.nil? &&journal.details.any? || (!journal.notes.eql?('') &&  journal.action_type.eql?('updated'))
        history_str += "<h3>#{t(:label_updated)} #{distance_of_time_in_words(journal.created_at,Time.now)} #{t(:label_ago)}, #{t(:label_by)} #{user}</h3>"
        history_str += '<ul>'
        journal.details.each do |detail|
          history_str += history_detail_render(detail)
        end
        history_str += '</ul>'
        unless journal.notes.eql?('')
          if journal.user_id.eql?(current_user.id) && show
            history_str += link_to(t(:link_delete), delete_note_issues_path(@project.slug, journal.id),
              {:class => 'icon icon-del right', :remote => true, :method => :delete,  :confirm => t(:text_delete_item )})
            history_str += link_to(t(:link_edit), edit_note_issues_path(@project.slug, journal.id), {:id => "link_edit_note_#{journal.id}", :class => 'icon icon-edit right edit_notes'})
          end
          history_str += "<div class='box_notes' id ='note_#{journal.id}'><p>#{textile_to_html(journal.notes)}</p>"
          history_str += '</div>'
        end
        history_str += '<br/><hr /><br/>' unless journal.eql?(journals.last)
        count_journal +=1
      end
    end
    if count_journal > 0
      s = ''
      s += "<div class='separator'></div>" if show
      history_str.insert(0,"#{s}<h2>#{t(:label_history)}</h2>")
    end
    return history_str.html_safe
  end

  def add_attachments_link(name)
    content = escape_once(render :partial => 'attachments', :locals => {:attachments => Attachment.new})
    link_to name, '#', {:class => 'add_attachment_link', 'data-content' => content}
  end

  def sort_hash_by_keys(hash, order)
    h = {}
    if order.eql?('desc')
      sorted_keys = hash.keys.sort{|x,y| y <=> x}
    else
      sorted_keys = hash.keys.sort{|x,y| x <=> y}
    end
    sorted_keys.each do |sorted_key|
      h[sorted_key] = hash[sorted_key]
    end
    return h
  end
  #  def act_as_admin?
  #    return session["act_as"].eql?("Admin")
  #  end

  #For following filter: e.g: Assigned with 3 radio button (All, equal, different) and 1 combo
  def generics_filter_simple_select(name, options_for_radio, options_for_select, multiple = true, size = nil,label = nil)
    label ||= name.capitalize
    size ||= 'cbb-large'
    tr = ''
    radio_str = generics_filter_radio_button(name,options_for_radio)
    select_str = ''
    select_str += "<div class='autocomplete-combobox nosearch no-padding_left no-height'>"
    select_str += select_tag("filter[#{name}][value][]", options_for_select(options_for_select), :class => 'chzn-select '+size, :id => name+'_list', :multiple => multiple)
    select_str += '</div>'
    tr += "<tr class='#{name}'>"
    tr += "<td class='label'>#{label}</td>"
    tr += "<td class='radio'>#{radio_str}</td>"
    tr += "<td id='td-#{name}' class='value'>#{select_str}</td>"
  end
  #For filters that require data from text field: e.g subject
  def generics_filter_text_field(name,options_for_radio, label = nil)
    label ||= name.capitalize
    tr = ''
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
    tr = ''
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
    radio_str = ''
    ary.each do |v|
      if v.eql?('all')
        radio_str += "<input align='center' class='#{name}' id='#{name}_#{v}' checked='checked' name='filter[#{name}][operator]' type='radio' value='#{v}'>#{v.capitalize}"
      else
        radio_str += "<input align='center' class='#{name}' id='#{name}_#{v}' name='filter[#{name}][operator]' type='radio' value='#{v}'>#{v.capitalize}"
      end
    end
    return radio_str
  end

  def generics_filter(hash, attr)
    query_str = ''
    #attributes from db: get real attribute name to build query
    attributes = attr
    #noinspection RubyStringKeysInHashInspection,RubyStringKeysInHashInspection
    operators = {'equal' => '<=>', 'different' => '<>', 'superior' => '>=', 'inferior' => '<=', 'contains' => 'LIKE', 'not contains' => 'NOT LIKE','today' => '<=>', 'open' => '<=>', 'close' => '<=>'}
    #noinspection RubyStringKeysInHashInspection
    null_operators = {'different' => 'IS NOT', 'equal' => 'IS'}
    #Specific link between query if there different value for a same attributes: e.g status_id <> 4 AND status_id <> 3
    #but status_id = 4 OR status_id = 3
    link_between_query = {%w(equal open close) => 'OR', ['different', 'superior', 'inferior', 'contains', 'not contains'] => 'AND'}

    #operators that are not remove even if value is nil or empty
    operators_without_value = %w(open close today)
    hash.delete_if{|k,v| v['operator'].eql?('all') ||(!operators_without_value.include?(v['operator']) && (v['value'].nil? || v['value'].eql?('')))}

    date_attributes = %w(created_at updated_at due_date start_date)
    link = ''
    inc_condition_item_ary = 0 #
    inc_condition_items = 0 #
    hash.each do |k,v|
      link_between_query.each_key{|key| link = link_between_query[key] if key.include?(v['operator'])}
      if date_attributes.include?(k) #if attribute is a date, apply a specific mysql function to convert a datetime format to date format.
        inc_condition_items += 1
        if v['operator'].eql?('today') #if user use "today" radio button we use the current date.
          # Add an "AND" at the end of the string if there any other conditions for the query
          query_str += "DATE_FORMAT(#{attributes[k]},'%Y-%m-%d') #{operators[v['operator']]} '#{Date.today.to_s}' #{'AND' if inc_condition_items != hash.size} "
        else
          # Add an "AND" at the end of the string if there any other conditions for the query
          query_str += "DATE_FORMAT(#{attributes[k]},'%Y-%m-%d') #{operators[v['operator']]} '#{v['value']}' #{'AND' if inc_condition_items != hash.size} "
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
              operator = null_operators[v['operator']]
            else
              operator = operators[v['operator']]
            end
            query_str += "#{'(' if inc_condition_item_ary == 1}"
            query_str += "#{attributes[k]} #{operator} #{value} "
            query_str += "#{link if inc_condition_item_ary != v['value'].size} "
            query_str += "#{'OR '+attributes[k].to_s+' IS NULL' if inc_condition_item_ary == v['value'].size && v['operator'].eql?('different') && !value.eql?('NULL')}"
            query_str += "#{')' if inc_condition_item_ary == v['value'].size} "
            query_str += "#{'AND' if inc_condition_item_ary == v['value'].size && inc_condition_items != hash.size} "
          end
        else #if ary contains less than 1 value
          if v['value'].first.eql?('NULL')
            operator = null_operators[v['operator']]
          else
            operator = operators[v['operator']]
          end
          inc_condition_items += 1
          query_str += "(#{attributes[k]} #{operator} #{v['value'].first} "
          query_str += "#{'OR '+attributes[k].to_s+' IS NULL' if v['operator'].eql?('different') && !v['value'].first.eql?('NULL')}) "
          query_str += "#{'AND' if inc_condition_items != hash.size} "
        end
      else #if attribute has an uniq value
        inc_condition_items += 1
        query_str += "#{attributes[k]} #{operators[v['operator']]} '%#{v['value']}%' #{'AND' if inc_condition_items != hash.size} "
      end
      inc_condition_item_ary = 0
    end
    #    query_str += "#{'AND' if hash.size != 0} issues.project_id = #{project_id}"
    query_str += "#{'AND' if hash.size != 0}"
    return query_str
  end
 #Build text from a specific journal
  def generics_activities_text_builder(journal, activity_icon, is_not_in_project = true)
    text = ''
    user = (journal.user ? journal.user.name : t(:label_unknown))
    #
    if journal.action_type.eql?('updated')
      text += "<p class='icon'>"
      text += "#{image_tag(activity_icon)} #{user} #{t(:label_updated_lower_case)} "
      if journal.journalized
        text += "<b>#{journal.journalized_type} : #{journal.identifier_value}</b>"
      else
        text += "<b>#{journal.journalized_type} : unknown</b>"
      end
      if journal.project_id && is_not_in_project
        text += " #{t(:label_at)} <b>#{link_to journal.project.slug,overview_projects_path(journal.project.slug)}</b>"
      end
      text += '</p>'
    elsif journal.action_type.eql?('created')
      text += "<p class='icon'>"
      text += "#{image_tag(activity_icon)} #{user} #{t(:label_created_lower_case)} "
      if journal.journalized
        text += "<b>#{journal.journalized_type} : #{journal.identifier_value}</b>"
      else
        text += "<b>#{journal.journalized_type} : unknown</b>"
      end
      if journal.project_id && is_not_in_project
        text += " #{t(:label_at)} <b>#{link_to journal.project.slug, overview_projects_path(journal.project.slug)}</b>"
      end
      text += '</p>'
    elsif journal.action_type.eql?('deleted')
      text += "<p class='icon'>"
      text += "#{image_tag('/assets/activity_deleted.png')} #{user} #{t(:label_deleted_lower_case)} "
      text += "<b>#{journal.journalized_type} : #{journal.identifier_value}</b>"
      if journal.project_id && is_not_in_project
        text += " #{t(:label_at)} <b>#{journal.project_id}</b>"
      end
      text += '</p>'
    end
    return text
  end
  def activities_text_builder(journal, specified_project = true)
    text = ''
    if journal.journalized_type.eql?('Issue')
       text += issues_activities_text_builder(journal, specified_project)
    else
      text += generics_activities_text_builder(journal, eval(journal.journalized_type).journalized_icon.to_s, specified_project)
    end
    return text.html_safe
  end
  #Params hash content:
  #method : possible values :post, :get , :put, :delete
  #target : possible values "nil" or "self", if self url will be '#' else will be path
  #html = {}
  def link_to_with_permissions(label, path, project, params = {})
    routes = Rails.application.routes
    hash_path = routes.recognize_path(path, :method => params[:method])
    if current_user.allowed_to?(hash_path[:action],hash_path[:controller],project)
      if params[:target] && params[:target].eql?('self')
        link_to(label, '#', params)
      else
        link_to(label, path, params)
      end
    end
  end
  def link_to_with_not_owner_permissions(label, path, project, owner_id, params = {})
    routes = Rails.application.routes
    hash_path = routes.recognize_path(path, :method => params[:method])
    if current_user.allowed_to?(hash_path[:action],hash_path[:controller],project) && owner_id.eql?(current_user.id) ||
          current_user.allowed_to?("#{hash_path[:action]}_not_owner",hash_path[:controller],project)
      if params[:target] && params[:target].eql?('self')
        link_to(label, '#', params)
      else
        link_to(label, path, params)
      end
    end
  end
  
  #Build rows for all entries from a given model
  #Model : An activeRecord model
  #Params : 
  # Exclude : all attributes exclude from model
  # Or Include : all attributes include from model
  #E.g: Display all users, exclude => [:password, :id]
  def generics_list_builder(model, params = {:exclude => []})
    attributes = model.attribute_names
    exclude_attributes = params[:exclude]
    attributes.delete_if{|attribute| exclude_attributes.include?(attribute.to_sym)}
    puts attributes.inspect
  end
end
