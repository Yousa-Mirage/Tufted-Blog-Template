/// Renders a compact metadata row below an article title.
#let post-meta(date: datetime, tags: ()) = {
  let date-display = date.display()

  html.div(
    class: "post-meta",
    {
      html.elem(
        "time",
        attrs: (datetime: date-display),
        date-display,
      )
      for tag in tags {
        html.span(class: "post-meta-tag", tag)
      }
    },
  )
}

/// Renders a blog index entry with a date column and linked title.
///
/// The `date` argument may be either a `datetime` value or preformatted
/// content. The `path` argument may include or omit a trailing slash.
#let blog-entry(date: auto, path: str, title: str) = {
  let href = if path.ends-with("/") {
    path
  } else {
    path + "/"
  }

  let date_display = if type(date) == datetime {
    date.display()
  } else {
    date
  }

  html.div(
    class: "blog-entry",
    {
      html.div(
        class: "blog-entry-date",
        date_display,
      )
      html.div(
        class: "blog-entry-content",
        html.a(href: href, title),
      )
    },
  )
}
