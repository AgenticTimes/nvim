# Neovim 配置

Doom Emacs 风格键位（Leader 为 `,`）的 Neovim 配置，面向"AI 写代码 + Neovim 查看"工作流。

## 目录结构

```
init.lua              入口（leader 设置、核心加载、插件装配）
lua/core/             核心配置（options、keymaps、theme、autosave、readonly）
lua/plugins/          插件 spec（按功能域拆分，lazy.nvim）
lua/lsp/              LSP 客户端配置（gopls/jdtls/marksman/angularls）
lua/custom/           Markdown 渲染、表格、链接等自定义模块
scripts/smoke.lua     headless 冒烟测试
doc/                  插件使用文档
```

## 主要特性

- **键位**：Doom Emacs 风格，`<Leader>` = `,`，which-key 实时提示；`,?` 弹出全部快捷键面板（legendary + telescope-ui-select）
- **查找**：fzf-lua（文件/搜索/symbols），telescope 保留给 vim.ui.select 场景
- **跳转**：flash.nvim（`s`/`S` 字符与 treesitter 节点跳转）
- **诊断**：trouble.nvim（`,xx` 聚合面板）
- **Git**：gitsigns（diff/blame）
- **AI**：opencode 终端集成 + pi.neovim
- **LSP**：Mason 管理服务器，nvim-lspconfig 装配（go/java/kotlin/ts/rust/clangd/markdown/angular）

## 冒烟测试

```bash
nvim --headless -u init.lua -c "luafile scripts/smoke.lua" -c "qa!" 2>&1 | grep SMOKE
```

