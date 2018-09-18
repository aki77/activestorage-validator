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
end

