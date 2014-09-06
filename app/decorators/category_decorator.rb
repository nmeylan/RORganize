class CategoryDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::edit_link
  def edit_link
    link = link_to_with_permissions(model.name, h.edit_category_path(model.project.slug, model.id), model.project, nil)
    link ? link : disabled_field(model.name)
  end

  # see #ApplicationDecorator::delete_link
  def delete_link
    super(h.t(:link_delete), h.category_path(model.project.slug, category.id), model.project)
  end
end
