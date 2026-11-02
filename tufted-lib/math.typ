/// Configure equation numbering and semantic HTML rendering for mathematics.
///
/// Equations are numbered with parentheses. HTML output wraps inline and block
/// equations in elements with the `math` role; other targets keep native output.
///
/// - `content`: Document content containing equations.
///
/// Returns the content with math-related show rules applied.
#let template-math(content) = {
  set math.equation(numbering: "(1)")

  let html-math-content(it) = if sys.version >= version(0, 15, 0) {
    it
  } else {
    html.frame(it)
  }

  show math.equation.where(block: false): it => {
    if target() == "html" {
      html.span(class: "math-inline", role: "math", html-math-content(it))
    } else {
      it
    }
  }

  show math.equation.where(block: true): it => {
    if target() == "html" {
      html.figure(class: "math-block", role: "math", html-math-content(it))
    } else {
      it
    }
  }

  content
}
