namespace :user do
  namespace :generate do
    desc 'Generate default avatar for user.'
    task :identicon => :environment do
      users = User.all
      users.each do |user|
        if user.avatar.nil?
          path = "#{Rails.root}/public/system/identicons/#{user.slug}_avatar.png"
          Identicon.file_for user.slug, path
          file = File.open(path)
          user.avatar = Attachment.new({object_type: user.class.to_s})
          user.avatar.avatar = file
          user.save(validation: false)
          avatar = user.avatar
          avatar.save(validation: false)
          file.close
        end
      end
    end
  end
end