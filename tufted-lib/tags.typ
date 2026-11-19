#import "blog-entry.typ": blog-entry

/// Match case variants and canonically equivalent Unicode spellings.
#let tag-key(name) = lower(name.normalize()).normalize()

/// Use short paths for ordinary labels and a separate namespace for encoded paths.
#let tag-id(key) = {
  let raw = bytes(key)
  let safe = (
    raw.len() <= 64
      and key.match(regex("^[\\p{L}\\p{N}_-]+$")) != none
      and key.match(regex("^(con|prn|aux|nul|com[1-9¹²³]|lpt[1-9¹²³])$")) == none
      and key.match(regex("^t-[0-9a-f]+$")) == none
      // Some lowercase letters, such as final sigma, share an uppercase form.
      and tag-key(upper(key)) == key
  )
  if safe {
    key
  } else {
    // Split long labels to stay within filesystem component limits.
    (
      "t-"
        + array(raw)
          .chunks(48)
          .map(chunk => chunk
            .map(b => {
              (if b < 16 { "0" } else { "" }) + str(b, base: 16)
            })
            .join())
          .join("/")
    )
  }
}

/// Share article link identities with the Python aggregator through metadata.
#let article-tag-records(tags) = {
  let names = tags.map(tag => tag.trim()).filter(tag => tag != "")
  names.map(name => (name: name, key: tag-key(name))).dedup(key: tag => tag.key).map(tag => tag + (id: tag-id(tag.key)))
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
            html.li(html.elem(
              "a",
              attrs: (
                href: group.url,
                class: "tag-link",
                ..if group.id == active { (aria-current: "page") } else { (:) },
              ),
              {
                html.span(group.name)
                html.span(class: "tag-count", " (" + str(group.count) + ")")
              },
            ))
          }
        })
      })
    })
  }
}

/// Render a tag archive using the same entry layout as manually written blog lists.
#let tag-page(group, index-url, index-title: "", lang: "zh") = {
  html.p(class: "tag-back", html.a(href: index-url, if lang.starts-with("zh") {
    "← 返回" + if index-title == "" { "列表" } else { index-title }
  } else { "← Back to " + if index-title == "" { "index" } else { index-title } }))
  heading(level: 1, group.name)
  html.p(
    class: "tag-summary",
    str(group.posts.len())
      + if lang.starts-with("zh") { " 篇文章" } else if group.posts.len() == 1 { " article" } else { " articles" },
  )
  for post in group.posts {
    blog-entry(date: post.date, path: post.url, title: post.title)
  }
}

/// Validate page tags and replace the page content and metadata for an archive build.
#let prepare-page-tags(tags, tag-index, page, lang: "zh") = {
  let tags = article-tag-records(tags)
  if tag-index != none {
    assert(
      type(tag-index) == str and tag-index.starts-with("/") and tag-index.ends-with("/"),
      message: "tag-index must be a site-root directory, e.g. /Blog/",
    )
    assert(tags.len() == 0, message: "A page cannot set both tag-index and tags")
  }
  let groups = ()
  let active = none
  let nav-path = sys.inputs.at("tag-navigation", default: none)
  if tag-index != none and nav-path != none {
    let navigation = json(nav-path)
    if navigation.scope == tag-index {
      groups = navigation.items
      let archive-path = sys.inputs.at("tag-archive", default: none)
      if archive-path != none {
        let archive = json(archive-path)
        assert(archive.scope == tag-index, message: "Tag archive scope does not match the index")
        let group = archive.group
        active = group.id
        page += (
          content: tag-page(group, archive.at("index-url"), index-title: page.title, lang: lang),
          title: group.name,
          description: "",
          date: none,
          extra-info: none,
        )
      }
    }
  }
  (tags: tags, groups: groups, active: active, ..page)
}

/// Encode hrefs like Python's quote(path, safe="/"), keeping path separators.
#let quote-tag-path(path) = path.replace(regex("[^A-Za-z0-9._~/-]+"), match => {
  array(bytes(match.text)).map(byte => "%" + (if byte < 16 { "0" } else { "" }) + upper(str(byte, base: 16))).join()
})

/// Show an article's labels, linking to the most specific configured tag index.
/// Without catalogue data, labels remain readable plain text.
#let article-tags(tags) = {
  if tags.len() > 0 {
    let page = sys.inputs.at("tag-page-path", default: "")
    let path = sys.inputs.at("tag-scopes", default: none)
    let scopes = if path == none { () } else { json(path) }
    let indexes = scopes.filter(scope => page.starts-with(scope)).sorted(key: scope => scope.len())
    html.p(class: "article-tags", {
      for (i, tag) in tags.enumerate() {
        if i > 0 { html.span(class: "article-byline-separator", " · ") }
        if indexes.len() == 0 {
          html.span(class: "tag-link", tag.name)
        } else {
          let href = quote-tag-path(indexes.last() + "tags/" + tag.id + "/")
          html.a(class: "tag-link", href: href, tag.name)
        }
      }
    })
  }
}
