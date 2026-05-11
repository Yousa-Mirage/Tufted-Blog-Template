import tempfile
import unittest
from datetime import datetime
from pathlib import Path

import build


class BuildMetadataTests(unittest.TestCase):
    def test_extract_post_metadata_preserves_iso_timezone(self):
        with tempfile.TemporaryDirectory() as tmp:
            post_dir = Path(tmp) / "2026-05-06-example"
            post_dir.mkdir()
            html_path = post_dir / "index.html"
            html_path.write_text(
                """
                <!doctype html>
                <html lang="zh">
                  <head>
                    <title>Example</title>
                    <meta name="description" content="Demo">
                    <meta name="date" content="2026-05-06T21:00:00+08:00">
                    <link rel="canonical" href="https://example.com/Blog/example/">
                  </head>
                </html>
                """,
                encoding="utf-8",
            )

            title, description, link, date_obj = build.extract_post_metadata(html_path)

            self.assertEqual(title, "Example")
            self.assertEqual(description, "Demo")
            self.assertEqual(link, "https://example.com/Blog/example/")
            self.assertEqual(date_obj, datetime.fromisoformat("2026-05-06T21:00:00+08:00"))

    def test_build_html_args_include_updated_input(self):
        typ_file = Path("content/Blog/2026-05-06-example/index.typ")
        output_path = Path("_site/Blog/2026-05-06-example/index.html")

        args = build.build_html_args(typ_file, output_path, updated="2026-05-06T13:00:00+00:00")

        self.assertIn("--input", args)
        self.assertIn("page-path=Blog/2026-05-06-example", args)
        self.assertIn("updated=2026-05-06T13:00:00+00:00", args)
        self.assertEqual(args[-2:], [str(typ_file), str(output_path)])


if __name__ == "__main__":
    unittest.main()
