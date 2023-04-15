require 'activestorage/validator/version'

ActiveSupport.on_load(:active_record) do
  require 'activestorage/validator/blob'
end

I18n.load_path += Dir[File.expand_path(File.join(__dir__, '../../config/locales', '*.yml')).to_s]
