#!/usr/bin/ruby

require 'rubygems'
require 'fcgi'

ENV['RAILS_ENV'] ||= 'production'

# Set GEM_PATH and GEM_HOME ("alwaysdata_user" is your alwaysdata user)
ENV['GEM_PATH'] ||= '/home/alwaysdata_user/gems'
ENV['GEM_HOME'] ||= '/home/alwaysdata_user/gems'

require File.join(File.dirname(__FILE__), '../config/environment')

class Rack::PathInfoRewriter
  def initialize(app)
    @app = app
  end

  def call(env)
    env.delete('SCRIPT_NAME')
    parts = env['REQUEST_URI'].split('?')
    env['PATH_INFO'] = parts[0]
    env['QUERY_STRING'] = parts[1].to_s
    @app.call(env)
  end
end

Rack::Handler::FastCGI.run Rack::PathInfoRewriter.new(WebApp::Application)