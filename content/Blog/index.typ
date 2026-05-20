#import "../index.typ": template, tufted
#show: template.with(
  title: "Blog",
  description: "数学算法、个人评论、绘画方法心得与日记。",
)

// 可点击跳转标签（有对应 label）
#let tag(target, body) = {
  link(target)[
    #box(
      stroke: 0.8pt + rgb("#4a90d9"),
      fill: rgb("#f0f6ff"),
      inset: (x: 10pt, y: 5pt),
      radius: 12pt,
    )[
      #text(size: 0.85em, fill: rgb("#4a90d9"), weight: "bold")[#body]
    ]
  ]
}

// 不可点击的占位标签（暂无内容时使用）
#let tag-placeholder(body) = {
  box(
    stroke: 0.8pt + luma(200),
    fill: luma(245),
    inset: (x: 10pt, y: 5pt),
    radius: 12pt,
  )[
    #text(size: 0.85em, fill: luma(160), weight: "bold")[#body]
  ]
}

// 系列卡片
#let series-block(title: "", body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: luma(248),
  stroke: 0.5pt + luma(210),
)[
  #text(size: 0.85em, weight: "bold", fill: luma(80))[📂 #title]
  #body
]

= 博客 / Blog

#quote[
  If you enjoy my blog, feel free to bookmark the site:
  #link("https://shiyilee11.github.io/Tufted-Blog-Template/Blog/")[shiyilee11.github.io/Blog].
  If you have any ideas or suggestions, don't hesitate to reach out via
  #link("mailto:1747819157@qq.com")[email].
  I'd love to hear your feedback! 🙌
]

// ==================== 数学与算法 ====================
== 数学与算法 <math>

#tag(<transformer>, [Transformer 系列])
#tag(<linear>, [线性代数])
#tag-placeholder[优化算法（即将更新）]

#series-block(title: "Transformer｜反向传播")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 20),
    path: "5-20-tr",
    title: "（3）以SwiGLU为例的前馈网络层推导",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 19),
    path: "5-19",
    title: "（2）两个特殊模块：Softmax 与 RMSNorm",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 18),
    path: "5-18",
    title: "（1）误差和梯度在 Linear 层的基础推导",
  )
] <transformer>

#series-block(title: "线性代数")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 13),
    path: "2026-05-13-strassen-matrix-blocking/",
    title: "矩阵分块优化与 Strassen 算法",
  )
] <linear>

// ==================== 实践与工具 ====================
== 实践与工具 <practice>

#tag-placeholder[工具分享（即将更新）]
#tag-placeholder[项目实践（即将更新）]
#tag-placeholder[实践看法（即将更新）]

#series-block(title: "实践与工具")[
  #text(fill: luma(150), style: "italic")[暂无文章，敬请期待。]
]

// ==================== 杂谈 ====================
== 杂谈 <chat>

#tag(<movie>, [影评])
#tag-placeholder[文化评论（即将更新）]

#series-block(title: "影评")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 17),
    path: "5-17",
    title: "影评杂谈｜浅析《沉默的羔羊》：女性困境“凝视”与当代文化延伸",
  )
] <movie>

// ==================== 绘画记录 ====================
== 绘画记录 <draw>

#tag-placeholder[速写（即将更新）]
#tag-placeholder[色彩研究（即将更新）]

#series-block(title: "绘画")[
  #text(fill: luma(150), style: "italic")[暂无文章，敬请期待。]
]

// ==================== 个人记录 ====================
== 个人记录 <life>

#tag-placeholder[语言学习（即将更新）]
#tag(<diary>, [日记])

#series-block(title: "日记")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 19),
    path: "5-19-jp",
    title: "“想让生活更有动力？你的选择是学习新的语言吗？🐶”",
  )
] <diary>