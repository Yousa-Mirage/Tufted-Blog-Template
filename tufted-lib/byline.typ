/// Render article metadata below the first level-one heading.
///
/// - `author`: Optional author name or content.
/// - `date`: Optional `datetime` or preformatted date content.
/// - `extra-info`: Optional additional metadata shown below the author and date.
///
/// Returns an HTML byline with semantic author and time elements.
#let article-byline(author: none, date: none, extra-info: none) = {
  let formatted-date = if date != none {
    if type(date) == datetime {
      (display: date.display(), datetime: date.display())
    } else {
      (display: date, datetime: none)
    }
  } else {
    (display: none, datetime: none)
  }

  html.div(
    class: "article-byline",
    {
      if author != none or date != none {
        html.p(
          class: "article-byline-main",
          {
            if author != none {
              html.span(class: "article-author", author)
            }
            if author != none and date != none {
              html.span(class: "article-byline-separator", " · ")
            }
            if date != none {
              let attrs = if formatted-date.datetime != none {
                (class: "article-date", datetime: formatted-date.datetime)
              } else {
                (class: "article-date")
              }

              html.elem("time", attrs: attrs, formatted-date.display)
            }
          },
        )
      }

      if extra-info != none {
        html.p(class: "article-extra-info", extra-info)
      }
    },
  )
}

/// Inject article metadata once, directly below the first level-one heading.
///
/// No byline is injected when both `date` and `extra-info` are omitted. The
/// author is passed through when a date or extra information enables injection.
///
/// - `content`: Document content containing the article's level-one heading.
/// - `author`: Optional author name or content.
/// - `date`: Optional `datetime` or preformatted date content.
/// - `extra-info`: Optional additional metadata.
///
/// Returns the content with a byline inserted after its first level-one heading.
#let template-byline(content, author: none, date: none, extra-info: none) = {
  if date != none or extra-info != none {
    let injected = state("article-byline-injected", false)

    show heading.where(level: 1): it => {
      it
      context {
        if not injected.get() {
          injected.update(true)
          article-byline(author: author, date: date, extra-info: extra-info)
        }
      }
    }

    content
  } else {
    content
  }
}
