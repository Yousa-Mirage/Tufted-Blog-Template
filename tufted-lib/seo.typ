#let seo-tags(
  title: "",
  description: none,
  site-url: none,
  page-path: none,
  image-path: none,
) = {
  // Description
  if description != none {
    html.meta(name: "description", content: description)
    html.elem("meta", attrs: (property: "og:description", content: description))
  }

  // Canonical URL
  let canonical = if site-url != none and page-path != none {
    let clean-site-url = site-url.trim("/", at: end)
    let clean-path = page-path.trim("/")
    if clean-path == "" {
      clean-site-url + "/"
    } else {
      clean-site-url + "/" + clean-path + "/"
    }
  } else {
    none
  }

  if canonical != none {
    html.link(rel: "canonical", href: canonical)
    html.elem("meta", attrs: (property: "og:url", content: canonical))
  }

  // Open Graph

  let auto-og-type = if page-path == "" or page-path == "/" {
    "website"
  } else {
    "article"
  }

  html.elem("meta", attrs: (property: "og:title", content: title))
  html.elem("meta", attrs: (property: "og:type", content: auto-og-type))
  if image-path != none {
    html.elem("meta", attrs: (property: "og:image", content: image-path))
  }

  // Twitter Card
  if image-path != none {
    html.meta(name: "twitter:card", content: "summary_large_image")
    html.meta(name: "twitter:image", content: image-path)
  } else {
    html.meta(name: "twitter:card", content: "summary")
  }
}
