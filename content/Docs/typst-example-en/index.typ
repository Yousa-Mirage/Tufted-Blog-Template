#import "../index.typ": template, tufted
#import "@preview/theorion:0.6.0": *
#import "@preview/tablem:0.3.0": *
#import "@preview/citegeist:0.2.2": load-bibliography
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.7": *

#show: template.with(
  title: "Typst Example",
  description: "A Typst example document that showcases Typst features and how they render in this web template.",
  lang: "en",
)

= Typst Example

This document showcases Typst features and how they look in the current web template. The rendered result is shown above, and the code blocks below are the corresponding source code.

#note-block[
  This is not a comprehensive Typst tutorial. The goal is to show how various Typst elements render in this template, and to demonstrate the syntax along the way.

  If you have never used Typst or any markup language before, I recommend reading the #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/Typst-%E5%BF%AB%E9%80%9F%E5%85%A5%E9%97%A8%E8%B5%84%E6%96%99")[Wiki page] and the resources there first.
]

== 1. Fonts and Text Styling <ch1>

Here we demonstrate *bold*, _italic_, #underline[underline], #strike[strikethrough], #overline[overline], superscript E=mc#super[2], subscript H#sub[2]O. Important content can be #highlight[highlighted].

```typ
Here we demonstrate *bold*, _italic_, #underline[underline], #strike[strikethrough], #overline[overline], superscript E=mc#super[2], subscript H#sub[2]O. Important content can be #highlight[highlighted].
```

You can create paragraphs by leaving a blank line.

This is a new paragraph. You can add a line break by appending `\` at the end of a line.\
This is a new line.

```typ
You can create paragraphs by leaving a blank line.

This is a new paragraph. You can add a line break by appending `\\` at the end of a line.\\
This is a new line.
```

Currently, `#line()` does not support HTML export, but you can use `#html.hr()` to add a horizontal divider.

#html.hr()

To display special characters, escape them: \* \_ \# \$ \@

```typ
To display special characters, escape them: \* \_ \# \$ \@
```

The site's visual appearance is controlled by CSS, so you currently cannot directly change text styles in Typst, such as #text(fill: blue)[color], #text(size: 14pt)[size], or #text(font: "Liu Jian Mao Cao")[font]. If you want to customize them, add your own CSS rules in `assets/custom.css`.

```typ
You currently cannot directly change text styles in Typst, such as #text(fill: blue)[color], #text(size: 14pt)[size], or #text(font: "Liu Jian Mao Cao")[font].
```


== 2. Headings

The “Typst Example” at the top is a level-1 heading, and “2. Headings” is a level-2 heading.

=== Level 3
==== Level 4

```typ
=== Level 3
==== Level 4
```

== 3. Links

You can use `#link()` to add links, for example:
- #link("https://github.com/Yousa-Mirage")[This is a link to an external webpage].
- #link("https://yousa-mirage.github.io/", "This is also an external link").
- You can also link to other pages or resources on this site, for example:
  - #link("../typst-example/sample-PDF.pdf")[This links to a PDF document]. You can create Typst documents that compile to PDF, such as this PDF built from `sample-PDF.typ`. You can link to the compiled PDF to showcase complex formatting (e.g. a PDF version of a resume).
  - #link("/CV/")[And this links to the CV page of this site.]

```typ
- #link("https://github.com/Yousa-Mirage")[This is a link to an external webpage].
- #link("https://yousa-mirage.github.io/", "This is also an external link").
- You can also link to other pages or resources on this site, for example:
  - #link("../typst-example/sample-PDF.pdf")[This links to a PDF document].
  - #link("/CV/")[And this links to the CV page of this site.]
```


== 4. Lists

Here is an example of mixed lists:

- Unordered item 1
- Unordered item 2
  - Indented levels are supported
    - Indent further
  + You can insert an ordered list inside an unordered list

    Add a paragraph at the current nesting level

+ Ordered item 1
+ Ordered item 2 (auto-numbered)
  + Nested ordered item A
    - You can insert an unordered list inside an ordered list
  - Nested unordered item B

/ Term list: list items with names, useful for definitions.
/ Typst: A new markup-based typesetting system.

```typ
- Unordered item 1
- Unordered item 2
  - Indented levels are supported
    - Indent further
  + You can insert an ordered list inside an unordered list

    Add a paragraph at the current nesting level

+ Ordered item 1
+ Ordered item 2 (auto-numbered)
  + Nested ordered item A
    - You can insert an unordered list inside an ordered list
  - Nested unordered item B

/ Term list: list items with names, useful for definitions.
/ Typst: A new markup-based typesetting system.
```


