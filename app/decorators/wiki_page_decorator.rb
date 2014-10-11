class WikiPageDecorator < ApplicationDecorator
  delegate_all

  # @return [String] render of the pages breadcrumb.
  def display_breadcrumb
    h.display_parent_breadcrumb(self, context[:project])
  end

  # @return [Array] list of all parents pages.
  def parents
    parents = []
    parent = model
    while parent do
      parents << parent
      parent = parent.parent
    end
    parents.reverse
  end

  # @return [String] author name.
  def author_name
    model.author ? model.author.name : h.t(:label_unknown)
  end

  # Render page markdown content.
  def content
    if model.content && !model.content.empty?
      h.markdown_to_html(model.content, model)
    else
      h.no_data h.t(:text_empty_page)
    end
  end

  # Render page.
  def display_page
    h.display_page(self)
  end

  # Render new subpage link.
  def new_subpage_link
    if User.current.allowed_to?('new', 'Wiki_pages', @project)
      h.link_to h.glyph(h.t(:link_new_sub_page), 'sub-file'), h.new_sub_page_wiki_pages_path(context[:project].slug, model.slug), {class: 'button'}
    end
  end

  # see #ApplicationDecorator::edit_link.
  def edit_link
    super(h.t(:link_edit), h.edit_wiki_page_path(context[:project].slug, model.slug), context[:project], model.author_id, {class: 'button'})
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    super(h.t(:link_delete), h.wiki_page_path(context[:project].slug, model.slug), context[:project], model.author_id, {class: 'danger button'})
  end

end
