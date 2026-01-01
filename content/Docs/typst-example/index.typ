#import "../index.typ": template, tufted
#import "@preview/theorion:0.4.1": *
#import "@preview/tablem:0.3.0": *
#import "@preview/citegeist:0.2.0": load-bibliography
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.6": *
#show: template.with(title: "Typst 文档编写示例")

= Typst 功能速览与样例文档

这份文档展示了 Typst 的核心功能。上方是实际渲染效果，下方灰色背景的代码块是对应的源代码。

== 1. 字体与文本修饰

这里展示了 *粗体*、_斜体_、#underline[下划线]、#strike[删除线]、#overline[上划线]、上标 E=mc#super[2]、下标 H#sub[2]O。重要内容可以使用 #highlight[高亮标记]。

```typ
这里展示了 *粗体*、_斜体_、#underline[下划线]、#strike[删除线]、#overline[上划线]、上标 E=mc#super[2]、下标 H#sub[2]O。重要内容可以使用 #highlight[高亮标记]。
```

你可以通过空行来实现分段。

这是新的一段。你可以通过在行末添加`\`来实现换行。\
这是新的一行。

```typ
你可以通过空行来实现分段。

这是新的一段。你可以通过在行末添加`\`来实现换行。\
这是新的一行。
```

不过由于编译 HTML 的限制，你目前还不能在网页中改变文字的 #text(fill: blue)[颜色]、#text(size: 14pt)[大小] 或 #text(font: "Liu Jian Mao Cao")[字体]。

```typ
不过由于编译 HTML 的限制，你目前还不能在网页中改变文字的 #text(fill: blue)[颜色]、#text(size: 14pt)[大小] 或 #text(font: "Liu Jian Mao Cao")[字体]。
```

如果要显示特殊字符，需要转义：\* \_ \# \$ \@

```typ
如果要显示特殊字符，需要转义：\* \_ \# \$ \@
```


== 2. 多级标题

开头的“Typst 功能速览与样例文档”是一级标题，上面的 “2. 多级标题” 是二级标题。

=== 三级标题
==== 四级标题

```typ
=== 三级标题
==== 四级标题
```

== 3. 链接

但你可以创建编译为 PDF 的 Typst 文档，并链接到编译的 PDF 文件。你可以使用 `#link()` 函数添加链接。

例如，#link("https://github.com/Yousa-Mirage")[这是一个外部网页的链接]。\
#link("https://yousa-mirage.github.io/", "这也是一个外部链接")。\
你也可以链接到本网站的其他位置，例如#link("sample-PDF.pdf")[这是一个指向 PDF 文档的链接]，这个 PDF 由名为 `sample-PDF.typ` 的文件编译而来。你可以通过这种方式展现带有复杂格式的 PDF 文档，例如插入你的 PDF 版简历。\
#link("/CV/")[而这是一个指向本网站 CV 页的链接。]

```typ
例如，#link("https://github.com/Yousa-Mirage")[这是一个外部网页的链接]。\
#link("https://yousa-mirage.github.io/", "这也是一个外部链接")。\
你也可以链接到本网站的其他位置，例如#link("sample-PDF.pdf")[这是一个指向 PDF 文档的链接]，这个 PDF 由名为 `sample-PDF.typ` 的文件编译而来。\
#link("/CV/")[而这是一个指向本网站 CV 页的链接。]
```


== 4. 列表结构

这是一个混合列表的示例：

- 无序列表项 1
- 无序列表项 2
  - 支持缩进层级
    - 继续缩进
  + 无序列表中可以插入有序列表

    在当前层级添加段落内容

+ 有序列表项 1
+ 有序列表项 2 (自动编号)
  + 子有序列表 A
    - 有序列表中可以插入无序列表
  - 子无序列表 B

/ 术语列表: 带有名称的列表项，适合用于名词解释。
/ Typst: 一个新的基于标记的排版系统。

