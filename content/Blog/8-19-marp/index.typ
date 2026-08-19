#import "../index.typ": template, tufted

// 如需生成 RSS feed，必须填写 title、description 和 date 元数据
#show: template.with(
  title: "工具分享｜Marp 基础使用指南（1）：平台安装与基础语法",
  description: "介绍 Marp 的核心概念，整理 VS Code、Obsidian 与 CLI 的安装使用方法，并讲解分页、指令、图片、主题和导出等基础语法。",
  date: datetime(year: 2026, month: 8, day: 19),
  category: "实践与工具",
  lang: "zh",
)

= 工具分享｜Marp 基础使用指南（1）：平台安装与基础语法

#tufted.post-meta(
  date: datetime(year: 2026, month: 8, day: 19),
  tags: ("工具分享", "Marp", "Markdown"),
)

#tufted.margin-note[
  *阅读提示*：这一篇是 Marp 基础使用指南的第一章，先解决“它是什么、去哪里用、怎么装、最基础的语法怎么写”这些问题。内容比较偏上手实践，不需要前端基础，会写一点 Markdown 就可以直接开工。祝食用愉快～🦭
]

#line(length: 100%, stroke: 0.6pt)

== *导言*

#quote[
  如果一份演示文稿的重点是结构、文字、公式、代码和版本管理，那么我们真的需要从空白画布开始拖拽每一个文本框吗？
]

PowerPoint、Keynote 这类软件很适合自由排版，但它们也有一个很明显的问题：当内容频繁修改时，我们会花很多时间处理文本框错位、字号不一致、主题漂移和版本覆盖。尤其是技术分享，一张幻灯片里常常有代码、公式、图片和结构化列表，鼠标拖来拖去并不一定是最高效的工作方式。

Marp 提供了另一条路线：*用 Markdown 写内容，再把 Markdown 渲染成幻灯片。* 一份 `.md` 文件既是源文件，也是可以被 Git 追踪的纯文本；标题、列表、代码块和图片都保留清楚的结构，最后再统一导出为 HTML、PDF 或 PPTX。

#quote[
  *Marp 最吸引笔者的地方，不是“用 Markdown 替代 PowerPoint”，而是把演示文稿从一个难以复用的画布文件，变成一份可以搜索、修改、比较、复制和自动构建的文本源码。*
]

当然，它也不是万能的。高度自由的视觉设计、复杂动画和逐元素拖拽仍然是传统演示软件更擅长的部分。Marp 的强项是：*让内容结构先稳定下来，再用主题和 CSS 统一控制视觉。*

#line(length: 100%, stroke: 0.6pt)

== *一：Marp 是什么？*

=== *1.1 Markdown Presentation Ecosystem*

Marp 的全称可以理解为 *Markdown Presentation Ecosystem*。官方将它描述为一套通过 Markdown 创建幻灯片的生态，而不是某一个单独的软件。

它最基本的工作流只有三步：

```text
Markdown 源文件
      ↓
Marp / Marpit 解析与主题渲染
      ↓
HTML、PDF、PPTX 或图片
```

普通 Markdown 用标题、列表、图片和代码块组织一篇文章；Marp 在这个基础上增加了“分页”“主题”“页码”“背景图”“页眉页脚”等演示文稿需要的能力。最关键的分页规则非常简单：

```markdown
# 第一页

这里是第一页的内容。

---

# 第二页

三个短横线会开始一张新幻灯片。
```

#tufted.margin-note[
  `---` 同时可能是 YAML Front Matter 的边界，也可能是幻灯片分页符。只要记住：文件最开头成对出现的 `---` 包住配置，配置结束后的 `---` 才负责分页。
]

#line(length: 100%, stroke: 0.6pt)

=== *1.2 Marp 生态里分别有什么？*

