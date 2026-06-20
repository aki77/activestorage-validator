---
name: activestorage-validator
description: "Validate ActiveStorage attachments (content type, file size, file extension) with the activestorage-validator gem's `blob` validator. Use when adding validations to has_one_attached / has_many_attached attributes."
---

# activestorage-validator

A Rails gem that adds a `blob` validator for ActiveStorage attachments. It
validates content type, file size, and file extension on both
`has_one_attached` and `has_many_attached` attributes.

## First: determine applicability

Use this gem **only** for validating ActiveStorage attachments. For ordinary
(non-attachment) attributes, use the standard Rails validators (`presence`,
`length`, `numericality`, etc.).

| What you validate | Tool |
| --- | --- |
| ActiveStorage attachment (content type / size / extension) | **`blob:` validator (this gem)** |
| Plain string/number/boolean columns | Standard Rails validators |
| Presence of the attachment itself | `presence: true` (works alongside `blob:`) |

There is no special read path — declare `validates ..., blob: { ... }` and the
attachment is validated like any other Rails validation on `save`/`valid?`.

## Usage

Declare validations on the model with the `blob:` validator.

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
  has_many_attached :photos

  # Allow only web image files (PNG, JPEG, GIF, WebP)
  validates :avatar, presence: true, blob: { content_type: :web_image }

  # Allow only JPEG/PNG, up to 5MB per file
  validates :photos, presence: true, blob: {
    content_type: ["image/png", "image/jpg", "image/jpeg"],
    size_range: 1..(5.megabytes)
  }

  # Regexp content_type + required extension (AND condition)
  validates :audio, blob: { content_type: "audio/mpeg", extension: %w[mp3] }
end
```

> For `has_many_attached`, every option (including `size_range`) is applied to
> **each file individually**.

## Options (all optional, combine freely)

| Option | Accepts | Notes |
| --- | --- | --- |
| `content_type` | Symbol / Array / Regexp / String / Proc | Allowed MIME type(s). See matching below. |
| `size_range` | Range / Proc | Allowed byte size, e.g. `1..(5.megabytes)`. |
| `extension` | String / Array / Proc | Allowed filename extension(s). |

Any option also accepts a **Proc/lambda** returning a value of the listed type,
resolved with the same arity convention as Rails' built-in validators (`if:` /
`unless:`): `-> { ... }` is called as-is, `->(record) { ... }` receives the
record. For `has_many_attached` the Proc is evaluated once per record. Example:
`content_type: ->(record) { record.premium? ? %w[image/png] : :web_image }`.

### `content_type` matching

- **`:web_image`** — special-cased to `ActiveStorage.web_image_content_types`
  (PNG, JPEG, GIF, WebP). Use this instead of `:image` when you want only
  browser-safe images.
- **Other Symbol** (`:image`, `:audio`, `:video`, `:text`) — calls the
  ActiveStorage built-in predicate `blob.image?` / `blob.audio?` / etc.
- **Array** — `["image/png", "image/jpeg"]`: exact membership of the blob's
  content type in the list.
- **Regexp** — `%r{^image/}`: matched against the blob's content type.
- **String** — `"application/pdf"`: exact equality.

### `extension` matching

- Accepts a String (`"mp3"`) or Array (`%w[mp3 m4a]`).
- Leading dot is optional (`"mp3"` == `".mp3"`).
- Case-insensitive (`PHOTO.JPG` matches `extension: "jpg"`).
- **A file with no extension is always rejected** when `extension` is set.
- When combined with `content_type`, both must pass (AND). E.g.
  `{ content_type: "audio/mpeg", extension: %w[mp3] }` rejects a `.wav` file
  even if its MIME type happens to be `audio/mpeg`.

## I18n error messages

Errors are I18n-compatible. Error types and their interpolation keys:

| Error type | Interpolation keys | When |
| --- | --- | --- |
| `content_type` | `filename` | content type not allowed |
| `min_size_error` | `filename`, `min_size` | smaller than `size_range.min` |
| `max_size_error` | `filename`, `max_size` | larger than `size_range.max` |
| `extension` | `filename`, `extension` | extension not allowed (or missing) |

`min_size` / `max_size` are humanized (`ActiveSupport::NumberHelper.number_to_human_size`).
`extension` is the allowed list joined by `, `.

```yaml
# config/locales/en.yml
en:
  errors:
    messages:
      content_type: "%{filename} has an invalid content type"
      min_size_error: "%{filename} is too small (minimum is %{min_size})"
      max_size_error: "%{filename} is too large (maximum is %{max_size})"
      extension: "%{filename} has an invalid file extension (allowed: %{extension})"
```

The gem ships default messages for 7 locales: `en`, `ja`, `de`, `es`, `fr`,
`pl`, `pt-br`. Override them in your app's locale files using the keys above.

## Behavior details

- **Unattached values are skipped.** Validation returns early unless the
  attachment is attached, so `blob:` does not enforce presence — add
  `presence: true` separately if the attachment is required.
- **Size boundaries are inclusive.** A blob is valid when
  `size_range.min <= byte_size <= size_range.max`. Below min → `min_size_error`;
  above max → `max_size_error`.
- **Extension normalization** is `downcase` + strip a single leading dot; an
  empty resulting extension (no extension on the file) fails.
- Options are independent — omit any you don't need; only the present ones run.

## Pitfalls

- A file **without an extension** is rejected whenever `extension:` is set —
  even if its content type is allowed. Don't set `extension:` if you accept
  extension-less uploads.
- For `has_many_attached`, `size_range` applies **per file**, not to the total.
- `blob:` alone does **not** require an attachment; pair it with `presence: true`
  when the upload is mandatory.
- No special read/preload path exists — this is a plain `EachValidator`; it runs
  on standard `valid?` / `save`.
