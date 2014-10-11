require 'rorganize/redcarpet/rorganize_markdown_renderer'
module ApplicationHelper
  include Rorganize::Managers::PermissionManager::PermissionHandler
  include Rorganize::Helpers::ToolboxHelper
  include Rorganize::Helpers::HistoryHelper
  include Rorganize::Helpers::FilterHelper
  include Rorganize::Helpers::LinksHelper
  include Rorganize::Helpers::CollectionHelper
  include Rorganize::Helpers::MarkdownRenderHelper
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

  def concat_span_tag(content, options = {})
    safe_concat content_tag :span, content, options
  end
end
