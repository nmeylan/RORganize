namespace :db do
  namespace :insertion do
    desc 'Create an admin account for RORganize. Please change login and password after the first connection.'
    task :admin_account => :environment do

      hashed_password = User.new(password: 'IAm@dm1n').encrypted_password
      sql = "INSERT INTO `users` (`admin`, `created_at`, `email`, `encrypted_password`, `login`, `name`, `slug`, `updated_at`) VALUES (1, '#{Time.now.to_formatted_s(:db)}', 'rorganize.admin@yourcompany.com', '#{hashed_password}', 'administrator', 'RORganize Admin', 'rorganize-admin', '#{Time.now.to_formatted_s(:db)}')"

      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      ActiveRecord::Base.connection.execute(sql)
      puts 'Administrator account was successfully created, your credentials are : administrator/IAm@dm1n. Please CHANGE THEM IMMEDIATELY.'
    end
  end
end