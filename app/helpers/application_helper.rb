module ApplicationHelper
  def sidebar_content?
    content_for?(:sidebar)
  end

  def clear_both
    content_tag :div, nil, {class: 'clear-both'}
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

  #Define pagination for the given collection : session is the current selected per_page item, path is the path of the controller
  def paginate(collection, session, path)
    safe_concat will_paginate(collection, :renderer => 'RemoteLinkRenderer')
    content_tag :div, class: 'autocomplete-combobox nosearch per_page', &Proc.new {
      safe_concat content_tag :label, t(:label_per_page), {for: 'per_page'}
      safe_concat select_tag 'per_page', options_for_select([%w(25 25), %w(50 50), %w(100 100)], session), :class => 'chzn-select cbb-small', :id => 'per_page', :'data-link' => "#{path}"
    }
  end

  #label : what is filtered (e.g : issues, documents)
  #filtered_attributes : which attributes will be filtered (e.g : Document.filtered_attributes)
  #submission_path : where the form must be send
  #options are :
  def filter_tag(label, filtered_attributes, submission_path, can_save = false, save_button_options = {})
    content_tag :fieldset, id: "#{label}_filter" do
      safe_concat content_tag :legend, link_to(glyph(t(:link_filter), 'chevron-right'), '#', {:class => 'icon-collapsed toggle', :id => "#{label}"})
      safe_concat content_tag :div, class: 'content', &Proc.new {
        safe_concat form_tag submission_path, {:method => :get, :class => 'filter_form', :id => 'filter_form', :remote => true}, &Proc.new {
          safe_concat radio_button_tag('type', 'all', true, {:align => 'center'})
          safe_concat label_tag('type_all', t(:label_all))
          safe_concat radio_button_tag 'type', 'filter', false
          safe_concat label_tag 'type_filter', t(:link_filter)
          safe_concat content_tag :div, class: 'autocomplete-combobox nosearch no-padding_left no-height', &Proc.new {
            select_tag 'filters_list', options_for_select(filtered_attributes), :class => 'chzn-select cbb-verylarge', :id => 'filters_list', :multiple => true
          }
          safe_concat content_tag :table, nil, id: 'filter_content'
          safe_concat submit_tag t(:button_apply), {:style => 'margin-left:0px'}
          if can_save
            safe_concat content_tag :span, save_filter_button_tag(save_button_options[:filter_content],save_button_options[:user], save_button_options[:project]), {id:'save_query_button'}
          end
        }
      }
    end
  end

  def save_filter_button_tag(filter_content, user, project)
    if !filter_content.eql?('') && user.allowed_to?('new', 'Queries', project) && params[:query_id].nil?
      link_to t(:button_save), new_project_query_queries_path(project.slug, 'Issue'), {:remote => true}
    elsif !filter_content.eql?('') && user.allowed_to?('new', 'Queries', project) && !params[:query_id].nil?
      link_to t(:button_save), edit_query_filter_queries_path(params[:query_id]), {:id => 'filter_edit_save'}
    end
  end

  def box_header_tag(title)
    content_tag :div, content_tag(:h2, title), class: 'header'
  end
  def toolbox_tag(toolbox)
    form_tag toolbox.path, :remote => true, :id => 'toolbox_form', &Proc.new {
      safe_concat(toolbox.menu.values.collect do |menu_item|
        content_tag :li do
          safe_concat link_to glyph(menu_item.caption, menu_item.glyph_name), '#', {:id => menu_item.name}
          safe_concat content_tag :ul, class: "submenu #{menu_item.attribute_name}", &Proc.new {
            if menu_item.all && menu_item.all.any?
              safe_concat hidden_field_tag "value[#{menu_item.attribute_name}]"
              safe_concat(menu_item.all.collect do |element|
                content_tag :li do
                  caption = element.respond_to?(:caption) ? element.caption : element.to_s
                  id = element.respond_to?(:id) ? element.id : element
                  safe_concat link_to(conditional_glyph(caption , menu_item.currents.include?(element), 'check'), '#', {:'data-id' => id})
                end
              end.join.html_safe)
              if menu_item.none_allowed
                safe_concat content_tag :li, link_to(conditional_glyph('None', menu_item.currents.include?(nil), 'check'), '#', {:'data-id' => -1})
              end
            end
          }
        end
      end.join.html_safe)
      safe_concat(toolbox.extra_actions.collect do |action|
        content_tag :li, action
      end.join.html_safe)
      safe_concat(toolbox.collection_ids.collect do |id|
        hidden_field_tag 'ids[]', id
      end.join.html_safe)
    }
  end

  #Here are define basic action into hash
  def find_action(action)
    basic_actions = {'update' => 'edit', 'create' => 'new'}
    if basic_actions.keys.include?(action)
      basic_actions[action]
    else
      action
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
    removed_zero ? removed_zero : decimal
  end

  def textile_to_html(text)
    t = RedCloth.new <<EOD
