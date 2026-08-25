// TODO: figures and figures with captions inside margin notes

#let margin-note(content) = {
  html.elem(
    "span",
    attrs: (
      class: "sidenote-anchor",
      aria-hidden: "true",
    ),
    "\u{2060}",
  )
  html.span(class: "marginnote sidenote-manual", role: "note", content)
}

// TODO: implement <figure class="fullwidth">
// possible requires introspection or `set html.figure(class: "fullwidth")` support

#let full-width(content) = {
  html.div(class: "fullwidth", content)
}
