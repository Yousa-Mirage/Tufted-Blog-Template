#let seo-tags(title: "", description: none, canonical-url: none) = {
  // Description
  if description != none {
    html.meta(name: "description", content: description)
    html.elem("meta", attrs: (property: "og:description", content: description))
  }

  // Canonical URL
  if canonical-url != none {
    html.link(rel: "canonical", href: canonical-url)
    html.elem("meta", attrs: (property: "og:url", content: canonical-url))
  }

  // Open Graph
  html.elem("meta", attrs: (property: "og:title", content: title))
  html.elem("meta", attrs: (property: "og:type", content: "website"))
  html.meta(name: "twitter:card", content: "summary_large_image")
}
