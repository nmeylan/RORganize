namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for issues with ffaker.'
    task :users => :environment do
      require 'ffaker'
      User.current = User.find_by_id(1)
      users_iterations = 100
      users_iterations.times do |x|
        user = User.new
        user.name =  Faker::Name.first_name + ' ' + Faker::Name.last_name
        user.login = Faker::Internet.user_name(user.name)
        user.email = Faker::Internet.email
        user.password = user.login
        user.admin = 0
        user.save

        path = "#{Rails.root}/public/system/identicons/#{user.slug}_avatar.png"
        Identicon.file_for user.slug, path
        file = File.open(path)
        user.avatar = Attachment.new({attachable_type: user.class.to_s})
        user.avatar.avatar = file
        avatar = user.avatar
        avatar.save(validation: false)
        file.close
      end
    end
  end
end 