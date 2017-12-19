require "bundler/setup"
require "active_record"
require "respond_to_faster"

require "database"
require "models"

RespondToFaster::Test::Database.connect

# for in-memory sqlite database
RespondToFaster::Test::Database.auto_migrate

require "database_cleaner"
DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :each do
    DatabaseCleaner.start
  end
  config.after :each do
    DatabaseCleaner.clean
  end
end

Dir[File.expand_path("../matchers/*.rb", __FILE__)].each(&method(:require))
