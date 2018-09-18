module BlobHelper
  def create_file_blob(filename:, content_type: "image/jpeg", metadata: nil)
    ActiveStorage::Blob.create_after_upload! io: file_fixture(filename).open, filename: filename, content_type: content_type, metadata: metadata
  end

  private

  def file_fixture(fixture_name)
    file_fixture_path = File.expand_path("../fixtures/files", __dir__)
    path = Pathname.new(File.join(file_fixture_path, fixture_name))

    if path.exist?
      path
    else
      msg = "the directory '%s' does not contain a file named '%s'"
      raise ArgumentError, msg % [file_fixture_path, fixture_name]
    end
  end
end
