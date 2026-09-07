# dot_file

macOS 上的 Neovim 和 tmux 配置。

## 安装

需要 Neovim 0.12+、tmux、Git、ripgrep、tree-sitter CLI、C 编译器、Python 3.9+ 和可运行 jdtls 的现代 JDK。

先备份已有配置，再将 `.tmux.conf` 放入用户主目录，将 `.config/nvim` 中的文件放入 `~/.config/nvim`。

Neovim 首次启动会由内置 `vim.pack` 安装锁定版本的插件。随后运行：

```vim
:MasonInstall jdtls
:lua require('nvim-treesitter').install({'java', 'lua'})
```

等待安装完成后重新打开 Java 文件。更新插件使用 `:lua vim.pack.update()`。

Java 启动配置会优先使用 `JAVA_HOME`，否则寻找 Homebrew 的 OpenJDK；`JAVA_HOME` 必须指向能启动 jdtls 的现代 JDK。Java 8 项目需另行配置项目 runtime。

tmux 使用 `tmux source-file ~/.tmux.conf` 加载。复制功能调用 macOS 的 `pbcopy`；当前重载快捷键使用 `/Users/hikari/.tmux.conf`，其他用户名需调整该路径。

## 快捷键

Neovim Leader 是空格：

| 按键 | 功能 |
| --- | --- |
| `gd` / `gy` / `gi` / `gr` | 定义 / 类型 / 实现 / 引用 |
| `<leader>i` | Java 整理导包 |
| `<leader>a` | Git blame |
| `<leader>ff` / `<leader>fg` | 文件 / 全文搜索 |
| `<leader>cs` / `<leader>ds` | 项目 / 当前文件符号 |
| `<leader>e` / `<leader>fd` | 当前行诊断 / 诊断列表 |
| `[d` / `]d` | 前一个 / 后一个诊断 |
| `<leader>s` | EasyMotion 双字符跳转 |
| `ysiw)` / `ds\"` | Surround 添加括号 / 删除双引号 |

tmux Prefix 是 `Ctrl-a`：`-` 上下分屏、`|` 左右分屏、`h/j/k/l` 切换窗格、`H/J/K/L` 调整尺寸、`r` 重载配置。`Prefix [` 进入 vi 复制模式，`v` 选择，`y` 复制，`q` 退出。
