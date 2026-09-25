-- 语言服务与补全配置。
-- LSP 让编辑器向语言服务器请求诊断、定义、重命名、格式化等能力。
-- Mason 管理服务器安装；vim.lsp 配置/启动服务器；blink.cmp 展示补全结果。
-- 本文件配置 Lua、JavaScript/TypeScript；Java 由 ftplugin/java.lua 单独启动。
-- 快捷键 <leader> 是空格；大写 D/F/K 等需要 Shift，grr 是依次按 g、r、r。

-- 始终预留左侧标记栏，避免诊断图标出现时正文左右跳动。
vim.opt.signcolumn = "yes"
-- 启用诊断显示。
vim.diagnostic.enable(true)
-- 统一配置警告、错误等诊断信息的显示方式。
vim.diagnostic.config({
  -- 在行尾显示诊断文字，间隔 2 个空格；存在多个来源时显示来源名。
  virtual_text = { spacing = 2, source = "if_many" },
  -- 左侧标记栏显示诊断符号。
  signs = true,
  -- 给问题代码加下划线。
  underline = true,
  -- 按严重程度排序诊断。
  severity_sort = true,
  -- 插入模式中暂缓刷新诊断，减少输入时的干扰。
  update_in_insert = false,
  -- 诊断浮窗使用圆角边框，并展示诊断来源。
  float = { border = "rounded", source = true },
})
-- 空格 Shift+d：浮窗查看当前行诊断。
vim.keymap.set("n", "<leader>D", function() vim.diagnostic.open_float({ scope = "line" }) end, { desc = "Line diagnostics" })
-- 空格 Shift+f：调用当前 buffer 可用的语言服务进行格式化。
vim.keymap.set("n", "<leader>F", function() vim.lsp.buf.format() end, { desc = "Format current buffer" })
-- 空格 f d：用 Telescope 搜索诊断。
vim.keymap.set("n", "<leader>fd", function() require("telescope.builtin").diagnostics() end, { desc = "Search diagnostics" })
-- [d：跳到上一条诊断，并打开说明浮窗。
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
-- ]d：跳到下一条诊断，并打开说明浮窗。
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })

-- 初始化外部工具管理器，可用 :Mason 打开界面；此处不自动安装服务器。
require("mason").setup({})
-- 配置补全菜单；setup({}) 一般表示使用插件默认设置，这里覆盖部分默认项。
require("blink.cmp").setup({
  keymap = {
    -- 使用以 Enter 确认补全为核心的按键预设。
    preset = "enter",
    -- 清空 blink 对 Ctrl+Space 的预设操作。
    ["<C-Space>"] = {},
  },
  completion = {
    -- 默认选中候选项，但不把候选文字自动插进正文，等待用户确认。
    list = { selection = { preselect = true, auto_insert = false } },
    -- 选中候选后，延迟 300 毫秒自动显示说明文档。
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },
  -- 补全来源依次包括语言服务、文件路径、代码片段、buffer 文本。
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  -- 使用 Lua 模糊匹配实现。
  fuzzy = { implementation = "lua" },
  -- 启用函数签名/参数提示。
  signature = { enabled = true },
})
-- 取得补全插件支持的能力，随后告诉语言服务器，以便提供匹配的补全结果。
local lsp_capabilities = require("blink.cmp").get_lsp_capabilities()

-- 注册 Lua 语言服务器配置；注册配置与真正启用服务器是两个步骤。
vim.lsp.config("lua_ls", {
  -- 从 Neovim 数据目录里的 Mason 安装位置启动 Lua 服务器。
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/lua-language-server" },
  -- 把 blink 的补全能力传给服务器。
  capabilities = lsp_capabilities,
  -- 此服务只处理 Lua 文件。
  filetypes = { "lua" },
  -- 确定项目根目录，通过 on_dir(目录) 告诉 LSP 应在哪个项目启动。
  root_dir = function(bufnr, on_dir)
    -- 取得当前文件的完整路径并规范化。
    local file = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    -- 取得 Neovim 配置目录，通常为 ~/.config/nvim。
    local config_dir = vim.fs.normalize(vim.fn.stdpath("config"))
    -- 编辑自己的 Neovim 配置时，把整个配置目录当成一个 Lua 项目。
    if vim.startswith(file, config_dir .. "/") then
      on_dir(config_dir)
    else
      -- 其他 Lua 文件向上寻找项目标记；找不到时退回文件所在目录。
      on_dir(vim.fs.root(bufnr, { ".luarc.json", ".luarc.jsonc", ".git" }) or vim.fs.dirname(file))
    end
  end,
  settings = {
    Lua = {
      -- 函数调用补全使用 Replace 模式处理调用片段。
      completion = { callSnippet = "Replace" },
      -- 关闭第三方库工作区检测提示。
      workspace = { checkThirdParty = false },
    },
  },
  -- 服务器初始化时，仅为 Neovim 自身配置项目补充专用 Lua 设置。
  on_init = function(client)
    if vim.fs.normalize(client.root_dir or "") == vim.fs.normalize(vim.fn.stdpath("config")) then
      -- Neovim 的 Lua 运行环境按 LuaJIT 分析。
      client.config.settings.Lua.runtime = { version = "LuaJIT" }
      -- 声明 vim 是合法全局变量，避免被报告为未定义。
      client.config.settings.Lua.diagnostics = { globals = { "vim" } }
      -- 把 Neovim 自带运行时加入分析库，供 API 识别和补全使用。
      client.config.settings.Lua.workspace.library = { vim.env.VIMRUNTIME }
      -- 把刚调整的设置通知给已初始化的服务器。
      client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
  end,
})
-- 只有服务器可执行文件已安装才启用；否则可通过 Mason 安装 lua-language-server。
if vim.fn.executable(vim.fn.stdpath("data") .. "/mason/bin/lua-language-server") == 1 then
  vim.lsp.enable("lua_ls")
