local jdtls_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
if vim.fn.executable(jdtls_bin) ~= 1 then
  vim.notify("Install the Java language server with :MasonInstall jdtls, then reopen this file.", vim.log.levels.WARN)
  return
end

-- Homebrew's JDK is not necessarily registered with macOS java_home.
local java_home = vim.env.JAVA_HOME
if not java_home or vim.fn.executable(java_home .. "/bin/java") ~= 1 then
  for _, candidate in ipairs({
    "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home",
    "/usr/local/opt/openjdk/libexec/openjdk.jdk/Contents/Home",
  }) do
    if vim.fn.executable(candidate .. "/bin/java") == 1 then
      java_home = candidate
      break
    end
  end
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
