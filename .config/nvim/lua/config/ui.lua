-- 界面配置：主题 → 图标 → 状态栏 → 文件标签 → 文件树。
-- buffer 是文件内容缓冲区，window 是显示 buffer 的窗口，tabpage 是一组窗口布局。
-- 本文件顶部标签展示 buffer，不等同于 Vim 原生 tabpage。
-- 快捷键中 <leader> 是空格，<S-h>/<S-l> 是 Shift+h/Shift+l（即大写 H/L）。

-- 初始化主题，再通过 colorscheme 命令真正应用。
require("catppuccin").setup({
  -- 使用 mocha 深色配色。
  flavour = "mocha",
  -- 覆盖行号颜色；colors 是主题提供的调色板。
  custom_highlights = function(colors)
    return {
      -- 普通行号使用较清晰的次级文字色。
      LineNr = { fg = colors.subtext0 },
      -- 光标上方的相对行号颜色。
      LineNrAbove = { fg = colors.subtext0 },
      -- 光标下方的相对行号颜色。
      LineNrBelow = { fg = colors.subtext0 },
      -- 当前行号用黄色加粗突出显示。
      CursorLineNr = { fg = colors.yellow, bold = true },
    }
  end,
})
-- 应用上面配置好的 Catppuccin Mocha 主题。
vim.cmd("colorscheme catppuccin-mocha")
-- 启用文件图标；未知类型也使用默认图标，显示效果取决于终端字体。
require("nvim-web-devicons").setup({ default = true })
-- 配置底部状态栏。
require("lualine").setup({
  options = {
    -- 让状态栏与编辑器主题一致。
    theme = "catppuccin-mocha",
    -- 所有分屏共用状态栏，对应 options.lua 中的 laststatus = 3。
    globalstatus = true,
    -- 允许状态栏组件显示图标。
    icons_enabled = true,
    -- 同一区域内的组件用竖线分隔。
    component_separators = "|",
    -- 不同区域之间不额外绘制分隔符。
    section_separators = "",
  },
  -- a/b/c 是左侧区域，x/y/z 是右侧区域。
  sections = {
    -- 当前模式，如 NORMAL、INSERT。
    lualine_a = { "mode" },
    -- Git 分支和诊断数量。
    lualine_b = { "branch", "diagnostics" },
    -- 文件名；path = 1 显示相对路径。
    lualine_c = { { "filename", path = 1 } },
    -- 文件编码、彩色文件类型图标及类型文字。
    lualine_x = { "encoding", { "filetype", colored = true, icon_only = false } },
    -- 当前阅读位置在文件中的百分比。
    lualine_y = { "progress" },
    -- 光标所在行、列。
    lualine_z = { "location" },
  },
})
-- Remove a file tab without removing the windows that display it.
-- 关闭一个文件 buffer，同时保留显示它的窗口及分屏布局；不会删除磁盘文件。
local function close_file_tab(buf)
  -- 未传入编号时使用当前 buffer。
  buf = buf or vim.api.nvim_get_current_buf()
  -- buffer 已不存在时直接返回。
  if not vim.api.nvim_buf_is_valid(buf) then return end
  -- 仅处理普通文件，排除终端、帮助、文件树等特殊 buffer。
  if vim.bo[buf].buftype ~= "" then
    vim.notify("请在代码窗口中关闭文件标签。", vim.log.levels.INFO)
    return
  end
  -- 拒绝关闭有未保存修改的文件，提示用户先保存。
  if vim.bo[buf].modified then
    vim.notify("文件尚未保存，请先 :w 保存后再关闭。", vim.log.levels.WARN)
    return
  end
  -- 替代文件必须有效、在 buffer 列表中、属于普通文件，且不是正在关闭的文件。
  local function usable(candidate)
    return candidate ~= buf and vim.api.nvim_buf_is_valid(candidate)
      and vim.bo[candidate].buflisted and vim.bo[candidate].buftype == ""
  end
  -- 优先选择 alternate buffer（#，通常是上一个访问的文件）。
  local replacement = vim.fn.bufnr("#")
  -- 上一个文件不可用时，遍历 buffer 列表找其他普通文件。
  if not usable(replacement) then
    replacement = nil
    for _, candidate in ipairs(vim.api.nvim_list_bufs()) do
      if usable(candidate) then replacement = candidate; break end
    end
  end
  -- 遍历各窗口，把正在显示待关闭文件的窗口换成替代 buffer。
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      -- 没有其他文件可显示时，新建一个空白的普通 buffer。
      replacement = replacement or vim.api.nvim_create_buf(true, false)
      -- 只替换窗口内容，不关闭窗口，所以分屏布局得以保留。
      vim.api.nvim_win_set_buf(win, replacement)
    end
  end
  -- 最后删除内存中的 buffer；force = false 不强制丢弃修改。
  vim.api.nvim_buf_delete(buf, { force = false })