#table(
  columns: (1fr, 1fr, 2fr),
  align: (left, left, left),
  table.header([*组件*], [*定位*], [*适合做什么*]),
  [Marpit], [底层框架], [定义分页、指令、图片和主题等基础规则，将 Markdown 与 CSS 转成幻灯片。],
  [Marp Core], [官方渲染核心], [在 Marpit 上加入内置主题、代码高亮、数学公式、Emoji 和自动缩放等能力。],
  [Marp for VS Code], [官方编辑器扩展], [在 VS Code 中实时预览、提示语法并导出幻灯片。],
  [Marp CLI], [官方命令行工具], [批量转换、监听文件、启动服务，以及接入脚本和 CI/CD。],
  [Obsidian 插件], [社区集成], [让笔记库中的 Markdown 直接预览和演示；不是 Marp 官方工具。],
)

这里容易混淆的一点是：*Marp 是生态，Marpit 是框架，Marp Core 是常用引擎，VS Code 扩展和 CLI 则是我们真正接触的应用入口。* 对普通使用者来说不需要研究它们的源码关系，只需要根据自己的写作环境选择入口。

#line(length: 100%, stroke: 0.6pt)

=== *1.3 它适合什么场景？*

Marp 很适合：

- 技术分享、课程讲义与组会汇报；
- 含代码、公式、表格和结构图的演示；
- 需要频繁修改和复用的模板；
- 希望用 Git 管理历史版本的团队；
- 想让 Agent 或脚本批量生成初稿，再由人修改的工作流；
- 需要同时输出网页、PDF 和 PPTX 的场景。

它不太适合：

- 每一页都需要完全不同、像海报一样的自由构图；
- 大量复杂转场、路径动画和逐对象动画；
- 必须交付“每个文本框都能在 PowerPoint 中随意拖动”的文件；
- 完全不愿意接触 Markdown 或 CSS，只想使用可视化画布。

#quote[
  *所以 Marp 不是为了消灭 PowerPoint。更合理的用法是：用 Marp 高效完成结构稳定、样式统一的主体；如果最终确实需要复杂动画或手工微调，再进入传统演示软件。*
]

#line(length: 100%, stroke: 0.6pt)

== *二：应该在哪个平台使用？*

#table(
  columns: (1fr, 2fr, 2fr),
  align: (left, left, left),
  table.header([*入口*], [*优点*], [*更适合谁*]),
  [VS Code], [官方扩展、预览稳定、语法提示完整、导出方便。], [第一次接触 Marp 的大多数用户。],
  [Obsidian], [幻灯片与知识库、双链、素材笔记放在一起。], [已经把 Obsidian 当作主要笔记库的人。],
  [Marp CLI], [可批量、可复现、可自动化，不依赖特定编辑器。], [需要固定版本、批处理或 CI/CD 的用户。],
  [独立二进制 / Docker], [可以不在本机配置完整 Node.js 项目环境。], [希望快速部署或保持构建环境一致的人。],
)

笔者给初学者的推荐顺序是：

+ *先用 VS Code 扩展*，把注意力放在语法和页面结构上。
+ 熟悉以后，再安装 *Marp CLI*，建立稳定的导出命令。
+ 如果日常笔记都在 Obsidian，再把同一份 Markdown 接入 *Obsidian 社区插件*。

这样做的原因很简单：VS Code 是官方维护的完整入口，遇到问题时最容易与官方文档对照；Obsidian 的 Marp 能力来自社区插件，不同插件的功能和版本会变化，适合在理解基础语法以后再加入工作流。

#line(length: 100%, stroke: 0.6pt)

== *三：在 VS Code 中安装与使用*

=== *3.1 安装官方扩展*

打开 VS Code 左侧的 *Extensions*，搜索：

```text
Marp for VS Code
```

确认发布者是 `marp-team` 后安装。也可以打开命令面板或终端执行：

```bash
code --install-extension marp-team.marp-vscode
```

安装扩展并不意味着所有 Markdown 都会自动变成幻灯片。Marp 通过文件开头的 Front Matter 判断是否启用：

```markdown
---
marp: true
---

# Hello Marp
```

`marp: true` 是 VS Code 扩展识别 Marp 文档的关键开关。没有它时，VS Code 只会把文件当成普通 Markdown。

#line(length: 100%, stroke: 0.6pt)

