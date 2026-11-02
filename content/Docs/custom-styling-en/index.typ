#import "../index.typ": template, tufted
#show: template.with(
  title: "Custom Styling",
  description: "Documentation on customizing the look and feel of the website.",
  lang: "en",
)

= Custom Styling / Scripts

The website's visual appearance is controlled by CSS, which means many styles cannot be directly modified in Typst, such as font size and text color.

To change styles, you need to edit the CSS files directly.

== Default Stylesheets

`tufted` loads three stylesheets by default:

- `assets/tufte.min.css`: the original Tufte stylesheet
- `assets/tufted.css`: the heavily customized template stylesheet
- `assets/theme.css`: the stylesheet that controls dark/light mode

They correspond to the original Tufte stylesheet, the template-adaptation stylesheet, and the theme stylesheet.

== Custom CSS

The `tufted` template accepts a `css` array parameter to specify custom stylesheet paths. The default is `assets/custom.css`. Custom stylesheets are loaded after the default ones, so they override rules from the defaults. For example:

```typst
#let template = tufted.tufted-web.with(
  // ...
  css: ("/assets/custom.css"),
  // ...
)
```

To customize the website style, just edit `assets/custom.css`. For example, to change link color:

```css
a {
  color: #ff0000;
}
```

== Custom JS Scripts

By default, the project loads the following JavaScript files on every page. They are located in `assets/scripts/`:

- `code-blocks.js` - adds line numbers and a copy button to code blocks
- `format-headings.js` - improves heading formatting
- `theme-toggle.js` - toggles dark/light mode
- `marginnote-toggle.js` - toggles margin notes (improves mobile experience)
- `math-copy.js` - copies formula MathML source on click

These bundled scripts are automatically loaded by `tufted-lib/tufted.typ`.

If you want to add your own JavaScript file, you can use the `js-scripts` parameter of `tufted-web`. It accepts an array of script paths. For example:

```typst
// config.typ
#let template = tufted.tufted-web.with(
  // ...
  js-scripts: ("/assets/custom.js"),
  // ...
)
```

If you need to add a JavaScript file only for a specific page, you can set `js-scripts` in that page's metadata:

```typst
#import "../index.typ": template, tufted
#show: template.with(
  title: "Custom Styling",
  description: "Custom styling documentation",
  js-scripts: ("/assets/page-specific.js"),
)
```
