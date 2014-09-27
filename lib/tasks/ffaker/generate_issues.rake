require 'ffaker'
namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for issues with ffaker.'
    task :issues => :environment do
      issues_iterations = 10_000

      members = Member.where(project_id: 1).eager_load(:user)
      versions = Version.where(project_id: 1)
      categories = Category.where(project_id: 1)
      issues_iterations.times do |x|
        User.current = members[rand(1..75)].user
        issue = Issue.new
        issue.subject = Faker::Lorem.word
        issue.description = Faker::Lorem.paragraph(2)
        issue.author_id = members[rand(1..75)].user_id
        issue.assigned_to_id = members[rand(1..75)].user_id
        issue.version_id = versions[rand(1..49)].id
        issue.category_id = categories[rand(1..49)].id
        issue.project_id = 1
        issue.tracker_id = rand(1..2)
        issue.status_id = rand(1..7)
        issue.done = rand(1..100).round(-1)
        issue.save
      end

    end
  end
end 