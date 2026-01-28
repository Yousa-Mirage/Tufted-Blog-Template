#import "math.typ": template-math
#import "refs.typ": template-refs
#import "notes.typ": template-notes
#import "figures.typ": template-figures
#import "layout.typ": full-width, margin-note
#import "links.typ": template-links
#import "seo.typ": seo-tags

#let make-header(links) = html.header(
  if links.len() > 0 {
    html.nav(
      for (href, title) in links {
        html.a(href: href, title)
      },
    )
  },
)

/// Tufted 博客模板的主包装函数。
///
/// 用于生成完整的 HTML 页面结构，包含 SEO 元数据、CSS/JS 资源加载以及页眉页脚布局。
#let tufted-web(
  header-links: (:),

  // Meta data
  title: "",
  author: none,
  description: "",
  lang: "zh",
  date: datetime,

  // SEO
  site-url: none,
  image-path: none,

  // Feed-RSS
  feed-dir: (),

  // Custom header and footer elements
  header-elements: (),
  footer-elements: (),

  // Custom CSS and JS
  css: ("/assets/custom.css",),
  js-scripts: (),
  content,
) = {
  // Apply styling
  show: template-math
  show: template-refs
  show: template-notes
  show: template-figures
  show: template-links

  set text(lang: lang)

  html.html(
    lang: lang,
    {
      // Head
      html.head({
        html.meta(charset: "utf-8")
        html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
        html.meta(name: "generator", content: "Typst")

        html.title(title)
        html.link(rel: "icon", href: "/assets/favicon.ico")

        if feed-dir != none and feed-dir.len() > 0 {
          html.link(
            rel: "alternate",
            type: "application/rss+xml",
            href: "/feed.xml",
            title: title + " RSS Feed"
          )
        }

        // SEO
        seo-tags(
          title: title,
          author: author,
          description: description,
          site-url: site-url,
          page-path: sys.inputs.at("page-path", default: none),
          image-path: image-path,
        )

        // load CSS
        let base-css = (
          "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
          "/assets/tufted.css",
          "/assets/theme.css",
        )
        for (css-link) in (base-css + css).dedup() {
          html.link(rel: "stylesheet", href: css-link)
        }

        // load JS scripts
        let base-js = (
          "/assets/code-blocks.js",
          "/assets/format-headings.js",
          "/assets/theme-toggle.js",
          "/assets/marginnote-toggle.js",
        )
        for (js-src) in (base-js + js-scripts).dedup() {
          html.script(src: js-src)
        }
      })

      // Body
      html.body({
        // Custom header elements (site header, not navigation)
        html.header(
          class: "site-header",
          {
            for (i, element) in header-elements.enumerate() {
              element
              if i < header-elements.len() - 1 {
                html.br()
              }
            }
          },
        )

        // Add website navigation
        make-header(header-links)

        // Main content
        html.article(
          html.section(content),
        )

        // Custom footer elements
        html.footer({
          for (i, element) in footer-elements.enumerate() {
            element
            if i < footer-elements.len() - 1 {
              html.br()
            }
          }
        })
      })
    },
  )
}
