/// Article date rendering helpers.
///
/// `date` is shown below the first level-1 heading. `updated` is rendered at
/// the end of the article. `date_geo` and `updated_geo` may contain a
/// "lat,lng" coordinate string; `assets/date-location.js` resolves the display
/// timezone and place name on the client.

#let date-element(datetime-str, kind, geo: none) = {
  if datetime-str != none {
    let normalized-datetime = if type(datetime-str) == datetime {
      datetime-str.display()
    } else {
      datetime-str
    }
    let time-attrs = (
      class: "article-date " + kind + "-date",
      datetime: normalized-datetime,
    )
    if geo != none {
      time-attrs.insert("data-geo", geo)
    }

    html.div(
      class: "article-date-wrapper " + kind + "-date-wrapper",
      html.elem("time", attrs: time-attrs, normalized-datetime),
    )
  }
}

#let template-date(date: none, date_geo: none) = (content) => {
  if date != none {
    let h1-injected = state("h1-date-injected", false)
    show heading.where(level: 1): it => {
      it
      context if not h1-injected.get() {
        h1-injected.update(true)
        date-element(date, "created", geo: date_geo)
      }
    }
    content
  } else {
    content
  }
}

#let updated-block(updated: none, updated_geo: none) = {
  if updated != none {
    date-element(updated, "updated", geo: updated_geo)
  }
}
