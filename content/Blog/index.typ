#import "../index.typ": template, tufted
#show: template.with(
  title: "Blog",
  description: "数学算法、个人评论、绘画方法心得与日记。",
)

= 博客 / Blog

这里按主题整理文章。Markdown 文章可以上传到 `content/Blog/_md/`，构建时会自动生成页面；在 front matter 里写 `category` 即可归入对应分区。

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
