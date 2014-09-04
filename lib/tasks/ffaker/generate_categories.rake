namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for issues with ffaker.'
    task :categories => :environment do
      require 'ffaker'
      User.current = User.find_by_id(1)

      categories_iterations = 50
      categories_iterations.times do |x|
        category = Category.new
        category.name = Faker::Lorem.word
        category.project_id = 1
        category.save
      end
    end
  end
end 