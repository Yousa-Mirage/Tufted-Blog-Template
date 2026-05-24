#import "math.typ": template-math
#import "refs.typ": template-refs
#import "notes.typ": template-notes
#import "figures.typ": template-figures
#import "blog-entry.typ": blog-entry
#import "layout.typ": full-width, margin-note
#import "links.typ": template-links
#import "metadata.typ": metadata
#import "byline.typ": template-byline

/// The main wrapper function of Tufted Blog Template.
///
/// Used to generate a complete HTML page structure,
/// including SEO metadata, CSS/JS resource loading, and header and footer layout.
#let tufted-web(
  header-links: (:),

  // Meta data
  title: "",
  author: none,
  description: "",
  lang: "zh",
  date: none,
  extra-info: none,
  website-title: "",
  website-url: none,

  // For SEO
  image-path: none,

  // For RSS
  feed-dir: (),

  // Custom header and footer
  header-elements: (),
  footer-elements: (),

  // Custom CSS and JS Scripts
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
  show: template-byline.with(author: author, date: date, extra-info: extra-info)

  set text(lang: lang)

  html.html(
    lang: lang,
    {
      // Head
      html.head({
        // All metadata
        metadata(
          title: title,
          author: author,
          description: description,
          lang: lang,
          date: date,
          website-title: website-title,
          website-url: website-url,
          image-path: image-path,
          feed-dir: feed-dir,
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
          "/assets/toc.js",
          "/assets/back-to-top.js",
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
        html.header(
          class: "site-header",
          if header-links != none {
            html.nav(
              class: "site-nav",
              {
                for (href, title) in header-links {
                  html.a(href: href, title)
                }
                html.elem(
                  "button",
                  attrs: (
                    id: "theme-toggle",
                    class: "theme-toggle-btn",
                    type: "button",
                    aria-label: "Toggle theme",
                  ),
                  "",
                )
              },
            )
          }
        )

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
