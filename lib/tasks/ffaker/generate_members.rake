require 'ffaker'

namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for issues with ffaker.'
    task :members => :environment do
      raise "Missing project_id parameter!\ne.g: rake ffaker:generate:members project_id=1" if (project_id = ENV['project_id']).blank?
      User.current = User.find_by_id(1)
      roles = Role.all
      users = User.all

      roles_count = roles.count
      users_count = users.count

      members_iterations = ENV['i'] ? ENV['i'].to_i : 75
      members_iterations.times do
        member = Member.new
        member.role = roles[rand(0..roles_count)]
        member.user = users[rand(0..users_count)]
        member.project_id = project_id
        member.save
      end
    end
  end
end 