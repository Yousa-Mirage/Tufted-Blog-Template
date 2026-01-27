#import "../index.typ": template, tufted
#show: template.with(
  title: "自定义样式",
  description: "自定义样式文档，介绍了如何修改网站的视觉外观。",
)

= 自定义样式

网站的视觉外观由 CSS 控制，这导致很多样式无法在 Typst 中直接修改，如字号、文字颜色等。

如需修改样式，你需要直接修改 CSS 样式文件。

== 默认样式表

`tufted` 模板接受一个 `css` 参数，该参数采用一组 URL 或样式表路径。默认情况下，它加载三个样式表：

```typst
#let template = tufted.tufted-web.with(
  // ...
  css: (
    "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
    "/assets/tufted.css",
    "/assets/custom.css",
  ),
  // ...
)
```

依次为原初的 Tufte 样式表、模板适配样式表、自定义样式表。

== 自定义样式

要自定义网站的样式，只需修改 `assets/custom.css`。由于默认情况下它是最后加载的，因此你在 `assets/custom.css` 中编写的自定义规则将覆盖其他规则。

例如，要更改链接颜色：

```css
a {
  color: #ff0000;
}
```

== 覆盖样式表

要覆盖默认样式表，你可以在 `config.typ` 中提供你自己的样式表列表。例如，仅使用自定义样式表：

```typst
#let template = tufted.tufted-web.with(
  // ...
  css: ("/assets/custom.css"),
  // ...
)
```
