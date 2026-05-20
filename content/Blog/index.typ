#import "../index.typ": template, tufted
#show: template.with(
  title: "Blog",
  description: "数学算法、个人评论、绘画方法心得与日记。",
)

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

#let series-block(title: "", body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: luma(248),
  stroke: 0.5pt + luma(210),
)[
  #text(size: 0.85em, weight: "bold", fill: luma(80))[📂 #title]
  #v(6pt)
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
#h(6pt)
#tag(<linear>, [线性代数])
#h(6pt)
#tag(<optimize>, [优化算法])

#v(12pt)

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

#v(8pt)

#series-block(title: "线性代数")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 13),
    path: "2026-05-13-strassen-matrix-blocking/",
    title: "矩阵分块优化与 Strassen 算法",
  )
] <linear>

// ==================== 实践与工具 ====================
== 实践与工具 <practice>

#tag(<tools>, [工具分享])
#h(6pt)
#tag(<project>, [项目实践])
#h(6pt)
#tag(<opinion>, [实践看法])

#v(12pt)

#series-block(title: "工具分享")[
  #text(fill: luma(150), style: "italic")[暂无文章，敬请期待。]
] <tools>

#v(8pt)

#series-block(title: "项目实践")[
  #text(fill: luma(150), style: "italic")[暂无文章，敬请期待。]
] <project>

#v(8pt)

#series-block(title: "实践看法")[
  #text(fill: luma(150), style: "italic")[暂无文章，敬请期待。]
] <opinion>

// ==================== 杂谈 ====================
== 杂谈 <chat>

#tag(<movie>, [影评])
#h(6pt)
#tag(<culture>, [文化评论])

#v(12pt)

#series-block(title: "影评")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 17),
    path: "5-17",
    title: "影评杂谈｜浅析《沉默的羔羊》：女性困境“凝视”与当代文化延伸",
  )
] <movie>

// ==================== 绘画记录 ====================
== 绘画记录 <draw>

#tag(<sketch>, [速写])
#h(6pt)
#tag(<color>, [色彩研究])

#v(12pt)

#series-block(title: "绘画")[
  #text(fill: luma(150), style: "italic")[暂无文章，敬请期待。]
] <sketch>

// ==================== 个人记录 ====================
== 个人记录 <life>

#tag(<language>, [语言学习])
#h(6pt)
#tag(<diary>, [日记])

#v(12pt)

#series-block(title: "日记")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 19),
    path: "5-19-jp",
    title: "“想让生活更有动力？你的选择是学习新的语言吗？🐶”",
  )
] <diary>