== 5. Margin Notes, Footnotes, and Bibliography

#tufted.margin-note[You can add margin content anywhere.]

The most distinctive feature of the *Tufte style* is its *wide margin layout*: notes, references, and figures are displayed in the margin right next to the main text, replacing traditional footnotes or endnotes. This recreates a clear, immersive, side-by-side reading experience on screens. #footnote[This is what the homepage of #link("/")[this site] says.]

You can use `footnote()` to add footnotes. They will automatically appear in the margin aligned with the main text, so readers don't have to scroll to the end of the page. #footnote[Footnotes really interrupt reading! That's also why I built this blog template with the Tufte style.]

```typ
You can use `footnote()` to add footnotes. #footnote[Footnotes really interrupt reading!]
```

You can use `tufted.margin-note()` to place arbitrary *unbroken* margin content anywhere, e.g. an image, inline code, or inline math. #footnote[`box()` can force content to stay in a single paragraph.]
#tufted.margin-note[
  #image("../../imgs/tufted-duck-male.webp")
]
#tufted.margin-note[
  ⬆️ This is a duck, this is `inline code`, and this is inline math $1 + 1 = 2$.\
  This is a line break
]

```typ
// Typst code that places an image and text in the right margin.
#tufted.margin-note[
  #image("../../imgs/tufted-duck-male.webp")
]
#tufted.margin-note[
  ⬆️ This is a duck, this is `inline code`, and this is inline math $1 + 1 = 2$.\\
  This is a line break
]
```

You can export references as a `.bib` file, then use `bibliography()` to load it into Typst. After that, you can cite entries with `@`, like this: @tufte1973relationship.\
By default, the bibliography is displayed at the position where `bibliography()` is called. The template does not yet support automatically showing the bibliography in the margin, but you can cite it manually in a footnote. #footnote[Tufte, E. R. (1973). The Relationship between Seats and Votes in Two-Party Systems. _American Political Science Review, 67_(2), 540–554. https://doi.org/10.2307/1958782]

#bibliography("../typst-example/papers.bib", title: none, style: "american-psychological-association")

```typ
Then you can cite entries with `@`, like this: @tufte1973relationship.\\
You can also cite it manually in a footnote. #footnote[Tufte, E. R. (1973). The Relationship between Seats and Votes in Two-Party Systems. _American Political Science Review, 67_(2), 540–554. https://doi.org/10.2307/1958782]

#bibliography("../typst-example/papers.bib", title: none, style: "american-psychological-association")
```

You can even write a `for` loop to manually typeset items from a `.bib` file:

#{
  let bib = load-bibliography(read("../typst-example/papers.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #data.author, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]
  ]
}

```typ
#import "@preview/citegeist:0.2.2": load-bibliography

#{
  let bib = load-bibliography(read("../typst-example/papers.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #data.author, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]
  ]
}
```

You can use `tufted.full-width()` to display content in full width, for example, here is a super wide MIKU:

#tufted.full-width[#image("../typst-example/miku.png")]

```typ
#tufted.full-width[#image("../typst-example/miku.png")]
```

== 6. Images

You can use `figure()` to add a caption for any content, especially images and tables. The caption will also appear in the margin.

Use `image()` to insert images. You can control size with `width` and `height`. For example, `figure + image`:

#figure(caption: "Another duck.")[
  #image("../../imgs/tufted-duck-female-with-duckling.webp", width: 250pt)
]<duck>

#image("../../imgs/gorilla.webp", height: 250pt)

```typ
#figure(caption: "Another duck.")[
  #image("../../imgs/tufted-duck-female-with-duckling.webp", width: 250pt)
]

#image("../../imgs/gorilla.webp", height: 250pt)
```


== 7. Tables <tbl1>

You can use `table()` to create a simple table:

#figure(caption: [A table created with the `table()` function])[
  #table(
    columns: (1fr, 2fr, auto),
    [*Name*], [*Bio*], [*Status*],
    [Alice], [Frontend developer, likes Rust], [Online],
    [Bob], [Backend engineer, likes Python], [Offline],
  )
]

```typ
#figure(caption: [A table created with the `table()` function])[
  #table(
    columns: (1fr, 2fr, auto),
    [*Name*], [*Bio*], [*Status*],
    [Alice], [Frontend developer, likes Rust], [Online],
    [Bob], [Backend engineer, likes Python], [Offline],
  )
]
```

