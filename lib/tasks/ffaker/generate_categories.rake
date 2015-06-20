require 'ffaker'

namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for issues with ffaker.'
    task :categories => :environment do
      raise "Missing project_id parameter!\ne.g: rake ffaker:generate:categories project_id=1" if (project_id = ENV['project_id']).blank?
      User.current = User.find_by_id(1)

      categories_iterations = ENV['i'] ? ENV['i'].to_i : 50
      categories_iterations.times do |x|
        category = Category.new
        category.name = FFaker::Lorem.words(rand(1..3)).join(' ')
        category.project_id = project_id
        category.save
      end
    end
  end
end 