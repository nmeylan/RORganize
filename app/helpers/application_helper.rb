module ApplicationHelper
  #  require 'Date'
  def sidebar_content?
    content_for?(:sidebar)
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html.erb", :status => :not_found }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

  def render_403
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/403.html.erb", :status => :forbidden }
      format.xml { head :forbidden }
      format.any { head :forbidden }
    end
  end

  def date_valid?(date, format='%Y-%m-%d')
    if date.eql?('') || date.nil?
      return true
    end
    begin
      Date.strptime(date, format)
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
    unless current_user.allowed_to?(find_action(params[:action]), params[:controller], @project)
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

  def decimal_zero_removing(decimal)
    removed_zero = decimal.gsub(/^*[.][0]$/, '')
    return removed_zero ? removed_zero : decimal
  end

  def textile_to_html(text)
    t = RedCloth.new <<EOD
#{text}
EOD
    t.to_html
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

  def mega_glyph(body, *names)
    content_tag(:span, nil, :class => names.map { |name| "octicon-#{name.to_s.gsub('_', '-')}" }.push('mega-octicon')) + body #TODO find a better way
  end

  def glyph(body, *names)
    content_tag(:span, nil, :class => names.map { |name| "octicon-#{name.to_s.gsub('_', '-')}" }.push('octicon')) + body #TODO find a better way
  end

  def conditional_glyph(body, bool, *names)
    if bool
      glyph(body, *names)
    else
      body
    end
  end

  def history_detail_render(detail)
    if detail.old_value && (detail.value.nil? || detail.value.eql?(''))
      content_tag :li do
        safe_concat content_tag :b, "#{detail.property} #{detail.old_value.to_s} "
        safe_concat "#{t(:text_deleted)}"
      end
    elsif detail.old_value && detail.value
      content_tag :li do
        safe_concat content_tag :b, "#{detail.property} #{t(:text_changed)} "
        safe_concat "#{t(:text_from)} "
        safe_concat content_tag :b, "#{detail.old_value.to_s} "
        safe_concat "#{t(:text_to)} "
        safe_concat content_tag :b, "#{detail.value.to_s}"
      end
    else
      content_tag :li do
        safe_concat content_tag :b, "#{detail.property} "
        safe_concat "#{t(:text_set_at)} "
        safe_concat content_tag :b, "#{detail.value.to_s}"
      end
    end
  end

  #generic journal renderer
  def history_render(journals, show = true) #If come from show action
    content_tag :div, class: 'history_blocks' do
      safe_concat content_tag :div, nil, class: 'separator'
      safe_concat content_tag :h2, t(:label_history)
      journals.to_a.compact.collect do |journal|
        if !journal.nil? && journal.details.any? || (!journal.notes.eql?('') && journal.action_type.eql?('updated'))
          safe_concat journal_render(journal, show).html_safe
        end
      end.join.html_safe
    end
  end

  def journal_render(journal, show)
    user = (journal.user ? journal.user.name : t(:label_unknown))
    content_tag :div, class: 'history_block' do
      safe_concat content_tag :h3, "#{t(:label_updated)} #{distance_of_time_in_words(journal.created_at, Time.now)} #{t(:label_ago)}, #{t(:label_by)} #{user}"
      safe_concat content_tag(:ul, (journal.details.collect { |detail| history_detail_render(detail) }).join.html_safe)
      unless journal.notes.eql?('')
        if journal.user_id.eql?(current_user.id) && show
          safe_concat link_to(glyph(t(:link_delete), 'trashcan'), delete_note_issues_path(@project.slug, journal.id), {:class => 'right', :remote => true, :method => :delete, :confirm => t(:text_delete_item)})
          safe_concat link_to(glyph(t(:link_edit), 'pencil'), edit_note_issues_path(@project.slug, journal.id), {:id => "link_edit_note_#{journal.id}", :class => 'right edit_notes'})
        end
        safe_concat content_tag :div, (textile_to_html(journal.notes).html_safe), {class: 'box_notes'}
      end
    end
  end

  def add_attachments_link(name)
    content = escape_once(render :partial => 'attachments', :locals => {:attachments => Attachment.new})
    link_to name, '#', {:class => 'add_attachment_link', 'data-content' => content}
  end

  def sort_hash_by_keys(hash, order)
    h = {}
    if order.eql?('desc')
      sorted_keys = hash.keys.sort { |x, y| y <=> x }
    else
      sorted_keys = hash.keys.sort { |x, y| x <=> y }
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
  def generics_filter_simple_select(name, options_for_radio, options_for_select, multiple = true, size = nil, label = nil)
    label ||= name.capitalize
    size ||= 'cbb-large'
    tr = ''
    radio_str = generics_filter_radio_button(name, options_for_radio)
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
  def generics_filter_text_field(name, options_for_radio, label = nil)
    label ||= name.capitalize
    tr = ''
    radio_str = generics_filter_radio_button(name, options_for_radio)
    field_str = text_field_tag("filter[#{name}][value]", '', {:size => 80})
    tr += "<tr class='#{name}'>"
    tr += "<td class='label'>#{label}</td>"
    tr += "<td class='radio'>#{radio_str}</td>"
    tr += "<td id='td-#{name}' class='value'>#{field_str}</td>"
  end

