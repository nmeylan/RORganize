# Author: Nicolas Meylan
# Date: 27.07.14
# Encoding: UTF-8
# File: commentable.rb
module Rorganize
  module Models
    module Commentable
      extend ActiveSupport::Concern
      included do |base|
        has_many :comments, -> { (where commentable_type: base).eager_load(:project, :author) }, as: :commentable, dependent: :delete_all
      end

      def commented?
        self.comments_count > 0
      end

      class << self
        def bulk_delete_dependent(commentable_ids, class_name)
          Comment.delete_all(commentable_id: commentable_ids, commentable_type: class_name)
        end
      end
    end
  end
end