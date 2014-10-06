require 'rorganize/redcarpet/rorganize_markdown_renderer'
module ApplicationHelper
  include Rorganize::Managers::PermissionManager::PermissionHandler

  # Check if there is any content for :sidebar
  def sidebar_content?
    content_for?(:sidebar)
  end

  # Dynamic page title depending on context (action / controller)
  # @return [String] page title.
  def title_tag
    title = ''
    if controller_name.eql?('exception')
      case @status
        when 404
          title += 'Page not found '
        when 403
          title += 'Permissions required '
        else
          title += 'Something went wrong '
      end
      title += '- RORganize'
    else
      if @project && !@project.new_record?
        title += @project.slug.capitalize + ' '
      elsif controller_name.eql?('profiles')
        title += User.current.login + " (#{User.current.caption}) "
      else
        title += 'RORganize '
      end
      if action_name.eql?('activity')
        title += t(:label_activity)
      elsif action_name.eql?('overview')
        title += t(:label_overview)
      elsif controller_name.eql?('rorganize')
        title += t(:home)
      elsif !controller_name.eql?('profiles')
        title += controller_name.capitalize
      end
    end
    title
  end


  # @return [String] : div that clear left and right.
  def clear_both
    content_tag :div, nil, {class: 'clear-both'}
  end

  # @param [String] text : to display when there are no data to display
  # @return [String] : div block containing text.
  # @param [String] glyph : glyph name to display.
  # @param [Boolean] large : large display or not?
  def no_data(text = nil, glyph = nil, large = false)
    content_tag :div, class: "no-data #{large ? 'large' : '' }" do
      if glyph
        safe_concat (glyph('', glyph))
      end
     safe_concat content_tag :h3, text ? text : t(:text_no_data)
    end
  end


  # Page render for http 500
  def render_500
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/500.html.erb", :status => :not_found }
      format.js { respond_to_js action: 'do_nothing', :response_header => :failure, :response_content => 'An unexpected error occured, please try again!' }
    end
  end

  # Page render for http 404
  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html.erb", :status => :not_found }
      format.js { respond_to_js action: 'do_nothing', :response_header => :failure, :response_content => t(:error_404) }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

  # Page render for http 403
  def render_403
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/403.html.erb", :status => :forbidden }
      format.js { respond_to_js action: 'do_nothing', :response_header => :failure, :response_content => t(:error_403) }
      format.xml { head :forbidden }
      format.all { respond_to_js action: 'do_nothing', :response_header => :failure, :response_content => t(:error_403) }
    end
  end

  # @param [Date] date : whose test for format validation
  # @param [Object] format : of the date.
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

  #Define pagination for the given collection : session is the current selected per_page item, path is the path of the controller.
  # @param [Enumerable] collection : the collection of items to display.
  # @param [Session] session : the per_page argument for pagination.
  # @param [String] path : to the controller to refresh the list when user change the per_page or current_page parameter.
  def paginate(collection, session, path)
    safe_concat will_paginate(collection, {renderer: 'RemoteLinkRenderer'})
    content_tag :div, class: 'autocomplete-combobox nosearch per_page
