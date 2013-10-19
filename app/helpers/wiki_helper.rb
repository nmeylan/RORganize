#Author : Nicolas
#Date: 25 juin 2013 
#Encoding: UTF-8
#File: wiki_pages_helper

module WikiHelper
  #Call with all parents page : parent_id must be nil
  def display_pages(pages, html)
    html ||= ''
    html += "<ul class='connectedSortable' id='pages_root'>"
    pages.sort{|x,y| x.position<=>y.position}.each do |page|
      html += "<li class='item' id='item_#{page.id}'>
              #{link_to page.title, wiki_page_path(@project.slug, page.slug)}</li>"
      if page.sub_pages.any?
        html = display_sub_pages(page.id,page.sub_pages, html)
      end
    end
    html += '</ul>'
    return html.html_safe
  end
  #Can be call with a single parent page
  def display_sub_pages(parent_id, pages, html )
    html ||= ''
    html += "<li class='parent' style='list-style:none'><ul id='parent_#{parent_id}' class='connectedSortable'>"
    pages.sort{|x,y| x.position<=>y.position}.each do |page|
      html += "<li class='item' id='item_#{page.id}'>#{link_to page.title, wiki_page_path(@project.slug, page.slug)}</li>"
      if page.sub_pages.any?
        html = display_sub_pages(page.id, page.sub_pages, html)
      end
    end
    html += '</ul></li>'
    return html
  end
  #
  def display_parent_breadcrumb(page, project_id, html)
    html ||= ''
    unless html.eql?('') && page.parent.nil?
      html.insert(0,"#{link_to(page.title, wiki_page_path(project_id, page.slug))} >> ")
    end
    if page.parent.nil?
      return html.html_safe
    else
      display_parent_breadcrumb(page.parent, project_id, html)
    end
  end
end