```typ
- 无序列表项 1
- 无序列表项 2
  - 支持缩进层级
    - 继续缩进
  + 无序列表中可以插入有序列表

    在当前层级添加段落内容

+ 有序列表项 1
+ 有序列表项 2 (自动编号)
  + 子有序列表 A
    - 有序列表中可以插入无序列表
  - 子无序列表 B

/ 术语列表: 带有名称的列表项，适合用于名词解释。
/ Typst: 一个新的基于标记的排版系统。
```


== 5. 边栏、注释和参考文献

#tufted.margin-note[你可以在任何地方添加边栏内容。]

*Tufte 样式*最鲜明的特点就是采用*宽大的侧边栏布局*，将注释、参考文献和图表直接并排展示在正文旁，取代了传统的脚注或尾注，在数字屏幕上复刻了经典学术著作般清晰、沉浸且图文对照的深度阅读体验。#footnote[这是#link("/")[本网站首页]写的话。]

你可以使用 `footnote()` 函数添加注释，会自动添加到与正文齐平的侧边栏中，不需要再翻到网站末尾。#footnote[脚注真的很打断阅读体验！这也是我使用 Tufte 样式制作博客模板的原因。]

```typ
你可以使用 `footnote()` 函数添加注释。#footnote[脚注真的很打断阅读体验！]
```

你可以使用 `tufted.margin-note()` 函数在任何地方添加任意的*不分段的*边栏内容。例如，你可以添加一行文本图片、行内代码、行内公式等#footnote[`box()` 函数可以将内容设置在一段内。]。
#tufted.margin-note[
  #image("../../imgs/tufted-duck-male.webp")
]
#tufted.margin-note[
  ⬆️这是一只鸭，这是 `一个行内代码`，这是一个行内公式 $1 + 1 = 2$。\
  这是换行文本
]

```typ
// 这是设置右侧图片和文本的 Typst 代码。
#tufted.margin-note[
  #image("../../imgs/tufted-duck-male.webp")
]
#tufted.margin-note[
  ⬆️这是一只鸭，这是 `一个行内代码`，这是一个行内公式 $1 + 1 = 2$。\
  这是换行文本
]
```

// TODO:
你可以将参考文献导出为 `.bib` 文件，使用 `bibliography()` 函数将其引用到 Typst中，然后就可以使用 `@` 引用它，就像这样@tufte1973relationship。\
默认会将使用的参考文献显示在调用 `bibliography()` 函数的位置。模板暂时不支持自动将参考文献展示在边栏中，但你可以手动引用#footnote[Tufte, E. R. (1973). The Relationship between Seats and Votes in Two-Party Systems. _American Political Science Review, 67_(2), 540～554. https://doi.org/10.2307/1958782]。

#bibliography("papers.bib", title: none, style: "american-psychological-association")

```typ
然后就可以使用 `@` 引用它，就像这样@tufte1973relationship。
你可以手动引用#footnote[Tufte, E. R. (1973). The Relationship between Seats and Votes in Two-Party Systems. _American Political Science Review, 67_(2), 540～554. https://doi.org/10.2307/1958782]。

#bibliography("papers.bib", title: none, style: "american-psychological-association")
```

你甚至可以编写一个 `for` 循环来手动展示 `.bib` 中的文献内容并进行排版：

#{
  let bib = load-bibliography(read("papers.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #data.author, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]
  ]
}

```typ
#import "@preview/citegeist:0.2.0": load-bibliography

#{
  let bib = load-bibliography(read("papers.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #data.author, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]
  ]
}
```

你可以使用 `tufted.full-width()` 将内容以全宽度展现出来，例如这是一张超长的 MIKU：

#tufted.full-width[#image("miku.png")]

```typ
#tufted.full-width[#image("miku.png")]
```

== 6. 图片

你可以使用 `figure()` 函数来为任意的内容添加标题信息，特别是图片和表格，这也会显示在侧边栏中。

