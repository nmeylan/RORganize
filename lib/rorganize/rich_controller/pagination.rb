module Rorganize
  module RichController
    module Pagination
      def set_pagination
        set_current_page
        set_per_page
      end

      def sort_direction
        @sessions[:direction] = params[:direction] ? params[:direction] : (@sessions[:direction] ? @sessions[:direction] : 'desc')
      end

      def sort_column(default_column = nil)
        @sessions[:sort] = params[:sort] ? params[:sort] : (@sessions[:sort] ? @sessions[:sort] : default_column)
      end

      def order(default_column)
        sort_column(default_column) + ' ' + sort_direction
      end

      def set_per_page
        @sessions[:per_page] = params[:per_page] ? params[:per_page] : (@sessions[:per_page] ? @sessions[:per_page] : 25)
      end

      def set_current_page
        # @sessions[:current_page] = params[:page] ? params[:page] : (@sessions[:current_page] ? @sessions[:current_page] : 1)
        @sessions[:current_page] = params[:page]
      end
    end
  end
end
