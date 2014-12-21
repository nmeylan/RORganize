# Author: Nicolas Meylan
# Date: 13.07.14
# Encoding: UTF-8
# File: wiki_pages_helper.rb

module WikiPagesHelper
  # Build render of a wiki page.
  # @param [WikiPage] page : the current page.
  def display_page(page)
    concat content_tag :h1, page.caption
    concat content_tag :em, page.creation_info
    content_tag :p, page.content
  end


  # Build a render of page breadcrumb.
  # @param [WikiPage] page : the current page.
  # @param [Project] project : the current project.
  def display_parent_breadcrumb(page, project)
    breadcrumb page.parents.collect { |parent| content_tag :h1, link_to(parent.title, wiki_page_path(project.slug, parent.slug)) }.join(mega_glyph('', 'chevron-right')).html_safe
  end
end