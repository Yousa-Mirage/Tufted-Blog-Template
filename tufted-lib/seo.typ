#let seo-tags(title: "", description: none, site-url: none, path: none, image: none) = {
  // Description
  if description != none {
    html.meta(name: "description", content: description)
    html.elem("meta", attrs: (property: "og:description", content: description))
  }

  // Canonical URL
  let canonical = if site-url != none and path != none {
    let clean-site-url = site-url.trim("/", at: end)
    let clean-path = path.trim("/")
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
  html.elem("meta", attrs: (property: "og:title", content: title))
  html.elem("meta", attrs: (property: "og:type", content: "website"))
  if image != none {
    html.elem("meta", attrs: (property: "og:image", content: image))
  }

  // Twitter Card
  if image != none {
    html.meta(name: "twitter:card", content: "summary_large_image")
    html.meta(name: "twitter:image", content: image)
  } else {
    html.meta(name: "twitter:card", content: "summary")
  }
}
