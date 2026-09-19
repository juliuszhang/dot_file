-- Tree-sitter 语法高亮：按语言的语法树识别代码结构。
-- 解析器负责理解语法，highlights 查询负责指定哪些结构使用哪些高亮。
-- 启动时只注册规则；解析器安装由 :TSInstallConfigured 手动触发。

-- 初始化解析器管理插件，使用默认设置。
require("nvim-treesitter").setup({})
-- 文件类型确定时，尝试为下面列出的文件类型启用 Tree-sitter。
vim.api.nvim_create_autocmd("FileType", {
  -- 独立事件组；重新执行配置时替换旧规则。
  group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
  -- 这里填写 Neovim 文件类型名，可能与解析器语言名不同，例如 typescriptreact 对应 tsx。
  pattern = { "java", "lua", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "mermaid", "markdown" },
  callback = function(event)
    -- 把当前 buffer 的文件类型映射为 Tree-sitter 语言名。
    local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
    -- pcall 会捕获报错：query_ok 表示调用成功，query 是找到的 highlights 查询。
    local query_ok, query = pcall(vim.treesitter.query.get, lang, "highlights")
    -- 只有查询存在才尝试启动高亮；解析器缺失等错误会被 pcall 捕获，不中断配置。
    local started = query_ok and query and pcall(vim.treesitter.start, event.buf, lang)
    -- Keep Vim syntax for Mermaid forms the parser does not cover (e.g. graph TD).
    -- Mermaid 即使成功启用 Tree-sitter，也保留传统语法高亮来补充未覆盖的语法。
    if started and lang == "mermaid" then
      vim.bo[event.buf].syntax = "mermaid"
    end
    -- 缺少查询或启动失败时，停止 Tree-sitter，并回退到该文件类型的传统语法高亮。
    if not started then
      pcall(vim.treesitter.stop, event.buf)
      vim.bo[event.buf].syntax = vim.bo[event.buf].filetype
    end
  end,
})

-- Explicit installation keeps network/build work out of normal startup.
-- 定义手动命令 :TSInstallConfigured，把下载/编译工作与日常启动分开。
vim.api.nvim_create_user_command("TSInstallConfigured", function()
  -- 这里填写解析器名；tsx 用于 TSX，markdown_inline 处理 Markdown 内联语法。
  require("nvim-treesitter").install({ "java", "lua", "javascript", "typescript", "tsx", "json", "mermaid", "markdown", "markdown_inline" })
end, { desc = "Install parsers used by this configuration" })