=== *3.2 打开实时预览*

打开 `.md` 文件后，可以：

- 点击编辑器右上角的 Markdown Preview 图标；
- Windows / Linux 使用 `Ctrl + Shift + V`；
- macOS 使用 `Cmd + Shift + V`；
- 使用 `Ctrl/Cmd + K` 后再按 `V`，在侧边打开预览。

编辑源文件时，预览会同步更新。这个“左边结构、右边结果”的方式非常适合调幻灯片，因为你可以立刻看到某一页是否文字过多、图片是否挤压内容。

#tufted.margin-note[
  如果预览仍然是一篇纵向 Markdown 文档，先检查文件开头是否真的有 `marp: true`，再检查扩展是否由 `marp-team` 发布。很多同名或相似插件并不是官方扩展。
]

#line(length: 100%, stroke: 0.6pt)

=== *3.3 从 VS Code 导出*

在编辑器工具栏点击 Marp 图标，选择 *Export slide deck...*；也可以打开命令面板，搜索：

```text
Marp: Export slide deck
```

官方扩展可以导出 HTML、PDF、PPTX、标题页 PNG/JPEG，以及只包含演讲备注的 TXT。需要注意：*PDF、PPTX 和图片导出依赖 Chrome、Chromium、Edge 或 Firefox 之一。* 如果预览正常但导出失败，浏览器依赖通常是第一检查项。

普通 PPTX 的页面主要是已经渲染好的幻灯片图像，因此能较好保持视觉效果，但里面的文字通常不能像普通 PowerPoint 文本框一样自由编辑。可编辑 PPTX 属于 CLI 的实验能力，后面会单独说明。

#line(length: 100%, stroke: 0.6pt)

=== *3.4 推荐的项目目录*

```text
my-slides/
├── slides.md
├── images/
│   ├── cover.png
│   └── workflow.png
├── themes/
│   └── my-theme.css
└── .vscode/
    └── settings.json
```

当图片、主题和源文件放在同一项目目录中时，相对路径更容易迁移到另一台电脑，也更适合 Git 管理。不要把幻灯片引用成一串只在当前电脑有效的绝对路径。

如果需要注册自定义主题，可以在 `.vscode/settings.json` 中加入：

```json
{
  "markdown.marp.themes": [
    "./themes/my-theme.css"
  ]
}
```

第一章先使用 Marp 自带的 `default`、`gaia` 和 `uncover` 三个主题，自定义主题会在后续章节单独展开。

#line(length: 100%, stroke: 0.6pt)

== *四：在 Obsidian 中安装与使用*

=== *4.1 先说明：这是社区集成*

Obsidian 本身有 Slides 核心插件，但它不等于 Marp。要在 Obsidian 中使用 Marp，需要安装社区插件。

截至 2026 年 8 月，比较直接的选择是 *Marp Extended*。它源自早期的 Marp Slides for Obsidian，现在作为独立项目维护，可以在 Obsidian 中预览、演示并调用本机 Marp CLI 导出。

#quote[
  *Obsidian 的价值不是让 Marp 语法发生变化，而是让“资料笔记 → 大纲 → 幻灯片”都留在同一个 Vault 中。*
]

#line(length: 100%, stroke: 0.6pt)

=== *4.2 从 Community Plugins 安装*

+ 打开 `Settings → Community plugins`。
+ 如果仍处于 Restricted mode，先允许社区插件。
+ 点击 `Browse`，搜索 `Marp Extended`。
+ 安装并启用插件。
+ 新建一个 Markdown 笔记，在开头加入 `marp: true`。
+ 从命令面板或侧边栏图标运行 `Slide Preview`。

最小文件仍然是标准 Marp Markdown：

```markdown
---
marp: true
theme: default
paginate: true
---

# Obsidian 中的 Marp

笔记和幻灯片终于可以放在一起了。

---

# 第二页

继续使用标准 Marp 语法。
```

插件第一次加载时会准备自己的主题目录。建议复制或 fork 一份主题后再修改，不要直接改插件管理的默认文件，否则升级时容易被覆盖。

