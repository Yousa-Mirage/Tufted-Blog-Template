#import "../index.typ": template, tufted
#show: template.with(title: "Changelog")

= 更新日志 / Changelog

== 2026-01-08

- 添加了交叉引用跳转功能
- 使 footer 始终位于页面底部
- 优化了表格边框样式，现在会生成美观的 HTML 表格
- 将 `assets/custom.css` 中的内容完全移动到 `assets/tufted.css`
- 合并 `assets/copy-code.js` 和 `assets/line-numbers.js` 为单个脚本 `assets/code-blocks.js`

== 2026-01-07

- 将 #link("https://github.com/vsheg/tufted")[`tufted`] 的源代码直接集成进项目
- 使用 `#html.script()` 嵌入 js 脚本 (#link("https://github.com/batkiz")[\@batkiz])
- 支持了自定义网站 header 和 footer 元素 (#link("https://github.com/batkiz")[\@batkiz])
- 优化了块级公式的显示效果
- 修复了 FireFox 下公式显示异常的问题

== 2026-01-04

- 优化深色模式效果

== 2026-01-02

初次发布
