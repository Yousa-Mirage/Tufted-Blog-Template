#import "../index.typ": template, tufted, tag, tag-placeholder, series-block

#show: template.with(
  title: "个人文件夹",
  description: "Shiyi Li 的私人随笔、绘画与日常记录。",
  lang: "zh",
)

= 个人文件夹

#quote[
  这里收纳较私人的随笔、兴趣与日常记录，不在公开 Blog 目录中展示。返回 #link("../")[Blog 首页]。
]

// ==================== 杂谈 ====================
== 杂谈 <chat>

#html.div(class: "blog-tags", [
  #tag(<movie>, [🎬 影评])
  #tag(<culture>, [🌐 泛文化杂谈])
])

#series-block(title: "影评", tone: "rose")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 17),
    path: "../5-17",
    title: "影评杂谈｜浅析《沉默的羔羊》：女性困境“凝视”与当代文化延伸",
  )
] <movie>

#series-block(title: "泛文化杂谈", tone: "rose")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 4),
    path: "../6-4-yu",
    title: "泛文化杂谈｜一个暴论——暗色元素和百合作品于文艺性上“两面共生”😠",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 1),
    path: "../6-1",
    title: "泛文化杂谈｜关于 Yuri 漫画的个人茶话会💦",
  )
] <culture>

// ==================== 绘画记录 ====================
== 绘画记录 <draw>

#html.div(class: "blog-tags", [
  #tag-placeholder[✏️ 绘画分享（即将更新）]
  #tag-placeholder[🎨 板绘研究（即将更新）]
])

#series-block(title: "绘画分享", tone: "cyan")[
  #text(fill: luma(150), style: "italic")[暂无文章，敬请期待。]
]

// ==================== 个人记录 ====================
== 个人记录 <life>

#html.div(class: "blog-tags", [
  #tag(<language>, [🗣️ 语言学习])
  #tag(<diary>, [📝 日常记录])
])

#series-block(title: "语言学习", tone: "amber")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 26),
    path: "../5-26",
    title: "语言学习｜一周后的收获🎉",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 19),
    path: "../5-19-jp",
    title: "语言学习｜开始学习日语：让生活更有动力🐶",
  )
] <language>

#series-block(title: "日常记录", tone: "amber")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 23),
    path: "../5-23-fp",
    title: "日常记录｜飞盘初体验🥏",
  )
] <diary>
