class VersionDecorator < ApplicationDecorator
  delegate_all

  def display_description
    if description?
      h.content_tag :div, class: 'box' do
        super
      end
    end
  end

  def display_id
    model.id ? model.id : 'unplanned'
  end

  def dec_position_link(collection_size)
    super(collection_size, h.change_position_versions_path(model.project.slug))
  end

  def inc_position_link
    super(h.change_position_versions_path(model.project.slug))
  end

  def delete_link
    super(h.t(:link_delete), h.version_path(model.project.slug, model.id))
  end

  def start_date
    model.start_date ? model.start_date : '-'
  end

  def target_date
    model.target_date ? model.target_date : '-'
  end

  def is_done
    model.is_done
  end

  def edit_link
    link = link_to_with_permissions(model.caption, h.edit_version_path(model.project.slug, model.id), model.project, nil)
    link ? link : disabled_field(model.caption)
  end
end
