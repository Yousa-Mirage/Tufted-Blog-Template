#import "layout.typ": margin-note

#let template-figures(content) = {
  // Redefine figure caption to use marginnote
  show figure.caption: it => html.span(
    class: "marginnote",
    it.supplement + sym.space.nobreak + it.counter.display() + it.separator + it.body,
  )

  // Add lazy-loading related attributes to raster images in HTML output.
  show image: it => context {
    if target() == "html" and type(it.source) == str {
      let alt = if it.alt == none { "" } else { it.alt }

      html.img(
        src: it.source,
        alt: alt,
        loading: "lazy",
        decoding: "async",
      )
    } else {
      it
    }
  }

  // Redefine figure itself
  show figure: it => if target() == "html" {
    html.figure({
      it.caption
      it.body
    })
  }

  content
}