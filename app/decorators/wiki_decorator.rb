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
end
