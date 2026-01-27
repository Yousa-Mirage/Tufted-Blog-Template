#import "../index.typ": template, tufted
#show: template.with(
  title: "自定义样式",
  description: "自定义样式文档，介绍了如何修改网站的视觉外观。",
)

= 自定义样式/脚本

网站的视觉外观由 CSS 控制，这导致很多样式无法在 Typst 中直接修改，如字号、文字颜色等。

如需修改样式，你需要直接修改 CSS 样式文件。

== 默认样式表

`tufted` 内部默认加载了三个样式表：

- `assets/tufte.min.css`: 原初的 Tufte 样式表
- `assets/tufted.css`: 深度修改的模板样式表
- `assets/theme.css`: 控制深色/浅色模式的样式表

依次为原初的 Tufte 样式表、模板适配样式表、自定义样式表。

== 自定义样式

`tufted` 模板接受一个 `css` 数组参数，用于指定自定义的样式表路径，默认参数为 `assets/custom.css`。传入的样式表将被加载在默认样式表之后，因此将覆盖默认样式表中的规则。例如：

```typst
#let template = tufted.tufted-web.with(
  // ...
  css: ("/assets/custom.css"),
  // ...
)
```

要自定义网站的样式，只需修改 `assets/custom.css`。例如，要更改链接颜色：

```css
a {
  color: #ff0000;
}
```

== 自定义 JS 脚本

项目默认为每个页面加载了以下 JavaScript 脚本，这些脚本均位于 `assets/` 目录中：

- `code-blocks.js` - 为代码块添加行号和复制按钮
- `format-headings.js` - 优化标题格式
- `theme-toggle.js` - 控制深色/浅色模式切换
- `marginnote-toggle.js` - 控制侧边注的显示/隐藏（改善移动端体验）

这些脚本已在 `tufted-lib/tufted.typ` 中通过 `js-scripts` 参数自动加载。

如果你想添加自己的 JavaScript 脚本，可以通过 `tufted-web` 的 `js-scripts` 参数来实现，该参数接受一个数组，用于指定自定义的 JavaScript 脚本路径。例如：

```typst
// config.typ
#let template = tufted.tufted-web.with(
  // ...
  js-scripts: ("/assets/custom.js"),
  // ...
)
```

如果需要单独针对某个页面添加 JavaScript 脚本，可以在该页面的元数据中指定 `js-scripts` 参数：

```typst
#import "../index.typ": template, tufted
#show: template.with(
  title: "自定义样式",
  description: "自定义样式文档",
  js-scripts: ("/assets/page-specific.js"),
)
```

