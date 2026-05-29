#import "../index.typ": template, tufted
#show: template.with(
  title: "Blog",
  description: "数学算法、个人评论、绘画方法心得与日记。",
)

// ── 可点击标签（蓝色）──
#let tag(target, body) = link(target)[#block(
  inset: (x: 10pt, y: 5pt),
  radius: 12pt,
  fill: rgb("#dbeafe"),
  stroke: 1pt + rgb("#3b82f6"),
)[#text(size: 1.1em, fill: rgb("#1d4ed8"), weight: "bold", style: "italic")[#body]]]

// ── 占位标签（灰色）──
#let tag-placeholder(body) = block(
  inset: (x: 10pt, y: 5pt),
  radius: 12pt,
  fill: luma(235),
  stroke: 1pt + luma(190),
)[#text(size: 1.1em, fill: luma(140), weight: "bold", style: "italic")[#body]]


// ── 系列卡片，支持自定义左边框颜色 ──
#let series-block(title: "", accent: rgb("#3b82f6"), body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: luma(249),
  stroke: (left: 3pt + accent, rest: 0.5pt + luma(220)),
)[
  #text(size: 0.9em, weight: "bold", fill: accent)[📂 #title]
  #body
]



= *Blog*

#quote[
  If you enjoy my blog, feel free to bookmark the site:*
  #link("https://shiyilee11.github.io/Tufted-Blog-Template/Blog/")[shiyilee11.github.io/Blog]*.
  If you have any ideas or suggestions, don't hesitate to reach out via
  *#link("mailto:1747819157@qq.com")[email]*.
  I'd love to hear your feedback! 🙌
]

// ==================== 数学与算法 ====================
== *数学与算法* <math>

#tag(<transformer>, [🤖 Transformer 系列])
#tag(<linear>, [📐 线性代数])

#series-block(title: "Transformer", accent: rgb("#6366f1"))[
   #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 25),
    path: "5-25-tr",
    title: "Transformer｜反向传播 (Backpropagation)（6）：缩放因子与初始化哲学",
  ) 
   #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 22),
    path: "5-22-tr",
    title: "Transformer｜反向传播 (Backpropagation)（5）：残差连接与归一化的选择",
  ) 
   #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 21),
    path: "5-21-tr",
    title: "Transformer｜反向传播 (Backpropagation)（4）：Self-Attention联合推导与整体总结",
  ) 
  
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 20),
    path: "5-20-tr",
    title: "Transformer｜反向传播 (Backpropagation)（3）：以SwiGLU为例的前馈网络层推导",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 19),
    path: "5-19",
    title: "Transformer｜反向传播 (Backpropagation)（2）：两个特殊模块：Softmax 与 RMSNorm",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 18),
    path: "5-18",
    title: "Transformer｜反向传播 (Backpropagation)（1）：误差和梯度在 Linear 层的基础推导",
  )
] <transformer>


#series-block(title: "线性代数", accent: rgb("#0ea5e9"))[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 13),
    path: "2026-05-13-strassen-matrix-blocking/",
    title: "线性代数｜矩阵分块优化与 Strassen 算法",
  )
] <linear>

// ==================== 实践与工具 ====================
== *实践与工具* <practice>

#tag-placeholder[🔧 工具分享（即将更新）]
#tag-placeholder[🚀 项目实践（即将更新）]

#tag(<realtry>, [💡 实践看法])

#series-block(title: "实践看法", accent: rgb("#f59e0b"))[

    #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 29),
    path: "5-29",
    title: "Pre-Train Framework｜深度表型数据适配的 Transformer 基础模型 ukbFound 架构与源码解析",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 20),
    path: "5-20-skill",
    title: "Skill｜基于上海交大最新 PaSaMaster构建优化文献检索 Skill 的设计",
  )
] <realtry>


// ==================== 杂谈 ====================
== *杂谈* <chat>

#tag(<movie>, [🎬 影评])
#tag-placeholder[🌐 泛文化评论（即将更新）]

#series-block(title: "影评", accent: rgb("#ec4899"))[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 17),
    path: "5-17",
    title: "影评杂谈｜浅析《沉默的羔羊》：女性困境“凝视”与当代文化延伸",
  )
] <movie>

// ==================== 绘画记录 ====================
== *绘画记录* <draw>

#tag-placeholder[✏️ 绘画分享（即将更新）]
#tag-placeholder[🎨 板绘研究（即将更新）]

#series-block(title: "绘画分享", accent: rgb("#10b981"))[
  #text(fill: luma(160), style: "italic")[暂无文章，敬请期待。]
]

// ==================== 个人记录 ====================
== *个人记录* <life>

#tag(<langauge>, [🗣️ 语言学习])
#tag(<diary>, [📝 日常记录])


#series-block(title: "语言学习", accent: rgb("#f97316"))[

   #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 26),
    path: "5-26",
    title: "“一周后的收获🎉”",
  )  
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 19),
    path: "5-19-jp",
    title: "“想让生活更有动力？你的选择是学习新的语言吗？🐶”",
  ) 
] <langauge>


#series-block(title: "日常记录", accent: rgb("#f97316"))[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 23),
    path: "5-23-fp",
    title: "日常记录｜飞盘初体验🥏",
  )
] <diary>

