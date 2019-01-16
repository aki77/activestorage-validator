module ActiveStorage
  module Validator
    class Railtie < Rails::Railtie
      initializer 'activestorage-validator' do |app|
        ActiveStorage::Validator::Railtie.instance_eval do
          pattern = pattern_from app.config.i18n.available_locales
  
          # Add aditional locale locations below this line
          add("app/config/locales/#{pattern}.yml")
        end
      end
  
      protected
  
      def self.add(pattern)
        files = Dir[File.join(File.dirname(__FILE__), '../../..', pattern)]
        I18n.load_path.concat(files)
      end
  
      def self.pattern_from(args)
        array = Array(args || [])
        array.blank? ? '*' : "{#{array.join ','}}"
      end

    end
  end
end