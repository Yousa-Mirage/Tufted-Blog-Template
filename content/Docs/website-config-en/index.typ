#import "../index.typ": template, tufted
#show: template.with(
  title: "Website Configuration",
  description: "Website configuration documentation",
  lang: "en",
)

= Website Configuration

== Template Structure

The template consists of 5 main parts:

- `config.typ` - core layout configuration
- `content/` - stores all site content
- `assets/` - shared resources, e.g. global CSS/JS scripts, icons, etc.
- `tufted-lib/` - Typst style library and functional modules
- `build.py` - the Python script that builds the website

== Available Functions

The `tufted` package currently provides these three functions:

- `tufted-web` - main template used to create pages
- `margin-note` - place content in the margin
- `full-width` - place content in a full-width container

See #link("../typst-example-en/")[Typst Example] for usage.

== Main Configuration

In `config.typ`, you can define your own template by changing the parameters of the imported `tufted-web` template. This template will be inherited by all subsequent pages (i.e. the global default configuration).

=== Basic Parameters

The `tufted-web()` function contains metadata parameters such as `title`, `description`, and `author`. These parameters are used to generate the page metadata.

The `header-links` parameter defines the links and labels in the top navigation bar. It is a dictionary: keys are paths, and values are labels.

The `lang` parameter defines the site language. It will be used to set the HTML `lang` attribute. The default is `zh` (Chinese). Different language settings may result in different fonts.

```typst
#import "tufted-lib/tufted.typ"

#let template = tufted.tufted-web.with(
  // Links and labels in the top navigation bar
  header-links: (
    "/": "Home",
    "/Blog/": "Blog",
    "/CV/": "CV",
    "/Docs/": "Docs",
  ),
  title: "My Personal Website",
  description: "My personal website description",
  author: "My Name",
  lang: "en",
)
```

=== SEO Parameters

SEO (Search Engine Optimization) parameters help improve your site's visibility in search engines. The template provides the following optional parameters:

- `website-url` - the root URL of the site, used to generate absolute links
- `image-path` - the default site image path, used to generate Open Graph images

Once `website-url` is set, the build script will automatically generate accurate absolute links for each page, ensuring SEO friendliness.

```typst
#let template = tufted.tufted-web.with(
  // Links and labels in the top navigation bar
  ...,
  website-url: "https://example.com",
  image-path: "/assets/image.png",
  ...,
)
```

The default `sitemap.xml` file will be generated in the root directory of the website, and you can access the file through `https://example.com/sitemap.xml`.

=== RSS Feed Parameters

You can enable the RSS feed by setting the `feed-dir` parameter (the `website-url` parameter must also be provided). This parameter accepts an array of strings, where each string represents a directory path (relative to the `content/` directory) that should be included in the RSS feed.

Additionally, you can use the `website-title` parameter to set the title of the RSS feed. If not set, it will default to the `title` parameter.

```typst
#let template = tufted.tufted-web.with(
  ...,
  // Enable RSS feed and include posts from the Blog directory
  feed-dir: ("Blog",),

  // RSS feed title
  website-title: "My Blog Feed",
  ...,
)
```

If the RSS subscription function is enabled for articles in the `Blog/` directory, then all article pages under this path must fill in metadata such as `title`, `description`, and `date`.

Once everything is configured correctly, the build script will automatically generate the RSS feed file `feed.xml`, which you can access through `https://example.com/feed.xml`.

=== Custom Styles and Scripts

See #link("../custom-styling-en/")[Custom Styling & Scripts].

=== Custom Header and Footer

You can customize the elements at the top and bottom of each page via the `header-elements` and `footer-elements` parameters. Both parameters accept an array of contents, separated by line breaks:

```typst
#let template = tufted.tufted-web.with(
  header-links: (
    "/": "Home",
    "/Blog/": "Blog",
  ),
  title: "My Website",

  // Custom header elements (shown above the navigation bar)
  header-elements: (
    [Hello Ciallo～(∠・ω< )⌒☆],
    [Welcome to my blog],
  ),

  // Custom footer elements (shown at the bottom of the page)
  footer-elements: (
    [© 2026 My Name. ],
    [#link("mailto:example@example.com")[Contact]],
  ),
)
```

== Hierarchy and Inheritance

The template configuration adopts a hierarchical structure, implemented through Typst's import/re-export mechanism.

First, we define a `template` function in `config.typ` at the project root. This function contains the global defaults, including the site title and navigation links.

All site content (including the home page, section pages, and individual posts) is located under `content/`. `content/index.typ` is the site home page. At the top of the file, it imports the `template` function defined in `config.typ`:

```typ
#import "../config.typ": template, tufted
#show: template
```

This inherits all default configuration.

All `**/index.typ` files under `content/` become accessible pages. The URL path corresponds to the folder path (e.g. `content/Blog/index.typ` → `example.github.io/Blog`). Each subpage imports `template` and `tufted` from its parent directory's `../index.typ`, enabling inheritance layer by layer without redefining the template.

You can modify the template at any level using `.with()`, and subpages will inherit the changes. For example, to change the current page title, description, and add a publication date:

```typst
#import "../index.typ": template, tufted
#show: template.with(
  title: "New Title",
  description: "New Description",
  date: datetime(year: 2026, month: 1, day: 29),
)
```

== Custom Site Icon

Simply name your icon file `favicon.ico` and put it in `assets/`. It will be loaded automatically during the build.
