#import "blog-entry.typ": blog-entry

/// Read the article catalogue supplied by build.py; direct compilation stays usable.
#let tag-catalogue() = {
  let path = sys.inputs.at("tags-data", default: none)
  if path == none { () } else { json(path) }
}

/// Normalize labels without merging distinct names such as C++ and C#.
#let normalize-tags(tags) = {
  assert(type(tags) == array, message: "tags must be an array of strings")
  tags.map(tag => {
    assert(type(tag) == str, message: "each tag must be a string")
    tag.trim()
  }).filter(tag => tag != "").dedup()
}

/// Group and sort a catalogue within a site-root directory.
/// Stable UTF-8 hex IDs keep arbitrary labels safe and collision-free in URLs.
#let tag-groups(posts, scope) = {
  let articles = posts.filter(post => post.path.starts-with(scope) and post.index == "")
  let labels = articles.map(post => post.tags).flatten().dedup().sorted()
  labels.map(name => {
    let id = "t-" + array(bytes(name)).chunks(48).map(chunk => chunk.map(b => {
      (if b < 16 { "0" } else { "" }) + str(b, base: 16)
    }).join()).join("/")
    let entries = articles.filter(post => name in post.tags)
    entries = entries.sorted(key: post => (post.date, post.url)).rev()
    (name: name, id: id, url: scope + "tags/" + id + "/", posts: entries)
  })
}

/// Render a semantic tag navigation, shared by the blog and tag archive pages.
#let tag-navigation(groups, lang: "zh", active: none) = {
  if groups.len() > 0 {
    let title = if lang == "zh" { "标签" } else { "Tags" }
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
#let tag-page(group, index-url, lang: "zh") = {
  html.p(class: "tag-back", html.a(href: index-url,
    if lang == "zh" { "← 返回博客" } else { "← Back to blog" }))
  heading(level: 1, group.name)
  html.p(class: "tag-summary", str(group.posts.len()) + if lang == "zh" { " 篇文章" } else if group.posts.len() == 1 { " article" } else { " articles" })
  for post in group.posts {
    blog-entry(date: post.date, path: post.url, title: post.title)
  }
}

/// Show an article's labels, linking to the most specific configured tag index.
/// Without catalogue data, labels remain readable plain text.
#let article-tags(tags, posts) = {
  if tags.len() > 0 {
    let page = "/" + sys.inputs.at("page-path", default: "")
    let indexes = posts.filter(post => post.index != "" and
      (page + "/").starts-with(post.index)).sorted(key: post => post.index.len())
    let groups = if indexes.len() > 0 { tag-groups(posts, indexes.last().index) } else { () }
    html.div(class: "article-tags", {
      for name in tags {
        let group = groups.find(group => group.name == name)
        if group == none {
          html.span(class: "tag-link", name)
        } else {
          html.a(class: "tag-link", href: group.url, name)
        }
      }
    })
  }
}
