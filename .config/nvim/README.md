# Neovim 配置

个人 Neovim 配置，使用内置 `vim.pack` 管理插件，`nvim-pack-lock.json` 记录插件版本。

## 环境

- Neovim 0.12+、Git。
- `ripgrep` 用于全文搜索；建议安装 `fd` 用于文件搜索。
- Java 语言服务需要 JDK 21+；可通过 `JDTLS_JAVA_HOME` 指定服务使用的 JDK，项目 JDK 可独立设置。
- 使用图标时建议选择 Nerd Font 终端字体。
- Tree-sitter 解析器安装需要对应的编译工具和插件要求的构建依赖。

## 安装

将仓库放到 `~/.config/nvim`（已有配置请先备份）。首次启动 Neovim 会安装缺失的插件。

打开 `:Mason`，按需要安装 `jdtls`、`lua-language-server` 和 `typescript-language-server`。
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

## 常用快捷键

Leader 为 **空格**，以下大写字母需要 Shift。

| 快捷键 | 功能 |
| --- | --- |
| `<leader>ff` | 搜索文件 |
| `<leader>fg` | 搜索项目文本 |
| `<leader>gi` | 回到上次插入位置并进入插入模式 |
| `gd` | 查找定义 |
| `gi` | 查找实现 |
| `<leader>o` | 搜索工作区符号，Java 过滤第三方和 JDK 类 |
| `<leader>O` | 搜索全部工作区符号，包含第三方和 JDK 类 |
| `<leader>ds` | 搜索当前文件符号 |
| `<leader>rn` | 重命名符号 |
| `<leader>ca` | 代码操作 |
| `<leader>F` | 格式化当前文件 |
| `<leader>i` | 整理 Java import |

语言服务相关快捷键在 LSP 连接当前文件后生效。补全使用 `blink.cmp`，Enter 确认候选项。
