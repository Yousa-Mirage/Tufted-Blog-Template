// 你可以在文件名包含 "PDF" 的文件中编写正常的 PDF 文档
// 这些文件会被自动编译为 PDF 文件，然后你就可以通过链接在访问
// 注意：目标是 PDF 的 Typst 文件中不能使用 `#show: template` 和来自 `tufted` 的命令
// 同时网页样式与 PDF 样式无关，你应该在 PDF 文件中自行控制 PDF 的样式效果

#import "@preview/citegeist:0.2.0": load-bibliography
#set page(height: auto)
#show link: it => underline(it)

= Edward R. Tufte: #text(weight: "regular", size: 0.9em)[Statistician, Artist, and Professor Emeritus]

Website: #link("https://www.edwardtufte.com")[edwardtufte.com]
#h(3em)
Email: #link("mailto:noreply@edwardtufte.com", "noreply@edwardtufte.com")

Research in statistical evidence and analytical design for information visualization, integrating principles from statistics, graphic design, and cognitive science for the effective presentation of quantitative data.

== Experience

- *1983--Present*: Founder & Publisher, Graphics Press. Independent publishing house specializing in information design and data visualization.
- *1977--1999*: Professor Emeritus, Yale University. Departments of Political Science, Statistics, and Computer Science.
- *1967--1977*: Instructor, Princeton University. Woodrow Wilson School of Public and International Affairs.

== Artworks

#figure(
  caption: [A homage to Edward R. Tufte's large stainless steel sculpture titled _Escaping Flatland_],
  numbering: none,
)[
  #image("escaping-flatland.webp", height: 150pt)
]

Founder of Hogpen Hill Farms, a 234-acre sculpture park in Woodbury, Connecticut. Creator of large-scale works including _Larkin’s Twig_ and the _Escaping Flatland_ series, exhibited at the Aldrich Contemporary Art Museum.

== Research Contributions

Development of sparklines, a method for embedding high-resolution data graphics within text, and formulation of the data-ink ratio as a quantitative measure of graphical efficiency.

== Books

#{
  let bib = load-bibliography(read("books.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #strong(data.year): #emph(data.title)
  ]
}

== Papers

#{
  let bib = load-bibliography(read("papers.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #data.author, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]
  ]
}

== Education

- PhD in Political Science: Yale University (1968).
- MS in Statistics: Stanford University.
- BS in Statistics: Stanford University.
