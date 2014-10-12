#Author : Nicolas
#Date: 25 juin 2013
#Encoding: UTF-8
#File: wiki_pages_helper

module WikiHelper
  # Build a render of all wiki pages.
  # Call with all parents page : parent_id must be nil
  # @param [Array] pages : all wiki root pages (nil parent_id).
  def display_pages(pages)
    content_tag :div, id: 'wiki-pages' do
      content_tag :ul, {class: 'connectedSortable', id: 'pages-root'} do
        render_all_pages(pages)
      end
    end
  end

  # Iterate over all pages.
  def render_all_pages(pages)
    pages.sort { |x, y| x.position<=>y.position }.collect do |page|
      render_sub_pages_from_root(page)
    end.join.html_safe
  end

  # Render all sub pages contains by a root page.
  # @param [WikiPage] page
  def render_sub_pages_from_root(page)
    if page.parent.nil?
      safe_concat page_link(page)
      safe_concat display_sub_pages(page.id, page.sub_pages) if page.sub_pages && page.sub_pages.to_a.any?
    end
  end

  # Build a render of all sub pages for the given parent.
  # Can be call with a single parent page
  # @param [Numeric] parent_id : id of the parent page.
  # @param [Array] pages : array of sub pages.
  def display_sub_pages(parent_id, pages)
    content_tag :li, {class: 'parent'} do
      content_tag :ul, {class: 'connectedSortable', id: "parent-#{parent_id}"} do
        render_sub_pages(pages)
      end
    end
  end

  # Build a render for all sub pages that are in the same "level".
  # @param [Array] pages
  def render_sub_pages(pages)
    pages.sort { |x, y| x.position<=>y.position }.collect do |page|
      safe_concat page_link(page)
      safe_concat display_sub_pages(page.id, page.sub_pages) if page.sub_pages.any?
    end.join.html_safe
  end

  # Render a link to the given sub page.
  # @param [WikiPage] page
  def page_link(page)
    content_tag :li, {class: 'item', id: "item-#{page.id}"} do
      safe_concat link_to page.title, wiki_page_path(@project.slug, page.slug)
    end
  end

end

