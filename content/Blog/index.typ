#import "../index.typ": template, tufted
#show: template.with(
  title: "Blog",
  description: "Some blog examples",
)

= 博客 / Blog

中文博客样例可参考 #link("https://yousa-mirage.github.io/Blog")[我的个人网站]。

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
  title: "Normal Distribution",
)
#tufted.blog-entry(
  date: datetime(year: 2025, month: 4, day: 16),
  path: "2025-04-16-monkeys-apes",
  title: "Monkeys vs Apes",
)

== 2024

#tufted.blog-entry(
  date: "2024-10-04",
  path: "2024-10-04-iterators-generators/",
  title: "Iterators vs Generators in Python",
)
