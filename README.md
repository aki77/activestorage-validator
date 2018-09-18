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

  validates :avatar, precence: true, blob: { content_type: :image }
  validates :photos, precence: true, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 1..5.megabytes }
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aki77/activestorage-validator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
