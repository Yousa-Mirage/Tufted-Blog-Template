#import "../index.typ": template, tufted
#show: template.with(
  title: "Blog",
  description: "数学算法、个人评论、绘画方法心得与日记。",
)

= 博客 / Blog
#quote[
  If you enjoy my blog, feel free to bookmark the site:
  #link("https://shiyilee11.github.io/Tufted-Blog-Template/Blog/")[shiyilee11.github.io/Blog].
  If you have any ideas or suggestions, don't hesitate to reach out via #link("mailto:1747819157@qq.com")[email].
  I'd love to hear your feedback! 🙌
]

== 数学与算法

#tufted.blog-entry(
  date: datetime(year: 2026, month: 5, day: 13),
  path: "2026-05-13-strassen-matrix-blocking/",
  title: "线性代数｜矩阵分块优化与 Strassen 算法",
)

#tufted.blog-entry(
  date: datetime(year: 2026, month: 5, day: 18),
  path: "5-18",
  title: "Transformer｜反向传播 (Backpropagation)（1）：误差和梯度在Linear层的基础推导",
)

#tufted.blog-entry(
  date: datetime(year: 2026, month: 5, day: 19),
  path: "5-19",
  title: "Transformer｜反向传播 (Backpropagation)（2）：两个特殊模块：Softmax 与 RMSNorm",
)

== 杂谈

#tufted.blog-entry(
  date: datetime(year: 2026, month: 5, day: 17),
  path: "5-17",
  title: "影评杂谈｜浅析《沉默的羔羊》：女性困境“凝视”与当代文化延伸",
)


== 绘画记录

暂无文章。

== 日记

暂无文章。
