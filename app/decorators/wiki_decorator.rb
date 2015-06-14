class WikiDecorator < ApplicationDecorator
  decorates_association :home_page, with: 'WikiPageDecorator'
  delegate_all

  # see #ApplicationDecorator::delete_link.
  def delete_link
    unless model.new_record?
      super(h.t(:link_delete), h.project_wiki_path(model.project.slug, model), model.project)
    end
  end

  # see #ApplicationDecorator::new_link.
  def new_link
    if model.new_record?
      h.concat h.content_tag :h2, h.t(:text_no_wiki)
      link_to_with_permissions(h.t(:button_create), h.project_wiki_index_path(context[:project].slug), context[:project], nil, {method: :post, class: 'button new'})
    end
  end

  # Render organize pages link.
  def organize_pages_link
    if User.current.allowed_to?('set_organization', 'Wiki', context[:project])
      h.link_to h.glyph(h.t(:link_organize_pages), 'list-ordered'), h.organize_pages_project_wiki_index_path(context[:project].slug), {class: 'button'}
    end
  end

  # see #ApplicationDecorator::new_link.
  def new_page_link
    link_to_with_permissions(h.glyph(h.t(:link_new_page), 'file-text'), h.new_project_wiki_page_path(context[:project].slug), context[:project], nil, {method: :get, class: 'button new'})
  end

  # Render home page. If doesn't exists display new link.
  def home_page
    unless model.new_record?
      if model.home_page.nil?
        display_nil_home_page
      else
        model.home_page = model.home_page.decorate
        model.home_page.display_page
      end
    end
  end

  def display_nil_home_page
    if User.current.allowed_to?('new', 'Wiki_pages', context[:project])
      h.link_to h.t(:label_new_home_page), h.new_home_page_project_wiki_pages_path(context[:project]), {class: 'button'}
    else
      h.no_data h.t(:text_empty_page)
    end
  end

  # Render pages list.
  def display_pages
    if model.pages && model.pages.to_a.any?
      h.display_pages(model.pages)
    else
      h.no_data h.t(:text_no_wiki_page), 'file-text', true
    end
  end
end
