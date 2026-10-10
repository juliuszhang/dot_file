# Neovim 配置

个人 Neovim 配置，使用内置 `vim.pack` 管理插件，`nvim-pack-lock.json` 记录插件版本。

## 环境

- Neovim 0.12+、Git。
- `ripgrep` 用于文件和全文搜索。
- Java 语言服务需要 JDK 21+；可通过 `JDTLS_JAVA_HOME` 指定服务使用的 JDK，项目 JDK 可独立设置。
- 使用图标时建议选择 Nerd Font 终端字体。
- Tree-sitter 解析器安装需要对应的编译工具和插件要求的构建依赖。

## 安装

将仓库放到 `~/.config/nvim`（已有配置请先备份）。首次启动 Neovim 会安装缺失的插件。

打开 `:Mason`，按需要安装 `jdtls`、`lua-language-server` 和 `typescript-language-server`，
以及格式化工具 `stylua`、`prettierd`。
JS/TS 语言服务器还需要可用的 Node.js 环境。安装完成后重新打开 Neovim。

执行 `:TSInstallConfigured` 安装配置使用的语法解析器。

插件更新命令：`:lua vim.pack.update()`。

## 配置结构

| 文件 | 内容 |
| --- | --- |
| `init.lua` | 配置入口 |
| `lua/config/options.lua` | 基础选项、Leader |
| `lua/config/plugins.lua` | 插件声明 |
| `lua/config/ui.lua` | 主题、状态栏、标签、文件树 |
| `lua/config/editing.lua` | 编辑、搜索、跳转快捷键 |
| `lua/config/lsp.lua` | 内置 LSP、Blink 补全、诊断、语言服务快捷键 |
| `lua/config/java.lua` | JDT LS 启动与 Java 配置 |
| `ftplugin/java.lua` | Java 文件入口 |
| `lua/config/treesitter.lua` | 语法高亮和解析器安装命令 |
| `snippets/mermaid.json` | Mermaid 代码片段 |
| `stylua.toml` | 本配置的 Lua 格式（2 空格缩进） |

## 常用快捷键

Leader 为 **空格**，以下大写字母需要 Shift。

| 快捷键 | 功能 |
| --- | --- |
| `<leader>ff` | 搜索当前文件所在项目的文件，包含隐藏文件 |
| `<leader>fg` | 搜索当前文件所在项目的文本，包含隐藏文件 |
| `<leader>fF` / `<leader>fG` | 按当前工作目录搜索文件 / 文本 |
| `<Esc>` | 清除搜索高亮 |
| `<leader>s` / `<leader>v` | 上下 / 左右分屏，新窗口出现在下方 / 右侧 |
| `H` / `L` | 前一个 / 后一个文件标签 |
| `<leader>w` / `<leader>W` | 关闭当前 / 其他文件标签，保留布局和未保存文件 |
| `gd` | 查找定义 |
| `gri` | 查找实现（原生 `gi` 保持不变） |
| `grr` | 查找引用 |
| `<leader>o` | 搜索工作区符号，Java 过滤第三方和 JDK 类 |
| `<leader>O` | 搜索全部工作区符号，包含第三方和 JDK 类 |
| `<leader>ds` | 搜索当前文件符号 |
| `<leader>rn` | 重命名符号 |
| `<leader>ca` | 代码操作 |
| `<leader>F` | 格式化当前文件：Lua 用 stylua，JS/TS/JSON/Markdown 用 prettierd，其他回退到语言服务 |
| `<leader>i` | 整理 Java import |

语言服务相关快捷键在 LSP 连接当前文件后生效。补全使用 `blink.cmp`，Enter 确认候选项。

搜索优先定位到当前文件的 Git 仓库根目录；无 Git 时使用最近的构建标记目录，否则使用文件所在目录。
编辑 Neovim 自身配置时固定搜索 `~/.config/nvim`；无文件或特殊窗口则使用当前工作目录。
文件和全文搜索均遵循 `.gitignore`，排除 `.git` 内部数据；`fF` / `fG` 可配合 `:cd` 指定搜索范围。

回到编辑器或切回文件时自动检查磁盘更新，只自动重载没有未保存修改的文件。
普通搜索忽略大小写，包含大写字母时区分大小写。
`:s` 替换实时预览，复制时短暂高亮复制范围；有未保存修改时 `:q` 会询问是否保存。
Tree-sitter 同时负责缩进和折叠：`zM` 全部折叠、`za` 切换当前、`zR` 全部展开，打开文件时默认展开。
已关闭 Python/Ruby/Perl/Node 外部插件接口（本配置插件均为 Lua）。

## tmux 配合

配置位于 `~/.tmux.conf`，Prefix 保持为 `Ctrl-a`。

| 按键 | 功能 |
| --- | --- |
| Prefix `-` / `\|` | 上下 / 左右分屏，继承当前目录 |
| Prefix `c` | 在当前窗格目录新建窗口 |
| Prefix `h/j/k/l` | 切换窗格，切换后输入立即交给应用 |
| Prefix `H/J/K/L` | 调整窗格大小，可连续按 |
| Prefix `[`，然后 `v`、`y` | 进入 vi 复制模式、选择、复制到 macOS 剪贴板 |
| Prefix `r` | 重载 tmux 配置 |

支持鼠标选择窗格、拖动边框和滚轮回看；复制模式下 Enter 或鼠标拖选结束也会复制。
Ghostty 真彩色与焦点事件会传递给 Neovim，保留扩展按键协议，历史容量为每窗格 50000 行。
窗口和窗格从 1 开始编号，关闭窗口后自动重新编号；开启 OSC 52，程序（包括 SSH 中的 Neovim）可写入系统剪贴板。
状态栏使用 Catppuccin Mocha 配色（与 Neovim 主题一致，无需插件）；按下 Prefix 后左侧会话名由紫色变为红色。
终端类型和历史容量对新建窗格生效；Neovim 配置在重新启动编辑器后生效。

## 更新记录

- 2026-09-25：同步导航、LSP 项目识别及重复配置清理，补充搜索和 tmux 体验设置。
- 2026-10-09：删除残留插件 hop.nvim / vim-easymotion，新增 conform.nvim，blink.cmp 改用 Rust 模糊匹配。
- 2026-10-09：补充 Tree-sitter 缩进/折叠、常用选项、复制高亮，关闭外部插件接口，Java 缩进移入 `ftplugin/java.lua`；tmux RGB 设置改为不写死下标并增加 `xterm-256color`。

修改前建议先备份 `~/.tmux.conf` 与 `~/.config/nvim/`，恢复时退出 Neovim 后复制回原位并重载 tmux 配置。
