module ActiveRecord
  module Validations
    class BlobValidator < ::ActiveModel::EachValidator
      def validate_each(record, attribute, values) # rubocop:disable Metrics/AbcSize
        return unless values.attached?

        size_range   = resolve_option(record, options[:size_range])
        content_type = resolve_option(record, options[:content_type])
        extension    = resolve_option(record, options[:extension])

        Array(values).each do |value|
          validate_size(record, attribute, value, size_range) if size_range.present?

          unless valid_content_type?(value.blob, content_type)
            record.errors.add(attribute, :content_type, filename: value.blob.filename.to_s)
          end

          unless valid_extension?(value.blob, extension)
            record.errors.add(
              attribute,
              :extension,
              filename: value.blob.filename.to_s,
              extension: Array(extension).map { |e| normalize_extension(e) }.join(', ')
            )
          end
        end
      end

      private

        # Resolve only when the value is a Proc, using the same arity convention
        # as Rails' built-in validators: arity 0 calls the proc as-is, otherwise
        # the record is passed in. Anything else (Symbol/String/Array/Regexp/
        # Range/nil) is returned untouched, preserving backward compatibility.
        def resolve_option(record, value)
          return value unless value.is_a?(Proc)

          value.arity.zero? ? value.call : value.call(record)
        end

        def validate_size(record, attribute, value, size_range)
          byte_size = value.blob.byte_size
          if size_range.min > byte_size
            record.errors.add(attribute, :min_size_error, min_size: ActiveSupport::NumberHelper.number_to_human_size(size_range.min), filename: value.blob.filename.to_s)
          elsif size_range.max < byte_size
            record.errors.add(attribute, :max_size_error, max_size: ActiveSupport::NumberHelper.number_to_human_size(size_range.max), filename: value.blob.filename.to_s)
          end
        end

        def valid_content_type?(blob, content_type)
          return true if content_type.nil?

          case content_type
          when Regexp
            content_type.match?(blob.content_type)
          when Array
            content_type.include?(blob.content_type)
          when :web_image
            ActiveStorage.web_image_content_types.include?(blob.content_type)
          when Symbol
            blob.public_send("#{content_type}?")
          else
            content_type == blob.content_type
          end
        end

        def valid_extension?(blob, extension)
          return true if extension.nil?

          allowed = Array(extension).map { |e| normalize_extension(e) }
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
