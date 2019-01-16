require 'activestorage/validator/railtie' if defined?(Rails)
require 'activestorage/validator/blob'
require 'activestorage/validator/version'

module ActiveStorage
  # https://github.com/rails/rails/commit/42259ce904eb2538761b32a793cbe390fb8272b7
  if Rails::VERSION::MAJOR < 6
    class Attached::One < Attached
      def blank?
        attachment.blank?
      end
    end
  end
end
