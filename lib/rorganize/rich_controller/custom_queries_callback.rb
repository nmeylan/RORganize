module Rorganize
  module RichController
    module CustomQueriesCallback

      def apply_custom_query
        @query = Query.find_by_slug(params[:query_id])
        if @query
          @sessions[@project.slug][:sql_filter] = @query.stringify_query
          @sessions[@project.slug][:json_filter] = JSON.parse(@query.stringify_params.gsub('=>', ':'))
        end
        index
      end

      def filter(klazz)
        @sessions[@project.slug] ||= {}
        apply_filter(klazz, params, @sessions[@project.slug])
      end

      def find_custom_queries(type)
        @custom_queries_decorator = Query.available_for(User.current, @project.id, type).decorate
      end

    end
  end
end
