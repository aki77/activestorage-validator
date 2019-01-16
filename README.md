# ActiveStorage Validator

ActiveStorage blob validator.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activestorage-validator', '~> 0.1.1'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activestorage-validator -v '~> 0.1.1'

## Internationalizacion (I18n)

There's no need to make any additional configuration into your Rails application to make the translations work. It's enough to configure `I18n.default_locale` or `I18n.available_locales` in your application. The following translation files are available at this moment:

```ruby
[en, es, es-NI]
```

**If your desired locale is not included yet**, you can temporally create a translation file `*.yml` inside your application's locales folder `app/config/locales/`. The locale structure goes like this:

```ruby
en:
  activerecord:
    errors:
      messages:
        content_type:   "is not a valid file format"
        max_size_error: "is not within valid size range"
        # ...and so on...
```

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aki77/activestorage-validator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

**CONTRIBUTORS:** Please feel free to add additional translation files into `app/config/locales` gem folder

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
