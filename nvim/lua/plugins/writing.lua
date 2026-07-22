-- ============================================================================
-- Writing / notes: Markdown preview + in-buffer render
-- ============================================================================

return {
  -- Pretty Markdown inside the editor
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      heading = { enabled = true, sign = false },
      code = { enabled = true, sign = false, width = "block" },
      bullet = { enabled = true },
      checkbox = { enabled = true },
    },
  },

  -- Browser preview (Ctrl-p in markdown)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install && git restore .",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "dark"
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.keymap.set("n", "<C-p>", "<cmd>MarkdownPreviewToggle<CR>", {
            buffer = true,
            desc = "Markdown browser preview",
          })
          vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", {
            buffer = true,
            desc = "Markdown browser preview",
          })
          -- Toggle in-editor render
          vim.keymap.set("n", "<leader>mr", function()
            require("render-markdown").toggle()
          end, { buffer = true, desc = "Toggle markdown render" })
        end,
      })
    end,
  },

  -- Zen-ish focus for long writing sessions
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>tz", "<cmd>ZenMode<CR>", desc = "Zen mode" },
    },
    opts = {
      window = {
        width = 90,
        options = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
        },
      },
      plugins = {
        twilight = { enabled = false },
        gitsigns = { enabled = false },
      },
    },
  },

  -- Quick UI toggles useful while writing
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      -- keep minimal; only bigfile protection + notifier if available
      bigfile = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      quickfile = { enabled = true },
    },
    keys = {
      {
        "<leader>un",
        function()
          require("snacks").notifier.hide()
        end,
        desc = "Dismiss notifications",
      },
      {
        "<leader>uw",
        function()
          vim.opt.wrap = not vim.opt.wrap:get()
        end,
        desc = "Toggle wrap",
      },
      {
        "<leader>us",
        function()
          vim.opt.spell = not vim.opt.spell:get()
        end,
        desc = "Toggle spell",
      },
      {
        "<leader>ul",
        function()
          vim.opt.number = not vim.opt.number:get()
          vim.opt.relativenumber = not vim.opt.relativenumber:get()
        end,
        desc = "Toggle line numbers",
      },
    },
  },
}
