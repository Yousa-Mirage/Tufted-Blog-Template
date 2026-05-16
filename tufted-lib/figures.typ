#import "layout.typ": margin-note

#let template-figures(base-path: "", content) = {
  let with-base(path) = {
    if type(path) != str or base-path == none or base-path == "" or base-path == "/" {
      path
    } else if path.starts-with("http") or path.starts-with("#") {
      path
    } else if path.starts-with("/") {
      base-path.trim("/", at: end) + path
    } else {
      path
    }
  }

  // Redefine figure caption to use marginnote
  show figure.caption: it => html.span(
    class: "marginnote",
    it.supplement + sym.space.nobreak + it.counter.display() + it.separator + it.body,
  )

  // Add lazy-loading related attributes to raster images in HTML output.
  show image: it => context {
    if target() == "html" and type(it.source) == str {
      let alt = if it.alt == none { "" } else { it.alt }

      let dims = measure(it)
      let img-w = int(dims.width.pt())
      let img-h = int(dims.height.pt())

      // When use scale to resize an image (e.g., `width: 50%`),
      // the measured dimensions are zero.
      // `layout` is not available when exporting to HTML.
      if img-w > 0 and img-h > 0 {
        html.img(
          src: with-base(it.source),
          alt: alt,
          loading: "lazy",
          decoding: "async",
          width: img-w,
          height: img-h,
        )
      } else {
        html.img(
          src: with-base(it.source),
          alt: alt,
          loading: "lazy",
          decoding: "async",
        )
      }
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
