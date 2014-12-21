require 'rorganize/redcarpet/rorganize_markdown_renderer'
module ApplicationHelper
  include Rorganize::Managers::PermissionManager::PermissionHandler
  include Rorganize::Helpers::ToolboxHelper
  include Rorganize::Helpers::HistoryHelper
  include Rorganize::Helpers::FilterHelper
  include Rorganize::Helpers::LinksHelper
  include Rorganize::Helpers::CollectionHelper
  include Rorganize::Helpers::MarkdownRenderHelper
  include Rorganize::Helpers::PageTitleHelper
  include Rorganize::Helpers::CustomTagHelper
  # Check if there is any content for :sidebar
  def sidebar_content?
    content_for?(:sidebar)
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

  # Build error message render, when a form is submitted with validation errors.
  # @param [Array] object : all errors contains on an ActiveRecord object.
  def error_messages(object)
    if object.any?
      javascript_tag("error_explanation('#{content_tag :ul, object.collect { |error| content_tag :li, error }.join.html_safe}')")
    end
  end

  # Build a select tag for versions.
  # @param [String] id : id of the select_tag.
  # @param [String] name : name of the select_tag.
  # @param [String] select_key : selected item key.
  def select_tag_versions(id, name, select_key, options = {})
    versions = @project.versions
    hash = {Open: [], Close: []}
    versions.each do |v|
      key = v.closed? ? :Close : :Open
      version_info = build_version_info(v)
      hash[key] << [v.caption, v.id, {'data-target_date' => v.target_date, 'data-start_date' => v.start_date, 'data-version_info' => version_info}]
    end
    default_options = options.merge({class: 'chzn-select-deselect  cbb-medium search', id: id, include_blank: true})
    select_tag name, grouped_options_for_select(hash, select_key), default_options
  end

  def build_version_info(v)
    "#{t(:info_version_start_date)} <b>#{v.start_date.strftime('%d %b. %Y')}</b> #{t(:text_to)} <b>#{v.target_date ? v.target_date.strftime('%d %b. %Y') : ' undetermined'}</b>"
  end


  # Build a breadcrumb on top of the page.
  # @param [String] title : title to display.
  # @param [String] breadcrumb : breadcrump to display.
  def contextual_with_breadcrumb(title, breadcrumb)
    content_for :contextual do
      concat content_tag :h1, title
      concat breadcrumb
      concat contextual_right_content(Proc.new) if block_given?
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
    concat content_tag :h1, title
    concat contextual_right_content(proc) if proc
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
      concat content_tag :span, nil, {class: 'octicon octicon-comment'}
      concat " #{number}"
    end
  end

  # @param [String] text : text to resize.
  # @param [Numeric] length : number of characters.
  def resize_text(text, length = 50)
    text.length > length ? "#{text[0..length]}..." : text
  end

  def style_background_color(color)
    color_tmp = color.tr('#', '')
    r = color_tmp[0,2].to_i(16)
    g = color_tmp[2,2].to_i(16)
    b = color_tmp[4,2].to_i(16)
    "background-color:#{color}; color:#{Math.sqrt((r*r*0.241) + (g*g*0.691) + (b*b*0.068))> 180 ? '#484848' : 'white'}"
  end
end
