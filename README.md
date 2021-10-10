[![Gem Version](https://badge.fury.io/rb/activestorage-validator.svg)](https://rubygems.org/gems/activestorage-validator)
[![Build](https://github.com/aki77/activestorage-validator/workflows/Build/badge.svg)](https://github.com/aki77/activestorage-validator/actions)

# ActiveStorage Validator

ActiveStorage blob validator.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activestorage-validator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activestorage-validator

## Usage

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
  has_many_attached :photos

  validates :avatar, presence: true, blob: { content_type: :image } # supported options: :image, :audio, :video, :text
  validates :photos, presence: true, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 1..5.megabytes }
  # validates :photos, presence: true, blob: { content_type: %r{^image/}, size_range: 1..5.megabytes }
end
```
Note: For `has_many_attached`, size is validated on each file individually. In the code above, `:photos` validation allows any number of photos to be upload, each one being 5 MB or less in size.

When declaring `size_range`, you might want to assign the values of the ranges into variables for passing rubocop linters, to create [an unambiguous range](https://github.com/rubocop/rubocop/blob/master/lib/rubocop/cop/lint/ambiguous_range.rb).

```ruby
class User < ApplicationRecord
  has_many_attached :photos
  
  @min_size = 1.megabytes
  @max_size = 5.megabytes
  
  validates :photos, presence: true, blob: {
    content_type: ['image/png', 'image/jpg', 'image/jpeg'],
    size_range: @min_size..@max_size
  }
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aki77/activestorage-validator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
