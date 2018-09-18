require "rails"
require "active_job/railtie"
require "active_record"
require "active_storage/engine"

module Dummy
  class Application < Rails::Application
    config.secret_key_base = 'abcdefghijklmnopqrstuvwxyz0123456789'
    config.eager_load = false
    config.load_defaults 5.2
    config.root = __dir__
    config.active_storage.service = :local
  end
end

Dummy::Application.initialize!

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

require "tmpdir"
ActiveStorage::Blob.service = ActiveStorage::Service::DiskService.new(root: Dir.mktmpdir("active_storage_tests"))
ActiveStorage.logger = ActiveSupport::Logger.new(nil)
ActiveStorage.verifier = ActiveSupport::MessageVerifier.new("Testing")

#
# Migrates
#

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.timestamps null: false
    end
  end
end

class CreateActiveStorageTables < ActiveRecord::Migration[5.2]
  def change
    create_table :active_storage_blobs do |t|
      t.string   :key,        null: false
      t.string   :filename,   null: false
      t.string   :content_type
      t.text     :metadata
      t.bigint   :byte_size,  null: false
      t.string   :checksum,   null: false
      t.datetime :created_at, null: false

      t.index [ :key ], unique: true
    end

    create_table :active_storage_attachments do |t|
      t.string     :name,     null: false
      t.references :record,   null: false, polymorphic: true, index: false
      t.references :blob,     null: false

      t.datetime :created_at, null: false

      t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
    end
  end
end

CreateUsers.new.change
CreateActiveStorageTables.new.change

class User < ActiveRecord::Base
  has_one_attached :file
  has_many_attached :files
end
