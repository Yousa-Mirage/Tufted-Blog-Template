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
== 数学算法

#tufted.blog-entry(
  date: datetime(year: 2026, month: 5, day: 13),
  path: "2026-05-13-strassen-matrix-blocking/",
  title: "线性代数｜矩阵分块优化与 Strassen 算法",
)

== 个人评论

暂无文章。

== 绘画方法心得

暂无文章。

== 日记模块

暂无文章。
