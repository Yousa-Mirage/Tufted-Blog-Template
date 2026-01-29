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

/// 生成完整的页面元数据，包括基础 meta 标签、SEO 标签和 RSS feed 链接
///
/// 参数：
/// - title: 页面标题
/// - author: 作者名称
/// - description: 页面描述
/// - lang: 网站语言
/// - date: 发布日期（datetime 或 string）
/// - website-title: 网站标题（用于 RSS feed）
/// - website-url: 网站 URL（用于 SEO 和 RSS feed）
/// - image-path: 页面图片路径（用于 Open Graph）
/// - feed-dir: RSS feed 目录配置
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
) = {
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
  html.link(rel: "icon", href: "/assets/favicon.ico")

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
