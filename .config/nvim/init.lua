-- Use the system clipboard for default yank, delete, and paste operations.
vim.opt.clipboard = "unnamedplus"

-- Show the current line number and relative numbers on surrounding lines.
vim.opt.number = true
vim.opt.relativenumber = true

-- Detect file types (including TypeScript and TSX) and load their syntax rules.
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

-- Set leaders before loading any plugins or mappings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>", { silent = true })

vim.opt.signcolumn = "yes"
vim.diagnostic.enable(true)
vim.diagnostic.config({
  virtual_text = { spacing = 2, source = "if_many" },
  signs = true,
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
})
vim.keymap.set("n", "<leader>D", function() vim.diagnostic.open_float({ scope = "line" }) end, { desc = "Line diagnostics" })
vim.keymap.set("n", "<leader>F", function() vim.lsp.buf.format() end, { desc = "Format current buffer" })
vim.keymap.set("n", "<leader>fd", function() require("telescope.builtin").diagnostics() end, { desc = "Search diagnostics" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })

-- Native Neovim 0.12 plugin management: :lua vim.pack.update()
-- Multi-cursor: press Ctrl+n repeatedly to select the word/subword under the cursor.
vim.g.VM_maps = {
  ["Find Under"] = "<C-n>",
  ["Find Subword Under"] = "<C-n>",
}
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("UserPackHooks", { clear = true }),
  callback = function(event)
    if event.data.spec.name == "nvim-treesitter" and event.data.kind == "update" then
      vim.cmd.packadd("nvim-treesitter")
      require("nvim-treesitter").update()
    end
  end,
})
vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/tpope/vim-abolish" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim", version = vim.version.range("4.x") },
  { src = "https://github.com/preservim/nerdtree" },
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", version = vim.version.range("*") },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/kylechui/nvim-surround", version = vim.version.range("4.x") },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/mg979/vim-visual-multi" },
  { src = "https://github.com/folke/flash.nvim", version = vim.version.range("*") },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mfussenegger/nvim-jdtls" },
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.x") },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
})
vim.opt.termguicolors = true
require("catppuccin").setup({
  flavour = "mocha",
  custom_highlights = function(colors)
    return {
      LineNr = { fg = colors.subtext0 },
      LineNrAbove = { fg = colors.subtext0 },
      LineNrBelow = { fg = colors.subtext0 },
      CursorLineNr = { fg = colors.yellow, bold = true },
    }
  end,
})
vim.cmd("colorscheme catppuccin-mocha")

require("mason").setup({})
require("blink.cmp").setup({
  keymap = {
    preset = "enter",
    ["<C-Space>"] = {},
  },
  completion = {
    list = { selection = { preselect = true, auto_insert = false } },
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "lua" },
  signature = { enabled = true },
})
local lsp_capabilities = require("blink.cmp").get_lsp_capabilities()
require("nvim-web-devicons").setup({ default = true })
vim.opt.termguicolors = true
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.showtabline = 2
vim.opt.hidden = true
vim.opt.mouse = "a"
require("lualine").setup({
  options = {
    theme = "catppuccin",
    globalstatus = true,
    icons_enabled = true,
    component_separators = "|",
    section_separators = "",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diagnostics" },
    lualine_c = { { "filename", path = 1 } },
    lualine_x = { "encoding", { "filetype", colored = true, icon_only = false } },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})
-- Remove a file tab without removing the windows that display it.
local function close_file_tab(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.bo[buf].buftype ~= "" then
    vim.notify("请在代码窗口中关闭文件标签。", vim.log.levels.INFO)
    return
  end
  if vim.bo[buf].modified then
    vim.notify("文件尚未保存，请先 :w 保存后再关闭。", vim.log.levels.WARN)
    return
  end
  local function usable(candidate)
    return candidate ~= buf and vim.api.nvim_buf_is_valid(candidate)
      and vim.bo[candidate].buflisted and vim.bo[candidate].buftype == ""
  end
  local replacement = vim.fn.bufnr("#")
  if not usable(replacement) then
    replacement = nil
    for _, candidate in ipairs(vim.api.nvim_list_bufs()) do
      if usable(candidate) then replacement = candidate; break end
    end
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      replacement = replacement or vim.api.nvim_create_buf(true, false)
      vim.api.nvim_win_set_buf(win, replacement)
    end
  end
  vim.api.nvim_buf_delete(buf, { force = false })
end
require("bufferline").setup({
  options = {
    mode = "buffers", -- Editor-style file tabs; Vim tab pages remain available.
    close_command = close_file_tab,
    right_mouse_command = close_file_tab,
    diagnostics = "nvim_lsp",
    always_show_bufferline = true,
    show_buffer_icons = true,
    separator_style = "thin",
    offsets = { { filetype = "nerdtree", text = "Files", text_align = "center" } },
    custom_filter = function(buf)
      return vim.bo[buf].buftype == ""
    end,
  },
})
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous file tab" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next file tab" })
vim.keymap.set("n", "<leader>w", function() close_file_tab() end, { desc = "Close file tab, keep window layout" })
vim.keymap.set("n", "<leader>W", function()
  local current = vim.api.nvim_get_current_buf()
  if vim.bo[current].buftype ~= "" then
    vim.notify("请在代码窗口中关闭其他文件标签。", vim.log.levels.INFO)
    return
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
      close_file_tab(buf)
    end
  end
end, { desc = "Close other file tabs, keep window layout" })
vim.g.NERDTreeWinSize = 32
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeChDirMode = 0
vim.keymap.set("n", "<leader>e", "<cmd>NERDTreeToggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>l", "<cmd>NERDTreeFind<cr>", { desc = "Locate current file in tree" })
vim.lsp.config("lua_ls", {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/lua-language-server" },
  capabilities = lsp_capabilities,
  filetypes = { "lua" },
  root_dir = function(bufnr, on_dir)
    local file = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    local config_dir = vim.fs.normalize(vim.fn.stdpath("config"))
    if vim.startswith(file, config_dir .. "/") then
      on_dir(config_dir)
    else
      on_dir(vim.fs.root(bufnr, { ".luarc.json", ".luarc.jsonc", ".git" }) or vim.fs.dirname(file))
    end
  end,
  settings = {
    Lua = {
      completion = { callSnippet = "Replace" },
      workspace = { checkThirdParty = false },
    },
  },
  on_init = function(client)
    if vim.fs.normalize(client.root_dir or "") == vim.fs.normalize(vim.fn.stdpath("config")) then
      client.config.settings.Lua.runtime = { version = "LuaJIT" }
      client.config.settings.Lua.diagnostics = { globals = { "vim" } }
      client.config.settings.Lua.workspace.library = { vim.env.VIMRUNTIME }
      client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
  end,
})
if vim.fn.executable(vim.fn.stdpath("data") .. "/mason/bin/lua-language-server") == 1 then
  vim.lsp.enable("lua_ls")