end
-- 注册 JavaScript、JSX、TypeScript、TSX 使用的语言服务器。
vim.lsp.config("ts_ls", {
  -- --stdio 表示通过标准输入/输出与编辑器通信。
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/typescript-language-server", "--stdio" },
  -- 把 blink 的补全能力传给服务器。
  capabilities = lsp_capabilities,
  -- javascriptreact 和 typescriptreact 分别是 JSX、TSX 的文件类型名。
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  -- 确定项目根目录，通过 on_dir(目录) 告诉 LSP 应在哪个项目启动。
  root_dir = function(bufnr, on_dir)
    -- 向上寻找 JS/TS 项目标记；找不到时不调用 on_dir，即不为该文件启动服务器。
    local root = vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
    if root then on_dir(root) end
  end,
})
-- 已安装 typescript-language-server 时才启用自动附加。
if vim.fn.executable(vim.fn.stdpath("data") .. "/mason/bin/typescript-language-server") == 1 then
  vim.lsp.enable("ts_ls")
end

-- 等语言服务真正连接到一个 buffer 后，再为这个 buffer 设置以下按键。
vim.api.nvim_create_autocmd("LspAttach", {
  -- 独立事件组；重新执行配置时清理旧回调，避免重复设置。
  group = vim.api.nvim_create_augroup("UserLspKeys", { clear = true }),
  callback = function(event)
    -- 局部辅助函数：统一创建普通模式映射，并把说明写入 desc。
    local function map(key, action, description)
      -- buffer = event.buf 把快捷键限制在此次连接到语言服务的文件内。
      vim.keymap.set("n", key, action, { buffer = event.buf, desc = description })
    end
    -- gd：查找/跳转到定义，结果由 Telescope 展示。
    map("gd", function() require("telescope.builtin").lsp_definitions() end, "Go to definition")
    -- gD：跳到声明（是否与定义不同，取决于语言和服务器）。
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    -- gy：跳到变量或表达式所对应的类型定义。
    map("gy", function() require("telescope.builtin").lsp_type_definitions() end, "Go to class/type")
    -- gi：查找实现；jump_type = never 避免结果只有一项时直接跳走。
    map("gi", function() require("telescope.builtin").lsp_implementations({ jump_type = "never" }) end, "Go to implementation")
    -- grr：查找符号在项目中的引用位置。
    map("grr", function() require("telescope.builtin").lsp_references() end, "Find references")
    -- Shift+k：查看光标下符号的悬浮文档。
    map("K", vim.lsp.buf.hover, "Documentation")
    -- 空格 r n：按语言服务理解的符号关系重命名。
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    -- 空格 c a：显示代码操作，例如可用的快速修复。
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    -- 下面的整理导入快捷键仅为 Java 文件添加。
    if vim.bo[event.buf].filetype == "java" then
      -- 空格 i：通过 jdtls 整理 Java import。
      map("<leader>i", function() require("jdtls").organize_imports() end, "Java: organize imports")
    end
    -- 空格 o：搜索工作区符号；Java 默认隐藏 JDK 和第三方依赖中的类。
    map("<leader>o", function()
      local opts = {}
      if vim.bo[event.buf].filetype == "java" then
        -- jdtls 用 jdt:// URI 返回依赖/JDK 类，项目源码使用普通文件路径。
        opts.file_ignore_patterns = vim.list_extend(
          vim.deepcopy(require("telescope.config").values.file_ignore_patterns or {}),
          { "^jdt://" }
        )
      end
      require("telescope.builtin").lsp_dynamic_workspace_symbols(opts)
    end, "Search project classes/symbols")
    -- 空格 Shift+o：搜索全部工作区符号，包括第三方依赖和 JDK 中的类。
    map("<leader>O", function()
      require("telescope.builtin").lsp_dynamic_workspace_symbols()
    end, "Search all classes/symbols (including dependencies)")
    -- 空格 d s：搜索当前文件中的符号。
    map("<leader>ds", function() require("telescope.builtin").lsp_document_symbols() end, "Search file symbols")
  end,
})
