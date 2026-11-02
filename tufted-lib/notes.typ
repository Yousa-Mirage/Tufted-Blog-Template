/// Render footnotes as linked margin notes in HTML output.
///
/// Each HTML footnote gets a numbered reference in the text and a matching
/// margin note with a link back to that reference. Other targets use Typst's
/// native footnote rendering.
///
/// - `content`: Document content containing footnotes.
///
/// Returns the content with the footnote show rule applied.
#let template-notes(content) = {
  show footnote: it => {
    if target() == "html" {
      let number = counter(footnote).display(it.numbering)
      let fn-id = "fn-" + number
      let ref-id = "fnref-" + number

      // Numeric references in the main text
      html.sup(class: "footnote-ref", html.a(
        class: "footnote-ref-link",
        href: "#" + fn-id,
        id: ref-id,
        number,
      ))

      // Footnote content in the margin
      html.span(
        class: "marginnote sidenote-footnote",
        id: fn-id,
        role: "note",
        html.sup(html.a(class: "footnote-ref-link", href: "#" + ref-id, number)) + [ ] + it.body,
      )
    }
  }
  content
}
