# Configure RSpec
RSpec.configure do |config|
  config.include Capybara::DSL

  # Use DB agnostic schema by default
  load Rails.root.join('db', 'schema.rb').to_s

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!

  config.use_transactional_fixtures = true

  # run retry only on features
  config.around :each, :js do |ex|
    ex.run_with_retry retry: 3
  end

  config.before(:suite) do
    FactoryBot.find_definitions

    # start the process by truncating all the tables, then use the faster transaction strategy the remaining time
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
