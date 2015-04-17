class AddScopedIdPerProject < ActiveRecord::Migration
  def change
    add_column :projects, :issues_sequence, :integer, null: false, default: 0
    add_column :projects, :documents_sequence, :integer, null: false, default: 0

    add_column :issues, :sequence_id, :integer, null: false
    add_column :documents, :sequence_id, :integer, null: false

    all_projects = Project.all

    all_projects.each do |project|
      project.update_column(:issues_sequence, project.issues.count)
      project.update_column(:documents_sequence, project.documents.count)

      i = 1
      project.issues.order(:id).each do |issue|
        issue.update_column(:sequence_id, i)
        i += 1
      end

      i = 1
      project.documents.order(:id).each do |doc|
        doc.update_column(:sequence_id, i)
        i += 1
      end
    end
  end
end
