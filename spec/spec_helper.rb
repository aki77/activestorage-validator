require "bundler/setup"
require "dummy/application"
require "activestorage/validator"
require "support/blob_helper"
require "support/locales_helper"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # THIS SECTION WAS ADDED DUE TO RAILTIE DOES NOT LOAD ON DUMMY-APPLICATIONS
  # Include translations
  config.before(:suite) do
    # Load locale files
    I18n.load_path.concat(LocalesHelper.locale_files)
  end

  # Inclussions
  config.include BlobHelper
  config.include LocalesHelper
end
