class VersionDecorator < ApplicationDecorator
  delegate_all

  def display_description
    if description?
      h.content_tag :div, class: 'box' do
        super
      end
    end
  end

  def diplay_id
    model.id ? model.id : 'unplanned'
  end
end
