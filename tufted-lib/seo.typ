#let seo-tags(title: "", description: none, site-url: none, path: none, image: none) = {
  // Description
  if description != none {
    html.meta(name: "description", content: description)
    html.elem("meta", attrs: (property: "og:description", content: description))
  }

  // Canonical URL
  let canonical = if site-url != none and path != none {
    if site-url.ends-with("/") { site-url + path.trim("/") } else { site-url + "/" + path.trim("/") }
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
  html.meta(name: "twitter:card", content: "summary_large_image")
  if image != none {
    html.meta(name: "twitter:image", content: image)
  }
}
