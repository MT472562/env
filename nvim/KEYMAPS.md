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

## メモ・Markdown

| キー | 動作 |
|------|------|
| `Ctrl-p` / `Space mp` | ブラウザプレビュー |
| `Space mr` | エディタ内レンダー切替 |
| `Space tz` | Zen モード（集中執筆） |
| `Space uw` | wrap 切替 |
| `Space us` | スペルチェック切替 |

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
