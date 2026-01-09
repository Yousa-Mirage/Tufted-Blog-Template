#import "../index.typ": template, tufted
#show: template.with(title: "Changelog")

= 更新日志 / Changelog

== Develop

开发中的更新内容将在此记录。

- 将 GitHub Actions 工作流由 Makefile 迁移至 uv
- 微调了切换按钮的位置，增加了距右侧边缘的距离
- 修复了链接下划线可能粗细不一致的问题

== v0.3.0

=== 优化

- 深色模式升级：添加了美观的浅色/深色模式切换按钮，并彻底优化了深色模式下的显示效果
- 为超长公式块添加了横向滚动条，支持滑动查看完整公式
- 优化了代码块的横向滚动条体验

=== 重构

- 脚本合并：合并了 `assets/copy-code.js` 和 `assets/line-numbers.js`，统一为单个脚本 `assets/code-blocks.js`
- 样式整合：清理了 CSS 文件结构，将 `assets/custom.css` 中的自定义样式完全整合至 `assets/tufted.css` 中，保持 `assets/custom.css` 空白

== v0.2.0

=== 新功能与重构

- 将 #link("https://github.com/vsheg/tufted")[`tufted`] 的源代码直接集成进项目
- 使用 `#html.script()` 嵌入 js 脚本，从而支持方便的脚本扩展 (#link("https://github.com/batkiz")[\@batkiz])
- 支持了自定义网站 header 和 footer 元素，可访问 #link("https://tufted-blog.pages.dev/")[示例网站] 查看效果 (#link("https://github.com/batkiz")[\@batkiz])
- 添加了交叉引用跳转功能

=== 优化与修复

- 优化了表格边框样式，现在会生成美观的 HTML 表格，可访问 #link("https://tufted-blog.pages.dev/Docs/typst-example/#tbl1")[示例网站] 查看效果
- 优化了块级公式的显示效果
- 修复了 FireFox 下公式显示异常的问题
- 使 footer 始终位于页面底部

== v0.1.1

- 优化深色模式效果

== v0.1.0

初次发布
