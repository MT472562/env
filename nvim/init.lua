-- ============================================================================
-- Neovim Configuration File (Lua 完全移植版)
-- ============================================================================

-- ============================================================================
-- 1. 基本設定 (Options)
-- ============================================================================
vim.cmd("syntax on")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.background = "dark"
vim.opt.termguicolors = true

-- インデント
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- 検索
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- パフォーマンス / その他
vim.opt.laststatus = 3 -- グローバルステータスライン（Neovim特有の快適機能）
vim.opt.updatetime = 100 -- エラー検知の追従性を最速(100ms)に
vim.opt.clipboard = "unnamedplus"

-- マウス有効化（行番号コピー問題の解決用）
vim.opt.mouse = "a"


-- ============================================================================
-- 2. キーバインド (Keymaps)
-- ============================================================================
vim.g.mapleader = " " -- Leaderキーをスペースに設定

-- 基本操作
vim.keymap.set("i", "jj", "<Esc>")

-- Insert mode cursor移動 (Ctrl / Alt + hjkl)
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-j>", "<Down>")
vim.keymap.set("i", "<C-k>", "<Up>")
vim.keymap.set("i", "<C-l>", "<Right>")
vim.keymap.set("i", "<A-h>", "<Left>")
vim.keymap.set("i", "<A-j>", "<Down>")
vim.keymap.set("i", "<A-k>", "<Up>")
vim.keymap.set("i", "<A-l>", "<Right>")

-- 検索ハイライト解除
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>")

-- WSL クリップボード貼り付け用バインド (win32yank)
vim.keymap.set("n", "<Space>p", ":put =system('win32yank.exe -o --lf')<CR>")


-- ============================================================================
-- 3. プラグイン管理 (lazy.nvim の自動インストールとセットアップ)
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- 外観・テーマ
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- ナビゲーション
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- 開発効率
  { "numToStr/Comment.nvim", opts = {} }, -- vim-commentary の Lua版 (gcc でコメント)
  { "windwp/nvim-autopairs", opts = {} }, -- auto-pairs の Lua版 (括弧の自動補完)

  -- キーバインド アシスト
  { "folke/which-key.nvim", event = "VeryLazy" }, -- vim-which-key の爆速後継版

  -- 内蔵LSPコア & 言語サーバー管理 (Cocの完全な代替)
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- 補完エンジン (VS Code並みのサクサク感)
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },

  -- VS Code完全再現: ファジーファインダー・Git・エラー一覧・インデントガイド
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
  { "lukas-reineke/indent-blankline.nvim", opts = {} },
})


-- ============================================================================
-- 4. 各種プラグインの個別設定
-- ============================================================================

-- --- テーマ設定 ---
vim.cmd([[colorscheme tokyonight-night]])
-- 背景透過設定
local highlight_groups = { "Normal", "NonText", "LineNr", "SignColumn", "EndOfBuffer" }
for _, group in ipairs(highlight_groups) do
  vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
end

-- --- Lualine (ステータスライン) 設定 ---
require('lualine').setup({ options = { theme = 'tokyonight' } })

-- --- NvimTree (ファイルツリー) 設定 ---
require("nvim-tree").setup()
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>") -- 旧設定の Ctrl+n を移植

-- --- Which-key 設定 ---
require("which-key").setup()


-- --- Telescope (ファイル検索 Ctrl+P / 全文検索 Ctrl+Shift+F) 設定 ---
local telescope = require("telescope")
telescope.setup({
  extensions = { fzf = {} },
})
telescope.load_extension("fzf")

vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")  -- Ctrl+P
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")    -- Ctrl+Shift+F
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>")
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>")

-- --- Trouble (エラー一覧 / VS Codeの問題パネル) キーバインド ---
vim.keymap.set("n", "<leader>xx", ":Trouble diagnostics toggle<CR>")
vim.keymap.set("n", "<leader>xd", ":Trouble diagnostics toggle filter.buf=0<CR>")

-- ============================================================================
-- 5. Native LSP & 自動補完 (nvim-cmp) の設定
-- ============================================================================
require("mason").setup()

-- あなたが Coc で使っていた言語サーバーをすべて Native LSP 用に定義
local servers = {
  html = {}, cssls = {}, tsserver = {}, pyright = {},
  rust_analyzer = {}, gopls = {}, clangd = {}, jdtls = {},
  bashls = {}, yamlls = {}, sqlls = {}, jsonls = {},
  vimls = {}, dockerls = {}
}

require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
})

-- LSPが有効になったバッファでのみ有効にするキーバインド (Cocの機能を完全移植)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    -- ショートカット直打ち
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ac", vim.lsp.buf.code_action, opts)

    -- VS Codeの Ctrl + . の感覚（Leader + .）
    vim.keymap.set("n", "<leader>.", vim.lsp.buf.code_action, opts)
    -- エラーの再起動（ゾンビエラー対策）
    vim.keymap.set("n", "<leader>cr", ":LspRestart<CR>", opts)
  end,
})

-- 各言語サーバーをNeovimクライアントと接続
local capabilities = require("cmp_nvim_lsp").default_capabilities()
require("mason-lspconfig").setup_handlers({
  function(server_name)
    require("lspconfig")[server_name].setup({
      capabilities = capabilities,
    })
  end,
})

-- --- 自動補完 (nvim-cmp) の挙動設定 ---
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item() else fallback() end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item() else fallback() end
    end, { "i", "s" }),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim-lsp" },
    { name = "buffer" },
    { name = "path" },
  }),
})
