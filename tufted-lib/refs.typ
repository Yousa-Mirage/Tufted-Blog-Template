/// Customize heading and equation references while preserving other references.
///
/// Heading references are wrapped in quotation marks. Equation references use
/// the equation's numbering and link to its location.
///
/// - `content`: Document content whose references should be transformed.
///
/// Returns the content with the reference show rule applied.
#let template-refs(content) = {
  show ref: it => {
    // Aliases
    let eq = math.equation
    let el = it.element

    // Equation reference
    if el != none and el.func() == eq {
      // Override equation references.
      return link(el.location(), numbering(
        el.numbering,
        ..counter(eq).at(el.location()),
      ))
    }

    if el != none and el.func() == heading {
      return link(el.location(), smartquote() + it.element.body + smartquote())
    }

    it
  }

  content
}
