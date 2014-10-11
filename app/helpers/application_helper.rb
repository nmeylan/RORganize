require 'rorganize/redcarpet/rorganize_markdown_renderer'
module ApplicationHelper
  include Rorganize::Managers::PermissionManager::PermissionHandler
  include ToolboxHelper
  include HistoryHelper
  include FilterHelper
  # Check if there is any content for :sidebar
  def sidebar_content?
    content_for?(:sidebar)
  end

  # Dynamic page title depending on context (action / controller)
  # @return [String] page title.
  def title_tag
    title = ''
    if controller_name.eql?('exception')
      title = title_tag_exception_pages(title)
    else
      title = title_tag_context_pages(title)
      title = title_tag_specific_pages(title)
    end
    title
  end

  def title_tag_context_pages(title)
    if @project && !@project.new_record?
      title += @project.slug.capitalize + ' '
    elsif controller_name.eql?('profiles')
      title += User.current.login + " (#{User.current.caption}) "
    else
      title += 'RORganize '
    end
    title
  end

  def title_tag_specific_pages(title)
    if action_name.eql?('activity')
      title += t(:label_activity)
    elsif action_name.eql?('overview')
      title += t(:label_overview)
    elsif controller_name.eql?('rorganize')
      title += t(:home)
    elsif !controller_name.eql?('profiles')
      title += controller_name.capitalize
    end
    title
  end

  def title_tag_exception_pages(title)
    case @status
      when 404
        title += 'Page not found '
      when 403
        title += 'Permissions required '
      else
        title += 'Something went wrong '
    end
    title += '- RORganize'
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
      format.html { render file: "#{Rails.root}/public/500.html.erb", status: :not_found }
      format.js { respond_to_js action: 'do_nothing', response_header: :failure, response_content: 'An unexpected error occured, please try again!' }
    end
  end

  # Page render for http 404
  def render_404
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html.erb", status: :not_found }
      format.js { respond_to_js action: 'do_nothing', response_header: :failure, response_content: t(:error_404) }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

  # Page render for http 403
  def render_403
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/403.html.erb", status: :forbidden }
      format.js { respond_to_js action: 'do_nothing', response_header: :failure, response_content: t(:error_403) }
      format.xml { head :forbidden }
      format.all { respond_to_js action: 'do_nothing', response_header: :failure, response_content: t(:error_403) }
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
    safe_concat will_paginate(collection, {renderer: 'RemoteLinkRenderer', next_label: t(:label_next), previous_label: t(:label_previous)})
    pagination_per_page(path, session)
  end

  # @param [String] path : to the controller to refresh the list when user change the per_page or current_page parameter.
  # @param [Session] session : the per_page argument for pagination.
  def pagination_per_page(path, session)
    content_tag :div, class: 'autocomplete-combobox nosearch per-page autocomplete-combobox-high' do
        safe_concat content_tag :label, t(:label_per_page), {for: 'per_page', class: 'per-page'}
        safe_concat select_tag 'per_page', pagination_options_tag(session), class: 'chzn-select cbb-small cbb-high', id: 'per-page', 'data-link' => "#{path}"
    end
  end

  # @param [Session] session : the per_page argument for pagination.
  def pagination_options_tag(session)
    options_for_select([%w(25 25), %w(50 50), %w(100 100)], session[:per_page])
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
      allow = markdown_task_list_enabled?(rendered_element)
      context.merge!({element_type: rendered_element.class, element_id: rendered_element.id, allow_task_list: allow})
    end
    context[:from_mail] = from_mail
    renderer = @project ? RorganizeMarkdownRenderer.new({issue_link_renderer: true}, context) : RorganizeMarkdownRenderer.new({}, context)
    extensions = {quote: true, space_after_headers: true, autolink: true}
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  end

  # @param [ActiveRecord::Base] rendered_element : The object that contains the content to be render. It use to define a context and let user click on task lists.
  def markdown_task_list_enabled?(rendered_element)
    allow = false
    if rendered_element.class.eql?(Issue)
      allow = can_user_check_issue_task?(rendered_element)
    elsif rendered_element.class.eql?(Comment)
      allow = can_user_check_comment_task?(rendered_element)
    elsif rendered_element.class.eql?(Document)
      allow = User.current.allowed_to?('edit', 'documents', @project)
    end
    allow
  end

  def can_user_check_comment_task?(rendered_element)
    User.current.id.eql?(rendered_element.user_id) || User.current.allowed_to?('edit_comment_not_owner', 'comments', @project)
  end

  def can_user_check_issue_task?(rendered_element)
    User.current.id.eql?(rendered_element.author_id) && User.current.allowed_to?('edit', 'issues', @project)|| User.current.allowed_to?('edit_not_owner', 'issues', @project)
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
    link_to glyph(title, icon), {sort: column, direction: direction, action: default_action}, {remote: true}
  end

  # Build a 32x32 glyph render.
  # @param [String] body : content.
  # @param [String] names : glyph names.
  def mega_glyph(body, *names)
    content_tag(:span, nil, class: names.map { |name| "octicon-#{name.to_s.tr('_', '-')}" }.push('mega-octicon')) + body
  end

  # Build a 24x24 glyph render.
  # @param [String] body : content.
  # @param [String] names : glyph names.
  def medium_glyph(body, *names)
    content_tag(:span, nil, class: names.map { |name| "octicon-#{name.to_s.tr('_', '-')}" }.push('medium-octicon')) + body
  end

  # Build a 16x16 glyph render.
  # @param [String] body : content.
  # @param [String] names : glyph names.
  def glyph(body, *names)
    content_tag(:span, nil, class: names.map { |name| "octicon-#{name.to_s.tr('_', '-')}" }.push('octicon')) + body
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

  # Build an add attachments link
  # @param [String] caption : link caption.
  # @param [ActiveRecord::Base] object that belongs to this attachment.
  # @param [Class] type : type of the object that belongs to this attachment.
  def add_attachments_link(caption, object, type)
    content = escape_once(render partial: 'shared/attachments', locals: {attachments: Attachment.new, object: object, type: type})
    link_to caption, '#', {class: 'add-attachment-link', 'data-content' => content}
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
    content_tag :div, class: 'autocomplete-combobox nosearch no-padding-left no-height' do
      select_tag("filter[#{name}][value][]", options_for_select(options_for_select), class: 'chzn-select '+size, id: name+'_list', multiple: multiple)
    end
  end

  # For filters that require data from text field: e.g subject.
  # @param [String] name : name of the input field.
  def generics_filter_text_field(name)
    text_field_tag("filter[#{name}][value]", '', {size: 80})
  end

  # For filters that require data from date field: e.g created_at.
  # @param [String] name : name of the input field.
  def generics_filter_date_field(name)
    date_field_tag("filter[#{name}][value]", '', {size: 6, id: 'calendar-'+name, class: 'calendar'})
  end

  # @param [String] name : name of the input field.
  # @param [Array] ary : array of radio names.
  def generics_filter_radio_button(name, ary)
    content_tag :span do
      ary.each do |v|
        safe_concat radio_button_tag %Q(filter[#{name}][operator]), v, v.eql?('all'), {class: name, id: %Q(#{name}_#{v.tr(' ', '_')}), align: 'center'}
        safe_concat label_tag %Q(#{name}_#{v}), v.tr('_', ' ').capitalize
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
      safe_concat contextual_right_content(Proc.new) if block_given?
    end
  end

  # Build a contextual div on top of the page. give a block to display some custom content.
  # @param [String] title of the contextual.
  def contextual(title = nil)
    content_for :contextual do
      if title
        proc = Proc.new if block_given?
        contextual_with_title(title, proc)
      elsif block_given?
        yield
      end
    end
  end

  # @param [String] title of the contextual.
  def contextual_with_title(title, proc = nil)
    safe_concat content_tag :h1, title
    safe_concat contextual_right_content(proc) if proc
  end

  def contextual_right_content(proc)
    content_tag :div, class: 'splitcontentright', &proc
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
  # @param [String] css_class : extra css_class.
  def progress_bar_tag(percent, css_class = nil)
    css_class ||= ''
    css_class += ' progress-bar'
    content_tag :span, class: css_class do
      safe_concat content_tag :span, '&nbsp'.html_safe, {class: 'progress', style: "width:#{percent}%"}
      safe_concat content_tag :span, "#{percent}%", {class: 'percent'}
    end
  end

  def mini_progress_bar_tag(percent, css_class = nil)
    css_class ||= ''
    css_class += ' progress-bar mini-progress-bar'
    content_tag :span, {class: css_class} do
      safe_concat content_tag :span, '&nbsp'.html_safe, {class: 'progress', style: "width:#{percent}%"}
    end
  end

  # Build a link to user profile.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [User|String] user or user name.
  def fast_profile_link(user)
    slug = user.is_a?(User) ? user.slug : user.downcase.tr(' ', '-')
    caption = user.is_a?(User) ? user.caption : user
    "<a href='/#{slug}' class='author-link' >#{caption}</a>"
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
    "<a href='/projects/#{project.slug}/issues/#{issue.id}'>#{resize_text(issue.caption, 35)}</a>"
  end


  # Build an avatar renderer for the given user.
  # @param [User] user.
  def fast_user_small_avatar(user)
    "<img alt='' class='small-avatar' src='/system/attachments/Users/#{user.id}/#{user.avatar.id}/very_small/#{user.avatar.avatar_file_name}'>"
  end

  # Build a link to issue show action.
  # Use this instead of link_to .., .._path due to performance issue. Indeed when we call link_to .. ; .. rails try check path validity and slow the application
  # in case of big render.
  # @param [Document] document.
  # @param [Project] project.
  def fast_document_link(document, project)
    "<b>document</b> <a href='/projects/#{project.slug}/documents/#{document.id}'>#{resize_text(document.caption, 35)}</a>"
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
    content_tag :span, {class: "#{number == 0 ? 'smooth-gray' : ''}"} do
      safe_concat content_tag :span, nil, {class: 'octicon octicon-comment'}
      safe_concat " #{number}"
    end
  end

  # Render a link to watch all activities from watchable.
  # @param [ActiveRecord::base] watchable : a model that include Watchable module.
  # @param [Project] project : the project which belongs to watchable.
  def watch_link(watchable, project)
    link_to glyph(t(:link_watch), 'eye'), watchers_path(project.slug, watchable.class.to_s, watchable.id), {id: "watch-link-#{watchable.id}", class: 'tooltipped tooltipped-s button', remote: true, method: :post, label: t(:text_watch)}
  end

  # Render a link to unwatch all activities from watchable.
  # @param [ActiveRecord::base] watchable : a model that include Watchable module.
  # @param [Watcher] watcher : the watcher model (activeRecord).
  # @param [Project] project : the project which belongs to watchable.
  def unwatch_link(watchable, watcher, project)
    link_to glyph(t(:link_unwatch), 'eye'), watcher_path(project.slug, watchable.class.to_s, watchable.id, watcher.id), {id: "unwatch-link-#{watchable.id}", class: 'tooltipped tooltipped-s button', remote: true, method: :delete, label: t(:text_unwatch)}
  end

  # @param [User] user : current user.
  # @return [String] build a link to notifications panel. Link changed if there are new notifications or not.
  def notification_link(user)
    if user.notified?
      new_notification_link
    else
      link_to glyph('', 'inbox'), notifications_path, {class: "#{params[:controller].eql?('notifications') ? 'selected' : ''}"}
    end
  end

  def new_notification_link
    link_to notifications_path, {class: "tooltipped tooltipped-s indicator #{params[:controller].eql?('notifications') ? 'selected' : ''}", label: t(:text_unread_notifications)} do
      safe_concat content_tag :span, nil, {class: 'unread inbox'}
      safe_concat glyph('', 'inbox')
    end
  end

  # @param [Fixnum] count : number to display.
  # @return [String] build a <span> do display a number with the "count" css class.
  def sidebar_count_tag(count)
    content_tag :span, count, class: 'count'
  end

  # @param [Form] form : the form in which the field will be placed.
  # @param [Symbol] field : the name of the field.
  # @return [String] build a color picker text field. Behaviour is bind on page load (JS).
  def color_field_tag(form, field)
    form.text_field field, autocomplete: 'off', maxlength: 7, class: 'color-editor-field'
  end

  # @param [String] text : text to resize.
  # @param [Numeric] length : number of characters.
  def resize_text(text, length = 50)
    text.length > length ? "#{text[0..length]}..." : text
  end
end