#line(length: 100%, stroke: 0.6pt)

=== *4.3 Obsidian 图片语法*

标准 Marp 使用普通 Markdown 图片：

```markdown
![说明文字](images/example.png)
```

Marp Extended 会额外转换常见的 Obsidian Wiki 图片语法：

```text
![[example.png]]
![[example.png|600]]
![[example.png|600x400]]
```

它们会在预览或导出前转换为 Marp 能理解的图片链接和宽高参数。这个功能很方便，但如果同一份幻灯片还要交给 VS Code 或纯 CLI 使用，笔者更推荐直接写标准 Markdown 图片语法，因为它的跨平台兼容性最好。

#line(length: 100%, stroke: 0.6pt)

=== *4.4 Obsidian 导出的额外要求*

预览和演示可以由插件完成，但 PDF、HTML、PPTX 导出仍然需要外部 Marp CLI。可以在插件设置中：

- 自动检测系统里的 `marp`；
- 手动填写 Marp CLI 可执行文件路径；
- 或启用 `npx` fallback。

截至本文写作日期，Marp Extended 的稳定版本会对 CLI 版本做兼容性约束，因此不要在插件明确要求固定版本时盲目升级。插件页面与更新日志应该作为最终依据。

Obsidian 集成更适合桌面端。移动端插件能力、外部命令和浏览器导出链路都可能受限，不建议把手机或平板作为第一套 Marp 生产环境。

#line(length: 100%, stroke: 0.6pt)

== *五：Marp CLI 的安装与下载*

=== *5.1 不安装：先用 npx 试一次*

如果电脑中已有 Node.js 18 或更高版本，可以直接运行：

```bash
npx @marp-team/marp-cli@latest slides.md
```

这会临时下载并运行最新版 CLI，默认把 Markdown 转换为 HTML。它非常适合第一次尝试，不需要先做全局安装。

检查版本：

```bash
npx @marp-team/marp-cli@latest --version
```

#line(length: 100%, stroke: 0.6pt)

=== *5.2 项目内安装：笔者更推荐的长期方式*

```bash
mkdir marp-demo
cd marp-demo
npm init -y
npm install --save-dev @marp-team/marp-cli
```

之后通过 `npx marp` 使用：

```bash
npx marp slides.md
npx marp slides.md --pdf
npx marp slides.md --pptx
```

项目内安装的优点是版本会记录在 `package.json` 和 lockfile 中。同一份幻灯片过几个月重新构建，或换一台电脑、交给同伴构建时，结果更容易复现。

全局安装则更适合个人电脑上的临时调用：

```bash
npm install -g @marp-team/marp-cli
marp --version
```

#line(length: 100%, stroke: 0.6pt)

=== *5.3 不同系统的其他安装方式*

#table(
  columns: (1fr, 2fr, 2fr),
  align: (left, left, left),
  table.header([*平台*], [*安装方式*], [*说明*]),
  [macOS / Linux], [`brew install marp-cli`], [Homebrew 配方由社区维护。],
  [Windows], [`scoop install marp`], [适合已经使用 Scoop 的用户。],
  [Linux / macOS / Windows], [GitHub Releases 独立二进制], [已打包 Node.js，不必另外安装 Node.js。],
  [任意 Docker 环境], [`docker pull marpteam/marp-cli`], [适合 CI/CD 或统一团队构建环境。],
)

不熟悉包管理器时，VS Code 扩展仍然是最轻松的入口；需要自动化时，再选择项目内 npm 安装或 Docker。

#line(length: 100%, stroke: 0.6pt)

=== *5.4 常用 CLI 命令*

```bash
# 默认导出 HTML
marp slides.md
marp slides.md -o output.html

# 导出 PDF
marp slides.md --pdf
marp slides.md -o output.pdf

# 导出 PPTX
marp slides.md --pptx
marp slides.md -o output.pptx

# 修改后自动重新构建
marp slides.md --watch

# 预览
marp slides.md --preview

# 把一个目录作为 Marp 服务启动
marp --server ./slides
```

