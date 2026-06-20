---
name: activestorage-validator
description: "activestorage-validator gem の `blob` バリデータで ActiveStorage 添付ファイル（content type・サイズ・拡張子）を検証する。has_one_attached / has_many_attached 属性にバリデーションを追加するときに使う。"
---

# activestorage-validator

ActiveStorage 添付ファイル用の `blob` バリデータを追加する Rails gem。`has_one_attached` /
`has_many_attached` の両方に対して、content type・ファイルサイズ・拡張子を検証する。

## まず適用可否を判断する

この gem は **ActiveStorage の添付ファイル検証専用**。添付以外の通常属性は標準の Rails
バリデータ（`presence` / `length` / `numericality` など）を使うこと。

| 検証対象 | 使うもの |
| --- | --- |
| ActiveStorage 添付（content type / サイズ / 拡張子） | **`blob:` バリデータ（この gem）** |
| 通常の文字列/数値/真偽値カラム | 標準の Rails バリデータ |
| 添付そのものの存在 | `presence: true`（`blob:` と併用可） |

特別な読み取りパスは不要。`validates ..., blob: { ... }` を宣言すれば、他の Rails
バリデーションと同様に `save` / `valid?` 時に添付が検証される。

## 使い方

モデルに `blob:` バリデータを宣言する。

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
  has_many_attached :photos

  # web 画像（PNG, JPEG, GIF, WebP）のみ許可
  validates :avatar, presence: true, blob: { content_type: :web_image }

  # JPEG/PNG のみ・1 ファイル 5MB まで
  validates :photos, presence: true, blob: {
    content_type: ["image/png", "image/jpg", "image/jpeg"],
    size_range: 1..(5.megabytes)
  }

  # Regexp content_type ＋ 拡張子必須（AND 条件）
  validates :audio, blob: { content_type: "audio/mpeg", extension: %w[mp3] }
end
```

> `has_many_attached` では、すべてのオプション（`size_range` を含む）が **各ファイルごとに**
> 適用される。

## オプション（すべて任意・自由に組み合わせ可）

| オプション | 受け付ける型 | 備考 |
| --- | --- | --- |
| `content_type` | Symbol / Array / Regexp / String | 許可する MIME タイプ。マッチ方法は下記。 |
| `size_range` | Range | 許可するバイトサイズ。例 `1..(5.megabytes)`。 |
| `extension` | String / Array | 許可するファイル拡張子。 |

### `content_type` のマッチ

- **`:web_image`** — `ActiveStorage.web_image_content_types`（PNG, JPEG, GIF, WebP）に
  特別対応。ブラウザで安全に表示できる画像のみを許可したいときは `:image` でなくこちらを使う。
- **その他の Symbol**（`:image` / `:audio` / `:video` / `:text`）— ActiveStorage 組み込み述語
  `blob.image?` / `blob.audio?` 等を呼ぶ。
- **Array** — `["image/png", "image/jpeg"]`: blob の content type がリストに含まれるか。
- **Regexp** — `%r{^image/}`: blob の content type にマッチさせる。
- **String** — `"application/pdf"`: 完全一致。

### `extension` のマッチ

- String（`"mp3"`）または Array（`%w[mp3 m4a]`）。
- 先頭ドットは任意（`"mp3"` と `".mp3"` は同じ）。
- 大文字小文字を区別しない（`PHOTO.JPG` は `extension: "jpg"` にマッチ）。
- `extension` 指定時、**拡張子のないファイルは常に reject** される。
- `content_type` と併用すると両方を満たす必要がある（AND）。例えば
  `{ content_type: "audio/mpeg", extension: %w[mp3] }` は、MIME タイプが `audio/mpeg` でも
  `.wav` ファイルを reject する。

## I18n エラーメッセージ

エラーは I18n 対応。エラータイプと補間キー:

| エラータイプ | 補間キー | 発生条件 |
| --- | --- | --- |
| `content_type` | `filename` | content type が許可外 |
| `min_size_error` | `filename`, `min_size` | `size_range.min` より小さい |
| `max_size_error` | `filename`, `max_size` | `size_range.max` より大きい |
| `extension` | `filename`, `extension` | 拡張子が許可外（または無し） |

`min_size` / `max_size` は humanize される（`ActiveSupport::NumberHelper.number_to_human_size`）。
`extension` は許可拡張子を `, ` で連結した文字列。

```yaml
# config/locales/ja.yml
ja:
  errors:
    messages:
      content_type: "%{filename}のコンテンツタイプが正しくありません"
      min_size_error: "%{filename}が小さすぎます（最小%{min_size}）"
      max_size_error: "%{filename}が大きすぎます（最大%{max_size}）"
      extension: "%{filename}の拡張子が正しくありません（許可: %{extension}）"
```

この gem は 7 言語のデフォルトメッセージを同梱している: `en`, `ja`, `de`, `es`, `fr`,
`pl`, `pt-br`。上記キーを使ってアプリ側の locale ファイルで上書きできる。

## 実装由来の挙動

- **未添付の値はスキップ。** 添付されていない場合は早期 return するため、`blob:` は存在を
  強制しない。必須なら `presence: true` を別途付ける。
- **サイズ境界は両端を含む。** `size_range.min <= byte_size <= size_range.max` で有効。
  min 未満 → `min_size_error`、max 超過 → `max_size_error`。
- **拡張子の正規化** は `downcase` ＋ 先頭ドット 1 個の除去。正規化後が空（拡張子なし）なら fail。
- 各オプションは独立。不要なものは省略でき、指定したものだけが実行される。

## 落とし穴

- `extension:` を指定すると、**拡張子のないファイル**は content type が許可されていても reject
  される。拡張子なしアップロードを受け付けたい場合は `extension:` を設定しないこと。
- `has_many_attached` では `size_range` は合計でなく **ファイルごと**に適用される。
- `blob:` 単体では添付を必須にしない。必須にするなら `presence: true` を併用する。
- 特別な読み取り/プリロードのパスは無い。これは普通の `EachValidator` で、標準の `valid?` /
  `save` 時に実行される。
