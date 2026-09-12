# dot_file

macOS 上的 tmux、IdeaVim 和 Neovim 配置，按用户主目录结构保存。

## 安装

需要 Neovim 0.12+、tmux、Git、ripgrep、tree-sitter CLI、C 编译器、Python 3.9+ 和可运行 jdtls 的现代 JDK。

先备份已有配置，再将 `.tmux.conf` 和 `.ideavimrc` 放入用户主目录，将 `.config/nvim` 中的文件放入 `~/.config/nvim`。

JetBrains IDE 需安装并启用 IdeaVim。配置中的 `keep-english-in-normal` 需要 IdeaVimExtension；其他扩展选项和 `Plug` 声明也需对应的 IdeaVim 扩展支持。

Neovim 首次启动会由内置 `vim.pack` 安装锁定版本的插件。随后运行：

```vim
:MasonInstall jdtls lua-language-server typescript-language-server
:lua require('nvim-treesitter').install({'java', 'lua'})
```

等待安装完成后重新打开 Java 文件。更新插件使用 `:lua vim.pack.update()`。

Java LSP 会依次检查 `JDTLS_JAVA_HOME`、`JAVA_HOME`、Homebrew 和 macOS 注册的 JDK，仅选用 JDK 21+ 启动 jdtls。项目的 `JAVA_HOME` 可以保留为 Java 8；Java 8 项目仍需另行配置项目 runtime。可设置 `JDTLS_JAVA_HOME` 单独指定语言服务器的 JDK。

编辑 `~/.config/nvim` 内的 Lua 文件时，自动以该目录为 LSP 根目录并加载 LuaJIT、`vim` 全局变量和 Neovim API 库。其他 Lua 项目按自己的配置文件或 Git 根目录识别。

tmux 使用 `tmux source-file ~/.tmux.conf` 加载。复制功能调用 macOS 的 `pbcopy`；当前重载快捷键使用 `/Users/hikari/.tmux.conf`，其他用户名需调整该路径。

## 快捷键

Neovim Leader 是空格：

底部 lualine 显示模式、文件名、诊断、文件类型图标和位置；顶部 bufferline 显示已打开文件（buffer 标签）。使用支持真彩色的终端，字体选择 Nerd Font（本机已安装 JetBrainsMono Nerd Font）。

补全使用 blink.cmp，来源包括 LSP、路径、代码片段和当前缓冲区；候选项预选开启，自动插入关闭，使用 `enter` 按键预设，`Ctrl-Space` 映射已清空。Lua、JavaScript/TypeScript 和 Java 的语言服务器配置分别位于 `init.lua` 和 `ftplugin/java.lua`。

`gr` 立即打开 Telescope 引用列表，不再等待默认 `gr…` 按键序列；重命名使用 `<leader>rn`，代码操作使用 `<leader>ca`。`Shift-h/l` 用于切换文件，覆盖 Vim 原生的屏幕顶部/底部跳转。

| 按键 | 功能 |
| --- | --- |
| `gd` / `gy` / `gi` / `gr` | 定义 / 类型 / 实现 / 引用 |
| `<leader>i` | Java 整理导包 |
| `<leader>a` | 切换 Git blame（再次按下关闭） |
| `<leader>e` / `<leader>l` | NERDTree 开关 / 定位当前文件 |
| `Shift-h` / `Shift-l` | 前一个 / 后一个文件标签 |
| `<leader>w` | 关闭当前文件标签并保留窗格布局，未保存时阻止关闭；最后一个文件关闭后保留空白编辑区 |
| `<leader>W` | 关闭其他文件标签，保留未保存文件 |
| `<leader>F` | LSP 格式化当前文件 |
| `<leader>ff` / `<leader>fg` | 文件 / 全文搜索 |
| `<leader>cs` / `<leader>ds` | 项目 / 当前文件符号 |
| `<leader>D` / `<leader>fd` | 当前行诊断 / 诊断列表 |
| `[d` / `]d` | 前一个 / 后一个诊断 |
| `crc` / `crp` | 当前单词转小驼峰 / 大驼峰 |
| `crs` / `cru` | 当前单词转下划线 / 全大写下划线 |
| `<leader><leader>s` | Flash 搜索跳转 |
| `<leader><leader>j` / `<leader><leader>k` | Flash 向下 / 向上按行跳转 |
| `Ctrl-n`（普通模式） | 多光标选择当前单词，再次按下扩展选择 |
| `ysiw)` / `ds\"` | Surround 添加括号 / 删除双引号 |

tmux Prefix 是 `Ctrl-a`：`-` 上下分屏、`|` 左右分屏、`h/j/k/l` 切换窗格、`H/J/K/L` 调整尺寸、`r` 重载配置。`Prefix [` 进入 vi 复制模式，`v` 选择，`y` 复制，`q` 退出。

## IdeaVim

Leader 是空格，启用相对行号、系统剪贴板、智能大小写搜索及 NERDTree 项目树。

| 按键 | 功能 |
| --- | --- |
| `<leader>e` / `<leader>l` | 显示或隐藏项目树 / 定位当前文件 |
| `<leader>f` / `<leader>i` | 格式化代码 / 优化导包 |
| `<leader>r` / `<leader>m` | 重命名 / 提取方法 |
| `<leader>w` / `<leader>W` | 关闭当前编辑器 / 关闭其他编辑器 |
| `Shift-h` / `Shift-l` | 上一个 / 下一个标签页 |
| `<leader>b` | 切换断点 |
| `<leader>o` / `<leader>t` | 查找类 / 打开终端 |
| `[d` / `]d` | 上一个 / 下一个错误 |
| `<leader>Enter` | 清除搜索高亮 |