如果 PDF 或 PPTX 中引用了本地图片，CLI 可能出于安全原因阻止访问。只对自己信任的 Markdown 使用：

```bash
marp slides.md --pdf --allow-local-files
```

不要对来源不明的 Markdown 随意开启本地文件访问，因为这会扩大文档读取本机资源的能力边界。

#line(length: 100%, stroke: 0.6pt)

== *六：Marp 基础语法*

=== *6.1 Front Matter：整份幻灯片的配置区*

Front Matter 必须位于文件最前面：

```yaml
---
marp: true
theme: gaia
size: 16:9
paginate: true
header: 'Marp 基础指南'
footer: 'Shiyi Li'
---
```

常用字段：

- `marp: true`：让编辑器识别这是 Marp 文档。
- `theme`：选择主题，内置 `default`、`gaia`、`uncover`。
- `size`：幻灯片比例，常用 `16:9` 或 `4:3`。
- `paginate: true`：显示页码。
- `header` / `footer`：设置页眉和页脚。
- `style`：在 Front Matter 中加入整份文稿使用的 CSS。

#line(length: 100%, stroke: 0.6pt)

=== *6.2 分页与普通 Markdown*

使用单独一行 `---` 分页：

```markdown
# 标题页

副标题

---

# 内容页

- 一级列表
  - 二级列表
- **粗体**、*斜体*、`行内代码`
- [链接](https://marp.app/)

> 也可以使用引用块。
```

Marp 基于 CommonMark，并支持常见的表格、删除线、代码块等能力。对初学者来说，可以先把每一页当成“一段很短的 Markdown 文档”。

#line(length: 100%, stroke: 0.6pt)

=== *6.3 全局指令、局部指令与单页指令*

Marp / Marpit 的扩展配置被称为 *Directives*。

- *全局指令*：控制整份文稿，例如 `theme`、`style`。
- *局部指令*：从当前页开始生效，并继续影响后面的页面。
- *单页指令（Spot Directives）*：加 `_` 前缀，只影响当前页。

例如只让当前页变成深色：

```markdown
<!--
_backgroundColor: #111827
_color: #f9fafb
_class: lead
_paginate: false
-->

# 这一页单独使用深色背景
```

如果去掉下划线，设置会从这一页继续传递到后续页面。这个差异非常重要，也是初学时“为什么后面所有页突然都变色了”的常见原因。

常用局部指令包括：

```markdown
<!-- paginate: true -->
<!-- header: '章节标题' -->
<!-- footer: '作者信息' -->
<!-- backgroundColor: #f8fafc -->
<!-- color: #0f172a -->
<!-- class: lead -->
```

#line(length: 100%, stroke: 0.6pt)

=== *6.4 图片大小*

普通图片：

```markdown
![图片说明](images/example.png)
```

指定宽高：

```markdown
![width:600px](images/example.png)
![height:400px](images/example.png)
![w:600 h:400](images/example.png)
```

`w` 和 `h` 是 `width`、`height` 的简写。图片路径建议相对于 Markdown 文件或项目目录书写。

#line(length: 100%, stroke: 0.6pt)

=== *6.5 背景图与左右分栏*

整页背景：

```markdown
![bg cover](images/cover.jpg)

# 标题会显示在背景图上
```

`cover` 会让图片覆盖整页；`contain` 会完整显示图片，但可能留下空白。

左右分栏最实用：

```markdown
![bg right:40% cover](images/example.jpg)

# 左侧标题

正文只占左侧 60%，图片占右侧 40%。
```

方向可以写成 `left` 或 `right`，百分比控制背景区域宽度。这种语法比手写两栏 HTML 更稳定，非常适合“左文右图”的技术分享。

#line(length: 100%, stroke: 0.6pt)

=== *6.6 代码、公式与自适应标题*

代码块沿用 Markdown：

````text
```python
for slide in deck:
    render(slide)
```
````

行内公式和块级公式可以写成：

