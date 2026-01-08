#import "../index.typ": template, tufted
#show: template.with(title: "网站配置")

= 网站结构

模板主要由 5 个部分组成：

- `config.typ` - 核心布局配置文件
- `content/` - 存储所有网页内容
- `assets/` - 存储共享的资源，例如全局 CSS、JS 脚本、图标等
- `tufted-lib/` - Typst 样式库和功能模块
- `build.py` / `Makefile` - 用于构建网站的脚本

== 可用函数

`tufted` 包目前提供了以下三个函数：

- `tufted-web` - 主模板，用于创建网页
- `margin-note` - 在边栏中放置内容（侧边注）
- `full-width` - 将内容放在全宽容器中

具体使用见 #link("../typst-example/")[Typst 功能速览与样例]。

== 主要配置

在 `config.typ` 中，你可以通过自定义从本地 `tufted-lib` 导入的 `tufted-web` 模板来定义自己的模板。项目已将 `tufted` 包的源代码集成到 `tufted-lib/` 目录中，无需从外部导入。

=== 基础配置示例

```typst
#import "tufted-lib/tufted.typ"

#let template = tufted.tufted-web.with(
  // 顶部导航栏的链接和标签
  header-links: (
    "/": "首页",
    "/Blog/": "博客",
    "/CV/": "简历",
    "/Docs/": "文档",
  ),
  // 网站标题（显示在浏览器标签页）
  title: "我的个人网站",
  // 语言设置
  lang: "zh",
)
```

=== 自定义 Header 和 Footer

你还可以自定义页面顶部的 header 元素和底部的 footer 元素：

```typst
#let template = tufted.tufted-web.with(
  header-links: (
    "/": "首页",
    "/Blog/": "博客",
  ),
  title: "我的网站",

  // 自定义 header 元素（显示在导航栏上方）
  header-elements: (
    [你好 Ciallo～(∠・ω< )⌒☆],
    [欢迎访问我的博客],
  ),

  // 自定义 footer 元素（显示在页面底部）
  footer-elements: (
    [© 2026 我的名字. 保留所有权利。],
    [#link("mailto:example@example.com")[联系我]],
  ),
)
```

`header-elements` 和 `footer-elements` 都接受数组，每个元素之间会自动添加换行。

=== 自定义样式

项目提供了两个 CSS 文件：

- `assets/tufted.css` - 主样式表，包含所有默认样式（排版、代码块、表格、深色模式等）
- `assets/custom.css` - 自定义样式表，默认为空，供用户添加个性化样式

如果你想自定义网站样式，只需编辑 `assets/custom.css` 文件，添加你自己的 CSS 规则即可。例如：

```css
/* 修改主色调 */
:root {
  --primary-color: #0066cc;
}

/* 自定义标题样式 */
h1 {
  color: var(--primary-color);
  border-bottom: 2px solid var(--primary-color);
}
```

具体可参考 #link("../custom-styling/")[自定义样式]。

=== 自定义 JavaScript 脚本

项目内置了几个实用的 JavaScript 脚本，位于 `assets/` 目录中：

- `code-blocks.js` - 为代码块添加行号和复制按钮
- `format-headings.js` - 优化标题格式

这些脚本已在 `tufted-lib/tufted.typ` 中通过 `js-scripts` 参数自动加载。
如果你想添加自己的 JavaScript 脚本，有以下两种方式：

*方法 1：在 `config.typ` 中添加脚本*

在 `config.typ` 中扩展 `tufted-web` 配置，添加你的脚本路径到 `js-scripts` 参数：

```typst
#let template = tufted.tufted-web.with(
  header-links: ( /* ... */ ),
  title: "我的网站",

  // 添加自定义脚本
  js-scripts: (
    "/assets/code-blocks.js",
    "/assets/format-headings.js",
    "/assets/my-custom-script.js",  // 你的自定义脚本
  ),
)
```

*方法 2：直接在文档中嵌入脚本*

使用 `#html.script()` 函数直接在任何页面中嵌入 JavaScript 代码：

```typ
#html.script(
  defer: true,
  src: "https://static.cloudflareinsights.com/beacon.min.js",
  "data-cf-beacon": "{\"token\": \"my-token\"}",
)
```

函数具体用法可参考 #link("https://typst.app/docs/reference/html/typed/#functions-script")[官方文档]。

== 层级结构与继承

网站遵循层级结构。根目录从 `../config.typ` 导入，而子页面从其父目录的 `../index.typ` 文件导入，这样就能实现继承关系，无需从项目根路径导入。

`content/` 目录中所有的 `**/index.typ` 文件都会成为可访问的页面，其路径对应文件夹的路径（例如 `content/Blog/index.typ` → `example.github.io/Blog`）。使用 `#link("相对/路径/")[点击我]` 来链接到其他页面或目录中其他文件，详细链接用法可参见 #link("../typst-example/")[Typst 功能速览与样例]。

你可以在任何层级修改定义，子页面都会继承这些更改。例如，要改变页面标题，可以从父级导入定义并修改 `template`：

```typst
#import "../index.typ": template, tufted
// 该页面及其所有子页面都将在浏览器标签中显示为 "新标题"
#show: template.with(title: "新标题")
```
