namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for issues with ffaker.'
    task :versions => :environment do
      require 'ffaker'
      versions_iterations = 50
      User.current = User.find_by_id(1)
      versions_iterations.times do |x|
        version = Version.new
        version.name = "versions_#{x}"
        version.description = Faker::Lorem.paragraph(4)
        version.start_date = Date.today
        version.target_date = version.start_date + 50
        version.project_id = 1
        version.is_done = true
        version.save
      end
    end
  end
end 