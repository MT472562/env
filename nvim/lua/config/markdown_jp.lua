-- ============================================================================
-- WSL + Windows IME 向け Markdown 補助
--   方針: 記号（# * -）は「打たない」。Normal の Space m* かスニペットで入れる。
--   OS IME はそのまま日本語入力に使い、nvim 内 IME は使わない。
-- ============================================================================

local M = {}

local function current_line()
  return vim.api.nvim_get_current_line()
end

local function set_current_line(s)
  vim.api.nvim_set_current_line(s)
end

--- 行頭（インデント後）に prefix を付ける。既存の見出し記号は剥がす。
local function set_line_prefix(prefix, strip_heading)
  local line = current_line()
  local indent = line:match("^(%s*)") or ""
  local body = line:sub(#indent + 1)
  if strip_heading then
    body = body:gsub("^#+%s*", "")
  end
  -- 同じプレフィックスが既にあるなら何もしない（トグルで外す）
  local bare = prefix:gsub("%s+$", "")
  if bare ~= "" and body:sub(1, #bare) == bare then
    local rest = body:sub(#bare + 1):gsub("^%s*", "")
    set_current_line(indent .. rest)
    return
  end
  -- リスト系の付け替え
  if prefix:match("^[-*+]%s") or prefix:match("^%d+%.%s") or prefix == "- [ ] " or prefix == "- [x] " then
    body = body:gsub("^[-*+]%s+%[[ xX]%]%s*", ""):gsub("^[-*+]%s+", ""):gsub("^%d+%.%s+", "")
  end
  set_current_line(indent .. prefix .. body)
  -- カーソルを行末へ
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_win_set_cursor(0, { row, #indent + #prefix + #body })
end

--- 選択範囲 or カーソル単語を left/right で囲む
local function wrap_selection(left, right)
  right = right or left
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    -- visual
    vim.cmd("normal! \27") -- esc to keep marks
    local s = vim.fn.getpos("'<")
    local e = vim.fn.getpos("'>")
    local srow, scol = s[2], s[3]
    local erow, ecol = e[2], e[3]
    if srow ~= erow then
      -- 複数行は各行の非空白を囲むのは重いので先頭末尾だけ
      vim.notify("1行選択で使ってね", vim.log.levels.INFO)
      return
    end
    local line = vim.fn.getline(srow)
    -- ecol can be past end in visual line
    ecol = math.min(ecol, #line)
    if scol > ecol then
      scol, ecol = ecol, scol
    end
    local before = line:sub(1, scol - 1)
    local mid = line:sub(scol, ecol)
    local after = line:sub(ecol + 1)
    -- 既に同じで囲まれていれば外す
    if mid:sub(1, #left) == left and mid:sub(-#right) == right and #mid > #left + #right then
      mid = mid:sub(#left + 1, #mid - #right)
      vim.fn.setline(srow, before .. mid .. after)
      return
    end
    vim.fn.setline(srow, before .. left .. mid .. right .. after)
  else
    -- normal: カーソル下の word
    local word = vim.fn.expand("<cword>")
    if word == "" then
      -- 空なら left/right を挿入して Insert
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = current_line()
      local before = line:sub(1, col)
      local after = line:sub(col + 1)
      set_current_line(before .. left .. right .. after)
      vim.api.nvim_win_set_cursor(0, { row, col + #left })
      vim.cmd("startinsert")
      return
    end
    -- cword を置換
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = current_line()
    -- 簡易: <cword> の位置を検索
    local ccol = col + 1 -- 1-based for string
    local start_col = ccol
    while start_col > 1 and line:sub(start_col - 1, start_col - 1):match("[%w_]") do
      start_col = start_col - 1
    end
    local end_col = start_col + #word - 1
    local before = line:sub(1, start_col - 1)
    local mid = line:sub(start_col, end_col)
    local after = line:sub(end_col + 1)
    if mid:sub(1, #left) == left and mid:sub(-#right) == right then
      mid = mid:sub(#left + 1, #mid - #right)
      set_current_line(before .. mid .. after)
    else
      set_current_line(before .. left .. mid .. right .. after)
    end
  end
end

function M.setup_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
  end

  -- 構造は Normal で入れる（IME を触らない）
  map("n", "<leader>m1", function()
    set_line_prefix("# ", true)
  end, "MD: 見出し1")
  map("n", "<leader>m2", function()
    set_line_prefix("## ", true)
  end, "MD: 見出し2")
  map("n", "<leader>m3", function()
    set_line_prefix("### ", true)
  end, "MD: 見出し3")
  map("n", "<leader>m4", function()
    set_line_prefix("#### ", true)
  end, "MD: 見出し4")
  map("n", "<leader>ml", function()
    set_line_prefix("- ", false)
  end, "MD: リスト")
  map("n", "<leader>mo", function()
    set_line_prefix("1. ", false)
  end, "MD: 番号リスト")
  map("n", "<leader>mk", function()
    set_line_prefix("- [ ] ", false)
  end, "MD: チェックボックス")
  map("n", "<leader>mq", function()
    set_line_prefix("> ", false)
  end, "MD: 引用")
  map("n", "<leader>mc", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(0, row, row, false, { "```", "", "```" })
    vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
    vim.cmd("startinsert")
  end, "MD: コードブロック")

  -- 装飾（選択 or 単語）。* を打たない
  map({ "n", "v" }, "<leader>mb", function()
    wrap_selection("**", "**")
  end, "MD: 太字")
  map({ "n", "v" }, "<leader>mi", function()
    wrap_selection("*", "*")
  end, "MD: 斜体")
  map({ "n", "v" }, "<leader>m`", function()
    wrap_selection("`", "`")
  end, "MD: インラインコード")
  map({ "n", "v" }, "<leader>ms", function()
    wrap_selection("~~", "~~")
  end, "MD: 打ち消し")

  -- リンク: [text](url)
  map({ "n", "v" }, "<leader>mL", function()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" then
      vim.cmd("normal! \27")
      local s = vim.fn.getpos("'<")
      local e = vim.fn.getpos("'>")
      local line = vim.fn.getline(s[2])
      local scol, ecol = s[3], math.min(e[3], #line)
      local before = line:sub(1, scol - 1)
      local mid = line:sub(scol, ecol)
      local after = line:sub(ecol + 1)
      vim.fn.setline(s[2], before .. "[" .. mid .. "]()" .. after)
      vim.api.nvim_win_set_cursor(0, { s[2], #before + #mid + 3 })
      vim.cmd("startinsert")
    else
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = current_line()
      local before = line:sub(1, col)
      local after = line:sub(col + 1)
      set_current_line(before .. "[]()" .. after)
      vim.api.nvim_win_set_cursor(0, { row, col + 1 })
      vim.cmd("startinsert")
    end
  end, "MD: リンク")

  -- 全角で打った記号を半角 MD に（IME のまま打ってもマシに）
  vim.cmd([[
    iabbrev <buffer> ＃ #
    iabbrev <buffer> ＊ *
    iabbrev <buffer> 〜 ~
    iabbrev <buffer> ｀ `
  ]])
end

--- LuaSnip: 半角トリガ（IME オフ時）＋ ひらがな確定後でも使える短いもの
function M.setup_snippets()
  local ok, ls = pcall(require, "luasnip")
  if not ok then
    return
  end
  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node
  local f = ls.function_node

  ls.add_snippets("markdown", {
    s("h1", { t("# "), i(1, "見出し") }),
    s("h2", { t("## "), i(1, "見出し") }),
    s("h3", { t("### "), i(1, "見出し") }),
    s("li", { t("- "), i(1) }),
    s("cb", { t("- [ ] "), i(1) }),
    s("link", { t("["), i(1, "表示"), t("]("), i(2, "url"), t(")") }),
    s("code", { t("```"), i(1, "lang"), t({ "", "" }), i(2), t({ "", "```" }) }),
    s("b", { t("**"), i(1), t("**") }),
    -- 日本語で変換確定したあとに使える（「み1」「み2」）
    s("み1", { t("# "), i(1, "見出し") }),
    s("み2", { t("## "), i(1, "見出し") }),
    s("み3", { t("### "), i(1, "見出し") }),
    s("りすと", { t("- "), i(1) }),
    s("ちぇっく", { t("- [ ] "), i(1) }),
  }, { key = "markdown-jp" })
end

return M
