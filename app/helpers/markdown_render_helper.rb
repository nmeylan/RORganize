# Author: Nicolas Meylan
# Date: 11.10.14
# Encoding: UTF-8
# File: markdown_render_helper.rb

module MarkdownRenderHelper
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
    (rendered_element.respond_to?(:author) && rendered_element.author.eql?(User.current)) ||
        User.current.allowed_to?('edit', Rorganize::Utils::class_name_to_controller_name(rendered_element.class.to_s), @project)
  end
end