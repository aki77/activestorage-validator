class User < ActiveRecord::Base
  has_one_attached :file
  has_many_attached :files
end
