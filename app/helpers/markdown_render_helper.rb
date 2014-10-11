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
end