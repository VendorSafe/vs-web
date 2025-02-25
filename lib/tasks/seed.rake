# lib/tasks/seed.rake
# Custom seed tasks for different scenarios

namespace :db do
  namespace :seed do
    desc 'Load the advanced scenario seed data'
    task advanced: :environment do
      # Load the advanced seed file
      load Rails.root.join('db/seeds/advanced.rb')
    end
  end
end
