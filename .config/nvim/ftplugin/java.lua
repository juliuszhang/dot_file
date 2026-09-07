local jdtls_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
if vim.fn.executable(jdtls_bin) ~= 1 then
  vim.notify("Install the Java language server with :MasonInstall jdtls, then reopen this file.", vim.log.levels.WARN)
  return
end

-- Keep the language server's JDK independent of the project's JDK.
-- Java 8 JAVA_HOME is valid for a project, but cannot launch modern jdtls.
local function is_server_jdk(home)
  if not home or home == "" or vim.fn.executable(home .. "/bin/java") ~= 1 then return false end
  local result = vim.system({ home .. "/bin/java", "-version" }, { text = true }):wait(5000)
  local version = ((result.stderr or "") .. (result.stdout or "")):match('version%s+"(%d+)')
  return result.code == 0 and version and tonumber(version) >= 21
end

local java_home
for _, candidate in ipairs({
  vim.env.JDTLS_JAVA_HOME or "",
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
if not java_home and vim.fn.executable("/usr/libexec/java_home") == 1 then
  local result = vim.system({ "/usr/libexec/java_home", "-v", "21+" }, { text = true }):wait(5000)
  local candidate = vim.trim(result.stdout or "")
  if result.code == 0 and is_server_jdk(candidate) then java_home = candidate end
end
if not java_home then
  vim.notify("jdtls requires JDK 21+. Set JDTLS_JAVA_HOME to a modern JDK; keep JAVA_HOME for your project.", vim.log.levels.ERROR)
  return
end

local root = vim.fs.root(0, { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
  or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root, ":t") .. "-" .. vim.fn.sha256(root):sub(1, 12)
-- Avoid exhausting macOS file descriptors with recursive LSP watchers.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
require("jdtls").start_or_attach({
  cmd = { jdtls_bin, "-data", workspace },
  cmd_env = java_home and { JAVA_HOME = java_home, PATH = java_home .. "/bin:" .. vim.env.PATH } or nil,
  root_dir = root,
  capabilities = capabilities,
  settings = { java = { signatureHelp = { enabled = true } } },
})
