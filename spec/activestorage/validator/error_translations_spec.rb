RSpec.describe ActiveRecord::Validations::BlobValidator do
  after { User.clear_validators! }

  describe 'with size_range option' do
    before do
      User.validates :file,  blob: { size_range: 1..1.megabyte }
      User.validates :files, blob: { size_range: 1..1.megabyte }
    end

    it "should translate the validation error according to it's locale" do
      # Iterate every available locale in app/config/locales
      available_locales.each do |locale|
        I18n.with_locale locale.to_sym do
          # Create new resource and validate it
          user = User.new(file: create_file_blob(filename: '1_4MB.jpg'), files: [create_file_blob(filename: '1_4MB.jpg')])
          user.validate

          # Run expectation
          expect(user.errors.messages[:file]).to  include(I18n.t('activerecord.errors.messages.max_size_error'))
          expect(user.errors.messages[:files]).to include(I18n.t('activerecord.errors.messages.max_size_error'))
        end
      end
    end
  end

  describe 'with content_type option' do
    before do
      User.validates :file,  blob: { content_type: :image }
      User.validates :files, blob: { content_type: :image }
    end

    it "should translate the validation error according to it's locale" do
      # Iterate every available locale in app/config/locales
      available_locales.each do |locale|
        I18n.with_locale locale.to_sym do
          # Create new resource and validate it
          user = User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain'), files: [create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')])
          user.validate

          # Run expectation
          expect(user.errors.messages[:file]).to  include(I18n.t('activerecord.errors.messages.content_type'))
          expect(user.errors.messages[:files]).to include(I18n.t('activerecord.errors.messages.content_type'))
        end
      end
    end
  end

end

