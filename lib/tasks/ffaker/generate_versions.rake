require 'ffaker'

namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for issues with ffaker.'
    task :versions => :environment do
      raise "Missing project_id parameter!\ne.g: rake ffaker:generate:versions project_id=1" if (project_id = ENV['project_id']).blank?
      versions_iterations = ENV['i'] ? ENV['i'].to_i : 50

      User.current = User.find_by_id(1)
      versions_iterations.times do |x|
        version = Version.new
        version.name = "#{Time.now.strftime('%Y%m%d%H%M%S%L')}"
        version.description = FFaker::Lorem.paragraph(4)
        version.start_date = Date.today
        version.target_date = version.start_date + 50
        version.project_id = project_id
        version.is_done = true
        version.save
      end
    end
  end
end 