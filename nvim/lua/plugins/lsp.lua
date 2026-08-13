-- ============================================================================
-- LSP + formatting (mason / lspconfig / conform)
-- ============================================================================

return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded" },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mason").setup()

      local servers = {
        "html",
        "cssls",
        "ts_ls",
        "pyright",
        "rust_analyzer",
        "gopls",
        "clangd",
        "bashls",
        "yamlls",
        "jsonls",
        "vimls",
        "dockerls",
        "lua_ls",
        "marksman", -- Markdown LSP
      }

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Lua: recognize vim global
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = true,
      })

      -- Diagnostics look & feel
      vim.diagnostic.config({
        underline = true,
        virtual_text = { spacing = 2, prefix = "●" },
        signs = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = true },
      })

      vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#ff5555" })
      vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#ffaa00" })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#ff5555" })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#ffaa00" })

      -- LSP attach keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "gy", vim.lsp.buf.type_definition, "Type definition")
          map("n", "gi", vim.lsp.buf.implementation, "Implementation")
          map("n", "K", vim.lsp.buf.hover, "Hover docs")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map({ "n", "v" }, "<leader>ac", vim.lsp.buf.code_action, "Code action")
          map({ "n", "v" }, "<leader>.", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>cr", "<cmd>LspRestart<CR>", "Restart LSP")
          map("n", "<leader>ci", "<cmd>LspInfo<CR>", "LSP info")
        end,
      })
    end,
  },

  -- Format on save
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        -- markdown: 手動フォーマットのみ（保存のたびに折り返しが変わると書きづらい）
        markdown = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        go = { "gofmt" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
      },
      format_on_save = function(bufnr)
        -- Disable for huge files
        local max = 512 * 1024
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        if ok and stats and stats.size > max then
          return nil
        end
        -- Markdown は執筆中のレイアウトを壊さないよう保存時フォーマットしない
        -- 必要なら <leader>cf で手動実行
        local ft = vim.bo[bufnr].filetype
        if ft == "markdown" or ft == "markdown.mdx" then
          return nil
        end
        return { timeout_ms = 1500, lsp_fallback = true }
      end,
    },
  },

  -- Install formatters via Mason
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "stylua",
        "prettier",
        "shfmt",
        "black",
        "ruff",
      },
      auto_update = false,
      run_on_start = true,
    },
  },
}