autocomplete-combobox-high',
                &Proc.new {
      safe_concat content_tag :label, t(:label_per_page), {for: 'per_page'}
      safe_concat select_tag 'per_page', options_for_select([%w(25 25), %w(50 50), %w(100 100)], session[:per_page]), :class => 'chzn-select cbb-small cbb-high', :id => 'per_page', :'data-link' => "#{path}"
    }
  end

  # Build a filter form for given criteria.
  # @param [String] label : what is filtered (e.g : issues, documents).
  # @param [Array] filtered_attributes : an array of filtered attribute @see Document.filtered_attributes.
  # @param [String] submission_path : the path to controller when the filter form is submit.
  # @param [Boolean] can_save : false when save button is hidden, true otherwise.
  # @param [hash] save_button_options
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
            safe_concat content_tag :span, save_filter_button_tag(save_button_options[:filter_content], save_button_options[:user], save_button_options[:project]), {id: 'save_query_button'}
          end
        }
      }
    end
  end

  # Build a save button for filter : based on user permissions (does user is allowed to create custom queries?)
  # @param [Array] filtered_content : an array of previous submitted filter, it use because if nothing were filtered then whe don't display the button.
  # @param [User] user : the current user.
  # @param [Project] project : current project.
  def save_filter_button_tag(filter_content, user, project)
    if !filter_content.eql?('') && user.allowed_to?('new', 'Queries', project) && params[:query_id].nil?
      link_to t(:button_save), new_project_query_queries_path(project.slug, 'Issue'), {:remote => true}
    elsif !filter_content.eql?('') && user.allowed_to?('new', 'Queries', project) && !params[:query_id].nil?
      link_to t(:button_save), edit_query_filter_queries_path(params[:query_id]), {:id => 'filter_edit_save'}
    end
  end

  # Build a header for the given title.
  # @param [String] title.
  def box_header_tag(title, css_class = 'header')
    content_tag :div, class: css_class do
      if block_given?
        safe_concat content_tag :div, yield, class: 'right actions'
      end
      safe_concat content_tag(:h2, title)
    end
  end

  # Build a button that display an info to the user when he click on it.
  # @param [String] info : text info.
  # @param [hash] options : html_options.
  def info_tag(info, options = {})
    default_options = {class: 'octicon octicon-info', title: info}
    content_tag :span, nil, default_options.merge(options)
  end

  # Build a toolbox render from a toolbox object.
  # @param [Toolbox] toolbox : the toolbox object.
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
                  safe_concat link_to(conditional_glyph(caption, menu_item.currents.include?(element), 'check'), '#', {:'data-id' => id})
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

  # Build error message render, when a form is submitted with validation errors.
  # @param [Array] object : all errors contains on an ActiveRecord object.
  def error_messages(object)
    if object.any?
      javascript_tag("error_explanation('#{content_tag :ul, object.collect { |error| content_tag :li, error }.join.html_safe}')")
    end
  end

  # The markdown to html render.
  # @param [String] text : to be transform into html.
  # @param [ActiveRecord::Base] rendered_element : The object that contains the content to be render. It use to define a context and let user click on task lists.
  def markdown_to_html(text, rendered_element = nil, from_mail = false)
    context = {}
    if @project
      context.merge!({project_slug: @project.slug})
    end
    if rendered_element
      allow = false
      if rendered_element.class.eql?(Issue)
        allow = User.current.id.eql?(rendered_element.author_id) && User.current.allowed_to?('edit', 'issues', @project)|| User.current.allowed_to?('edit_not_owner', 'issues', @project)
      elsif rendered_element.class.eql?(Comment)
        allow = User.current.id.eql?(rendered_element.user_id) || User.current.allowed_to?('edit_comment_not_owner', 'comments', @project)
      elsif rendered_element.class.eql?(Document)
        allow = User.current.allowed_to?('edit', 'documents', @project)
      end
      context.merge!({element_type: rendered_element.class, element_id: rendered_element.id, allow_task_list: allow})
    end
    context[:from_mail] = from_mail
    renderer = @project ? RorganizeMarkdownRenderer.new({issue_link_renderer: true}, context) : RorganizeMarkdownRenderer.new({}, context)
    extensions = {quote: true, space_after_headers: true, autolink: true}
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  end

  # Build a sort link for table.
  # @param [String] column.
  # @param [String] title : if provide replace the default column name.
  # @param [String] default_action : when link is clicked it will send an ajax query to the given default_action. (defaults 'index').
  def sortable(column, title = nil, default_action = nil)
    default_action ||= 'index'
    title ||= column.titleize
    icon = if column == sort_column then
             sort_direction == 'asc' ? 'triangle-up' : 'triangle-down'
           else
             ''
           end
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to glyph(title, icon), {:sort => column, :direction => direction, :action => default_action}, {:remote => true}
  end

  # Build a 32x32 glyph render.
  # @param [String] body : content.
  # @param [String] names : glyph names.
  def mega_glyph(body, *names)
    content_tag(:span, nil, :class => names.map { |name| "octicon-#{name.to_s.gsub('_', '-')}" }.push('mega-octicon')) + body
  end

  # Build a 24x24 glyph render.
  # @param [String] body : content.
  # @param [String] names : glyph names.
  def medium_glyph(body, *names)
    content_tag(:span, nil, :class => names.map { |name| "octicon-#{name.to_s.gsub('_', '-')}" }.push('medium-octicon')) + body
  end

  # Build a 16x16 glyph render.
  # @param [String] body : content.
  # @param [String] names : glyph names.
  def glyph(body, *names)
    content_tag(:span, nil, :class => names.map { |name| "octicon-#{name.to_s.gsub('_', '-')}" }.push('octicon')) + body
  end

  # Build a 16x16 glyph render, if condition is true else return raw content.
  # @param [String] body : content.
  # @param [Boolean] bool : the condition.
  # @param [String] names : glyph names.
  def conditional_glyph(body, bool, *names)
    if bool
      glyph(body, *names)
    else
      body
    end
  end


  # Build a generic history for journalizable models.
  # @param [History] history : object.
  def history_render(history) #If come from show action
    safe_concat content_tag :div, nil, class: 'separator'
    safe_concat content_tag :h2, t(:label_history)
    safe_concat content_tag :div, id: 'history_blocks', &Proc.new {
      history.content.collect do |activity|
        if activity.is_a?(Journal)
          safe_concat history_block_render(activity).html_safe
        else
          safe_concat comment_block_render(activity, nil, false).html_safe
        end
      end.join.html_safe
    }
  end

  # Build a history block for one Journal.
  # @param [Journal] journal : to render.
  def history_block_render(journal)
    user = journal.display_author(false)
    content_tag :div, {class: 'history_block', id: "journal_#{journal.id}"} do
      safe_concat journal.display_author_avatar
      safe_concat content_tag :div, class: "history_header #{'display_avatar' if journal.user_avatar?}", &Proc.new {
        safe_concat content_tag :span, user, {class: 'author'}
        safe_concat " #{t(:label_updated).downcase} #{t(:text_this)} "
        safe_concat "#{distance_of_time_in_words(journal.created_at, Time.now)} #{t(:label_ago)}. "
        safe_concat content_tag :span, journal.created_at.strftime(Rorganize::TIME_FORMAT), {class: 'history_date'}
      }
      safe_concat clear_both
      safe_concat content_tag(:ul, (journal.details.collect { |detail| history_detail_render(detail) }).join.html_safe)
    end
  end

  # Build a history detail block.
  # @param [JournalDetail] detail to render.
  # @param [Boolean] no_icon : if true don't display for the updated field, else display the icon. Rendered icons are depending of the object's updated field.
  # for the list of icons @see Rorganize::ACTION_ICON.
  def history_detail_render(detail, no_icon = false)
    content_tag :li do
      icon = Rorganize::ACTION_ICON[detail.property_key.to_sym]
      icon ||= 'pencil'
      safe_concat content_tag :span, nil, class: "octicon octicon-#{icon} activity_icon" unless no_icon
      safe_concat content_tag :span, class: 'detail', &Proc.new {
        if detail.old_value && (detail.value.nil? || detail.value.eql?(''))
          safe_concat content_tag :b, "#{detail.property} #{detail.old_value.to_s} "
          safe_concat "#{t(:text_deleted)}"
        elsif detail.old_value && detail.value
          safe_concat content_tag :b, "#{detail.property} #{t(:text_changed)} "
          safe_concat "#{t(:text_from)} "
          safe_concat content_tag :b, "#{detail.old_value.to_s} "
          safe_concat "#{t(:text_to)} "
          safe_concat content_tag :b, "#{detail.value.to_s}"
        else
          safe_concat content_tag :b, "#{detail.property} "
          safe_concat "#{t(:text_set_at)} "
          safe_concat content_tag :b, "#{detail.value.to_s}"
        end
      }
    end
  end

  # Build an add attachments link
  # @param [String] caption : link caption.
  # @param [ActiveRecord::Base] object that belongs to this attachment.
  # @param [Class] type : type of the object that belongs to this attachment.
  def add_attachments_link(caption, object, type)
    content = escape_once(render :partial => 'shared/attachments', locals: {attachments: Attachment.new, object: object, type: type})
    link_to caption, '#', {:class => 'add_attachment_link', 'data-content' => content}
  end


  # Build filter form input.
  # @param [Symbol] filter_type : type of the filtered link. values are :simple_select, :text, :date.
  # @param [String] label.
  # @param [String] name of the input.
  # @param [Array] options_for_radio : this array must contains one or more of these values
  # ('all', 'contains', 'not_contains', 'equal', 'superior', 'inferior', 'different', 'today', 'open', 'close').
  # @param [Object] args : for simple_select are  ('options_for_select', 'multiple', 'size').
  def generic_filter(filter_type, label, name, options_for_radio, *args)
    types = %w(:simple_select :date :text)
    label ||= name.capitalize
    filter = case filter_type
               when :simple_select then
                 generics_filter_simple_select(name, *args)
               when :date then
                 generics_filter_date_field(name)
               when :text then
                 generics_filter_text_field(name)
               else
                 raise Exception, "Filter with type : :#{filter_type}, doesn't exist! Allowed types are : #{types.join(', ')}"
             end
    content_tag :tr, class: name do
      safe_concat content_tag :td, label, class: 'label'
      safe_concat content_tag :td, generics_filter_radio_button(name, options_for_radio).html_safe, class: 'radio'
      safe_concat content_tag :td, filter, id: "td-#{name}", class: 'value'
    end
  end


  # For following filter: e.g: Assigned with 3 radio button (All, equal, different) and 1 combo
  # @param [String] name : name of the input field.
  # @param [Object] options_for_select : options for select.
  # @param [Boolean] multiple : true multiple select enabled, disabled otherwise.
  # @param [Object] size
  def generics_filter_simple_select(name, options_for_select, multiple = true, size = nil)
    size ||= 'cbb-large'
    content_tag :div, class: 'autocomplete-combobox nosearch no-padding_left no-height' do
      select_tag("filter[#{name}][value][]", options_for_select(options_for_select), :class => 'chzn-select '+size, :id => name+'_list', :multiple => multiple)
    end
  end

  # For filters that require data from text field: e.g subject.
  # @param [String] name : name of the input field.
  def generics_filter_text_field(name)
    text_field_tag("filter[#{name}][value]", '', {:size => 80})
  end

  # For filters that require data from date field: e.g created_at.
  # @param [String] name : name of the input field.
  def generics_filter_date_field(name)
    date_field_tag("filter[#{name}][value]", '', {:size => 6, :id => 'calendar_'+name, :class => 'calendar'})
  end

  # @param [String] name : name of the input field.
  # @param [Array] ary : array of radio names.
  def generics_filter_radio_button(name, ary)
    content_tag :span do
      ary.each do |v|
        safe_concat radio_button_tag %Q(filter[#{name}][operator]), v, v.eql?('all'), {class: name, id: %Q(#{name}_#{v.gsub(' ', '_')}), align: 'center'}
        safe_concat label_tag %Q(#{name}_#{v}), v.gsub('_', ' ').capitalize
      end
    end
  end

  # Build a select tag for versions.
  # @param [String] id : id of the select_tag.
  # @param [String] name : name of the select_tag.
  # @param [String] select_key : selected item key.
  def select_tag_versions(id, name, select_key)
    versions = @project.versions
    hash = {Open: [], Close: []}
    versions.each do |v|
      key = v.closed? ? :Close : :Open
      version_info = "#{t(:info_version_start_date)} <b>#{v.start_date.strftime('%d %b. %Y')}</b> #{t(:text_to)} <b>#{v.target_date ? v.target_date.strftime('%d %b. %Y') : ' undetermined'}</b>"
      hash[key] << [v.caption, v.id, {'data-target_date' => v.target_date, 'data-start_date' => v.start_date, 'data-version_info' => version_info}]
    end
    select_tag name, grouped_options_for_select(hash, select_key), {class: 'chzn-select-deselect  cbb-medium search', id: id, include_blank: true}
  end


  # Build a breadcrumb on top of the page.
  # @param [String] title : title to display.
  # @param [String] breadcrumb : breadcrump to display.
  def contextual_with_breadcrumb(title, breadcrumb)
    content_for :contextual do
      safe_concat content_tag :h1, title
      safe_concat breadcrumb
      safe_concat content_tag :div, class: 'splitcontentright', &Proc.new {
        yield if block_given?
      }
    end
  end

  # Build a contextual div on top of the page. give a block to display some custom content.
  # @param [String] title of the contextual.
  def contextual(title = nil)
    content_for :contextual do
      if title
        safe_concat content_tag :h1, title
        safe_concat content_tag :div, class: 'splitcontentright', &Proc.new {
          yield if block_given?
        }
      else
        yield if block_given?
      end
    end
  end

  # Build a breadcrumb div.
  # @param [String] content : breadcrumb content.
  def breadcrumb(content)
    content_tag :div, class: 'breadcrumb' do
      content
    end
  end


  # Build a dynamic progress bar for a given percentage.
  # @param [Numeric] percent : percentage of progression.
  def progress_bar_tag(percent)
    content_tag :span, class: 'progress_bar' do
      safe_concat content_tag :span, '&nbsp'.html_safe, {class: 'progress', style: "width:#{percent}%"}
      safe_concat content_tag :span, "#{percent}%", {class: 'percent'}
    end
  end

  # Build a link to user profile.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [User] user.
  def fast_profile_link(user)
    "<a href='/#{user.slug}' class='author_link' >#{user.caption}</a>"
  end

  # Build a link to project overview.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [Project] project.
  def fast_project_link(project)
    "<a href='/projects/#{project.slug}/overview'>#{project.caption}</a>"
  end

  # Build a link to issue show action.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [Issue] issue.
  # @param [Project] project.
  def fast_issue_link(issue, project)
    "<a href='/projects/#{project.slug}/issues/#{issue.id}'>#{issue.caption}</a>"
  end


  # Build an avatar renderer for the given user.
  # @param [User] user.
  def fast_user_small_avatar(user)
    "<img alt='' class='small_avatar' src='/system/attachments/Users/#{user.id}/#{user.avatar.id}/very_small/#{user.avatar.avatar_file_name}'>"
  end

  # Build a link to issue show action.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [Document] document.
  # @param [Project] project.
  def fast_document_link(document, project)
    "<b>document</b> <a href='/projects/#{project.slug}/documents/#{document.id}'>#{document.caption}</a>"
  end

  #id is the id of the tab
  #array must contains hash with following keys
  # :name, the name of the tabs
  # :element, the tab content
  # @param [id] id of the tab.
  # @param [Hash] hash must be (name: the name of the tab, element: tab content(text/glyph)).
  def horizontal_tabs(id, hash)
    content_tag :div, {class: 'tabnav', id: id} do
      content_tag :ul, hash.collect { |el| content_tag :li, link_to(el[:element], '#', {class: "tabnav-tab #{hash.first.eql?(el) ? 'selected' : ''}", 'data-tab_id' => el[:name]}) }.join.html_safe, {class: 'tabnav-tabs'}
    end
  end

  # @param [Numeric] number of comments that belongs to the model.
  def comment_presence(number)
    content_tag :span, {class: "#{number == 0 ? 'smooth_gray' : ''}"} do
      safe_concat content_tag :span, nil, {class: 'octicon octicon-comment'}
      safe_concat " #{number}"
    end
  end

  # Render a link to watch all activities from watchable.
  # @param [ActiveRecord::base] watchable : a model that include Watchable module.
  # @param [Project] project : the project which belongs to watchable.
  def watch_link(watchable, project)
    link_to glyph(t(:link_watch), 'eye'), watchers_path(project.slug, watchable.class.to_s, watchable.id), {id: "watch_link_#{watchable.id}", class: 'tooltipped tooltipped-s button', remote: true, method: :post, label: t(:text_watch)}
  end

  # Render a link to unwatch all activities from watchable.
  # @param [ActiveRecord::base] watchable : a model that include Watchable module.
  # @param [Watcher] watcher : the watcher model (activeRecord).
  # @param [Project] project : the project which belongs to watchable.
  def unwatch_link(watchable, watcher, project)
    link_to glyph(t(:link_unwatch), 'eye'), watcher_path(project.slug, watchable.class.to_s, watchable.id, watcher.id), {id: "unwatch_link_#{watchable.id}", class: 'tooltipped tooltipped-s button', remote: true, method: :delete, label: t(:text_unwatch)}
  end

  def notification_link(user)
    if user.notified?
      link_to notifications_path, {class: "tooltipped tooltipped-s indicator #{params[:controller].eql?('notifications') ? 'selected' : ''}", label: t(:text_unread_notifications)} do
        safe_concat content_tag :span, nil, {class: 'unread inbox'}
        safe_concat glyph('', 'inbox')
      end
    else
      link_to glyph('', 'inbox'), notifications_path, {class: "#{params[:controller].eql?('notifications') ? 'selected' : ''}"}
    end
  end

  def sidebar_count_tag(count)
    content_tag :span, count, class: 'count'
  end
end
