/// Renders a blog index entry with a date column and linked title.
///
/// The `date` argument may be either a `datetime` value or preformatted
/// content. The `path` argument may include or omit a trailing slash.
///
/// - `date`: Date value or content shown in the date column.
/// - `path`: Destination URL for the entry title; a trailing slash is added
///   when missing.
/// - `title`: Linked title content.
///
/// Returns an HTML blog-entry element with separate date and title columns.
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
