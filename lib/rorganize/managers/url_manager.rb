# Author: Nicolas Meylan
# Date: 21.11.14
# Encoding: UTF-8
# File: url_manager.rb
module Rorganize
  module Managers
    module UrlManager

      # Recognize the given path, even if it defined in an engine.
      # @param [String] path.
      # @param [Object] options
      def recognize_path(path, options)
        recognized_path = Rails.application.routes.recognize_path(path, options)
          # We have a route that catches everything and sends it to 'errors#not_found', you might
          # need to rescue ActionController::RoutingError
      rescue ActionController::RoutingError
        # The main app didn't recognize the path, try the engines...
        Rails::Engine.subclasses.each do |engine|
          engine_instance = engine.instance
          # Find the route to the engine, e.g. '/blog' -> Blog::Engine (a.k.a. "mount")
          engine_route = find_route_to_the_engine(engine_instance)
          next unless engine_route

          # The engine won't recognize the "mount", so strip it off the path,
          # e.g. '/blog/posts/new'.gsub(%r(^/blog), '') #=> '/posts/new', which will be recognized by the engine
          path_for_engine = path.gsub(%r(^#{engine_route.path.spec.to_s}), '')
          recognized_path = handle_path_recognition(engine_instance, options, path_for_engine)
        end
        recognized_path
      end

      def url_for_with_engine_lookup(path)
        # Try to build an url for the given path
        url = url_for(path)
      rescue ActionController::UrlGenerationError # If fail
        Rails::Engine.subclasses.each do |engine| #Looking for this path in engines
          begin
            url = engine.routes.url_for(path.merge({only_path: true})) # Try to build an url for the given path from this engine
          rescue ActionController::UrlGenerationError
            nil
          end
          break if url # Stop when url is build.
        end
        url
      end

      def handle_path_recognition(engine_instance, options, path_for_engine)
        begin
          engine_instance.routes.recognize_path(path_for_engine, options)
        rescue ActionController::RoutingError => e
          nil
        end
      end


      def find_route_to_the_engine(engine_instance)
        engine_class = engine_instance.class
        Rails.application.routes.routes.find { |r| r.app == engine_class }
      end
    end
  end
end