require 'activestorage/validator/version'

ActiveSupport.on_load(:active_record) do
  require 'activestorage/validator/blob'
end

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

I18n.load_path += Dir[File.expand_path(File.join(__dir__, '../../config/locales', '*.yml')).to_s]
