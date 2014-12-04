require 'ffaker'

namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for issues with ffaker.'
    task :issues => :environment do
      raise "Missing project_id parameter!\ne.g: rake ffaker:generate:issues project_id=1" if (project_id = ENV['project_id']).blank?
      issues_iterations = ENV['i'] ? ENV['i'].to_i : 10_000
      project = Project.find_by_id(project_id)

      members = project.members.eager_load(:user)
      versions = project.versions
      categories = project.categories
      trackers = project.trackers
      statuses = IssuesStatus.all

      members_count = members.count - 1
      versions_count = versions.count - 1
      categories_count = categories.count - 1
      trackers_count = trackers.count - 1
      statuses_count = statuses.count - 1

      issues_iterations.times do
        User.current = members[rand(0..members_count)].user
        issue = Issue.new
        issue.subject = Faker::Lorem.words(rand(5..15)).join(' ')
        issue.description = Faker::Lorem.paragraph(rand(2..7))
        issue.author_id = members[rand(0..members_count)].id
        issue.assigned_to_id = members[rand(0..members_count)].id
        issue.version = versions[rand(0..versions_count)]
        issue.category = categories[rand(0..categories_count)]
        issue.project = project
        issue.tracker = trackers[rand(0..trackers_count)]
        issue.status = statuses[rand(0..statuses_count)]
        issue.done = rand(1..100).round(-1)
        issue.save
      end

    end
  end
end 