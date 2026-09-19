-- 配置入口：正常启动 Neovim 时，从上到下执行本文件。
-- require("config.xxx") 会加载 lua/config/xxx.lua；同一模块通常只执行一次，随后使用缓存。
-- 阅读顺序建议沿用下方顺序；Java 的额外入口是 ftplugin/java.lua。
-- 本配置面向 Neovim 0.12+，插件版本由 nvim-pack-lock.json 记录。
-- 补充：snippets/mermaid.json 是 Mermaid 代码片段，JSON 不支持普通注释。
-- 其中 prefix 是触发词，description 是说明，body 是展开内容；${1:默认值} 是占位符，$0 是最终光标位置。

-- Neovim 0.12+; plugin versions are recorded in nvim-pack-lock.json
-- 剪贴板、行号、空格作为 Leader 键、缩进、鼠标等基础设置
-- ① 基础设置：剪贴板、行号、Leader、缩进等；先确定 Leader，再定义其他快捷键。
require("config.options")
-- 用内置 vim.pack.add() 管理插件，并设置部分插件加载前的选项
-- ② 插件管理：先加载插件，后续模块才能调用各插件的 setup()。
require("config.plugins")
-- Catppuccin 主题、状态栏、文件标签栏、NERDTree 文件树，以及相关快捷
-- ③ 界面：主题、图标、状态栏、文件标签、文件树。
require("config.ui")
-- 代码诊断、补全、语言服务，以及跳转定义、重命名等快捷键
-- ④ 语言服务：诊断、补全、Lua/JS/TS 服务，以及语言服务快捷键。
require("config.lsp")
-- 括号配对、包围符编辑、搜索、Flash 跳转、Git blame 等操作
-- ⑤ 编辑操作：包围符、自动配对、搜索、跳转、Git blame。
require("config.editing")
-- 根据文件类型启用语法解析高亮，并定义解析器安装命令
-- ⑥ 语法解析高亮：注册文件类型事件，提供手动安装解析器的命令。
require("config.treesitter")
