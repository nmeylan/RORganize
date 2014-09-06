class VersionDecorator < ApplicationDecorator
  delegate_all

  # see #ApplicationDecorator::display_history.
  def display_description
    if description?
      h.content_tag :div, class: 'box' do
        super
      end
    end
  end

  # @return [String] version id.
  def display_id
    model.id ? model.id : 'unplanned'
  end

  # see #ApplicationDecorator::dec_position_link.
  def dec_position_link(collection_size)
    super(collection_size, h.change_position_versions_path(model.project.slug))
  end

  # see #ApplicationDecorator::inc_position_link.
  def inc_position_link
    super(h.change_position_versions_path(model.project.slug))
  end

  # see #ApplicationDecorator::delete_link.
  def delete_link
    super(h.t(:link_delete), h.version_path(model.project.slug, model.id))
  end

  # @return [String] start date.
  def start_date
    model.start_date ? model.start_date : '-'
  end

  # @return [String] target_date.
  def display_target_date
    model.target_date ? model.target_date : '-'
  end

  # @return [String] is done.
  def is_done
    model.is_done
  end

  # see #ApplicationDecorator::edit_link.
  def edit_link
    link = link_to_with_permissions(model.caption, h.edit_version_path(model.project.slug, model.id), model.project, nil)
    link ? link : disabled_field(model.caption)
  end
end
