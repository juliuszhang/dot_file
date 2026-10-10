-- 基础选项，由 init.lua 最先加载。
-- vim.opt 设置编辑器选项；vim.g 设置全局变量；vim.cmd 执行 Vim 命令。
-- vim.keymap.set 定义快捷键；vim.bo[编号] 访问指定 buffer（文件缓冲区）的选项。

-- Use the system clipboard for default yank, delete, and paste operations.
-- 默认复制 y、删除 d、粘贴 p 使用系统剪贴板（需要可用的剪贴板支持）。
-- 删除也可能覆盖剪贴板；只删除不保存内容可用黑洞寄存器，例如 "_dd。
vim.opt.clipboard = "unnamedplus"

-- 本配置的插件均为 Lua，关闭 Python/Ruby/Perl/Node 外部插件接口，省去启动探测和 checkhealth 警告。
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Show the current line number and relative numbers on surrounding lines.
-- 显示当前行的实际行号。
vim.opt.number = true
-- 其他行显示距当前行的行数，便于使用 3j、5k 等相对移动。
vim.opt.relativenumber = true

-- 文件类型识别（含 ftplugin/缩进）和传统语法高亮在 Neovim 中默认开启，无需再设置。

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
-- a = 在各编辑模式中启用鼠标，可点击定位、选择文本、拖动分屏边界。
vim.opt.mouse = "a"

-- 小写搜索忽略大小写；包含大写时精确匹配。
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- 新分屏出现在右侧/下方，光标周围保留少量可见上下文。
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
-- 始终预留左侧标记栏，避免诊断图标出现时正文左右跳动。
vim.opt.signcolumn = "yes"
-- :s 替换时在正文实时预览，并在下方小窗口列出所有受影响的行。
vim.opt.inccommand = "split"
-- 高亮光标所在行，便于在大屏或分屏间定位光标。
vim.opt.cursorline = true
-- 有未保存修改时 :q 弹出“保存/不保存/取消”，而不是直接报 E37。
vim.opt.confirm = true
-- 长行折行后，续行保持与首行相同的缩进。
vim.opt.breakindent = true
-- 光标停止 250 毫秒即视为停留（默认 4 秒），LSP 同名高亮等更及时，交换文件也更早写入。
vim.opt.updatetime = 250
-- 打开文件时默认全部展开；Tree-sitter 折叠规则见 treesitter.lua。
vim.opt.foldlevel = 99

-- 复制时短暂高亮被复制的范围，确认复制内容是否正确。
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("UserYankHighlight", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- 回到编辑器或切回文件时检查磁盘更新；未保存的 buffer 不自动覆盖。
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("UserChecktime", { clear = true }),
  callback = function(event)
    if vim.bo[event.buf].buftype == "" and not vim.bo[event.buf].modified
      and vim.fn.getcmdwintype() == "" and vim.fn.mode() == "n" then
      vim.cmd("checktime " .. event.buf)
    end
  end,
})
