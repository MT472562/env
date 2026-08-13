# NeoVim キーマップ早見表

Leader = **Space**

## ファイル・検索

| キー | 動作 |
|------|------|
| `Ctrl-n` | ファイルツリー開閉 |
| `Space fe` | ツリーで現在ファイルを表示 |
| `Space ff` | ファイル検索 |
| `Space fg` | 全文検索 (grep) |
| `Space fb` | バッファ一覧 |
| `Space fr` | 最近開いたファイル |
| `Space /` | バッファ内検索 |
| `Space fw` | カーソル下の単語を検索 |

## 編集

| キー | 動作 |
|------|------|
| `jj` | Insert 脱出 |
| `Ctrl-s` / `Space w` | 保存 |
| `gcc` | 行コメント |
| `gc` (visual) | 選択範囲コメント |
| `ys` / `ds` / `cs` | 囲み文字追加/削除/変更 (surround) |
| `Alt-j` / `Alt-k` | 行を上下に移動 |
| `Space cf` | フォーマット |
| 保存時 | 自動フォーマット |

## LSP（プログラム）

| キー | 動作 |
|------|------|
| `gd` | 定義へジャンプ |
| `gr` | 参照一覧 |
| `gi` | 実装へ |
| `gy` | 型定義へ |
| `K` | ホバー（ドキュメント） |
| `Space rn` | リネーム |
| `Space ac` / `Space .` | コードアクション |
| `[g` / `]g` | 前後の診断 |
| `Space e` | 行の診断を表示 |
| `Space xx` | 診断一覧 (Trouble) |

## Git

| キー | 動作 |
|------|------|
| `]h` / `[h` | 前後の hunk |
| `Space gh` | hunk プレビュー |
| `Space gb` | blame |
| `Space gs` | git status |

## メモ・Markdown（WSL + Windows IME 向け）

**方針:** OS の IME で日本語を書く。`#` `*` `-` は **打たない** → `Space m…` で入れる。
（nvim 内 SKK は使わない。WSL では OS IME が本体。）

執筆時は生の Markdown。保存時 prettier は走らない（`Space cf` で手動）。

### 構造・装飾（Normal / Visual）— IME のまま Esc してから

| キー | 動作 |
|------|------|
| `Space m1`〜`m4` | 見出し `#`〜`####`（もう一度で解除） |
| `Space ml` | `- ` リスト |
| `Space mo` | `1. ` 番号リスト |
| `Space mk` | `- [ ] ` チェック |
| `Space mq` | `> ` 引用 |
| `Space mc` | コードブロック |
| `Space mb` | **太字**（選択 or 単語） |
| `Space mi` | *斜体* |
| `Space m`` | `インラインコード` |
| `Space ms` | ~~打ち消し~~ |
| `Space mL` | `[text](url)` リンク |
| `Ctrl-p` / `Space mp` | ブラウザプレビュー |
| `Space mr` | エディタ内レンダー |
| `Space cf` | prettier 手動 |
| `Space tz` | Zen モード |

### スニペット（Insert・Tab 展開）

| 入力 | 結果 |
|------|------|
| `h1` / `み1` | `# ` |
| `h2` / `み2` | `## ` |
| `li` / `りすと` | `- ` |
| `b` | `**…**` |
| `link` | `[表示](url)` |

### 全角 → 半角（Insert 中の iabbrev）

`＃`→`#`　`＊`→`*`　`｀`→`` ` ``

### 型の例

1. `Esc`（Normal）→ `Space m1` → 見出し記号が入る
2. `i` → Windows IME で本文を日本語入力
3. リストは `Esc` → `Space ml` → また `i` で本文
4. 太字にしたい単語を Visual 選択 → `Space mb`

## ウィンドウ・バッファ・ターミナル

| キー | 動作 |
|------|------|
| `Ctrl-h/j/k/l` | **全モードでカーソル移動**（h/j/k/l と同じ） |
| `Ctrl-w` + `h/j/k/l` | ウィンドウ移動 |
| `Alt-h` / `Alt-l` | ウィンドウ左右（Normal） |
| `]b` / `[b` | 次/前バッファ |
| `Space bn` / `bp` | 次/前バッファ |
| `Space bd` | バッファ閉じる |
| `Ctrl-\` / `Space tt` | フローティングターミナル |
| `Esc Esc` (terminal) | ノーマルモードへ |
| 補完中 `Tab` / `C-n` / `C-p` | 候補の次/前 |

## その他

| キー | 動作 |
|------|------|
| `Space` (単押し) | which-key で候補表示 |
| `]f` / `[f` | 次/前の関数 (Treesitter) |
| `af` / `if` | 関数外側/内側を選択 (visual) |
| `:Mason` | 言語サーバー管理 |
| `:Lazy` | プラグイン管理 |
