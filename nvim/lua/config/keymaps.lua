-- ============================================================================
-- Global keymaps (plugin-specific maps live in plugins/*)
-- ============================================================================

local map = vim.keymap.set

-- Escape
map("i", "jj", "<Esc>", { desc = "Leave insert mode" })

-- ============================================================================
-- Ctrl + HJKL = カーソル移動（全モード）
-- ウィンドウ移動は素の Vim どおり <C-w>h/j/k/l
-- ============================================================================
local ctrl_hjkl = {
  ["<C-h>"] = { motion = "h", arrow = "<Left>", desc = "Move left" },
  ["<C-j>"] = { motion = "j", arrow = "<Down>", desc = "Move down" },
  ["<C-k>"] = { motion = "k", arrow = "<Up>", desc = "Move up" },
  ["<C-l>"] = { motion = "l", arrow = "<Right>", desc = "Move right" },
}

for lhs, spec in pairs(ctrl_hjkl) do
  -- Normal / Visual / Select / Operator-pending
  map({ "n", "x", "o", "s" }, lhs, spec.motion, { desc = spec.desc })
  -- Insert / Command-line / Terminal
  map({ "i", "c", "t" }, lhs, spec.arrow, { desc = spec.desc })
end

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Window navigation (Ctrl-hjkl を移動に使ったのでこちらへ)
-- 素の <C-w>h/j/k/l もそのまま使えます
map("n", "<A-h>", "<C-w>h", { desc = "Window left" })
map("n", "<A-l>", "<C-w>l", { desc = "Window right" })
-- Alt-j/k は行移動に使うため、ウィンドウ上下は Ctrl-w を利用
map("t", "<A-h>", [[<C-\><C-n><C-w>h]], { desc = "Window left" })
map("t", "<A-j>", [[<C-\><C-n><C-w>j]], { desc = "Window down" })
map("t", "<A-k>", [[<C-\><C-n><C-w>k]], { desc = "Window up" })
map("t", "<A-l>", [[<C-\><C-n><C-w>l]], { desc = "Window right" })

-- Resize splits
map("n", "<A-Left>", "<cmd>vertical resize -2<CR>", { desc = "Shrink width" })
map("n", "<A-Right>", "<cmd>vertical resize +2<CR>", { desc = "Grow width" })
map("n", "<A-Up>", "<cmd>resize +2<CR>", { desc = "Grow height" })
map("n", "<A-Down>", "<cmd>resize -2<CR>", { desc = "Shrink height" })

-- Buffers（H/L は Vim 本来の画面上下端移動のまま）
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Alternate buffer" })

-- Save / quit
map({ "n", "i" }, "<C-s>", "<cmd>write<CR><Esc>", { desc = "Save file" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all force" })

-- Move lines（Alt-j/k）
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep visual selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Center after jump / search
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Diagnostics
map("n", "[g", function()
  vim.diagnostic.goto_prev({ float = true })
end, { desc = "Prev diagnostic" })
map("n", "]g", function()
  vim.diagnostic.goto_next({ float = true })
end, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- WSL clipboard helper
if vim.fn.executable("win32yank.exe") == 1 then
  map("n", "<leader>p", function()
    vim.cmd("put =system('win32yank.exe -o --lf')")
  end, { desc = "Paste from Windows clipboard" })
end
