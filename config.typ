#import "tufted-lib/tufted.typ" as tufted

#let template = tufted.tufted-web.with(
  // 你可以在 header-links 中修改网站上方的导航栏都包含哪些页面
  // 例如，如果你想添加一个 Entry 页，你需要添加 `"/Entry/": "Entry"`
  // 然后在 `content/` 路径中新建 `Entry/`路径，在其中添加 `index.typ` 作为 Entry 页的内容
  header-links: (
    "/": "Home",
    "/Docs/": "Docs",
    "/Blog/": "Blog",
    "/CV/": "CV",
    "/Changelog/": "Changelog",
  ),
  lang: "zh",
  title: "Tufted Blog Template", // 你的网站在浏览器中显示的标题
  description: "Tufted Blog Template", // 你的网站的描述
  site-url: "https://tufted-blog.pages.dev/", // 你的网站的 canonical URL

  // 自定义 header 和 footer 元素
  // 数组格式，可以添加任意数量的内容，内容之间将使用换行分隔
  header-elements: (
    [你好],
    [Ciallo～(∠・ω< )⌒☆],
  ),
  footer-elements: (
    "© 2026 Yousa-Mirage",
    [Powered by #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template")[Tufted-Blog-Template]],
  ),
)