使用 `image()` 函数可以添加图片，使用 `width`、`height` 参数可以控制大小，例如 `figure + image`：

#figure(caption: "这也是鸭鸭。")[
  #image("../../imgs/tufted-duck-female-with-duckling.webp", width: 250pt)
]

#figure(caption: "这是只猴！")[
  #image("../../../_site/Blog/2025-04-16-monkeys-apes/imgs/gorilla.webp", height: 250pt)
]

```typ
#figure(caption: "这也是鸭鸭。")[
  #image("../../imgs/tufted-duck-female-with-duckling.webp", width: 250pt)
]

#figure(caption: "这是只猴！")[
  #image("../../../_site/Blog/2025-04-16-monkeys-apes/imgs/gorilla.webp", height: 250pt)
]
```


== 7. 表格

HTML 导出还不支持调整列宽、表格样式等，甚至目前连边框都没有。现在推荐直接#link("sample-PDF.pdf")[添加 PDF] 或表格图片。

你可以使用 `table()` 函数创建简单的表格：

#figure(caption: [`table()` 函数生成的表格])[
  #table(
    columns: (1fr, 2fr, auto),
    [*姓名*], [*简介*], [*状态*],
    [Alice], [前端开发者，喜欢 Rust], [在线],
    [Bob], [后端工程师，喜欢 Python], [离线],
  )
]

```typ
#figure(caption: [`table()` 函数生成的表格])[
  #table(
    columns:(1fr, 2fr, auto),
    [*姓名*], [*简介*], [*状态*],
    [Alice], [前端开发者，喜欢 Rust], [在线],
    [Bob], [后端工程师，喜欢 Python], [离线],
  )
]
```

更推荐使用橘子大佬写的 `tablem` 包，根据 markdown 表格格式生成表格：

#tablem[
  | *Name* | *Location* | *Height* | *Score* |
  | :----: | :--------: | :------: | :-----: |
  | John   | Second St. | 180 cm   | 5       |
  | Wally  | Third Av.  | 160 cm   | 10      |
]

```typ
#import "@preview/tablem:0.3.0": *

#tablem[
  | *Name* | *Location* | *Height* | *Score* |
  | :----: | :--------: | :------: | :-----: |
  | John   | Second St. | 180 cm   | 5       |
  | Wally  | Third Av.  | 160 cm   | 10      |
]
```

== 8. 代码块

使用 ```` ``` ```` 包裹代码来添加代码块，支持语法高亮，也可以和图片、表格一样使用 `figure()` 添加标题。我修改了代码块样式，并添加了行号和复制按钮。

```python
# Python 中的斐波那契函数
def fib(n):
    if n <= 1: return n
    return fib(n-1) + fib(n-2)
```

#figure(caption: "我最近在学习 Rust。")[
  ```rs
  fn main() {
      println!("Typst 正是 Rust 编写的。");
  }
  ```
]

上述 Rust 代码块对应的 Typst 源代码如下：

````typ
#figure(caption: "我最近在学习 Rust。")[
  ```rs
  fn main() {
      println!("Hello, Typst!");
  }
  ```
]
````


== 9. 对齐、分栏与段落块

目前 Typst 编译 HTML 还不支持段落对齐方式和分栏，但你可以#link("sample-PDF.pdf")[在 PDF 中实现]。这在简历、分栏论文、演示文稿中非常有用。

你可以使用同样是橘子大佬写的定理包 `theorion` 来实现各种特殊的段落样式，例如：

#quote-box[
  这是一个引用块。你可以在这里引用相当长的内容。你可以在这里引用相当长的内容。你可以在这里引用相当长的内容。你可以在这里引用相当长的内容。支持换行、分段，甚至可以在其中添加新的引用块。

  #quote-box[这是引用块内部的引用块。]
  - 列表
  `This is a code block.`
]
#tip-box[这是一个提示块。]
#note-box[这是一个注意块。]
#important-box[这是一个强调块。]
#warning-box[这是一个警告块。]
#caution-box[这也是一个警告块。]

```typ
#import "@preview/theorion:0.4.1": *