#For filters that require data from date field: e.g created_at
  def generics_filter_date_field(name, options_for_radio, label = nil)
    label ||= name.capitalize
    tr = ''
    radio_str = generics_filter_radio_button(name, options_for_radio)
    field_str = date_field_tag("filter[#{name}][value]", '', {:size => 6, :id => 'calendar_'+name, :class => 'calendar'})
    tr += "<tr class='#{name}'>"
    tr += "<td class='label'>#{label}</td>"
    tr += "<td class='radio'>#{radio_str}</td>"
    tr += "<td id='td-#{name}' class='value'>#{field_str}</td>"
  end

#Filters' operator
  def generics_filter_radio_button(name, ary)
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

#Build text from a specific journal
  def generics_activities_text_builder(journal, activity_icon, is_not_in_project = true)
    user = (journal.user ? journal.user.name : t(:label_unknown))
    #
    content_tag :p do
      if journal.action_type.eql?('updated') || journal.action_type.eql?('created')
        safe_concat content_tag :span, nil, {class: 'octicon octicon-pencil'} if journal.action_type.eql?('updated')
        safe_concat content_tag :span, nil, {class: 'octicon octicon-diff-added'} if journal.action_type.eql?('created')
        safe_concat "#{user} #{t(:label_updated_lower_case)} "
        if journal.journalized
          safe_concat content_tag :b, "#{journal.journalized_type} : #{journal.identifier_value}"
        else
          safe_concat content_tag :b, "#{journal.journalized_type} : unknown"
        end
        if journal.project_id && is_not_in_project
          safe_concat "#{t(:label_at)} "
          safe_concat content_tag :b, link_to(journal.project.slug, overview_projects_path(journal.project.slug))
        end
      elsif journal.action_type.eql?('deleted')
        safe_concat content_tag :span, nil, {class: 'octicon octicon-trashcan'}
        safe_concat "#{user} #{t(:label_deleted_lower_case)} "
        safe_concat content_tag :b, "#{journal.journalized_type} : #{journal.identifier_value}"
        if journal.project_id && is_not_in_project
          safe_concat "#{t(:label_at)} "
          safe_concat content_tag :b, "#{journal.project_id}"
        end
      end
    end
  end

  def activities_text_builder(journal, specified_project = true)
    if journal.journalized_type.eql?('Issue')
      issues_activities_text_builder(journal, specified_project).html_safe
    else
      generics_activities_text_builder(journal, '', specified_project).html_safe
    end
  end

#Params hash content:
#method : possible values :post, :get , :put, :delete
#target : possible values "nil" or "self", if self url will be '#' else will be path
#html = {}
  def link_to_with_permissions(label, path, project, params = {})
    routes = Rails.application.routes
    hash_path = routes.recognize_path(path, :method => params[:method])
    unless params[:confirm].nil?
      params[:data] ||= {}
      params[:data][:confirm] = params[:confirm].clone
      params[:confirm] = nil
    end
    if current_user.allowed_to?(hash_path[:action], hash_path[:controller], project)
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
    unless params[:confirm].nil?
      params[:data] ||= {}
      params[:data][:confirm] = params[:confirm]
      params[:confirm] = nil
    end
    if current_user.allowed_to?(hash_path[:action], hash_path[:controller], project) && owner_id.eql?(current_user.id) ||
        current_user.allowed_to?("#{hash_path[:action]}_not_owner", hash_path[:controller], project)
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
    attributes.delete_if { |attribute| exclude_attributes.include?(attribute.to_sym) }
    puts attributes.inspect
  end


end
