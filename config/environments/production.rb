RORganize::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  #########################################"
  config.cache_classes = true
  #
  #  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.log_level = :error
  #  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false
  #
  #  # Compress JavaScripts and CSS
  config.assets.compress = true
  #
  #  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false
  #
  #  # Generate digests for assets URLs
  config.assets.digest = true

  ##########################"
  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  #   config.log_level = :debug

  # Show full error reports and disable caching
  #  config.consider_all_requests_local       = true
  #  config.action_controller.perform_caching = false
  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, rorganize.scss, and all non-JS/CSS are already added)
  config.assets.precompile = %w(*.js *.css *.png *.jpg *.jpeg *.bmp *.gif *.eot *.ttf *.svg *.woff)
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  config.eager_load = true

  config.exceptions_app = ->(env) { ExceptionController.action(:show).call(env) }

  #MAILS
  config.action_mailer.default_url_options = { host: 'your host' }
  config.action_mailer.default_options = {from: 'your_email'}
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #     address:              'smtp.gmail.com',
  #     port:                 587,
  #     domain:               'example.com',
  #     user_name:            '<username>',
  #     password:             '<password>',
  #     authentication:       'plain',
  #     enable_starttls_auto: true  }
  # Send deprecation notices to registered listeners
  #  config.active_support.deprecation = :notice
  #ImageMagick
  Paperclip.options[:command_path] = '/usr/local/bin/'

  config.active_record.raise_in_transactional_callbacks = true
end
