class ProjectsDecorator < ApplicationCollectionDecorator

  # see #ApplicationCollectionDecorator::new_link
  def new_link
    super(h.t(:link_new_project), h.new_project_path)
  end

  # see #ApplicationCollectionDecorator::display_collection
  def display_collection
    h.content_tag :div, id: 'projects' do
      super true, h.t(:no_data_projects) do
        h.project_list(self, context[:allow_to_star])
      end
    end
  end

end
