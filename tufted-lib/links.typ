/// Create an accessible link that displays a monochrome SVG as a theme-aware icon.
///
/// The icon is applied as a CSS mask, so its original SVG colors are ignored and
/// the icon inherits the navigation foreground color. The resulting link uses
/// the shared navigation icon styles and can be placed in `header-icons`.
///
/// - `url`: Destination of the link, such as an HTTPS URL or `mailto:` address.
/// - `icon`: Site-root path or HTTPS URL of the SVG file.
/// - `label`: Accessible name and hover tooltip for the link.
///
/// Returns an HTML anchor element with the `nav-icon custom-icon-link` classes.
///
/// ```typst
/// tufted.icon-link(
///   url: "https://github.com/yourname",
///   icon: "/assets/icons/github.svg",
///   label: "GitHub",
/// )
/// ```
#let icon-link(url: none, icon: none, label: none) = {
  assert(type(url) == str, message: "url must be a string")
  assert(type(icon) == str, message: "icon must be a string")
  assert(type(label) == str, message: "label must be a string")
  assert(
    icon.starts-with("/") or icon.starts-with("https://"),
    message: "icon must be a site-root path or an https URL",
  )

  html.elem(
    "a",
    attrs: (
      href: url,
      class: "nav-icon custom-icon-link",
      style: "--nav-icon: url(\"" + icon + "\")",
      aria-label: label,
      title: label,
    ),
    "",
  )
}

/// Open external and non-HTML resource links in a new browser tab.
///
/// String destinations beginning with `http`, and resource destinations that
/// are not HTML pages, receive `target="_blank"` and safe `rel` attributes.
/// Internal links and non-string destinations keep their original rendering.
///
/// - `content`: Document content containing links.
///
/// Returns the content with the link show rule applied.
#let template-links(content) = {
  // Open external links and non-web resources in a new tab
  show link: it => {
    if type(it.dest) == str {
      // 1. Determine whether it is an external link (starting with http)
      let is-external = it.dest.starts-with("http")

      // 2. Determine whether it is a "non-web page resource"
      let is-resource = it.dest.contains(".") and not it.dest.ends-with(".html")

      if is-external or is-resource {
        html.a(
          href: it.dest,
          target: "_blank",
          rel: ("noopener", "noreferrer"),
          it.body,
        )
      } else {
        it // Internal page link (.html) or anchor link (#top), keep as is
      }
    } else {
      it // Internal reference object, keep as is
    }
  }

  content
}
