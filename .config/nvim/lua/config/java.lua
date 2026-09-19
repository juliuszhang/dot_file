-- Java 语言服务模块：由 ftplugin/java.lua 在打开 Java 文件时调用 setup()。
-- 使用 Mason 安装的 jdtls，通过 nvim-jdtls 为当前项目启动或复用语言服务。
-- 本配置为服务进程选择 JDK 21+；服务运行 JDK 与项目编译目标是不同概念。

-- 用表保存模块对外暴露的函数，末尾 return M 供 require() 获取。
local M = {}
-- 缓存成功找到的 JDK 路径，避免每次打开 Java 文件都重新运行探测命令。
local cached_java_home

-- Keep the server JDK independent of the project JDK.
-- 检查候选目录里是否有可运行的 Java，并且版本满足此配置的 21+ 条件。
local function is_server_jdk(home)
  -- 空路径或不存在可执行的 bin/java 时直接判定不合适。
  if not home or home == "" or vim.fn.executable(home .. "/bin/java") ~= 1 then return false end
  -- 执行 java -version，并最多等待 5000 毫秒取得结果。
  local result = vim.system({ home .. "/bin/java", "-version" }, { text = true }):wait(5000)
  -- Java 版本信息可能写到 stderr；合并两个输出流后提取版本号中的主版本。
  local version = ((result.stderr or "") .. (result.stdout or "")):match('version%s+"(%d+)')
  -- 要求进程正常退出、成功提取版本号，并且主版本不低于 21。
  return result.code == 0 and version and tonumber(version) >= 21
end

-- 按优先级寻找服务使用的 JDK，找到第一个合格路径即停止。
local function find_java_home()
  -- 有成功缓存时直接复用；未找到的结果为 nil，后续调用仍可重试。
  if cached_java_home then return cached_java_home end
  local java_home
  -- 先查显式环境变量，再查 Apple Silicon / Intel 常见 Homebrew 安装目录。
  for _, candidate in ipairs({
    -- 最高优先级：专门为 Java 语言服务设置的 JDK。
    vim.env.JDTLS_JAVA_HOME or "",
    -- 其次检查项目/终端的 JAVA_HOME，但仍需通过上面的版本检查。
    vim.env.JAVA_HOME or "",
    "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home",
    "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
    "/usr/local/opt/openjdk/libexec/openjdk.jdk/Contents/Home",
    "/usr/local/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
  }) do
    if is_server_jdk(candidate) then
      java_home = candidate
      break
    end
  end
  -- 前面的路径均不可用时，尝试 macOS 自带的 Java 安装查找工具。
  if not java_home and vim.fn.executable("/usr/libexec/java_home") == 1 then
    -- 让系统查找版本 21 及以上的 JDK，再检查返回路径能否实际运行。
    local result = vim.system({ "/usr/libexec/java_home", "-v", "21+" }, { text = true }):wait(5000)
    -- 移除命令输出路径末尾的换行和两端空白。
    local candidate = vim.trim(result.stdout or "")
    if result.code == 0 and is_server_jdk(candidate) then java_home = candidate end
  end
  -- 保存找到的路径供后续 Java buffer 复用。
  cached_java_home = java_home
  return java_home
end

-- 模块的公开入口；每个 Java 文件触发时都会执行，但服务可按项目复用。
function M.setup()
  -- 定位 Mason 安装的 jdtls 启动器。
  local jdtls_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
  -- 未安装时提示 :MasonInstall jdtls 并提前返回，不继续尝试启动。
  if vim.fn.executable(jdtls_bin) ~= 1 then
    vim.notify("Install the Java language server with :MasonInstall jdtls, then reopen this file.", vim.log.levels.WARN)
    return
  end

  -- 选择仅用于语言服务进程的 JDK。
  local java_home = find_java_home()
  -- 没有满足条件的 JDK 时给出提示；可单独设置 JDTLS_JAVA_HOME。
  if not java_home then
    vim.notify("jdtls requires JDK 21+. Set JDTLS_JAVA_HOME to a modern JDK; keep JAVA_HOME for your project.", vim.log.levels.ERROR)
    return
  end

  -- 从当前文件向上寻找 Maven、Gradle 或 Git 项目标记，确定服务的项目根目录。
  local root = vim.fs.root(0, { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
    -- 没有项目标记时，退回当前文件所在目录。
    or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  -- 每个项目使用独立的 jdtls 缓存目录：项目目录名 + 根路径哈希前 12 位，减少同名冲突。
  local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root, ":t") .. "-" .. vim.fn.sha256(root):sub(1, 12)
  -- Avoid exhausting macOS file descriptors with recursive LSP watchers.
  -- 获取并合并 Neovim 的基础 LSP 能力与 blink 补全能力。
  local capabilities = require("blink.cmp").get_lsp_capabilities(nil, true)
  -- 禁用服务器动态注册文件监听，避免递归监听在 macOS 上耗尽文件描述符。
  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
  -- 已有适用的项目服务时连接它，否则启动新进程。
  require("jdtls").start_or_attach({
    -- -data 指定 jdtls 的工作数据目录，不是项目源代码目录。
    cmd = { jdtls_bin, "-data", workspace },
    -- 只给语言服务子进程设置 JAVA_HOME 和优先 PATH，不修改父终端的项目环境。
    cmd_env = java_home and { JAVA_HOME = java_home, PATH = java_home .. "/bin:" .. vim.env.PATH } or nil,
    -- 用项目根目录划分语言服务的工作范围。
    root_dir = root,
    -- 把补全能力和文件监听限制交给语言服务器。
    capabilities = capabilities,
    -- 启用 Java 函数签名帮助，供补全插件展示参数提示。
    settings = { java = { signatureHelp = { enabled = true } } },
  })
end

-- require("config.java") 得到此表，从而可以调用 .setup()。
return M
