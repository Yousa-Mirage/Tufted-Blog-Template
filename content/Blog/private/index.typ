#import "../index.typ": template, tufted, tag, tag-placeholder, series-block

#show: template.with(
  title: "个人文件夹",
  description: "Shiyi Li 的私人记录入口。",
  lang: "zh",
)

= *个人文件夹*

#quote[
  你已进入私人记录区域。这里的内容不会在公开 Blog 页展示。
  如需返回公开目录，可前往 #link("../")[Blog 首页]。
]

// ==================== 杂谈 ====================
== *杂谈* <chat>

#tag(<movie>, [🎬 影评])
#tag(<wide>, [🌐 泛文化杂谈])

#series-block(title: "影评", accent: rgb("#ec4899"))[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 17),
    path: "../5-17",
    title: "影评杂谈｜浅析《沉默的羔羊》：女性困境“凝视”与当代文化延伸",
  )
] <movie>

#series-block(title: "泛文化杂谈", accent: rgb("#ec4899"))[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 4),
    path: "../6-4-yu",
    title: "泛文化杂谈｜一个暴论——暗色元素和百合作品于文艺性上“两面共生”",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 1),
    path: "../6-1",
    title: "泛文化杂谈｜关于yuri漫画的个人茶话会💦",
  )
] <wide>

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
    path: "../5-26",
    title: "“一周后的收获🎉”",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 19),
    path: "../5-19-jp",
    title: "“想让生活更有动力？你的选择是学习新的语言吗？🐶”",
  )
] <langauge>

#series-block(title: "日常记录", accent: rgb("#f97316"))[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 23),
    path: "../5-23-fp",
    title: "日常记录｜飞盘初体验🥏",
  )
] <diary>