#quote-box[
  这是一个引用块。你可以在这里引用相当长的内容。你可以在这里引用相当长的内容。你可以在这里引用相当长的内容。你可以在这里引用相当长的内容。支持换行、分段，甚至可以在其中添加新的引用块。

  #quote-box[这是引用块内部的引用块。]
  - 列表
  `This is a code block.`
]
#tip-box[这是一个提示块。]
#note-box[这是一个注意块。]
#important-box[这是一个强调块。]
#warning-box[这是一个警告块。]
#caution-box[这也是一个警告块。]
```

== 10. 数学公式

#quote-box[目前 FireFox 浏览器显示公式可能存在问题。]

Typst 使用 `$ $`包裹公式。行内公式嵌入在文字中，写法是 `$ $` 内紧跟公式内容，例如 $f(x) = x^2$。

```typ
例如 $f(x) = x^2$。
```

而块级公式独占一行，写法是 `$ $` 与公式内容之间存在空格，例如 $ A = pi r^2 $

```typ
例如 $ A = pi r^2 $。
```

包含分式、根号、求和与积分：
$ integral_0^infinity e^(-x^2) d x = sqrt(pi) / 2 $
$ sum_(k=0)^n k = 1 + ... + n = (n(n+1)) / 2 $

```typ
包含分式、根号、求和与积分：
$ integral_0^infinity e^(-x^2) d x = sqrt(pi) / 2 $
$ sum_(k=0)^n k = 1 + ... + n = (n(n+1)) / 2 $
```

矩阵与行列式：
$
  mat(
    1, 2;
    3, 4
  ) dot vec(x, y) = vec(5, 6)
$

```typ
矩阵与行列式：
$
  mat(
    1, 2;
    3, 4
  ) dot vec(x, y) = vec(5, 6)
$
```

多行对齐公式：
$
  f(x) & = (x + 1)^2 \
       & = x^2 + 2x + 1
$

```typ
多行对齐公式：
$
  f(x) & = (x + 1)^2 \
       & = x^2 + 2x + 1
$
```

更加复杂的公式和符号写法可参考#link("https://typst-doc-cn.github.io/docs/reference/math/")[官方文档]。


== 11. 交叉引用

TODO

== 12. 编程特性

Typst 不但是一个标记排版语言，还是一门编程排版语言：

```typ
#let name = "Typst"
#if name == "Typst" [
  #for i in range(3) [
    这是 Typst！
  ]
] else [
  这不是 Typst。
]
```

#let name = "Typst"
#if name == "Typst" [
  #for i in range(3) [
    这是 Typst #i！
  ]
] else [
  这不是 Typst。
]

```typ
#show "Latex": "Typst"
我爱 Latex!
```

#show "Latex": "Typst"
我爱 Latex!

```typ
// 支持自定义函数
#let greet(name) = [Hello, #name!]
#greet("World")\
#greet("Yousa Mirage")
```

#let greet(name) = [Hello, #name!]
#greet("World")\
#greet("Yousa Mirage")


== 13. 嵌入 Markdown

你可以使用 `cmarker` 将 Markdown 内容嵌入到 Typst 文档中。这在将现有 Markdown 文件集成到基于 Typst 的网站时尤其有用。要渲染数学表达式，请使用 `mitex`。例如这段代码：

```
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.6": *

// 这个 scope 是必要的
#let scope = (image: (source, alt: none, format: auto) => figure(image(source, alt: alt, format: format)))
#let md-content = read("tufted-titmouse.md")
#cmarker.render(md-content, math: mitex, scope: scope)
```

将 `"tufted-titmouse.md"` 渲染为以下内容：

#let scope = (image: (source, alt: none, format: auto) => figure(image(source, alt: alt, format: format)))
#let md-content = read("tufted-titmouse.md")
#cmarker.render(md-content, math: mitex, scope: scope)