end
vim.lsp.config("ts_ls", {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/typescript-language-server", "--stdio" },
  capabilities = lsp_capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" }))
  end,
})
if vim.fn.executable(vim.fn.stdpath("data") .. "/mason/bin/typescript-language-server") == 1 then
  vim.lsp.enable("ts_ls")
end
require("nvim-surround").setup({})
require("nvim-autopairs").setup({})
require("flash").setup({ modes = { char = { enabled = false } } })
require("telescope").setup({})
require("nvim-treesitter").setup({})
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
  pattern = { "java", "lua" },
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
    local query_ok, query = pcall(vim.treesitter.query.get, lang, "highlights")
    local started = query_ok and query and pcall(vim.treesitter.start, event.buf, lang)
    if not started then
      pcall(vim.treesitter.stop, event.buf)
      vim.bo[event.buf].syntax = vim.bo[event.buf].filetype
    end
  end,
})
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>a", function()
  local original_win = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "fugitiveblame" then
      vim.api.nvim_set_current_win(win)
      -- Use Fugitive's own close action to restore the source window.
      vim.cmd.normal("gq")
      if vim.api.nvim_win_is_valid(original_win) then
        vim.api.nvim_set_current_win(original_win)
      end
      return
    end
  end
  if vim.fn.FugitiveGitDir() == "" then
    vim.notify("Current file is not in a Git repository", vim.log.levels.WARN)
    return
  end
  vim.cmd("Git blame")
end, { desc = "Toggle Git annotate (blame)" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Search project text" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Search help" })
vim.keymap.set({ "n", "x", "o" }, "<leader><leader>s", function()
  require("flash").jump()
end, { desc = "Flash: search and jump" })

local function flash_line(forward)
  require("flash").jump({
    search = { mode = "search", max_length = 0, forward = forward, wrap = false, multi_window = false },
    label = { after = { 0, 0 } },
    pattern = "^",
  })
end
vim.keymap.set({ "n", "x", "o" }, "<leader><leader>j", function() flash_line(true) end, { desc = "Flash: line below" })
vim.keymap.set({ "n", "x", "o" }, "<leader><leader>k", function() flash_line(false) end, { desc = "Flash: line above" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeys", { clear = true }),
  callback = function(event)
    local function map(key, action, description)
      vim.keymap.set("n", key, action, { buffer = event.buf, desc = description })
    end
    map("gd", function() require("telescope.builtin").lsp_definitions() end, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gy", function() require("telescope.builtin").lsp_type_definitions() end, "Go to class/type")
    map("gi", function() require("telescope.builtin").lsp_implementations({ jump_type = "never" }) end, "Go to implementation")
    vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references() end,
      { buffer = event.buf, nowait = true, desc = "Find references" })
    map("K", vim.lsp.buf.hover, "Documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    if vim.bo[event.buf].filetype == "java" then
      map("<leader>i", function() require("jdtls").organize_imports() end, "Java: organize imports")
    end
    map("<leader>cs", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "Search project classes/symbols")
    map("<leader>ds", function() require("telescope.builtin").lsp_document_symbols() end, "Search file symbols")
  end,
})
