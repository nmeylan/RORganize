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
        pages.sort { |x, y| x.position<=>y.position }.collect do |page|
          if page.parent.nil?
            safe_concat content_tag :li, link_to(page.title, wiki_page_path(@project.slug, page.slug)), {class: 'item', id: "item-#{page.id}"}
            if page.sub_pages && page.sub_pages.to_a.any?
              safe_concat display_sub_pages(page.id, page.sub_pages)
            end
          end
        end.join.html_safe
      end
    end
  end

  # Build a render of all sub pages.
  # Can be call with a single parent page
  # @param [Numeric] parent_id : id of the parent page.
  # @param [Array] pages : array of sub pages.
  def display_sub_pages(parent_id, pages)
    content_tag :li, {class: 'parent'}, &Proc.new {
      content_tag :ul, {class: 'connectedSortable', id: "parent-#{parent-id}"}, &Proc.new {
        pages.sort { |x, y| x.position<=>y.position }.collect do |page|
          safe_concat content_tag :li, {class: 'item', id: "item-#{page.id}"}, &Proc.new {
            safe_concat link_to page.title, wiki_page_path(@project.slug, page.slug)
          }
          if page.sub_pages.any?
            safe_concat display_sub_pages(page.id, page.sub_pages)
          end
        end.join.html_safe
      }
    }
  end

end

