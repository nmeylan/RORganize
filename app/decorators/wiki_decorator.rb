class WikiDecorator < ApplicationDecorator
  decorates_association :home_page, with: 'WikiPageDecorator'
  delegate_all

  def delete_link
    unless model.new_record?
      super(h.t(:link_delete), h.wiki_path(model.project.slug, model.id), model.project)
    end
  end

  def new_link
    if model.new_record?
      h.content_tag :h2, h.t(:text_no_wiki)
      link_to_with_permissions(h.t(:button_create), h.wiki_index_path(context[:project].slug), context[:project], nil, {method: :post})
    end
  end

  def organize_pages_link
    if User.current.allowed_to?('set_organization', 'Wiki', context[:project])
      h.link_to h.glyph(h.t(:link_organize_pages), 'list-ordered'), h.organize_pages_wiki_index_path(context[:project].slug)
    end
  end

  def new_page_link
    link_to_with_permissions(h.glyph(h.t(:link_new_page), 'file-text'), h.new_wiki_page_path(context[:project].slug), context[:project], nil, {:method => :get})
  end

  def home_page
    unless model.new_record?
      if model.home_page.nil?
        h.link_to h.t(:label_new_home_page), h.new_home_page_wiki_pages_path(context[:project])
      else
        model.home_page = model.home_page.decorate
        model.home_page.display_page
      end
    end
  end

  def display_pages
    if model.pages && model.pages.to_a.any?
      h.display_pages(model.pages)
    else
      h.content_tag :div, h.t(:text_no_data), class: 'no-data'
    end
  end
end