```markdown
行内公式：$E = mc^2$

块级公式：

$$
\nabla_\theta L = \frac{1}{N}\sum_{i=1}^{N}\nabla_\theta L_i
$$
```

当标题过长时，可以让 Marp 尝试自动缩放：

```markdown
# <!-- fit --> 这是一个很长、但希望仍然保持在单行中的标题
```

#tufted.margin-note[
  自动缩放是兜底工具，不是把一整页塞满文字的许可证。幻灯片内容溢出时，优先删减、拆页和提炼结构，通常比一味缩小字号更好。
]

#line(length: 100%, stroke: 0.6pt)

=== *6.7 演讲者备注*

普通 HTML 注释可以作为 presenter notes：

```markdown
# 这一页展示给观众

- 观众能看到的内容

<!--
这里是演讲者备注。
提醒自己补充案例，但不会直接显示在幻灯片正文中。
-->
```

CLI 可以把备注导出为 TXT，PDF 与 PPTX 也有相应的备注支持选项。需要注意：如果注释内容恰好是合法 Directive，它会被当作指令，而不是普通备注。

#line(length: 100%, stroke: 0.6pt)

=== *6.8 页面级样式与整份文稿样式*

在 Front Matter 中统一写 CSS：

```yaml
---
marp: true
theme: default
style: |
  section {
    font-family: "Noto Sans CJK SC", sans-serif;
  }
  h1 {
    color: #2563eb;
  }
---
```

也可以在文稿中使用 `<style>`，但不同编辑器对 HTML 的安全策略不同。跨平台使用时，优先选择 Front Matter 的 `style` 或独立主题 CSS，兼容性会更清楚。

#line(length: 100%, stroke: 0.6pt)

== *七：一份可以直接复制的最小完整示例*

````markdown
---
marp: true
theme: gaia
size: 16:9
paginate: true
header: 'Marp 基础使用指南'
footer: 'Shiyi Li'
style: |
  section {
    font-family: "Noto Sans CJK SC", sans-serif;
  }
---

<!--
_class: lead
_paginate: false
_header: ''
_footer: ''
-->

# Marp 基础使用指南

用 Markdown 写一份可复现的演示文稿

---

# 为什么使用 Marp？

- 内容与样式分离
- Markdown 源文件适合 Git
- 代码、公式和图片语法统一
- 可以导出 HTML、PDF 与 PPTX

---

![bg right:42% cover](images/workflow.jpg)

# 一个简单工作流

1. 编写 `slides.md`
2. 实时预览
3. 调整主题
4. 导出并检查

---

<!-- _backgroundColor: #0f172a -->
<!-- _color: #f8fafc -->

# <!-- fit --> 一页单独使用深色样式

Spot Directive 只影响当前页。

<!--
讲到这里时，演示一下把下划线去掉后会发生什么。
-->
````

把它保存为 `slides.md`，替换图片路径后，就可以在 VS Code 或 Obsidian 中预览，也可以用 CLI 导出：

```bash
npx @marp-team/marp-cli slides.md --pdf --allow-local-files
```

#line(length: 100%, stroke: 0.6pt)

== *八：新手最常遇到的问题*

=== *8.1 为什么没有变成幻灯片？*

依次检查：

+ 文件是不是 `.md`；
+ Front Matter 是否位于第一行；
+ 是否写了 `marp: true`；
+ VS Code 是否安装并启用了官方 Marp 扩展；
+ Obsidian 是否真的打开了 Marp 插件的 Slide Preview，而不是普通阅读视图。

#line(length: 100%, stroke: 0.6pt)

=== *8.2 为什么本地图片预览正常，导出却消失？*

- 检查相对路径和文件名大小写；
- 检查图片是否位于项目或 Vault 内；
- CLI 的浏览器导出可能需要 `--allow-local-files`；
- 路径中包含空格时，优先使用规范的 Markdown 路径并确认插件是否做了 URL 编码；
- 不要把只在本机存在的绝对路径交给其他人构建。

#line(length: 100%, stroke: 0.6pt)

=== *8.3 为什么 PDF 或 PPTX 导出失败？*

