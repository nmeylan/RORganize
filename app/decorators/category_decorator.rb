class CategoryDecorator < ApplicationDecorator
  delegate_all

  def edit_link
    link = link_to_with_permissions(model.name, h.edit_category_path(model.project.slug, model.id), model.project, nil)
    link ? link : disabled_field(model.name)
  end

  def delete_link
    link_to_with_permissions(h.glyph(h.t(:link_delete), 'trashcan'), h.category_path(model.project.slug, category.id),model.project,
                             {:method => :delete,:remote => true,:confirm => h.t(:text_delete_item)})
  end

  def new_link

  end

end
