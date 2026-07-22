-- ============================================================================
-- Autocommands
-- ============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 2-space indent languages
autocmd("FileType", {
  group = augroup("indent_2", { clear = true }),
  pattern = {
    "lua",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "yaml",
    "yml",
    "html",
    "css",
    "scss",
    "markdown",
    "toml",
    "vue",
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Writing / prose comfort (memo, markdown, text, git commits)
autocmd("FileType", {
  group = augroup("prose", { clear = true }),
  pattern = { "markdown", "text", "gitcommit", "plaintext", "mail" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = false -- enable with <leader>us if needed
    vim.opt_local.conceallevel = 2
    vim.opt_local.number = true
    vim.opt_local.relativenumber = false
    -- j/k move by display line when wrap is on
    vim.keymap.set({ "n", "v" }, "j", "gj", { buffer = true, silent = true })
    vim.keymap.set({ "n", "v" }, "k", "gk", { buffer = true, silent = true })
    vim.keymap.set({ "n", "v" }, "0", "g0", { buffer = true, silent = true })
    vim.keymap.set({ "n", "v" }, "$", "g$", { buffer = true, silent = true })
  end,
})

-- Close some filetypes with q
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = {
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "checkhealth",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-create parent dirs on save
autocmd("BufWritePre", {
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Remove trailing whitespace on save (skip markdown — double-space line breaks)
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  callback = function()
    if vim.bo.filetype == "markdown" or vim.bo.binary then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})
