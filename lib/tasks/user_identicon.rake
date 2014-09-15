namespace :user do
  namespace :generate do
    desc 'Generate default avatar for user.'
    task :identicon => :environment do
      users = User.all
      users.each do |user|
        user.avatar.destroy unless user.avatar.nil?
        dir = "#{Rails.root}/public/system/identicons/"
        Dir.mkdir(dir, 0700) unless File.directory?(dir)
        path = "#{Rails.root}/public/system/identicons/#{user.slug}_avatar.png"
        Identicon.file_for user.slug, path
        file = File.open(path)
        user.avatar = Avatar.new({attachable_type: user.class.to_s})
        user.avatar.avatar = file
        avatar = user.avatar
        avatar.save(validation: false)
        file.close
      end
    end
  end
end