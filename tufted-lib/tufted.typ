#import "math.typ": template-math
#import "refs.typ": template-refs
#import "notes.typ": template-notes
#import "figures.typ": template-figures
#import "blog-entry.typ": blog-entry
#import "layout.typ": full-width, margin-note
#import "links.typ": icon-link, template-links
#import "metadata.typ": metadata
#import "byline.typ": template-byline

/// The main wrapper function of Tufted Blog Template.
///
/// Builds the document shell, metadata, styles and scripts, navigation, article,
/// and footer. The template also installs show rules for figures, notes,
/// references, math, links, and article bylines.
///
/// - `header-links`: Dictionary mapping navigation URLs to visible labels.
/// - `header-icons`: Icon-link content, typically created with `icon-link`.
/// - `title`: Page title.
/// - `author`: Author name shown in metadata and the article byline.
/// - `description`: Page description used by metadata and social previews.
/// - `lang`: Document language, also used to localize the RSS label.
/// - `date`: Publication date used in metadata and the article byline.
/// - `extra-info`: Additional article byline content.
/// - `website-title`: Site title used in metadata and RSS titles.
/// - `website-url`: Site root URL used to build canonical and social URLs.
/// - `image-path`: Optional social preview image.
/// - `feed-dir`: Non-empty RSS directory list enables the global RSS link and
///   RSS discovery metadata.
/// - `header-elements`: Custom content shown above the navigation.
/// - `footer-elements`: Custom content shown in the site footer.
/// - `css`: Additional stylesheet URLs appended after the bundled styles.
/// - `js-scripts`: Additional script URLs, loaded after the bundled scripts.
/// - `margin-citations`: Enable bibliography entries as margin notes.
/// - `content`: Main page content.
///
/// Returns a complete HTML document for the HTML target and the input content
/// with the template's show rules for other targets.
#let tufted-web(
  header-links: (:),
  header-icons: (),

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

  // Copy bibliography entries into the margin next to author-date citations
  margin-citations: false,

  content,
) = {
  // Apply styling
  show: template-math
  show: template-refs
  show: template-notes
  show: template-figures
  show: template-links
  show: template-byline.with(author: author, date: date, extra-info: extra-info)
  show line: it => if target() == "html" { html.hr() } else { it }

  set text(lang: lang)
  set raw(syntaxes: (
    "custom-syntaxes/Just.sublime-syntax",
    "custom-syntaxes/Mermaid.sublime-syntax",
    "custom-syntaxes/JSON5.sublime-syntax",
    "custom-syntaxes/JSONC.sublime-syntax",
  ))

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
          "/assets/scripts/code-blocks.js",
          "/assets/scripts/format-headings.js",
          "/assets/scripts/theme-toggle.js",
          "/assets/scripts/marginnote-toggle.js",
          "/assets/scripts/toc.js",
          "/assets/scripts/back-to-top.js",
          "/assets/scripts/math-copy.js",
        )
        for (js-src) in (base-js + js-scripts).dedup() {
          html.script(src: js-src)
        }
        // Must run before sidenote-layout.js so the new notes get laid out
        if margin-citations { html.script(type: "module", src: "/assets/scripts/cite-margin.js") }
        html.script(type: "module", src: "/assets/scripts/sidenote-layout.js")
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
          html.nav(
            class: "site-nav",
            {
              if header-links != none {
                html.div(class: "site-nav-links", {
                  for (href, title) in header-links {
                    html.a(href: href, title)
                  }
                })
              }
              html.div(class: "site-nav-tools", {
                // Custom header icons
                for icon in header-icons {
                  icon
                }
                // RSS feed icon
                if feed-dir != none and feed-dir.len() > 0 {
                  let label = if lang == "zh" { "订阅 RSS" } else { "Subscribe via RSS" }
                  html.elem(
                    "a",
                    attrs: (
                      href: "/feed.xml",
                      class: "nav-icon rss-link",
                      type: "application/rss+xml",
                      aria-label: label,
                      title: label,
                    ),
                    "",
                  )
                }
                // Toggle theme button
                html.elem(
                  "button",
                  attrs: (
                    id: "theme-toggle",
                    class: "nav-icon theme-toggle-btn",
                    type: "button",
                    aria-label: "Toggle theme",
                  ),
                  "",
                )
              })
            },
          ),
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
