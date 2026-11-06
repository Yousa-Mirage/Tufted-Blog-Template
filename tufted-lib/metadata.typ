/// Emit SEO, Open Graph, and Twitter Card metadata tags.
///
/// Relative image paths are made absolute when a site URL is provided. The page
/// path determines whether Open Graph content is marked as a website or article.
///
/// - `title`: Page title.
/// - `author`: Optional author name.
/// - `description`: Optional page description.
/// - `site-url`: Optional website root URL used to resolve relative image paths.
/// - `canonical-url`: Optional canonical page URL.
/// - `image-path`: Optional absolute or site-relative preview image URL.
/// - `page-path`: Optional page path used to select the Open Graph type.
///
/// Returns the generated HTML metadata elements.
#let seo-tags(
  title: "",
  author: none,
  description: none,
  site-url: none,
  canonical-url: none,
  image-path: none,
  page-path: none,
) = {
  // Process Absolute image path
  let og-image = if image-path == none {
    none
  } else if image-path.starts-with("http") {
    image-path
  } else if site-url != none {
    site-url.trim("/", at: end) + "/" + image-path.trim("/", at: start)
  } else {
    none
  }

  // Process OG type
  let auto-og-type = if page-path == none or page-path == "" or page-path == "/" {
    "website"
  } else {
    "article"
  }

  // Open Graph
  html.elem("meta", attrs: (property: "og:title", content: title))
  html.elem("meta", attrs: (property: "og:type", content: auto-og-type))

  if description != none {
    html.meta(name: "description", content: description)
    html.elem("meta", attrs: (property: "og:description", content: description))
  }

  if canonical-url != none {
    html.elem("meta", attrs: (property: "og:url", content: canonical-url))
  }

  if author != none {
    html.meta(name: "author", content: author)
    if auto-og-type == "article" {
      html.elem("meta", attrs: (property: "article:author", content: author))
    }
  }

  if og-image != none {
    html.elem("meta", attrs: (property: "og:image", content: og-image))
    html.meta(name: "twitter:card", content: "summary_large_image")
    html.meta(name: "twitter:image", content: og-image)
  } else {
    html.meta(name: "twitter:card", content: "summary")
  }
}

/// Generate page metadata, including basic tags, SEO tags, and RSS discovery.
///
/// Emits the document title, viewport and generator tags, favicon, optional
/// publication date, RSS alternate link, canonical URL, and social preview tags.
///
/// - `title`: Page title; falls back to `website-title`, then "Untitled Page".
/// - `author`: Optional author name.
/// - `description`: Optional page description.
/// - `lang`: Document language.
/// - `date`: Optional publication date as a `datetime` or string.
/// - `website-title`: Optional site title used as a title fallback and RSS title.
/// - `website-url`: Optional site root URL used for canonical and social URLs.
/// - `image-path`: Optional absolute or site-relative social preview image path.
/// - `feed-dir`: Non-empty RSS directory configuration enables feed discovery.
/// - `favicon`: ICO icon URL; defaults to `/assets/favicon.ico`.
///
/// Returns the generated HTML metadata elements.
#let metadata(
  title: "",
  author: none,
  description: "",
  lang: "zh",
  date: none,
  website-title: "",
  website-url: none,
  image-path: none,
  feed-dir: (),
  favicon: "/assets/favicon.ico",
) = {
  assert(type(favicon) == str, message: "favicon must be an ICO URL string")
  assert(favicon.starts-with("/"), message: "favicon must start with /")
  assert(lower(favicon).ends-with(".ico"), message: "favicon must end with .ico")
  // Basic meta tags
  html.meta(charset: "utf-8")
  html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
  html.meta(name: "generator", content: "Typst")

  // Page title and favicon
  let page-title = if title != "" {
    title
  } else if website-title != "" {
    website-title
  } else {
    "Untitled Page"
  }
  html.title(page-title)
  html.link(rel: "icon", type: "image/x-icon", href: favicon)

  // Date
  if type(date) == datetime {
    html.meta(name: "date", content: date.display())
  } else if type(date) == str {
    html.meta(name: "date", content: date)
  }

  // RSS feed link
  if feed-dir != none and feed-dir.len() > 0 {
    let rss-title = if website-title != "" { website-title } else { title }
    html.link(
      rel: "alternate",
      type: "application/rss+xml",
      href: "/feed.xml",
      title: rss-title + " RSS Feed",
    )
  }

  // Link
  let page-path = sys.inputs.at("page-path", default: none)

  let canonical-url = if website-url != none and page-path != none {
    let clean-site-url = website-url.trim("/", at: end)
    let clean-path = page-path.trim("/")
    if clean-path == "" {
      clean-site-url + "/"
    } else {
      clean-site-url + "/" + clean-path + "/"
    }
  } else {
    none
  }

  if canonical-url != none {
    html.link(rel: "canonical", href: canonical-url)
  }

  // SEO tags (Open Graph, Twitter Card, etc.)
  seo-tags(
    title: title,
    author: author,
    description: description,
    site-url: website-url,
    image-path: image-path,
    page-path: page-path,
    canonical-url: canonical-url,
  )
}
