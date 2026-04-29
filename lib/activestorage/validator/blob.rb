module ActiveRecord
  module Validations
    class BlobValidator < ::ActiveModel::EachValidator
      def validate_each(record, attribute, values) # rubocop:disable Metrics/AbcSize
        return unless values.attached?

        Array(values).each do |value|
          if options[:size_range].present?
            if options[:size_range].min > value.blob.byte_size
              record.errors.add(attribute, :min_size_error, min_size: ActiveSupport::NumberHelper.number_to_human_size(options[:size_range].min), filename: value.blob.filename.to_s)
            elsif options[:size_range].max < value.blob.byte_size
              record.errors.add(attribute, :max_size_error, max_size: ActiveSupport::NumberHelper.number_to_human_size(options[:size_range].max), filename: value.blob.filename.to_s)
            end
          end

          unless valid_content_type?(value.blob)
            record.errors.add(attribute, :content_type, filename: value.blob.filename.to_s)
          end

          unless valid_extension?(value.blob)
            record.errors.add(
              attribute,
              :extension,
              filename: value.blob.filename.to_s,
              extension: Array(options[:extension]).map { |e| normalize_extension(e) }.join(', ')
            )
          end
        end
      end

      private

        def valid_content_type?(blob)
          return true if options[:content_type].nil?

          case options[:content_type]
          when Regexp
            options[:content_type].match?(blob.content_type)
          when Array
            options[:content_type].include?(blob.content_type)
          when :web_image
            ActiveStorage.web_image_content_types.include?(blob.content_type)
          when Symbol
            blob.public_send("#{options[:content_type]}?")
          else
            options[:content_type] == blob.content_type
          end
        end

        def valid_extension?(blob)
          return true if options[:extension].nil?

          allowed = Array(options[:extension]).map { |e| normalize_extension(e) }
          actual = normalize_extension(blob.filename.extension)
          return false if actual.empty?

          allowed.include?(actual)
        end

        def normalize_extension(value)
          value.to_s.downcase.delete_prefix('.')
        end
    end
  end
end
