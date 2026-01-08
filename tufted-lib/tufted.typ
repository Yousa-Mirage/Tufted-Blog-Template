#import "math.typ": template-math
#import "refs.typ": template-refs
#import "notes.typ": template-notes
#import "figures.typ": template-figures
#import "layout.typ": full-width, margin-note

#let make-header(links) = html.header(
  if links != none {
    html.nav(
      for (href, title) in links {
        html.a(href: href, title)
      },
    )
  },
)

#let tufted-web(
  header-links: none,
  title: "Tufted",
  lang: "en",
  css: (
    "https://cdnjs.cloudflare.com/ajax/libs/tufte-css/1.8.0/tufte.min.css",
    "/assets/tufted.css",
    "/assets/theme.css",
    "/assets/custom.css",
  ),
  icon: "/assets/favicon.ico",
  js-scripts: (
    "/assets/code-blocks.js",
    "/assets/format-headings.js",
    "/assets/theme-toggle.js",
  ),
  header-elements: (),
  footer-elements: (),
  content,
) = {
  // Apply styling
  show: template-math
  show: template-refs
  show: template-notes
  show: template-figures

  set text(lang: lang)

  html.html(
    lang: lang,
    {
      // Head
      html.head({
        html.meta(charset: "utf-8")
        html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
        html.title(title)
        html.link(rel: "icon", href: icon)

        // Stylesheets
        for (css-link) in css {
          html.link(rel: "stylesheet", href: css-link)
        }

        for (js-src) in js-scripts {
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
