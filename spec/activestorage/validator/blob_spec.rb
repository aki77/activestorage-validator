RSpec.describe ActiveRecord::Validations::BlobValidator do
  after { User.clear_validators! }

  describe 'presence: true' do
    context 'has_one_attached' do
      before do
        User.validates :file, presence: true
      end

      it { expect(User.new.valid?).to eq false }
      it { expect(User.new(file: create_file_blob(filename: 'dummy.txt')).valid?).to eq true }
    end

    context 'has_many_attached' do
      before do
        User.validates :files, presence: true
      end

      it { expect(User.new.valid?).to eq false }
      it { expect(User.new(files: [create_file_blob(filename: 'dummy.txt')]).valid?).to eq true }
    end
  end

  describe 'with size_range option' do
    before do
      User.validates :file, blob: { size_range: 1..1.megabyte }
      User.validates :files, blob: { size_range: 1..1.megabyte }
    end

    context '600KB' do
      it { expect(User.new(file: create_file_blob(filename: '600KB.jpg')).valid?).to eq true }
      it { expect(User.new(files: [create_file_blob(filename: '600KB.jpg')]).valid?).to eq true }
    end

    context '1.4MB' do
      it { expect(User.new(file: create_file_blob(filename: '1_4MB.jpg')).valid?).to eq false }
      it { expect(User.new(files: [create_file_blob(filename: '1_4MB.jpg')]).valid?).to eq false }

      it "should translate the validation error according to it's locale" do
        user = User.new(file: create_file_blob(filename: '1_4MB.jpg'))
        user.validate
        expect(user.errors.messages[:file][0]).to eq 'File size should be less than 1 MB'
      end
    end
  end

  describe 'with content_type option' do
    context 'regexp' do
      before do
        User.validates :file, blob: { content_type: /^image/ }
        User.validates :files, blob: { content_type: /^image/ }
      end

      it { expect(User.new(file: create_file_blob(filename: '600KB.jpg')).valid?).to eq true }
      it { expect(User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')).valid?).to eq false }

      it { expect(User.new(files: [create_file_blob(filename: '600KB.jpg')]).valid?).to eq true }
      it { expect(User.new(files: [create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')]).valid?).to eq false }
    end

    context 'array' do
      before do
        User.validates :file, blob: { content_type: %w[image/jpeg image/png] }
        User.validates :files, blob: { content_type: %w[image/jpeg image/png] }
      end

      it { expect(User.new(file: create_file_blob(filename: '600KB.jpg')).valid?).to eq true }
      it { expect(User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')).valid?).to eq false }

      it { expect(User.new(files: [create_file_blob(filename: '600KB.jpg')]).valid?).to eq true }
      it { expect(User.new(files: [create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')]).valid?).to eq false }
    end

    context ':web_image' do
      before do
        User.validates :file, blob: { content_type: :web_image }
      end

      it { expect(User.new(file: create_file_blob(filename: '600KB.jpg')).valid?).to eq true }
      it { expect(User.new(file: create_file_blob(filename: 'sample.tiff', content_type: 'image/tiff')).valid?).to eq false }
    end

    context 'symbol' do
      before do
        User.validates :file, blob: { content_type: :image }
        User.validates :files, blob: { content_type: :image }
      end

      it { expect(User.new(file: create_file_blob(filename: '600KB.jpg')).valid?).to eq true }
      it { expect(User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')).valid?).to eq false }

      it { expect(User.new(files: [create_file_blob(filename: '600KB.jpg')]).valid?).to eq true }
      it { expect(User.new(files: [create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')]).valid?).to eq false }
    end

    context 'string' do
      before do
        User.validates :file, blob: { content_type: 'image/jpeg' }
        User.validates :files, blob: { content_type: 'image/jpeg' }
      end

      it { expect(User.new(file: create_file_blob(filename: '600KB.jpg')).valid?).to eq true }
      it { expect(User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')).valid?).to eq false }

      it { expect(User.new(files: [create_file_blob(filename: '600KB.jpg')]).valid?).to eq true }
      it { expect(User.new(files: [create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')]).valid?).to eq false }
    end
  end

  describe 'with extension option' do
    context 'string' do
      before do
        User.validates :file, blob: { extension: 'jpg' }
        User.validates :files, blob: { extension: 'jpg' }
      end

      it { expect(User.new(file: create_file_blob(filename: '600KB.jpg')).valid?).to eq true }
      it { expect(User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')).valid?).to eq false }

      it { expect(User.new(files: [create_file_blob(filename: '600KB.jpg')]).valid?).to eq true }
      it { expect(User.new(files: [create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')]).valid?).to eq false }
    end

    context 'array' do
      before do
        User.validates :file, blob: { extension: %w[jpg png] }
        User.validates :files, blob: { extension: %w[jpg png] }
      end

      it { expect(User.new(file: create_file_blob(filename: '600KB.jpg')).valid?).to eq true }
      it { expect(User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')).valid?).to eq false }

      it { expect(User.new(files: [create_file_blob(filename: '600KB.jpg')]).valid?).to eq true }
      it { expect(User.new(files: [create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')]).valid?).to eq false }
    end

    context 'case insensitive' do
      before do
        User.validates :file, blob: { extension: 'jpg' }
      end

      it { expect(User.new(file: create_file_blob(filename: 'UPPERCASE.JPG')).valid?).to eq true }
    end

    context 'leading dot in option' do
      before do
        User.validates :file, blob: { extension: '.jpg' }
      end

      it { expect(User.new(file: create_file_blob(filename: '600KB.jpg')).valid?).to eq true }
    end

    context 'file without extension' do
      before do
        User.validates :file, blob: { extension: 'jpg' }
      end

      it { expect(User.new(file: create_file_blob(filename: 'no_extension')).valid?).to eq false }
    end

    context 'combined with content_type (AND)' do
      before do
        User.validates :file, blob: { content_type: 'image/jpeg', extension: %w[jpg jpeg] }
      end

      it 'rejects file when filename has no extension even if content_type matches' do
        user = User.new(file: create_file_blob(filename: 'no_extension'))
        expect(user.valid?).to eq false
        expect(user.errors.details[:file].map { |d| d[:error] }).to include(:extension)
      end
    end
  end

  describe 'filename parameter in validation errors' do
    context 'content_type validation' do
      before do
        User.validates :file, blob: { content_type: /^image/ }
        User.validates :files, blob: { content_type: /^image/ }
      end

      it "passes filename for has_one_attached" do
        user = User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain'))
        user.validate
        error_detail = user.errors.details[:file][0]
        expect(error_detail[:filename]).to eq('dummy.txt')
      end

      it "passes filename for has_many_attached" do
        user = User.new(files: [create_file_blob(filename: 'dummy.txt', content_type: 'text/plain')])
        user.validate
        error_detail = user.errors.details[:files][0]
        expect(error_detail[:filename]).to eq('dummy.txt')
      end
    end

    context 'extension validation' do
      before do
        User.validates :file, blob: { extension: %w[jpg png] }
      end

      it 'passes filename and allowed extensions' do
        user = User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain'))
        user.validate
        error_detail = user.errors.details[:file][0]
        expect(error_detail[:filename]).to eq('dummy.txt')
        expect(error_detail[:extension]).to eq('jpg, png')
      end

      it 'translates the validation error according to its locale' do
        user = User.new(file: create_file_blob(filename: 'dummy.txt', content_type: 'text/plain'))
        user.validate
        expect(user.errors.messages[:file][0]).to eq 'has an invalid file extension (allowed: jpg, png)'
      end
    end
  end
end
