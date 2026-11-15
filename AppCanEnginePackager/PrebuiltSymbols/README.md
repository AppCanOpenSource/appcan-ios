# Ono/pop 预编译框架符号

基础工程中的 Ono/pop 仅在维护者升级依赖时手动同步。这里保存与 `AppCanPlugin/AppCanPlugin/uexFrameworks/` 中两个 framework **同一次 Release 构建**产生的 dSYM；普通引擎出包不会覆盖这两个 framework。

每次手动更新任一依赖时，须同时替换基础工程的完整 framework 与这里对应的完整 `.framework.dSYM`，再用 `xcrun dwarfdump --uuid` 核对二进制和 `Contents/Resources/DWARF/` 下文件的 arm64 UUID。出包器也会执行相同校验，不一致时停止出包。
