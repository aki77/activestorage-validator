module ActiveRecord
  module Validations
    class BlobValidator < ::ActiveModel::EachValidator
      def validate_each(record, attribute, values) # rubocop:disable Metrics/AbcSize
        return unless values.attached?

        Array(values).each do |value|
          if options[:size_range].present?
            if options[:size_range].is_a? Proc
              range = record.instance_exec(&options[:size_range])
              size_range_error(record, attribute, range, value)
            else
              size_range_error(record, attribute, options[:size_range], value)
            end
          end

          unless valid_content_type?(record, value.blob)
            record.errors.add(attribute, :content_type)
          end
        end
      end

      private

      def size_range_error(record, attribute, range, value)
        if range.min > value.blob.byte_size
          record.errors.add(
            attribute,
            :min_size_error,
            min_size: ActiveSupport::NumberHelper.number_to_human_size(range.min)
          )
        elsif range.max < value.blob.byte_size
          record.errors.add(
            attribute,
            :max_size_error,
            max_size: ActiveSupport::NumberHelper.number_to_human_size(range.max)
          )
        end
      end

      def valid_content_type?(record, blob)
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
        when Proc
          content_types = record.instance_exec(&options[:content_type])
          content_types.include?(blob.content_type)
        else
          options[:content_type] == blob.content_type
        end
      end
    end
  end
end
