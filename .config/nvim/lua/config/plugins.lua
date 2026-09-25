-- 插件清单，由 init.lua 在基础选项之后加载。
-- 使用 Neovim 内置 vim.pack 管理插件；更新命令是 :lua vim.pack.update()。
-- src 是插件仓库；name 可覆盖本地名称；version 指定版本范围或分支。
-- 这里只负责加载与少量加载前设置，具体功能在 ui/lsp/editing/treesitter 等模块配置。

-- Native Neovim 0.12 plugin management: :lua vim.pack.update()
-- Multi-cursor: press Ctrl+n repeatedly to select the word/subword under the cursor.
-- 在多光标插件加载前设置其按键；<C-n> 表示 Ctrl+n，可连续选择匹配项。
vim.g.VM_maps = {
  -- 普通的查找并选择光标下单词操作。
  ["Find Under"] = "<C-n>",
  -- 插件的子词查找操作也使用 Ctrl+n。
  ["Find Subword Under"] = "<C-n>",
}
-- 监听插件变更；仅在 nvim-treesitter 被更新后更新其解析器。
vim.api.nvim_create_autocmd("PackChanged", {
  -- 使用独立事件组，重新执行此段时先清除旧监听。
  group = vim.api.nvim_create_augroup("UserPackHooks", { clear = true }),
  callback = function(event)
    -- 同时检查插件名和变更类型，其他插件或其他变更不触发此操作。
    if event.data.spec.name == "nvim-treesitter" and event.data.kind == "update" then
      -- 确保插件已加载，再调用它的解析器更新函数。
      vim.cmd.packadd("nvim-treesitter")
      require("nvim-treesitter").update()
    end
  end,
})
-- 声明并加载以下插件；缺失的插件由内置管理器安装。
vim.pack.add({
  -- Catppuccin：配色主题，本地名称设为 catppuccin；在 ui.lua 中选择 mocha。
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  -- vim-abolish：单词变体替换、大小写和命名风格转换。
  { src = "https://github.com/tpope/vim-abolish" },
  -- nvim-web-devicons：文件类型图标，供状态栏、文件标签等组件使用。
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  -- lualine：底部状态栏，显示模式、分支、诊断、文件信息等。
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  -- bufferline：顶部文件标签栏；版本限制在 4.x 系列。
  { src = "https://github.com/akinsho/bufferline.nvim", version = vim.version.range("4.x") },
  -- NERDTree：侧边文件树，相关设置和快捷键在 ui.lua。
  { src = "https://github.com/preservim/nerdtree" },
  -- Fugitive：Git 集成；editing.lua 使用它切换 Git blame。
  { src = "https://github.com/tpope/vim-fugitive" },
  -- plenary：Lua 通用工具库，供 Telescope 等插件使用。
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  -- Telescope：文件、文本、符号等模糊搜索；* 是版本范围，不是固定某个版本。
  { src = "https://github.com/nvim-telescope/telescope.nvim", version = vim.version.range("*") },
  -- nvim-treesitter：管理语法解析器，这里跟踪 main 分支。
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  -- nvim-surround：添加、修改、删除括号或引号等包围符，使用 4.x 系列。
  { src = "https://github.com/kylechui/nvim-surround", version = vim.version.range("4.x") },
  -- nvim-autopairs：输入左括号、引号时自动补齐配对符号。
  { src = "https://github.com/windwp/nvim-autopairs" },
  -- vim-visual-multi：多光标编辑，Ctrl+n 的映射在本文件开头设置。
  { src = "https://github.com/mg979/vim-visual-multi" },
  -- Flash：给匹配位置加跳转标签，在 editing.lua 定义搜索和按行跳转。
  { src = "https://github.com/folke/flash.nvim", version = vim.version.range("*") },
  -- Mason：安装和管理语言服务器等外部工具；不会仅凭此行自动安装所有服务器。
  { src = "https://github.com/mason-org/mason.nvim" },
  -- nvim-jdtls：Java 语言服务集成，具体启动逻辑见 config/java.lua。
  { src = "https://github.com/mfussenegger/nvim-jdtls" },
  -- blink.cmp：补全菜单、文档和参数提示，使用 1.x 系列。
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.x") },
  -- friendly-snippets：现成的多语言代码片段，供补全系统使用。
  { src = "https://github.com/rafamadriz/friendly-snippets" },
})
