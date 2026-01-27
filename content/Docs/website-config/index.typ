#import "../index.typ": template, tufted
#show: template.with(
  title: "网站配置",
  description: "网站配置文档",
)

= 网站配置

== 模板结构

模板主要由 5 个部分组成：

- `config.typ` - 核心布局配置文件
- `content/` - 存储所有网页内容
- `assets/` - 存储共享的资源，例如全局 CSS、JS 脚本、图标等
- `tufted-lib/` - Typst 样式库和功能模块
- `build.py` - 构建网站的 Python 脚本

== 可用函数

`tufted` 包目前提供了以下三个函数：

- `tufted-web` - 主模板，用于创建网页
- `margin-note` - 在边栏中放置内容
- `full-width` - 将内容放在全宽容器中

具体使用见 #link("../typst-example/")[Typst 功能速览与样例]。

== 主要配置

在 `config.typ` 中，你可以通过改变导入的 `tufted-web` 模板参数来定义自己的模板，该模板会被后续所有页面继承（即全局默认配置）。

=== 基本参数

`tufted-web()` 函数包含 `title`、`description`、`author` 等元数据参数。这些参数会被用于生成页面的元数据。

`header-links` 参数用于定义顶部导航栏的链接和标签。它是一个字典，键是链接的路径，值是链接的标签。

`lang` 参数用于定义网站的语言，这将被用于设置 HTML 的 `lang` 属性，默认为 `zh` （中文）。不同的语言设置可能会导致字体的不同。

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
  title: "我的个人网站",
  description: "我的个人网站描述",
  author: "我的名字",
  lang: "zh",
)
```

=== SEO 参数

SEO (Search Engine Optimization，搜索引擎优化) 参数用于优化网站在搜索引擎中的可见性。模板提供以下参数（均为可选）：

- `site-url` - 网站的根 URL，用于生成绝对链接
- `image-path` - 网站的默认图片路径，用于生成 Open Graph 图片

一旦设置了 `site-url`，构建脚本会自动为每个页面生成准确的绝对链接，确保 SEO 友好。

```typst
#let template = tufted.tufted-web.with(
  // 顶部导航栏的链接和标签
  ...,
  site-url: "https://example.com",
  image-path: "/assets/image.png",
  ...,
)
```

=== 自定义样式和脚本

见 #link("../custom-styling/")[自定义样式与脚本]。

=== 自定义 Header 和 Footer

你可以通过 `header-elements` 和 `footer-elements` 参数来自定义页面顶部和底部元素，两个参数均接受内容数组，内容之间以换行分隔：

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
    [© 2026 我的名字. ],
    [#link("mailto:example@example.com")[联系我]],
  ),
)
```

== 层级结构与继承

该网站模板的配置采用层级结构，基于 Typst 的导入/重导出机制实现。

首先，我们在项目根目录的 `config.typ` 中定义了一个 `template` 函数。该函数包含了网站的全局默认配置，包括网站标题、网站链接等。

网站的所有内容（包括首页、栏目页、具体文章等）全部位于 `content/` 目录中。`content/index.typ` 是网站首页，该文件顶部通过

```typ
#import "../config.typ": template, tufted
#show: template
```

导入了我们在 `config.typ` 中定义好的 `template` 函数，从而继承了所有的默认配置。

`content/` 目录中所有的 `**/index.typ` 文件都会成为可访问的页面，其路径对应文件夹的路径（例如 `content/Blog/index.typ` → `example.github.io/Blog`）。所有子页面均从其父目录的 `../index.typ` 中导入 `template` 和 `tufted`，从而实现层层继承，无需重复定义模板。

你可以在任何层级、任何页面中使用 `.with()` 修改 `template` 的定义，子页面都会继承这些更改。例如，要修改当前页面的标题和描述，可以这样：

```typst
#import "../index.typ": template, tufted
#show: template.with(title: "新标题", description: "新描述")
```

== 自定义网站图标

只需将事先准备好的图标文件命名为 `favicon.ico` 并放入 `assets/` 目录中即可，构建时会自动加载。
