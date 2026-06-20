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

  # Require the filename to have one of the allowed extensions
  # validates :audio, blob: { content_type: "audio/mpeg", extension: %w[mp3] }
end
```

> **Note:** For `has_many_attached`, the size validation is applied to each file individually.

## Validation Options

| Option        | Description                                                                                 |
|--------------|---------------------------------------------------------------------------------------------|
| content_type | Allowed MIME types. Accepts a symbol (`:web_image`, `:image`, `:audio`, `:video`, `:text`), an array of MIME types, a regular expression, or a string (single MIME type). Or a Proc/lambda returning one of the above. |
| size_range   | Allowed file size range (e.g. `1..5.megabytes`). Or a Proc/lambda returning a Range.        |
| extension    | Allowed file extensions. Accepts a String or an Array of Strings. Case-insensitive, leading dot optional. Files without an extension are rejected. Or a Proc/lambda returning one of the above. |

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

### extension Examples

- **String**
  - `extension: "mp3"` ... Only allow `.mp3` files
- **Array**
  - `extension: %w[mp3 m4a]` ... Allow either `.mp3` or `.m4a`
- **Combined with content_type (AND)**
  - `blob: { content_type: "audio/mpeg", extension: %w[mp3] }` ... Reject both `my_podcast` (no extension) and `my_podcast.wav` (wrong extension), even when their MIME types match.

The leading dot is optional (`"mp3"` and `".mp3"` behave the same), and matching is case-insensitive (`PHOTO.JPG` matches `extension: "jpg"`).

## Dynamic Options (Proc/lambda)

Every option (`content_type`, `size_range`, `extension`) also accepts a Proc/lambda,
so you can decide the allowed values per record at validation time:

```ruby
validates :avatar, blob: {
  content_type: ->(record) { record.premium? ? %w[image/png image/jpeg] : :web_image },
  size_range:   ->(record) { 1..(record.premium? ? 20.megabytes : 5.megabytes) }
}
```

The Proc is resolved with the same arity convention as Rails' built-in validators
(the same rule used by `if:` / `unless:`):

- **No argument** (`-> { ... }`) — called as-is.
- **One argument** (`->(record) { ... }`) — the record is passed in.

The Proc must return a value of one of the types the option already accepts
(a Symbol/Array/Regexp/String for `content_type`, a Range for `size_range`, a
String/Array for `extension`). For `has_many_attached`, the Proc is evaluated
once per record (not per attached file).

## I18n Error Message Options

Validation error messages are I18n compatible. The following interpolation keys are available in your translation files, according to the validator's implementation:

| Key            | Description                                 |
|----------------|---------------------------------------------|
| filename       | The uploaded file's name                    |
| min_size       | The minimum allowed file size (humanized)   |
| max_size       | The maximum allowed file size (humanized)   |
| extension      | The list of allowed extensions, joined by `, ` |

The following error types are used:

- `content_type` (invalid content type)
- `min_size_error` (file is too small)
- `max_size_error` (file is too large)
- `extension` (invalid file extension)

Example (config/locales/en.yml):

```yaml
en:
  errors:
    messages:
      content_type: "%{filename} has an invalid content type"
      min_size_error: "%{filename} is too small (minimum is %{min_size})"
      max_size_error: "%{filename} is too large (maximum is %{max_size})"
      extension: "%{filename} has an invalid file extension (allowed: %{extension})"
```

## Notes

- Some features may not work depending on your ActiveStorage or Rails version.
- Validation error messages are I18n compatible and support interpolation keys as described above.

## Agent skill

This repo ships an [agent skill](skills/activestorage-validator/) (`SKILL.md`,
plus a Japanese `SKILL-ja.md`) that teaches coding agents when and how to apply
`activestorage-validator`. Install it into your project with the GitHub CLI:

```sh
gh skill install aki77/activestorage-validator
```

> `gh skill` is currently a GitHub CLI preview feature.

Alternatively, if your project already pulls `activestorage-validator` in via
Bundler, the [bundler-skills](https://github.com/aki77/bundler-skills) plugin
auto-syncs this skill on `bundle install` — keeping the skill version locked to
the gem version.

## Contributing

Bug reports and pull requests are welcome on GitHub via [issues](https://github.com/aki77/activestorage-validator/issues) or [pull requests](https://github.com/aki77/activestorage-validator/pulls).

This project adheres to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

This gem is released under the MIT License. See [LICENSE.txt](LICENSE.txt) for details.