A nicer option is the #link("https://typst.app/universe/package/tablem")[`tablem`] package by #link("https://blog.orangex4.workers.dev/")[\@OrangeX4], which builds tables from a Markdown-like table syntax:

#tablem[
  | *Name* | *Location* | *Height* | *Score* |
  | :----: | :--------: | :------: | :-----: |
  | John   | Second St. | 180 cm   | 5       |
  | Wally  | Third Av.  | 160 cm   | 10      |
]

```typ
#import "@preview/tablem:0.3.0": *

#tablem[
  | *Name* | *Location* | *Height* | *Score* |
  | :----: | :--------: | :------: | :-----: |
  | John   | Second St. | 180 cm   | 5       |
  | Wally  | Third Av.  | 160 cm   | 10      |
]
```

Complex custom table designs are not supported yet. Of course, you can also #link("../typst-example/sample-PDF.pdf")[link a PDF] or use table images.

== 8. Code Blocks

Wrap code with ```` ``` ```` to insert a code block (with syntax highlighting). Like images and tables, you can also use `figure()` to add a caption. I customized the code block style and added line numbers and a copy button.

#figure(caption: "I can write Python.")[
  ```python
  # Fibonacci function in Python
  def fib(n):
      if n <= 1: return n
      return fib(n-1) + fib(n-2)
  ```
]<code1>

#figure(caption: "I have been learning Rust recently.")[
  ```rs
  fn main() {
      println!("Typst is written in Rust.");
  }
  ```
]

The Rust code block above corresponds to the following Typst source:

````typ
#figure(caption: "I have been learning Rust recently.")[
  ```rs
  fn main() {
      println!("Typst is written in Rust.");
  }
  ```
]
````


== 9. Alignment, Columns, and Blocks

Currently, Typst's HTML export does not support paragraph alignment or multi-column layouts, but you can #link("../typst-example/sample-PDF.pdf")[do it in PDFs]. This is very useful for resumes, multi-column papers, and slide decks.

You can use the theorem package #link("https://typst.app/universe/package/theorion")[`theorion`] by #link("https://blog.orangex4.workers.dev/")[\@OrangeX4] to create special block styles, for example:

#quote-block[
  This is a quote block. You can place fairly long content here. You can place fairly long content here. You can place fairly long content here. You can place fairly long content here.
  It supports line breaks and paragraphs, and you can even nest another quote block inside.
  #quote-block[This is a nested quote block.]
  - A list
  `This is a code block.`
]
#tip-block[This is a tip box.]
#note-block[This is a note box.]
#important-block[This is an important box.]
#warning-block[This is a warning box.]
#caution-block[This is also a warning box.]

```typ
#import "@preview/theorion:0.6.0": *

#quote-block[
  This is a quote block. You can place fairly long content here. You can place fairly long content here. You can place fairly long content here. You can place fairly long content here.
  It supports line breaks and paragraphs, and you can even nest another quote block inside.
  #quote-block[This is a nested quote block.]
  - A list
  `This is a code block.`
]
#tip-block[This is a tip box.]
#note-block[This is a note box.]
#important-block[This is an important box.]
#warning-block[This is a warning box.]
#caution-block[This is also a warning box.]
```

== 10. Math

Typst uses `$ $` to typeset math. Inline math is embedded in text, written with `$` immediately followed by the formula, e.g. $f(x) = x^2$.

```typ
For example, $f(x) = x^2$.
```

Block math occupies its own line. In this case there is a space between `$` and the formula, e.g. $ A = pi r^2 $

```typ
$ A = pi r^2 $
```

Fractions, roots, sums, and integrals:
$ integral_0^infinity e^(-x^2) d x = sqrt(pi) / 2 $
$ sum_(k=0)^n k = 1 + ... + n = (n(n+1)) / 2 $
$
  P(A | B) = (P(B | A) P(A)) / P(B) = (P(B | A) P(A)) / (sum_(i=1)^n P(B | A_i) P(A_i))
$

```typ
$ integral_0^infinity e^(-x^2) d x = sqrt(pi) / 2 $
$ sum_(k=0)^n k = 1 + ... + n = (n(n+1)) / 2 $
```

Matrices and determinants:
$
  mat(
    1, 2;
    3, 4
  ) dot vec(x, y) = vec(5, 6)
$

```typ
$
  mat(
    1, 2;
    3, 4
  ) dot vec(x, y) = vec(5, 6)