end
-- 配置顶部文件标签栏。
require("bufferline").setup({
  options = {
    -- 标签对应已打开的文件 buffer；Vim 自身的 tabpage 仍可单独使用。
    mode = "buffers", -- Editor-style file tabs; Vim tab pages remain available.
    -- 点击标签关闭按钮时使用上面的保护逻辑。
    close_command = close_file_tab,
    -- 右键点击标签也执行同样的关闭逻辑。
    right_mouse_command = close_file_tab,
    -- 在标签上显示内置 LSP 的诊断信息。
    diagnostics = "nvim_lsp",
    -- 只有一个文件时也显示标签栏。
    always_show_bufferline = true,
    -- 显示文件类型图标。
    show_buffer_icons = true,
    -- 标签间使用细分隔线。
    separator_style = "thin",
    -- 文件树打开时，在其上方预留对应区域并居中显示 Files。
    offsets = { { filetype = "nerdtree", text = "Files", text_align = "center" } },
    -- 标签栏只显示普通文件，过滤帮助、终端等特殊 buffer。
    custom_filter = function(buf)
      return vim.bo[buf].buftype == ""
    end,
  },
})
-- 普通模式 H：切到上一个文件标签。
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous file tab" })
-- 普通模式 L：切到下一个文件标签。
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next file tab" })
-- 空格 w：关闭当前文件标签，保留窗口布局。
vim.keymap.set("n", "<leader>w", function() close_file_tab() end, { desc = "Close file tab, keep window layout" })
-- 空格 Shift+w：关闭其他普通文件标签；未保存的文件仍由保护逻辑保留。
vim.keymap.set("n", "<leader>W", function()
  -- 记录当前文件，用于遍历时排除它。
  local current = vim.api.nvim_get_current_buf()
  -- 要求从普通代码窗口发起操作。
  if vim.bo[current].buftype ~= "" then
    vim.notify("请在代码窗口中关闭其他文件标签。", vim.log.levels.INFO)
    return
  end
  -- 遍历所有 buffer，只对当前文件之外的普通、已列出文件尝试关闭。
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
      close_file_tab(buf)
    end
  end
end, { desc = "Close other file tabs, keep window layout" })
-- 文件树宽度设为 32 列。
vim.g.NERDTreeWinSize = 32
-- 显示以点开头的隐藏文件。
vim.g.NERDTreeShowHidden = 1
-- 浏览文件树时不自动改变 Neovim 的工作目录。
vim.g.NERDTreeChDirMode = 0
-- 空格 e：打开或关闭文件树。
vim.keymap.set("n", "<leader>e", "<cmd>NERDTreeToggle<cr>", { desc = "Toggle file tree" })
-- 空格 l：在文件树中定位当前文件（这里是小写字母 L）。
vim.keymap.set("n", "<leader>l", "<cmd>NERDTreeFind<cr>", { desc = "Locate current file in tree" })
-- 垂直分屏
vim.keymap.set("n", "<leader>s", "<cmd>split<cr>",{desc="split"})
-- 水平分屏
vim.keymap.set("n", "<leader>v", "<cmd>vsplit<cr>",{desc="vsplit"})
