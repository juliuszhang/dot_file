-- Show the current line number and relative numbers on surrounding lines.
vim.opt.number = true
vim.opt.relativenumber = true

-- Detect file types (including TypeScript and TSX) and load their syntax rules.
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

-- The default theme renders Java types/keywords like normal text.
-- This bundled theme supplies distinct GUI and 256-color terminal colors.
vim.cmd("colorscheme habamax")

-- Set leaders before loading any plugins or mappings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>", { silent = true })

-- Native LSP completion: select explicitly, never insert a suggestion by accident.
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }
vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, { desc = "Show completions" })
vim.keymap.set("i", "<CR>", function()
  return vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected >= 0 and "<C-y>" or "<CR>"
end, { expr = true, desc = "Accept selected completion or newline" })

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
vim.keymap.set("n", "<leader>fd", function() require("telescope.builtin").diagnostics() end, { desc = "Search diagnostics" })
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })

-- Native Neovim 0.12 plugin management: :lua vim.pack.update()
vim.g.EasyMotion_do_mapping = 0
vim.g.EasyMotion_smartcase = 1
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
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim", version = vim.version.range("4.x") },
  { src = "https://github.com/preservim/nerdtree" },
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", version = vim.version.range("*") },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/kylechui/nvim-surround", version = vim.version.range("4.x") },
  { src = "https://github.com/easymotion/vim-easymotion" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mfussenegger/nvim-jdtls" },
})
require("mason").setup({})
require("nvim-web-devicons").setup({ default = true })
vim.opt.termguicolors = true
vim.opt.laststatus = 3
vim.opt.showmode = false
vim.opt.showtabline = 2
vim.opt.hidden = true
vim.opt.mouse = "a"
local statusline_theme = vim.deepcopy(require("lualine.themes.auto"))
statusline_theme.normal.a = { fg = "#10243A", bg = "#7AA2F7", gui = "bold" }
statusline_theme.normal.b = { fg = "#B9D3FF", bg = "#243852" }
statusline_theme.normal.c = { fg = "#C0CAF5", bg = "#1B2536" }
require("lualine").setup({
  options = {
    theme = statusline_theme,
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
require("bufferline").setup({
  options = {
    mode = "buffers", -- Editor-style file tabs; Vim tab pages remain available.
    close_command = "bdelete %d",
    right_mouse_command = "bdelete %d",
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
vim.keymap.set("n", "<leader>w", "<cmd>bdelete<cr>", { desc = "Close current file (preserve unsaved changes)" })
vim.g.NERDTreeWinSize = 32
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeChDirMode = 0
vim.keymap.set("n", "<leader>e", "<cmd>NERDTreeToggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>l", "<cmd>NERDTreeFind<cr>", { desc = "Locate current file in tree" })
vim.lsp.config("lua_ls", {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
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
require("nvim-surround").setup({})
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
  vim.cmd("Git blame")
end, { desc = "Toggle Git annotate (blame)" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Search project text" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Search help" })
vim.keymap.set("n", "<leader><leader>", "<Plug>(easymotion-overwin-f2)", { desc = "EasyMotion: two characters" })
vim.keymap.set({ "n", "x", "o" }, "<leader>j", "<Plug>(easymotion-j)", { desc = "EasyMotion: line below" })
vim.keymap.set({ "n", "x", "o" }, "<leader>k", "<Plug>(easymotion-k)", { desc = "EasyMotion: line above" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeys", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      local triggers = client.server_capabilities.completionProvider.triggerCharacters or {}
      for char in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$"):gmatch(".") do
        if not vim.tbl_contains(triggers, char) then triggers[#triggers + 1] = char end
      end
      client.server_capabilities.completionProvider.triggerCharacters = triggers
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
    local function map(key, action, description)
      vim.keymap.set("n", key, action, { buffer = event.buf, desc = description })
    end
    map("gd", function() require("telescope.builtin").lsp_definitions() end, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gy", function() require("telescope.builtin").lsp_type_definitions() end, "Go to class/type")
    map("gi", function() require("telescope.builtin").lsp_implementations({ jump_type = "never" }) end, "Go to implementation")
    map("gr", function() require("telescope.builtin").lsp_references() end, "Find references")
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
