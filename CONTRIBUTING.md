## Contributing To RORganize

We want to start off by saying thank you for using RORganize. _This project is a labor of love, and we appreciate all of the users that catch bugs, make performance improvements, and help with documentation. Every contribution is meaningful, so thank you for participating. That being said, here are a few guidelines that we ask you to follow so we can successfully address your issue._

### Submitting Issues

Please include the following:

* Which browser you use.
* A screenshot of the error (if it is relevant).
* Stack trace (preferably as a Gist, since they're easier to read) If you can add a failing test, that's great!

Help us to be more effective and make your issues' title **start with**:

* **[Feature]**, for a feature suggestion.
* **[Bug]**, for a bug.
* **[Deployment]**, for an issue with the deployment phase.
* **[Documentation]**, for a mistake in the wiki, or other *.md files.

### Running Tests

RORganize has a high level of code coverage, if you want to be sure your development environment is correctly set up then run :

    $ rake test

### Development environment
* Fork the repo.
* Create the ```database.yml``` file into the ```config/``` folder, with your database properties.
* Set up your ```development.rb``` file into the ```config/environments/``` folder, with the following content :


    RORganize::Application.configure do
      # Settings specified here will take precedence over those in config/application.rb

      # In the development environment your application's code is reloaded on
      # every request.  This slows down response time but is perfect for development
      # since you don't have to restart the web server when you make code changes.
      config.cache_classes = false

      # Show full error reports and disable caching
      config.consider_all_requests_local = true
      config.action_controller.perform_caching = false

      # Don't care if the mailer can't send
      config.action_mailer.raise_delivery_errors = false
      config.action_mailer.default_url_options = { host: 'example.com' }
      config.action_mailer.default_options = {from: 'example.com'}
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = {
          address:              'smtp.gmail.com',
          port:                 587,
          domain:               'gmail.com',
          user_name:            'example@gmail.com',
          password:             'example',
          authentication:       'plain',
          enable_starttls_auto: true  }

      # Print deprecation notices to the Rails logger
      config.active_support.deprecation = :log

      # Only use best-standards-support built into browsers
      config.action_dispatch.best_standards_support = :builtin

      # Do not compress assets **********
      config.assets.compress = false
      # Expands the lines which load the assets
      config.assets.debug = false

      #ImageMagick
      Paperclip.options[:command_path] = #If you are on Windows : the path to image magick root dir e.g "C:\Program%20Files\ImageMagick-6.8.6-Q16"

      ActiveRecordQueryTrace.enabled = true
      ActiveRecordQueryTrace.level = :full

      config.eager_load = false
      #  Paperclip.options[:swallow_stderr] = false
      config.after_initialize do
        #Bullet sql eager loading optimization
        if defined? Bullet
          Bullet.enable = false
          Bullet.console = true
          Bullet.add_footer = true
          Bullet.bullet_logger = true
        else
          puts 'BULLET IS NOT DEFINED!'
        end
      end

      config.active_record.raise_in_transactional_callbacks = true

    end
* Run the database migration commands : ```rake db:create``` followed by ```rake db:migrate```
* Create an admin account : ```rake db:insertion:admin_account``` then copy/paste the credential from the console output.
* Generate default identicon : ```rake user:generate:identicon```.
* **[Optional ]** Install [imagemagick](http://www.imagemagick.org/script/binary-releases.php), else image upload will crash.

Start rorganize application as you start any other rails application.

### Suggest a feature

If you want to see a feature to be add in RORganize, please submit an issue make the title start with **[Feature]**.

Explain :

* what the feature will do,
* how you want to use it
* what are the gains for the final user.

Screenshot, schema, draw can helps to understand.

### Make a Pull request
If you want to participate with pull request then it is find :+1:.

Remember those (small) following rules :
* Keep your commit atomic
 Please follow the [Coding Style Guide](https://github.com/bbatsov/ruby-style-guide)
* **Always run the full test suite**. `rake test`.
* Please add a detailed commit message. The preference is for a (max) 50 character summary as line one, a blank line, then any number of lines, no longer than 80 characters.
* Send you PR!

We really appreciate any help :smile:.

