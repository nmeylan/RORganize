# Author: Nicolas Meylan
# Date: 22.01.15 20:53
# Encoding: UTF-8
# File: custom_http_request.rb

module Rorganize
  module CustomHttpRequest

    # Simulate a GET request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def get_with_permission(action, *args)
      allow_user_to(action)
      _get(action, *args)
    end

    # Simulate a POST request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def post_with_permission(action, *args)
      allow_user_to(action)
      _post(action, *args)
    end

    # Simulate a PATCH request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def patch_with_permission(action, *args)
      allow_user_to(action)
      _patch(action, *args)
    end

    # Simulate a PUT request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def put_with_permission(action, *args)
      allow_user_to(action)
      _put(action, *args)
    end

    # Simulate a DELETE request with the given parameters. But add permission to the current user to perform the action.
    # Otherwise user will get a 403 error.
    # See +get+ for more details.
    def delete_with_permission(action, *args)
      allow_user_to(action)
      _delete(action, *args)
    end

    # Simulate a GET request with the given parameters. But merge project context params.
    def _get(action, *args)
      args = merge_project_context_params(args)
      hash = args.first
      if hash[:format] && hash[:format].eql?(:js)
        xhr :get, action, *args
      else
        get(action, *args)
      end
    end

    # Simulate a POST request with the given parameters. But merge project context params.
    def _post(action, *args)
      args = merge_project_context_params(args)
      hash = args.first
      if hash[:format] && hash[:format].eql?(:js)
        xhr :post, action, *args
        else
          post(action, *args)
      end
    end

    # Simulate a PATCH request with the given parameters. But merge project context params.
    def _patch(action, *args)
      args = merge_project_context_params(args)
      hash = args.first
      if hash[:format] && hash[:format].eql?(:js)
        xhr :patch, action, *args
      else
        patch(action, *args)
      end
    end

    # Simulate a PUT request with the given parameters. But merge project context params.
    def _put(action, *args)
      args = merge_project_context_params(args)
      hash = args.first
      if hash[:format] && hash[:format].eql?(:js)
        xhr :put, action, *args
      else
        put(action, *args)
      end
    end

    # Simulate a DELETE request with the given parameters. But merge project context params.
    def _delete(action, *args)
      args = merge_project_context_params(args)
      hash = args.first
      if hash[:format] && hash[:format].eql?(:js)
        xhr :delete, action, *args
      else
        delete(action, *args)
      end
    end

    def merge_project_context_params(args)
      args = [{}] unless args.first
      if @project && args.first[:project_id].nil?
        args.first.merge!({project_id: @project.slug})
      end
      args
    end
  end
end