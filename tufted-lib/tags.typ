#import "blog-entry.typ": blog-entry

/// Read the article catalogue supplied by build.py; direct compilation stays usable.
#let tag-catalogue() = {
  let path = sys.inputs.at("tags-data", default: none)
  if path == none { () } else { json(path) }
}

/// Normalize labels without merging distinct names such as C++ and C#.
#let normalize-tags(tags) = tags.map(tag => tag.trim()).filter(tag => tag != "").dedup()

/// Keep ordinary ASCII labels readable; the hex suffix preserves case-sensitive identity.
/// Split long hex IDs to stay within filesystem component limits.
#let tag-id(name) = {
  let encoded = array(bytes(name)).chunks(48).map(chunk => chunk.map(b => {
    (if b < 16 { "0" } else { "" }) + str(b, base: 16)
  }).join()).join("/")
  let prefix = if name.len() <= 48 and name.match(regex("^[A-Za-z0-9_-]+$")) != none {
    "tag-" + name + "-"
  } else { "t-" }
  prefix + encoded
}

/// Group and sort a catalogue within a site-root directory.
/// Stable UTF-8 hex IDs keep arbitrary labels safe and collision-free in URLs.
#let tag-groups(posts, scope) = {
  let articles = posts.filter(post => post.path.starts-with(scope))
  let labels = articles.map(post => post.tags).flatten().dedup().sorted()
  labels.map(name => {
    let id = tag-id(name)
    let entries = articles.filter(post => name in post.tags)
    entries = entries.sorted(key: post => (post.date, post.url)).rev()
    (name: name, id: id, url: scope + "tags/" + id + "/", posts: entries.map(post => (title: post.title, date: post.date, url: post.url)))
  })
}

/// Render a semantic tag navigation, shared by the blog and tag archive pages.
#let tag-navigation(groups, lang: "zh", active: none) = {
  if groups.len() > 0 {
    let title = if lang.starts-with("zh") { "标签" } else { "Tags" }
    html.elem("aside", attrs: (class: "tag-sidebar"), {
      html.nav(aria-label: title, {
        html.p(class: "tag-sidebar-title", title)
        html.ul({
          for group in groups {
            html.li(html.elem("a", attrs: (
              href: group.url,
              class: "tag-link",
              ..if group.id == active { (aria-current: "page") } else { (:) },
            ), {
              html.span(group.name)
              html.span(class: "tag-count", " (" + str(group.posts.len()) + ")")
            }))
          }
        })
      })
    })
  }
}

/// Render a tag archive using the same entry layout as manually written blog lists.
#let tag-page(group, index-url, index-title: "", lang: "zh") = {
  html.p(class: "tag-back", html.a(href: index-url,
    if lang.starts-with("zh") { "← 返回" + if index-title == "" { "列表" } else { index-title } }
    else { "← Back to " + if index-title == "" { "index" } else { index-title } }))
  heading(level: 1, group.name)
  html.p(class: "tag-summary", str(group.posts.len()) + if lang.starts-with("zh") { " 篇文章" } else if group.posts.len() == 1 { " article" } else { " articles" })
  for post in group.posts {
    blog-entry(date: post.date, path: post.url, title: post.title)
  }
}

/// Show an article's labels, linking to the most specific configured tag index.
/// Without catalogue data, labels remain readable plain text.
#let article-tags(tags) = {
  if tags.len() > 0 {
    let page = "/" + sys.inputs.at("page-path", default: "")
    let path = sys.inputs.at("tag-scopes", default: none)
    let scopes = if path == none { () } else { json(path) }
    let indexes = scopes.filter(scope => (page + "/").starts-with(scope)).sorted(key: scope => scope.len())
    html.div(class: "article-tags", {
      for name in tags {
        if indexes.len() == 0 {
          html.span(class: "tag-link", name)
        } else {
          html.a(class: "tag-link", href: indexes.last() + "tags/" + tag-id(name) + "/", name)
        }
      }
    })
  }
}

// Standalone query entry; importing this module does not render its content.
#if sys.inputs.at("tag-query-scope", default: none) != none {
  [#metadata(tag-groups(tag-catalogue(), sys.inputs.at("tag-query-scope"))) <tag-plan>]
}