预览主要依赖渲染引擎，而 PDF、PPTX 和图片导出还需要浏览器。请确认安装了受支持的 Chrome、Chromium、Edge 或 Firefox，并检查插件或 CLI 是否能够找到浏览器路径。

在 Obsidian 中还要检查 Marp CLI 是否安装、路径是否正确，以及插件当前要求的 CLI 版本。

#line(length: 100%, stroke: 0.6pt)

=== *8.4 为什么 PPTX 打开后不能直接编辑文字？*

普通 Marp PPTX 主要保存渲染后的页面，优势是视觉还原稳定，代价是内容并不是原生 PowerPoint 文本框。

CLI 提供实验性的：

```bash
marp slides.md --pptx --pptx-editable
```

但它还需要 LibreOffice，复杂主题可能导出不完整，视觉还原也会下降。*如果外观必须稳定，就使用普通 PPTX；如果必须二次编辑，就要接受实验导出的限制，或者回到 PowerPoint 手工整理。*

#line(length: 100%, stroke: 0.6pt)

=== *8.5 为什么一页越来越挤？*

这是 Marp 最常见、也最应该正面面对的问题：幻灯片不是文章页面。一个技术点如果需要五段文字解释，就应该拆成两到三页，而不是不断缩小字号。

笔者目前比较认可的顺序是：

+ 先删掉不影响结论的句子；
+ 再把并列内容拆页；
+ 把详细解释移到演讲者备注；
+ 最后才考虑 `fit`、缩小图片或微调 CSS。

#line(length: 100%, stroke: 0.6pt)

== *小结*

这一章先完成 Marp 的基础闭环：

- Marp 是以 Markdown 为源文件的演示文稿生态；
- `---` 负责分页，Front Matter 负责整份文稿配置；
- VS Code 官方扩展是最适合初学者的入口；
- Obsidian 通过社区插件把幻灯片接入知识库；
- Marp CLI 负责稳定导出、批量构建与自动化；
- Directives 控制主题、页码、颜色、页眉页脚和单页样式；
- 扩展图片语法可以快速完成背景图与左右分栏；
- HTML、PDF、PPTX 各有不同用途，PPTX 的可编辑性需要特别注意。

#quote[
  *掌握 Marp 的关键不是记住所有语法，而是建立“内容写进 Markdown、重复样式交给主题、特殊页面交给局部指令、最终输出交给 CLI”的分工。*
]

#line(length: 100%, stroke: 0.6pt)

== *笔者的话*

#quote[
  Marp 对笔者来说是一种很舒服的中间态：它比纯 Markdown 多了完整的演示能力，又没有传统 PPT 那么多重复的排版操作。第一章先把地基搭好，后面如果继续整理，会重点看看自定义主题、CSS 布局、Mermaid、动画与自动构建这些更有趣的部分。希望这篇能让你十分钟内做出第一份可以正常导出的 Marp 幻灯片～🥳
]

#line(length: 100%, stroke: 0.6pt)

== *参考资料*

- Marp 官方网站：#link("https://marp.app/")[https://marp.app/]
- Marp for VS Code：#link("https://github.com/marp-team/marp-vscode")[https://github.com/marp-team/marp-vscode]
- Marp CLI：#link("https://github.com/marp-team/marp-cli")[https://github.com/marp-team/marp-cli]
- Marpit Markdown：#link("https://marpit.marp.app/markdown")[https://marpit.marp.app/markdown]
- Marpit Directives：#link("https://marpit.marp.app/directives")[https://marpit.marp.app/directives]
- Marpit Image Syntax：#link("https://marpit.marp.app/image-syntax")[https://marpit.marp.app/image-syntax]
- Marp Core Markdown Features：#link("https://github.com/marp-team/marp-core/blob/main/docs/markdown.md")[https://github.com/marp-team/marp-core/blob/main/docs/markdown.md]
- Marp Extended for Obsidian：#link("https://github.com/shuuul/obsidian-marp-extended")[https://github.com/shuuul/obsidian-marp-extended]

#line(length: 100%, stroke: 0.6pt)
