#!/usr/bin/env python3

"""Manage encrypted post routes for the blog build."""

import argparse
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
CONTENT_DIR = PROJECT_ROOT / "content"
PRIVATE_POSTS_CONFIG_FILE = PROJECT_ROOT / "private-posts.txt"


def normalize_route(raw: str, default_section: str = "Blog") -> str:
    """
    Normalize user input into a site route like ``Blog/6-1``.
    """
    text = raw.strip().replace("\\", "/")
    if not text:
        raise ValueError("路径不能为空。")

    text = text.removeprefix("./").strip("/")

    if text.startswith("content/"):
        text = text.removeprefix("content/")
        if text.endswith("/index.typ"):
            text = text.removesuffix("/index.typ")
        elif text.endswith(".typ"):
            text = text.removesuffix(".typ")
        return text.strip("/")

    if text.endswith("/index.typ"):
        text = text.removesuffix("/index.typ")
    elif text.endswith(".typ"):
        text = text.removesuffix(".typ")

    text = text.strip("/")
    if "/" not in text:
        return f"{default_section.strip('/')}/{text}"

    return text


def get_source_path(route: str) -> Path:
    """
    Resolve the source article path for a route.
    """
    return CONTENT_DIR / route / "index.typ"


def load_routes(config_path: Path) -> list[str]:
    """
    Load the configured private routes.
    """
    if not config_path.exists():
        return []

    routes: list[str] = []
    seen: set[str] = set()

    for raw_line in config_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.split("#", 1)[0].strip()
        if not line:
            continue

        route = line.strip("/")
        if route not in seen:
            seen.add(route)
            routes.append(route)

    return routes


def save_routes(config_path: Path, routes: list[str]) -> None:
    """
    Save routes in stable sorted order.
    """
    config_path.write_text(
        "\n".join(sorted(routes)) + ("\n" if routes else ""),
        encoding="utf-8",
    )


def cmd_list(config_path: Path) -> int:
    routes = load_routes(config_path)
    if not routes:
        print("当前没有私密文章。")
        return 0

    for route in routes:
        print(route)
    return 0


def cmd_add(route_input: str, config_path: Path, default_section: str, force: bool) -> int:
    route = normalize_route(route_input, default_section=default_section)
    source_path = get_source_path(route)

    if not force and not source_path.exists():
        print(f"❌ 文章不存在: {source_path}")
        print("   如果你已经确认路径没问题，可加上 --force 跳过检查。")
        return 1

    routes = load_routes(config_path)
    if route in routes:
        print(f"已存在: {route}")
        return 0

    routes.append(route)
    save_routes(config_path, routes)
    print(f"已加入私密列表: {route}")
    print("下一步运行: uv run build.py build")
    return 0


def cmd_remove(route_input: str, config_path: Path, default_section: str) -> int:
    route = normalize_route(route_input, default_section=default_section)
    routes = load_routes(config_path)

    if route not in routes:
        print(f"不在私密列表中: {route}")
        return 0

    routes = [item for item in routes if item != route]
    save_routes(config_path, routes)
    print(f"已移出私密列表: {route}")
    print("下一步运行: uv run build.py build")
    return 0


def create_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="管理 staticrypt 私密文章列表",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=PRIVATE_POSTS_CONFIG_FILE,
        help=f"私密文章配置文件路径（默认: {PRIVATE_POSTS_CONFIG_FILE.name}）",
    )
    parser.add_argument(
        "--section",
        default="Blog",
        help="当只传文章 slug 时，默认补到哪个栏目下（默认: Blog）",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("list", help="列出当前私密文章")

    add_parser = subparsers.add_parser("add", help="加入一篇私密文章")
    add_parser.add_argument("route", help="文章路径，如 6-10、Blog/6-10 或 content/Blog/6-10/index.typ")
    add_parser.add_argument(
        "--force",
        action="store_true",
        help="即使文章源文件尚不存在，也强制加入列表",
    )

    remove_parser = subparsers.add_parser("remove", help="移出一篇私密文章")
    remove_parser.add_argument("route", help="文章路径，如 6-10 或 Blog/6-10")

    return parser


def main() -> int:
    parser = create_parser()
    args = parser.parse_args()

    config_path = args.config.resolve() if not args.config.is_absolute() else args.config

    match args.command:
        case "list":
            return cmd_list(config_path)
        case "add":
            return cmd_add(args.route, config_path, args.section, args.force)
        case "remove":
            return cmd_remove(args.route, config_path, args.section)
        case _:
            parser.print_help()
            return 1


if __name__ == "__main__":
    sys.exit(main())
