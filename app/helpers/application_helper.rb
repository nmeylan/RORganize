require 'rorganize/redcarpet/rorganize_markdown_renderer'
require 'rorganize/form_builder/rorganize_form_builder'
module ApplicationHelper
  include PageTitleHelper
  include Rorganize::Managers::PermissionManager::PermissionHandler
  include ToolboxHelper
  include HistoryHelper
  include FilterHelper
  include LinksHelper
  include CollectionHelper
  include MarkdownRenderHelper
  include CustomTagHelper
  # Check if there is any content for :sidebar
  def sidebar_content?
    content_for?(:sidebar)
  end

  # Page render for http 500
  def render_500
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/500.html.erb", status: :internal_server_error }
      format.js { respond_to_js action: 'do_nothing', response_header: :failure,
                                response_content: 'An unexpected error occured, please try again!', status: :internal_server_error }
    end
  end

  # Page render for http 404
  def render_404
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html.erb", status: :not_found }
      format.js { respond_to_js action: 'do_nothing', response_header: :failure,
                                response_content: t(:error_404), status: :not_found }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

  # Page render for http 403
  def render_403
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/403.html.erb", status: :forbidden }
      format.js { respond_to_js action: 'do_nothing', response_header: :failure,
                                response_content: t(:error_403), status: :forbidden }
      format.xml { head :forbidden }
      format.all { respond_to_js action: 'do_nothing', response_header: :failure,
                                 response_content: t(:error_403), status: :forbidden }
    end
  end

  # Build error message render, when a form is submitted with validation errors.
  # @param [Array] object : all errors contains on an ActiveRecord object.
  def error_messages(object)
    if object.any?
      javascript_tag("errorExplanation('#{content_tag :ul, object.collect { |error| content_tag :li, error }.join.html_safe}')")
    end
  end

  # Build a select tag for versions.
  # @param [String] id : id of the select_tag.
  # @param [String] name : name of the select_tag.
  # @param [String] select_key : selected item key.
  def select_tag_versions(versions, id, name, select_key, options = {})
    default_options = options.merge({class: 'chzn-select-deselect  cbb-medium search', id: id, include_blank: true})
    select_tag name, grouped_options_for_select(versions_grouped_options(versions), select_key), default_options
  end

  def versions_grouped_options(versions)
    hash = {Opened: [], Done: []}
    versions.sort_by(&:position).reverse.each do |v|
      key = v.is_done ? :Done : :Opened
      version_info = build_version_info(v)
      hash[key] << [v.caption, v.id, {'data-target_date' => v.target_date, 'data-start_date' => v.start_date, 'data-version_info' => version_info}]
    end
    hash
  end

  def build_version_info(v)
    "#{t(:info_version_start_date)} <b>#{v.start_date.strftime('%d %b. %Y')}</b> #{t(:text_to)} <b>#{v.target_date ? v.target_date.strftime('%d %b. %Y') : t(:text_undetermined)}</b>"
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

  # @param [id] id of the tab.
  # @param [Array[Hash]] tabs must be (name: the name of the tab, element: tab content(text/glyph)).
  # hash with following keys
  # :name, the name of the tabs
  # :element, the tab content
  def horizontal_tabs(id, tabs)
    content_tag :div, {class: '', id: id} do
      content_tag :ul, {class: 'nav nav-tabs'} do
        tabs.collect do |el|
          content_tag :li, link_to(el[:element], "##{el[:name]}", data: {toggle: "tab"}), class: "#{tabs.first.eql?(el) ? 'active' : ''}"
        end.join.html_safe
      end
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
    r = color_tmp[0, 2].to_i(16)
    g = color_tmp[2, 2].to_i(16)
    b = color_tmp[4, 2].to_i(16)
    "background-color:#{color}; color:#{Math.sqrt((r*r*0.241) + (g*g*0.691) + (b*b*0.068))> 180 ? '#484848' : 'white'}"
  end

  def rorganize_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(builder: RorganizeFormBuilder)), &block)
  end
end
