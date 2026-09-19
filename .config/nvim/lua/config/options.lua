-- 基础选项，由 init.lua 最先加载。
-- vim.opt 设置编辑器选项；vim.g 设置全局变量；vim.cmd 执行 Vim 命令。
-- vim.keymap.set 定义快捷键；vim.bo[编号] 访问指定 buffer（文件缓冲区）的选项。

-- Use the system clipboard for default yank, delete, and paste operations.
-- 默认复制 y、删除 d、粘贴 p 使用系统剪贴板（需要可用的剪贴板支持）。
-- 删除也可能覆盖剪贴板；只删除不保存内容可用黑洞寄存器，例如 "_dd。
vim.opt.clipboard = "unnamedplus"

-- Show the current line number and relative numbers on surrounding lines.
-- 显示当前行的实际行号。
vim.opt.number = true
-- 其他行显示距当前行的行数，便于使用 3j、5k 等相对移动。
vim.opt.relativenumber = true

-- Detect file types (including TypeScript and TSX) and load their syntax rules.
-- 开启文件类型识别、文件类型专属配置（ftplugin）和缩进规则。
vim.cmd("filetype plugin indent on")
-- 开启传统语法高亮；Tree-sitter 模块还会在解析器不可用时回退到它。
vim.cmd("syntax enable")

-- Set leaders before loading any plugins or mappings.
-- 全局快捷键前缀设为空格；例如 <leader>e 表示先按空格，再按 e。
vim.g.mapleader = " "
-- 文件类型专属映射常用的另一套前缀，也设为空格。
vim.g.maplocalleader = " "
-- n = 普通模式，x = 可视选择模式；<Nop> 取消空格原本的移动动作。
-- 插入模式不受影响；silent = true 表示不回显映射命令。
vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>", { silent = true })

-- Default to two spaces; project EditorConfig settings take precedence.
-- 输入缩进时使用空格，不会自动转换文件中已有的真实 Tab 字符。
vim.opt.expandtab = true
-- 自动缩进及 >>、<< 等操作，每一级默认占 2 列；项目规则可进一步覆盖。
vim.opt.shiftwidth = 2
-- 设为 -1 表示编辑时 Tab/退格涉及的缩进宽度跟随 shiftwidth。
vim.opt.softtabstop = -1
-- 已有 Tab 字符按每 2 列一个制表位显示，与“用空格还是 Tab 缩进”是两回事。
vim.opt.tabstop = 2
-- 把撤销历史保存到磁盘，重新打开文件后仍可撤销；这不是自动保存文件。
vim.opt.undofile = true
-- 启用真彩色，供主题使用完整的 RGB 颜色。
vim.opt.termguicolors = true
-- 3 = 所有分屏共用底部的一条全局状态栏。
vim.opt.laststatus = 3
-- 隐藏命令区域的 -- INSERT -- 等模式提示，模式由 lualine 状态栏展示。
vim.opt.showmode = false
-- 2 = 始终显示顶部标签栏区域，后续由 bufferline 展示文件标签。
vim.opt.showtabline = 2
-- 允许切换离开尚未保存的 buffer，使其留在后台；不会自动保存，也与隐藏文件无关。
vim.opt.hidden = true
-- a = 在各编辑模式中启用鼠标，可点击定位、选择文本、拖动分屏边界。
vim.opt.mouse = "a"

-- 注册自动命令：当文件类型被设定时运行回调，下面只针对 Java。
vim.api.nvim_create_autocmd("FileType", {
  -- 把规则归入 UserIndent；clear 清除该组旧规则，避免重新执行配置时重复注册。
  group = vim.api.nvim_create_augroup("UserIndent", { clear = true }),
  -- 匹配文件类型名 java，而不是文件名通配符 *.java。
  pattern = "java",
  -- event.buf 是触发此次事件的 buffer 编号。
  callback = function(event)
    -- 只把此 Java buffer 改为 4 列缩进；softtabstop = -1 会自动跟随。
    vim.bo[event.buf].shiftwidth = 4
    -- Java 中的真实 Tab 按 4 列制表位显示；expandtab 仍让新缩进使用空格。
    vim.bo[event.buf].tabstop = 4
  end,
})
