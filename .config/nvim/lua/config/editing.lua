-- 日常编辑增强与搜索快捷键。
-- <leader> 是空格；n = 普通模式，x = 可视选择模式，o = 等待动作的操作符模式。
-- 例如 <leader><leader>s 就是依次按 空格、空格、s；<cmd>...<cr> 表示执行命令并回车。

-- 启用包围符编辑并使用默认设置，例如给文本添加/替换/删除括号或引号。
require("nvim-surround").setup({})
-- 启用括号、引号等字符的自动配对。
require("nvim-autopairs").setup({})
-- 启用 Flash 跳转，但关闭其 char 模式，保留 f/F/t/T 的原有字符查找行为。
require("flash").setup({ modes = { char = { enabled = false } } })
-- 文件和全文搜索包含隐藏配置文件，仍遵循 .gitignore，并排除 Git 内部数据。
require("telescope").setup({
  pickers = {
    find_files = { find_command = { "rg", "--files", "--hidden", "--glob", "!.git", "--color", "never" } },
    live_grep = { additional_args = { "--hidden", "--glob", "!.git" } },
  },
})

-- 从文件确定搜索范围，避免从主目录启动 nvim 后误搜整个主目录。
-- 优先使用整个 Git 仓库；无 Git 时采用最近的构建标记或文件所在目录。
local function search_root()
  local file = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype ~= "" or file == "" then return vim.fn.getcwd() end
  local config = vim.fs.normalize(vim.fn.stdpath("config"))
  if vim.startswith(vim.fs.normalize(file), config .. "/") then return config end
  return vim.fs.root(0, { ".git" })
    or vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts", "package.json", "pyproject.toml", "Cargo.toml", "go.mod" })
    or vim.fs.dirname(file)
end

-- 空格 f f：按文件名查找文件。
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files({ cwd = search_root() })
end, { desc = "Find project files" })
-- 大写 F/G 保留按当前工作目录搜索的入口，便于临时跨项目查找。
vim.keymap.set("n", "<leader>fF", "<cmd>Telescope find_files<cr>", { desc = "Find files in working directory" })
-- 空格 a：切换当前 tabpage 的 Git blame，查看每行对应的提交归属。
vim.keymap.set("n", "<leader>a", function()
  -- 记住操作前所在窗口，关闭 blame 后尽量返回这里。
  local original_win = vim.api.nvim_get_current_win()
  -- 只遍历当前 tabpage（窗口布局页）里的窗口。
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- 发现已打开的 Fugitive blame 窗口时，切换过去执行关闭。
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "fugitiveblame" then
      vim.api.nvim_set_current_win(win)
      -- Use Fugitive's own close action to restore the source window.
      -- 使用 Fugitive 自己的 gq 关闭动作，以恢复源码窗口。
      vim.cmd.normal("gq")
      -- 原窗口仍存在才切回，避免访问被关闭的窗口。
      if vim.api.nvim_win_is_valid(original_win) then
        vim.api.nvim_set_current_win(original_win)
      end
      return
    end
  end
  -- 没有打开 blame 时，先检查当前文件是否属于 Git 仓库。
  if vim.fn.FugitiveGitDir() == "" then
    vim.notify("Current file is not in a Git repository", vim.log.levels.WARN)
    return
  end
  -- 调用 Fugitive 展示当前文件的逐行提交信息。
  vim.cmd("Git blame")
end, { desc = "Toggle Git annotate (blame)" })
-- 空格 f g：按内容搜索项目文本，live_grep 通常调用外部 rg（ripgrep）。
vim.keymap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep({ cwd = search_root() })
end, { desc = "Search project text" })
vim.keymap.set("n", "<leader>fG", "<cmd>Telescope live_grep<cr>", { desc = "Search text in working directory" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
-- 空格 f b：搜索已打开的 buffer。
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find open buffers" })
-- 空格 f h：搜索 Neovim/插件帮助标签。
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Search help" })
-- 空格 空格 s：启动 Flash，输入搜索内容后按提示标签跳转；支持选择和操作符组合。
vim.keymap.set({ "n", "x", "o" }, "<leader><leader>s", function()
  require("flash").jump()
end, { desc = "Flash: search and jump" })

-- 复用的按行跳转函数：forward 为 true 向下，为 false 向上。
local function flash_line(forward)
  require("flash").jump({
    -- 使用搜索模式；max_length = 0 直接进入标签选择；不绕回文件开头/结尾，只处理当前窗口。
    search = { mode = "search", max_length = 0, forward = forward, wrap = false, multi_window = false },
    -- 把跳转标签放在匹配位置之后，偏移为 0 行、0 列。
    label = { after = { 0, 0 } },
    -- ^ 匹配行首，因此每个候选跳转目标对应一行。
    pattern = "^",
  })
end
-- 空格 空格 j：选择下方某一行并跳转。
vim.keymap.set({ "n", "x", "o" }, "<leader><leader>j", function() flash_line(true) end, { desc = "Flash: line below" })
-- 空格 空格 k：选择上方某一行并跳转。
vim.keymap.set({ "n", "x", "o" }, "<leader><leader>k", function() flash_line(false) end, { desc = "Flash: line above" })
