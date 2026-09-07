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
vim.keymap.set("n", "<leader>e", function() vim.diagnostic.open_float({ scope = "line" }) end, { desc = "Line diagnostics" })
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
vim.keymap.set("n", "<leader>a", "<cmd>Git blame<cr>", { desc = "Git annotate (blame)" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Search project text" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Search help" })
vim.keymap.set("n", "<leader>s", "<Plug>(easymotion-overwin-f2)", { desc = "EasyMotion: two characters" })
vim.keymap.set({ "n", "x", "o" }, "<leader>w", "<Plug>(easymotion-bd-w)", { desc = "EasyMotion: word" })
vim.keymap.set({ "n", "x", "o" }, "<leader>j", "<Plug>(easymotion-j)", { desc = "EasyMotion: line below" })
vim.keymap.set({ "n", "x", "o" }, "<leader>k", "<Plug>(easymotion-k)", { desc = "EasyMotion: line above" })

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
