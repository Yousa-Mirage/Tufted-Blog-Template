#import "../config.typ": template, tufted
#show: template

// tufted.margin-note 可以让你在边栏中放置内容
// 宽大的边栏是 tufte 样式的特点，将注释放于其中并与正文并排，便于对照
#tufted.margin-note({
  image("imgs/tufted-duck-female-with-duckling.webp")
  image("imgs/tufted-duck-male.webp")
})

#tufted.margin-note[
  凤头潜鸭（学名 _Aythya fuligula_）是一种中型潜水鸭，原生于欧亚大陆。凭借卓越的潜水能力，它们能深入水下捕食猎物。
]
#tufted.margin-note[
  The tufted duck (_Aythya fuligula_) is a medium-sized diving duck native to Eurasia. Known for its diving ability, it can plunge to great depths to forage for food.
]

= Tufted 博客模板

这是一个基于 #link("https://typst.app/")[Typst] 和 #link("https://github.com/vsheg/tufted")[Tufted] 的静态网站构建模板，手把手教你搭建简洁、美观的个人博客、作品集和简历设计。

#figure(caption: "网站示例")[#image("imgs/devices.webp")]

如果你通过访问本地地址（运行 `preview` 或其他本地服务）中看到了本页面，说明你已经成功安装了依赖、成功构建了网页、成功运行了预览。恭喜你！

想要使用这个模板编写你自己的网站，你需要学会使用 Typst。放心，非常好上手。

我在目前的网站中包含了尽可能多的 Typst 用例#footnote[例如文字、段落、分级标题、引用块、代码块、有序列表、无序列表、表格、图片、公式、链接、脚注、参考文献、嵌入 markdown 等。这块文字便是脚注，使用 `#footnote()` 函数编写。]，你可以在源代码中看到这些内容的 Typst 实现。我也包含了丰富的文档来帮助你编写页面和部署网站，你可以在 #link("/Docs/")[Docs] 页看到这些文档。

== 🎨 样式特点

#link("https://edwardtufte.github.io/tufte-css/")[*Tufte 样式*] 源于数据可视化大师 Edward Tufte#footnote[爱德华·罗尔夫·塔夫特（生于1942年3月14日），常被称为“ET”，是美国统计学家，耶鲁大学政治学、统计学与计算机科学荣休教授。他因在信息设计领域的著述和作为数据可视化领域的先驱而闻名。] 的设计理念，主张“内容至上”与极简主义，力求去除一切干扰信息的视觉杂音。

#link("https://edwardtufte.github.io/tufte-css/")[*The Tufte style*] originates from the design philosophy of data visualization master _Edward Tufte_#footnote[Edward Rolf Tufte (/ˈtʌfti/; born March 14, 1942), sometimes known as "ET", is an American statistician and professor emeritus of political science, statistics, and computer science at Yale University. He is noted for his writings on information design and as a pioneer in the field of data visualization.], advocating for a "content-first" approach and minimalism while striving to eliminate all visual noise that distracts from the information.

其最鲜明的特点是采用*宽大的侧边栏布局*，将注释、参考文献和图表直接并排展示在正文旁，取代了传统的脚注或尾注，配合优雅的*衬线字体*与*类纸张背景*，在数字屏幕上复刻了如经典学术著作般清晰、优雅、沉浸的深度阅读体验。
