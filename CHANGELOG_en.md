# Changelog

## Develop

Development updates will be recorded here.

- feat: open external links and PDF links in new tabs ([#15](https://github.com/Yousa-Mirage/Tufted-Blog-Template/pull/15), [@yanwenwang24](https://github.com/yanwenwang24))
- feat: add rich SEO metadata support ([#16](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues/16), [#17](https://github.com/Yousa-Mirage/Tufted-Blog-Template/pull/17), [@yanwenwang24](https://github.com/yanwenwang24))

## v0.5.0

- feat: optimize sidebar display on mobile ([#14](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues/14)), adding a gray background to sidebar content, and:
  - `footnote` is collapsed by default on mobile and can be expanded by clicking the number
  - `marginnote`, `figure-caption` are expanded by default on mobile
- style: slightly reduce the top and bottom margins of the `article` element
- fix: resolve issue where inline math was affected by `p { text-indent: 2em; }` ([#12](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues/12))
- fix: fix unnecessary scrollbar when content height is insufficient ([#13](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues/13))
- fix: correct display position of math on mobile
- fix: prevent images from being stretched and not centered on mobile

## v0.4.0

- feat: fine-tune the position of toggle buttons, increasing the distance from the right edge
- style: center images and tables in the main column by default
- fix: solve inconsistent thickness of link underlines
- fix: fix `#quote-box()` exceeding the main column width
- chore: migrate GitHub Actions workflow from Makefile to uv

## v0.3.0

- feat: upgrade dark mode with a new toggle button and comprehensive visual optimizations
- feat: add horizontal scrollbar for long math blocks
- feat: improve horizontal scrolling experience for code blocks
- refactor: merge `assets/copy-code.js` and `assets/line-numbers.js` into `assets/code-blocks.js`
- refactor: integrate custom styles from `assets/custom.css` into `assets/tufted.css` and clear `assets/custom.css`

## v0.2.0

- feat: support custom website header and footer elements; see [demo site](https://tufted-blog.pages.dev/) for examples ([@batkiz](https://github.com/batkiz))
- feat: add cross-reference navigation
- style: optimize table border styles to generate elegant HTML tables; see [demo site](https://tufted-blog.pages.dev/Docs/typst-example/#tbl1) for examples
- style: improve display of block-level math
- fix: fix math display issues in Firefox
- fix: ensure footer always stays at the bottom of the page
- refactor: integrate `tufted` source code directly into the project
- refactor: use `#html.script()` to embed JS scripts for easy extension ([@batkiz](https://github.com/batkiz))

## v0.1.1

- feat: optimize dark mode appearance

## v0.1.0

- feat: initial release
