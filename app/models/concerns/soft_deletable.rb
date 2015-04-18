module SoftDeletable
  extend ActiveSupport::Concern

  included do
    default_scope(-> { where(deleted_at: nil) })
    scope :not_deleted, -> { where(deleted_at: nil) }
    scope :deleted, -> { unscoped.where.not(deleted_at: nil) }
    define_callbacks :soft_delete
  end

  def soft_delete
    run_callbacks(:soft_delete) { touch(:deleted_at) }
  end

  module ClassMethods
    def soft_delete_all
      update_all(deleted_at: Time.current)
    end
  end

  extend ClassMethods
end