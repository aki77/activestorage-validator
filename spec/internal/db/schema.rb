# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.timestamps null: false
  end

  create_table :active_storage_blobs do |t|
    t.string   :key,        null: false
    t.string   :filename,   null: false
    t.string   :content_type
    t.text     :metadata
    t.bigint   :byte_size,  null: false
    t.string   :checksum,   null: false
    t.datetime :created_at, null: false
    if Rails.version.to_f >= 6.1
      t.string   :service_name, null: false
    end

    t.index [ :key ], unique: true
  end

  create_table :active_storage_attachments do |t|
    t.string     :name,     null: false
    t.references :record,   null: false, polymorphic: true, index: false
    t.references :blob,     null: false

    t.datetime :created_at, null: false

    t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
    t.foreign_key :active_storage_blobs, column: :blob_id
  end

  create_table :active_storage_variant_records do |t|
    t.references :blob,     null: false
    t.string     :variation_digest, null: false

    t.index [ :blob_id, :variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end
end
