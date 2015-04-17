module Sequenceable
  extend ActiveSupport::Concern

  included do |base|
    before_create :populate_sequence_id
  end

  def populate_sequence_id
    sequence_name = "#{self.class.table_name}_sequence".to_sym
    project.update_column(sequence_name, project.send(sequence_name) + 1)
    self.sequence_id = project.send(sequence_name)
  end

  def to_param
    self.sequence_id.to_s
  end
end