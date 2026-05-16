#import "../index.typ": template, tufted
#show: template.with(
  title: "Blog",
  description: "Some blog examples",
)

= 博客 / Blog

这里会自动列出 `content/Blog/` 下的文章。Markdown 文章可以上传到 `content/Blog/_md/`，构建时会自动生成页面。

== 2026

#tufted.blog-entry(
  date: datetime(year: 2026, month: 5, day: 13),
  path: "2026-05-13-strassen-matrix-blocking/",
  title: "线性代数｜矩阵分块优化与 Strassen 算法",
)

== 2025

#tufted.blog-entry(
  date: datetime(year: 2025, month: 10, day: 30),
  path: "2025-10-30-normal-distribution/",
  title: "The Normal Distribution: A Fundamental Concept in Statistics",
)
#tufted.blog-entry(
  date: datetime(year: 2025, month: 4, day: 16),
  path: "2025-04-16-monkeys-apes/",
  title: "Monkeys vs Apes: Understanding the Difference",
)

== 2024

#tufted.blog-entry(
  date: datetime(year: 2024, month: 10, day: 4),
  path: "2024-10-04-iterators-generators/",
  title: "Iterators vs Generators in Python",
)
