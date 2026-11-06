// TODO: figures and figures with captions inside margin notes

/// Place content in a Tufte-style margin note.
///
/// The note is emitted as an HTML margin-note span preceded by an invisible
/// anchor used by the sidenote layout script.
///
/// - `content`: Text or other content to show in the margin.
///
/// Returns the anchor and margin-note elements.
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

/// Place content in a full-width HTML container.
///
/// - `content`: Content to place in the full-width region.
///
/// Returns an HTML `div` with the `fullwidth` class around the content.
#let full-width(content) = {
  html.div(class: "fullwidth", content)
}

/// Style native quotes for HTML, with an optional trailing attribution.
///
/// - `content`: Document content containing quotes.
///
/// Returns content with block quotes by default and no quotation marks.
/// Explicit inline quotes remain inline; paged output retains native rendering.
#let template-quotes(content) = {
  show quote: it => if target() == "html" {
    if it.block {
      html.elem("blockquote", attrs: (class: "quote-block"), {
        html.div(class: "quote-body", it.body)
        if it.attribution != none {
          html.div(class: "quote-attribution", it.attribution)
        }
      })
    } else {
      html.span(class: "quote-inline", {
        it.body
        if it.attribution != none { [ — #it.attribution] }
      })
    }
  } else {
    it
  }
  context {
    if target() == "html" {
      set quote(block: true, quotes: false)
      content
    } else {
      content
    }
  }
}