#{text}
EOD
    t.to_html.html_safe
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
    icon = column == sort_column ? (sort_direction == 'asc' ? 'triangle-up' : 'triangle-down') : ''
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to glyph(title, icon), {:sort => column, :direction => direction, :action => default_action}, {:remote => true}
  end

  def mega_glyph(body, *names)
    content_tag(:span, nil, :class => names.map { |name| "octicon-#{name.to_s.gsub('_', '-')}" }.push('mega-octicon')) + body #TODO find a better way
  end

  def medium_glyph(body, *names)
    content_tag(:span, nil, :class => names.map { |name| "octicon-#{name.to_s.gsub('_', '-')}" }.push('medium-octicon')) + body #TODO find a better way
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

  def add_attachments_link(name, object, type)
    content = escape_once(render :partial => 'shared/attachments', locals: {attachments: Attachment.new, object: object, type: type})
    link_to name, '#', {:class => 'add_attachment_link', 'data-content' => content}
  end


  #Filter type : (simple_select date text)
  # Field label
  # Field name
  # Options for radio button selection
  # Filter arguments (depending on type of filter)
  def generic_filter(filter_type, label, name, options_for_radio, *args)
    types = %w(:simple_select :date :text)
    label ||= name.capitalize
    filter = case filter_type
               when :simple_select then
                 generics_filter_simple_select(name, *args)
               when :date then
                 generics_filter_date_field(name, *args)
               when :text then
                 generics_filter_text_field(name, *args)
               else
                 raise Exception, "Filter with type : :#{filter_type}, doesn't exist! Allowed types are : #{types.join(', ')}"
             end
    content_tag :tr, class: name do
      safe_concat content_tag :td, label, class: 'label'
      safe_concat content_tag :td, generics_filter_radio_button(name, options_for_radio).html_safe, class: 'radio'
      safe_concat content_tag :td, filter, id: "td-#{name}", class: 'value'
    end
  end


#For following filter: e.g: Assigned with 3 radio button (All, equal, different) and 1 combo
  def generics_filter_simple_select(name, options_for_select, multiple = true, size = nil)
    size ||= 'cbb-large'
    content_tag :div, class: 'autocomplete-combobox nosearch no-padding_left no-height' do
      select_tag("filter[#{name}][value][]", options_for_select(options_for_select), :class => 'chzn-select '+size, :id => name+'_list', :multiple => multiple)
    end
  end

#For filters that require data from text field: e.g subject
  def generics_filter_text_field(name)
    text_field_tag("filter[#{name}][value]", '', {:size => 80})
  end

#For filters that require data from date field: e.g created_at
  def generics_filter_date_field(name)
    date_field_tag("filter[#{name}][value]", '', {:size => 6, :id => 'calendar_'+name, :class => 'calendar'})
  end

#Filters' operator
  def generics_filter_radio_button(name, ary)
    content_tag :span do
      ary.each do |v|
        safe_concat radio_button_tag %Q(filter[#{name}][operator]), v, v.eql?('all'), {class: name, id: %Q(#{name}_#{v.gsub(' ', '_')}), align: 'center'}
        safe_concat label_tag %Q(#{name}_#{v}), v.capitalize
      end
    end
  end

#Build text from a specific journal
  def generics_activities_text_builder(journal, activity_icon, is_not_in_project = true)
    user = (journal.user ? journal.user.name : t(:label_unknown))
    content_tag :p do
      if journal.action_type.eql?('updated') || journal.action_type.eql?('created')
        safe_concat content_tag :span, nil, {class: 'octicon octicon-pencil'} if journal.action_type.eql?('updated')
        safe_concat content_tag :span, nil, {class: 'octicon octicon-diff-added'} if journal.action_type.eql?('created')
        safe_concat "#{user} #{t(:label_updated_lower_case)} "
        if journal.journalized
          safe_concat content_tag :b, "#{journal.journalized_type} : #{journal.journalized_identifier}"
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
        safe_concat content_tag :b, "#{journal.journalized_type} : #{journal.journalized_identifier}"
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

  #TODO remove this code
  #Params hash content:
  #method : possible values :post, :get , :put, :delete
  #target : possible values "nil" or "self", if self url will be '#' else will be path
  #html = {}
  def link_to_with_permissions(label, path, project, params = {})
    ActiveSupport::Deprecation.warn 'This method is deprecated and will be removed.'
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
    ActiveSupport::Deprecation.warn 'This method is deprecated and will be removed.'
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

  def select_tag_versions(id, name, select_key)
    #Don't use hash because, grouped_options will be sort asc : close before open
    option_group_ary = []
    open_ary = []
    open = []
    open << 'Open'
    close_ary = []
    close = []
    close << 'Close'
    versions = @project.versions
    today = Date.current
    select_tag = ''
    versions.each do |version|
      if version.target_date.nil? || (version.target_date && version.target_date > today)
        open_ary << [version.name, version.id, version.target_date]
      else
        close_ary << [version.name, version.id, version.target_date]
      end
    end
    open << open_ary
    close << close_ary
    option_group_ary << open
    option_group_ary << close
    select_tag += "<select class='chzn-select-deselect cbb-medium' tabindex='-1' id='#{id}' name='#{name}'>"
    select_tag += "<option value=''></option>"
    #    select_tag += grouped_options_for_select(option_group_ary, select_key)
    option_group_ary.each do |opt_group|
      select_tag += "<optgroup label='#{opt_group[0].to_s}'>"
      opt_group[1].each do |options|
        select_tag += "<option id='#{options[2]}' value='#{options[1]}' #{'selected="selected"' if options[1].eql?(select_key)}>"+options[0].to_s+'</option>'
      end
      select_tag += '</optgroup>'
    end
    select_tag += '</select>'
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
  end

  def contextual(title)
    content_for :contextual do
      safe_concat content_tag :h1, title
      safe_concat content_tag :div, class: 'splitcontentright', &Proc.new {
        yield if block_given?
      }
    end
  end


end
