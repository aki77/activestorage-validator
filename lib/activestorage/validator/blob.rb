module ActiveRecord
  module Validations
    class BlobValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, values) # rubocop:disable Metrics/AbcSize
        return unless values.attached?
        invalid_blob = false

        Array(values).each do |value|
          if options[:size_range].present?
            if options[:size_range].min > value.blob.byte_size
              record.errors.add(attribute, :min_size_error, min_size: ActiveSupport::NumberHelper.number_to_human_size(options[:size_range].min))
              invalid_blob = true
            elsif options[:size_range].max < value.blob.byte_size
              record.errors.add(attribute, :max_size_error, max_size: ActiveSupport::NumberHelper.number_to_human_size(options[:size_range].max))
              invalid_blob = true
            end
          end

          unless valid_content_type?(value.blob)
            record.errors.add(attribute, :content_type)
            invalid_blob = true
          end

          if invalid_blob && options[:purge]
            # Purge this record from file and from ActiveStorage::Blob database model
            # This is made in a new thread in order to avoid current thead transaction rollbacks ActiveStorage::Blob purge
            Thread.new do
              ActiveRecord::Base.connection_pool.with_connection do
                file_blob = ActiveStorage::Blob.find_signed(value.signed_id)
                file_blob.purge
              end
            end
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
          when Symbol
            blob.public_send("#{options[:content_type]}?")
          else
            options[:content_type] == blob.content_type
          end
        end
    end
  end
end
