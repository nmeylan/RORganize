class WikiPageDecorator < ApplicationDecorator
  delegate_all

  def display_breadcrumb
    h.display_parent_breadcrumb(self, context[:project])
  end

  def parents
    parents = []
    parent = model
    while parent do
      parents << parent
      parent = parent.parent
    end
    parents.reverse
  end

  def creation_info
    "#{h.t(:label_created)} #{h.distance_of_time_in_words(model.created_at, Time.now)} #{h.t(:label_ago)}, #{h.t(:label_by)} #{self.author_name}. #{self.update_info}"
  end

  def update_info
    unless model.created_at.eql?(model.updated_at)
      "#{h.t(:label_updated)} #{h.distance_of_time_in_words(model.updated_at, Time.now)}  #{h.t(:label_ago)}."
    end
  end

  def author_name
    model.author ? model.author.name : h.t(:label_unknown)
  end

  def content
    if model.content && !model.content.empty?
      h.markdown_to_html(model.content, model)
    else
      h.content_tag :div, h.t(:text_empty_page), class: 'no-data'
    end
  end

  def display_page
    h.display_page(self)
  end

  def new_subpage_link
    if User.current.allowed_to?('new', 'Wiki_pages', @project)
      h.link_to h.glyph(h.t(:link_new_sub_page), 'sub-file'), h.new_sub_page_wiki_pages_path(context[:project].slug, model.slug)
    end
  end

  def edit_link
    super(h.t(:link_edit), h.edit_wiki_page_path(context[:project].slug, model.slug), context[:project], model.author_id)
  end

  def delete_link
    super(h.t(:link_delete), h.wiki_page_path(context[:project].slug, model.slug), context[:project], model.author_id)
  end

end
