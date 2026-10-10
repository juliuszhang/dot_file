-- 配置入口：正常启动 Neovim 时，从上到下执行本文件。
-- require("config.xxx") 会加载 lua/config/xxx.lua；同一模块通常只执行一次，随后使用缓存。
-- 阅读顺序建议沿用下方顺序；Java 的额外入口是 ftplugin/java.lua。
-- 本配置面向 Neovim 0.12+，插件版本由 nvim-pack-lock.json 记录。
-- 补充：snippets/mermaid.json 是 Mermaid 代码片段，JSON 不支持普通注释。
-- 其中 prefix 是触发词，description 是说明，body 是展开内容；${1:默认值} 是占位符，$0 是最终光标位置。

-- ① 基础设置：剪贴板、行号、Leader、缩进、鼠标等；先确定 Leader，再定义其他快捷键。
require("config.options")
-- ② 插件管理：用内置 vim.pack.add() 加载插件，后续模块才能调用各插件的 setup()。
require("config.plugins")
-- ③ 界面：Catppuccin 主题、图标、状态栏、文件标签、NERDTree 文件树。
require("config.ui")
-- ④ 语言服务：诊断、补全、格式化、Lua/JS/TS 服务，以及跳转定义、重命名等快捷键。
require("config.lsp")
-- ⑤ 编辑操作：包围符、自动配对、搜索、Flash 跳转、Git blame。
require("config.editing")
-- ⑥ 语法解析：按文件类型启用 Tree-sitter 高亮、缩进和折叠，提供解析器安装命令。
require("config.treesitter")
