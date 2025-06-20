[![Gem Version](https://badge.fury.io/rb/activestorage-validator.svg)](https://rubygems.org/gems/activestorage-validator)
[![Build](https://github.com/aki77/activestorage-validator/workflows/Build/badge.svg)](https://github.com/aki77/activestorage-validator/actions)

# ActiveStorage Validator

A Rails gem that makes it easy to add validations such as `content_type` and file size to ActiveStorage attachments.

- Supports both `has_one_attached` and `has_many_attached` of ActiveStorage
- Flexible validations for content type and file size

## Installation

### Using Bundler

Add this line to your application's Gemfile:

```ruby
gem 'activestorage-validator'
```

Then execute:

    $ bundle install

### Install with gem command

    $ gem install activestorage-validator

## Usage

You can add validations to models with ActiveStorage attachments using the `blob` validator.

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
  has_many_attached :photos

  # Allow only web image files
  validates :avatar, presence: true, blob: { content_type: :web_image }

  # Allow only JPEG/PNG, up to 5MB per file
  validates :photos, presence: true, blob: { content_type: ["image/png", "image/jpg", "image/jpeg"], size_range: 1..(5.megabytes) }

  # You can also use a regular expression for content_type
  # validates :photos, blob: { content_type: %r{^image/}, size_range: 1..(5.megabytes) }
end
```

> **Note:** For `has_many_attached`, the size validation is applied to each file individually.

## Validation Options

| Option        | Description                                                                                 |
|--------------|---------------------------------------------------------------------------------------------|
| content_type | Allowed MIME types. Accepts a symbol (`:web_image`, `:image`, `:audio`, `:video`, `:text`), an array of MIME types, a regular expression, or a string (single MIME type). |
| size_range   | Allowed file size range (e.g. `1..5.megabytes`)                                             |

### content_type Examples

- **Symbol**
  - `:web_image` ... PNG, JPEG, GIF, WebP (special handling)
  - `:image`, `:audio`, `:video`, `:text` ... Calls `blob.image?`, `blob.audio?`, etc. (ActiveStorage built-in predicate)
- **Array**
  - `["image/png", "image/jpg", "image/jpeg"]` ... Only allow these MIME types
- **Regexp**
  - `%r{^image/}` ... Allow any image type (MIME type starts with `image/`)
- **String**
  - `"application/pdf"` ... Only allow PDF files

## I18n Error Message Options

Validation error messages are I18n compatible. The following interpolation keys are available in your translation files, according to the validator's implementation:

| Key            | Description                                 |
|----------------|---------------------------------------------|
| filename       | The uploaded file's name                    |
| min_size       | The minimum allowed file size (humanized)   |
| max_size       | The maximum allowed file size (humanized)   |

The following error types are used:

- `content_type` (invalid content type)
- `min_size_error` (file is too small)
- `max_size_error` (file is too large)

Example (config/locales/en.yml):

```yaml
en:
  errors:
    messages:
      content_type: "%{filename} has an invalid content type"
      min_size_error: "%{filename} is too small (minimum is %{min_size})"
      max_size_error: "%{filename} is too large (maximum is %{max_size})"
```

## Notes

- Some features may not work depending on your ActiveStorage or Rails version.
- Validation error messages are I18n compatible and support interpolation keys as described above.

## Contributing

Bug reports and pull requests are welcome on GitHub via [issues](https://github.com/aki77/activestorage-validator/issues) or [pull requests](https://github.com/aki77/activestorage-validator/pulls).

This project adheres to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

This gem is released under the MIT License. See [LICENSE.txt](LICENSE.txt) for details.
