-- Java 文件类型入口。
-- 开启 filetype plugin 后，Neovim 会为识别为 java 的 buffer 加载本文件。
-- require 获取 lua/config/java.lua 返回的模块表，再调用其 setup()。
-- 模块本身有 require 缓存，但这里的 setup() 仍会在各 Java buffer 加载时执行。
-- 它按项目启动或复用 jdtls，而不是为每个文件都创建独立的语言服务器。

require("config.java").setup()
