source 'http://rubygems.org'

gem 'rails', '4.2.0'

gem 'ruby-prof'
gem 'devise'
gem 'mysql2'
gem 'friendly_id'
gem 'identicon'
gem 'paperclip'
gem 'mimemagic'
gem 'redcarpet'
gem 'will_paginate'
gem 'gon'
gem 'tzinfo-data', platforms: [:mingw, :mswin]
gem 'mime-types'
gem 'draper'
gem 'delayed_job_active_record'
gem 'daemons'
# Peek bar
gem 'peek'
gem 'peek-mysql2'
gem 'peek-rblineprof'
gem 'peek-performance_bar'
#Assets
gem 'sass-rails', '~> 4.0.1'
gem 'jquery-rails'
gem 'coffee-rails'
gem 'uglifier'
group :test do
  # Pretty printed test output
  gem 'turn', '~> 0.8.3', :require => false
  # Fake test data
  gem 'ffaker'
  # Test cover
  gem 'simplecov', require: false
  gem 'mocha'
  # In memory sqlite db for faster test
  gem 'memory_test_fix'
  gem 'sqlite3'
  gem 'coveralls', require: false
  gem "codeclimate-test-reporter", require: false
  gem 'minitest-reporters'
end

group :development do
  #Performance and code tracer
  gem 'bullet'
  gem 'active_record_query_trace'
  gem 'rack-mini-profiler'
  gem 'memory_profiler'
  gem 'flamegraph'
  gem 'stackprof', '~> 0.2.7'
  #local server
end

group :development, :test do
  gem 'spring'
  gem 'mongrel', '>= 1.2.0.pre2'
end

group :development, :production do
  # File Upload
  gem 'cocaine'
end

#RORganize plugins
eval_gemfile 'PluginsGemfile'