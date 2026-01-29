# 更新日志

[English version](CHANGELOG_en.md)

## 开发阶段

开发中的更新内容将在此记录。

- 修复：修复主题切换问题，重新打开网页时会自动跟随系统主题，而不是使用上次手动选择的主题

## v1.0.0

- 功能：在新标签页中打开外部链接和 PDF 链接（[#15](https://github.com/Yousa-Mirage/Tufted-Blog-Template/pull/15), [@yanwenwang24](https://github.com/yanwenwang24)）
- 功能：增加了丰富的 SEO 元数据支持，具体内容见[网站配置](https://tufted-blog.pages.dev/Docs/website-config/)（[#16](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues/16), [#17](https://github.com/Yousa-Mirage/Tufted-Blog-Template/pull/17), [@yanwenwang24](https://github.com/yanwenwang24)）
- 功能：增加了 RSS 订阅支持，具体内容见[网站配置](https://tufted-blog.pages.dev/Docs/website-config/)（[#19](https://github.com/Yousa-Mirage/Tufted-Blog-Template/pull/19), [@ghost-him](https://github.com/ghost-him)）
- *BREAKING*：现在应该在 `config.typ` 中使用 `website-title` 参数来设置网站标题，对于每个页面的标题，仍然使用 `title` 参数
- 样式：统一了 `table` 和 `figure>table` 的显示效果，实现了居中和自动列宽
- 修复：强制构建时未清理旧文件的问题
- 重构：将最低支持的 Python 版本更新至 3.10
- 重构：调整了 `tufted-lib/tufted.typ` 中的 `tufted-web` 模板函数
  - 将默认 CSS 与 JS 硬编码在函数内部，参数只用来接收自定义文件
  - 在函数内部将`icon` 硬编码为 `/assets/favicon.ico`
  - **BERAKING：**移除了 `icon`、`page-path` 参数，`lang` 默认值改为 `zh`

## v0.5.0

- 优化了移动端的边栏显示效果（[#14](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues/14)），为边栏内容添加了灰色背景，同时：
  - `footnote` 在移动端默认折叠，点击序号可以展开
  - `marginnote`、`figure-caption` 在移动端默认展开
- 略微缩小了 `article` 元素的上下边距
- 修复了行内公式会受 `p { text-indent: 2em; }` 影响的问题（[#12](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues/12)）
- 修复了内容不足时仍然显示滚动条的问题（[#13](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues/13)）
- 修复了公式在移动端显示位置不正确的问题
- 修复了图片在移动端会被拉伸且不居中的问题

## v0.4.0

- 优化了切换按钮的位置，增加了距右侧边缘的距离
- 调整了图片、表格的显示效果，在正文栏内默认居中
- 修复了链接下划线可能粗细不一致的问题
- 修复了 `#quote-box()` 超出正文宽度的问题
- 将 GitHub Actions 工作流由 Makefile 迁移至 uv

## v0.3.0

- 深色模式升级：添加了美观的浅色/深色模式切换按钮，并彻底优化了深色模式下的显示效果
- 为超长公式块添加了横向滚动条，支持滑动查看完整公式
- 优化了代码块的横向滚动条体验
- 脚本合并：合并了 `assets/copy-code.js` 和 `assets/line-numbers.js`，统一为单个脚本 `assets/code-blocks.js`
- 样式整合：清理了 CSS 文件结构，将 `assets/custom.css` 中的自定义样式完全整合至 `assets/tufted.css` 中，保持 `assets/custom.css` 空白

## v0.2.0

- 支持了自定义网站 header 和 footer 元素，可访问 [示例网站](https://tufted-blog.pages.dev/) 查看效果 ([@batkiz](https://github.com/batkiz))
- 添加了交叉引用跳转功能
- 优化了表格边框样式，现在会生成美观的 HTML 表格，可访问 [示例网站](https://tufted-blog.pages.dev/Docs/typst-example/#tbl1) 查看效果
- 优化了块级公式的显示效果
- 修复了 FireFox 下公式显示异常的问题
- 使 footer 始终位于页面底部
- 将 [`tufted`](https://github.com/vsheg/tufted) 的源代码直接集成进项目
- 使用 `#html.script()` 嵌入 js 脚本，从而支持方便的脚本扩展 ([@batkiz](https://github.com/batkiz))

## v0.1.1

- 优化了深色模式效果

## v0.1.0

- 初次发布
