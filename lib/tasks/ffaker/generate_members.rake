namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for issues with ffaker.'
    task :members => :environment do
      require 'ffaker'
      User.current = User.find_by_id(1)
      roles = Role.all
      users = User.all
      members_iterations = 75
      members_iterations.times do |x|
        member = Member.new
        member.role = roles[rand(1..2)]
        member.user = users[rand(1..74)]
        member.project_id = 1
        member.save
      end
    end
  end
end 