$
```

Multi-line aligned equations:

#figure(caption: "Multi-line aligned equations")[
  $
    f(x) & = (x + 1)^2 \\ & = x^2 + 2x + 1
  $
]

```typ
#figure(caption: "Multi-line aligned equations")[
  $
    f(x) & = (x + 1)^2 \\
         & = x^2 + 2x + 1
  $
]
```

Very long block equations (overflowing the screen width):

$
  Psi(x, t) = sum_(n=1)^infinity c_n phi_n(x) e^(-i E_n t / planck) = integral_(-infinity)^(+infinity) tilde(Psi)(k) e^(i k x - i omega(k) t) d k = e^(i (k x - omega t)) + sum_(l=1)^infinity a_l e^(i (k_l x + phi_l - omega_l t))
$

$
  cal(L)_(S M) = underbrace(- 1/4 B_(mu nu) B^(mu nu) - 1/8 tr(bold(W)_(mu nu) bold(W)^(mu nu)) - 1/2 tr(bold(G)_(mu nu) bold(G)^(mu nu)), "Gauge Bosons")
  + underbrace(sum_(j=1)^3 (bar(Q)_(L j) i D slash Q_(L j) + bar(u)_(R j) i D slash u_(R j) + bar(d)_(R j) i D slash d_(R j) + bar(L)_(L j) i D slash L_(L j) + bar(e)_(R j) i D slash e_(R j)), "Fermions Kinetic Terms")
  + underbrace((D_mu phi)^dagger (D^mu phi) - mu^2 phi^dagger phi - lambda (phi^dagger phi)^2, "Higgs Sector")
  - underbrace(sum_(i, j=1)^3 (y_(i j)^u bar(Q)_(L i) tilde(phi) u_(R j) + y_(i j)^d bar(Q)_(L i) phi d_(R j) + y_(i j)^e bar(L)_(L i) phi e_(R j) + h.c.), "Yukawa Couplings")
$

For more complex formulas and symbols, see the #link("https://typst-doc-cn.github.io/docs/reference/math/")[documentation].


== 11. Cross References

Typst supports cross references. You can label headings, figures, code blocks, etc., and reference them elsewhere.

Link to the @ch1 section.\
Link to the @code1 block.\
Link to the @duck figure.\
Link to the @tbl1 table.

```typ
Link to the @ch1 section.\\
Link to the @code1 block.\\
Link to the @duck figure.\\
Link to the @tbl1 table.
```

The corresponding label syntax looks like:

```typ
== 1. Fonts and Text Styling <ch1>

#figure(caption: "I can write Python.")[
  ... code block ...
]<code1>

#figure(caption: "Another duck.")[
  ... image ...
]<duck>

#figure(caption: [A table created with the `table()` function])[
  ... table ...
]<tbl1>
```

== 12. Programming Features

Typst is not only a markup typesetting language, but also a programmable typesetting language:

```typ
#let name = "Typst"
#if name == "Typst" [
  #for i in range(3) [
    This is Typst #i!
  ]
] else [
  This is not Typst.
]
```

#let name = "Typst"
#if name == "Typst" [
  #for i in range(3) [
    This is Typst #i!
  ]
] else [
  This is not Typst.
]

```typ
#show "Latex": "Typst"
I love Latex!
```

#show "Latex": "Typst"
I love Latex!

```typ
// Custom functions are supported
#let greet(name) = [Hello, #name!]
#greet("World")\\
#greet("Yousa Mirage")
```

#let greet(name) = [Hello, #name!]
#greet("World")\
#greet("Yousa Mirage")


== 13. Embedding Markdown

You can use `cmarker` to embed Markdown content in Typst documents. This is especially useful when integrating existing Markdown files into a Typst-based website. To render math expressions, use `mitex`. For example, the following code:

```
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.7": *

// This scope is required
// See https://typst.app/universe/package/cmarker#resolving-paths-correctly
#let scope = (image: (source, alt: none, format: auto) => figure(image(source, alt: alt, format: format)))
#let md-content = read("tufted-titmouse-en.md")
#cmarker.render(md-content, math: mitex, scope: scope)
```

will render `tufted-titmouse-en.md` as the following content:

#html.hr()

#let scope = (
  image: (source, alt: none, format: auto) => figure(image(source, alt: alt, format: format)),
)
#let md-content = read("tufted-titmouse-en.md")
#cmarker.render(md-content, math: mitex, scope: scope)

#html.hr()

`tufted-titmouse-en.md` rendered.
