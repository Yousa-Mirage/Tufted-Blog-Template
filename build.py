#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.10"
# ///

"""
Tufted Blog Template 构建脚本

这是一个跨平台的构建脚本，用于将 Typst (.typ) 文件编译为 HTML 和 PDF，
并复制静态资源到输出目录。

支持增量编译：只重新编译修改后的文件，加快构建速度。

用法:
    uv run build.py build       # 完整构建 (HTML + PDF + 资源)
    uv run build.py html        # 仅构建 HTML 文件
    uv run build.py pdf         # 仅构建 PDF 文件
    uv run build.py assets      # 仅复制静态资源
    uv run build.py clean       # 清理生成的文件
    uv run build.py preview     # 启动本地预览服务器（默认端口 8000）
    uv run build.py preview -p 3000  # 使用自定义端口
    uv run build.py watch       # 启动预览，并在文件变化时自动构建
    uv run build.py --help      # 显示帮助信息

增量编译选项:
    --force, -f                 # 强制完整重建，忽略增量检查

预览服务器选项:
    --port, -p PORT             # 指定服务器端口号（默认: 8000）

也可以直接使用 Python 运行:
    python build.py build
    python build.py build --force
    python build.py preview -p 3000
"""

import argparse
import json
import logging
import os
import re
import shutil
import signal
import subprocess
import sys
import threading
import time
from collections.abc import Callable
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass, field
from datetime import datetime, timezone
from hashlib import sha256
from html import escape
from html.parser import HTMLParser
from pathlib import Path, PureWindowsPath
from stat import S_ISREG
from typing import Literal, TypedDict
from urllib.parse import quote, urljoin, urlsplit

# ============================================================================
# 配置
# ============================================================================

CONTENT_DIR = Path("content")  # 源文件目录
SITE_DIR = Path("_site")  # 输出目录
ASSETS_DIR = Path("assets")  # 静态资源目录
CONFIG_FILE = Path("config.typ")  # 全局配置文件
TAG_CACHE_DIR = Path("target/tufted-tags")
MATHML_MIN_TYPST_VERSION = (0, 15, 0)


@dataclass
class BuildStats:
    """构建统计信息"""

    success: int = 0
    skipped: int = 0
    failed: int = 0

    def format_summary(self) -> str:
        """格式化统计摘要"""
        parts = []
        if self.success > 0:
            parts.append(f"编译: {self.success}")
        if self.skipped > 0:
            parts.append(f"跳过: {self.skipped}")
        if self.failed > 0:
            parts.append(f"失败: {self.failed}")
        return ", ".join(parts) if parts else "无文件需要处理"

    @property
    def has_failures(self) -> bool:
        """是否存在失败"""
        return self.failed > 0


class HTMLMetadataParser(HTMLParser):
    """
    从 HTML 文件中提取元数据的解析器。

    解析以下元数据：
    - lang: 从 <html lang="..."> 属性获取
    - title: 从 <title> 标签获取
    - description: 从 <meta name="description" content="..."> 获取
    - link: 从 <link rel="canonical" href="..."> 获取
    - date: 从 <meta name="date" content="..."> 获取
    """

    def __init__(self):
        super().__init__()
        self.metadata = {"title": ""}
        self._in_title = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]):
        attrs_dict = {k: v for k, v in attrs if v}

        match tag:
            case "html":
                self.metadata["lang"] = attrs_dict.get("lang", "")
            case "title":
                self._in_title = True
            case "meta":
                name = attrs_dict.get("name", "")
                if name in {"description", "date", "article-tags", "tag-index"}:
                    self.metadata[name] = attrs_dict.get("content", "")
            case "link":
                if attrs_dict.get("rel") == "canonical":
                    self.metadata["link"] = attrs_dict.get("href", "")

    def handle_endtag(self, tag: str):
        if tag == "title":
            self._in_title = False

    def handle_data(self, data: str):
        if self._in_title:
            self.metadata["title"] += data


def get_typst_version() -> tuple[int, ...] | None:
    """
    获取当前 Typst CLI 的语义化版本号。

    返回:
        tuple[int, int, int] | None: 版本号，获取失败时返回 None
    """
    try:
        result = subprocess.run(
            ["typst", "--version"],
            capture_output=True,
            text=True,
            encoding="utf-8",
            check=False,
        )
    except (FileNotFoundError, OSError):
        return None

    if result.returncode != 0:
        return None

    match = re.search(r"typst (\d+)\.(\d+)\.(\d+)", result.stdout)
    if match is None:
        return None

    return tuple(int(component) for component in match.groups())


def warn_if_typst_version_is_outdated() -> None:
    """
    对低于 MathML 支持基线的 Typst 版本输出提示。
    """
    version = get_typst_version()
    if version is None or version >= MATHML_MIN_TYPST_VERSION:
        return

    current = ".".join(str(component) for component in version)
    required = ".".join(str(component) for component in MATHML_MIN_TYPST_VERSION)
    print(
        f"  ⚠️ 检测到 Typst {current}。HTML 导出的原生 MathML 公式支持需要 Typst {required}+，建议升级 Typst 版本。"
    )


# ============================================================================
# 增量编译辅助函数
# ============================================================================


def get_file_mtime(path: Path) -> float:
    """
    获取文件的修改时间戳。

    参数:
        path: 文件路径

    返回:
        float: 修改时间戳，文件不存在返回 0
    """
    try:
        return path.stat().st_mtime
    except (OSError, FileNotFoundError):
        return 0.0


def is_dep_file(path: Path) -> bool:
    """
    判断一个文件是否被追踪为依赖）。

    content/ 下的普通页面文件不被视为模板文件，因为它们是独立的页面，
    不应该相互依赖。

    参数:
        path: 文件路径

    返回:
        bool: 是否是依赖文件
    """
    try:
        resolved_path = path.resolve()
        project_root = Path(__file__).parent.resolve()
        content_dir = (project_root / CONTENT_DIR).resolve()

        # config.typ 是依赖文件
        if resolved_path == (project_root / CONFIG_FILE).resolve():
            return True

        # 检查是否在 content/ 目录下
        try:
            relative_to_content = resolved_path.relative_to(content_dir)
            # content/_* 目录下的文件视为依赖文件
            parts = relative_to_content.parts
            return bool(parts and parts[0].startswith("_"))
        except ValueError:
            # 不在 content/ 目录下，视为依赖文件（如 config.typ）
            return True

    except (OSError, RuntimeError):
        return True


def find_typ_dependencies(typ_file: Path) -> set[Path]:
    """
    解析 .typ 文件中的依赖（通过 #import 和 #include 导入的文件）。

    只追踪 .typ 文件的依赖，忽略 content/ 下的普通页面文件。
    其他资源文件（如 .md, .bib, 图片等）通过 copy_content_assets 处理。

    参数:
        typ_file: .typ 文件路径

    返回:
        set[Path]: 依赖的 .typ 文件路径集合
    """
    dependencies: set[Path] = set()

    try:
        content = typ_file.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as e:
        print(f"⚠️ 无法读取依赖文件 {typ_file}: {e}")
        return dependencies

    # 获取文件所在目录，用于解析相对路径
    base_dir = typ_file.parent

    patterns = [
        r'#import\s+"([^"]+)"',
        r"#import\s+'([^']+)'",
        r'#include\s+"([^"]+)"',
        r"#include\s+'([^']+)'",
    ]

    for pattern in patterns:
        for match in re.finditer(pattern, content):
            dep_path_str = match.group(1)

            # 跳过包导入（如 @preview/xxx）
            if dep_path_str.startswith("@"):
                continue

            # 解析相对路径
            if dep_path_str.startswith("/"):
                # 相对于项目根目录的路径
                dep_path = Path(dep_path_str.lstrip("/"))
            else:
                # 相对于当前文件的路径
                dep_path = base_dir / dep_path_str

            # 规范化路径，只追踪 .typ 文件
            try:
                dep_path = dep_path.resolve()
                if (
                    dep_path.exists()
                    and dep_path.suffix == ".typ"
                    and is_dep_file(dep_path)
                ):
                    dependencies.add(dep_path)
            except (OSError, RuntimeError) as e:
                print(f"⚠️ 无法解析依赖路径 {dep_path}: {e}")

    return dependencies


def get_all_dependencies(typ_file: Path, visited: set[Path] | None = None) -> set[Path]:
    """
    递归获取 .typ 文件的所有依赖（包括传递依赖）。

    参数:
        typ_file: .typ 文件路径
        visited: 已访问的文件集合（用于避免循环依赖）

    返回:
        set[Path]: 所有依赖文件路径集合
    """
    if visited is None:
        visited = set()

    # 避免循环依赖
    abs_path = typ_file.resolve()
    if abs_path in visited:
        return set()
    visited.add(abs_path)

    all_deps: set[Path] = set()
    direct_deps = find_typ_dependencies(typ_file)

    for dep in direct_deps:
        all_deps.add(dep)
        # 只对 .typ 文件递归查找依赖
        if dep.suffix == ".typ":
            all_deps.update(get_all_dependencies(dep, visited))

    return all_deps


def needs_rebuild(
    source: Path, target: Path, extra_deps: list[Path] | None = None
) -> bool:
    """
    判断是否需要重新构建。

    当以下任一条件满足时需要重建：
    1. 目标文件不存在
    2. 源文件比目标文件新
    3. 任何额外依赖文件比目标文件新
    4. 源文件的任何导入依赖比目标文件新
    5. 源文件同目录下的任何非 .typ 文件比目标文件新（如 .md, .bib, 图片等）

    参数:
        source: 源文件路径
        target: 目标文件路径
        extra_deps: 额外的依赖文件列表（如 config.typ）

    返回:
        bool: 是否需要重新构建
    """
    # 目标不存在，需要构建
    if not target.exists():
        return True

    target_mtime = get_file_mtime(target)

    # 源文件更新了
    if get_file_mtime(source) > target_mtime:
        return True

    # 检查额外依赖
    if extra_deps:
        for dep in extra_deps:
            if dep.exists() and get_file_mtime(dep) > target_mtime:
                return True

    # 检查源文件的导入依赖
    for dep in get_all_dependencies(source):
        if get_file_mtime(dep) > target_mtime:
            return True

    # 检查源文件同目录下的非 .typ 资源文件（如 .md, .bib, 图片等）
    # 只检查同一目录，不递归子目录，避免过度重编译
    source_dir = source.parent
    for item in source_dir.iterdir():
        if (
            item.is_file()
            and item.suffix != ".typ"
            and get_file_mtime(item) > target_mtime
        ):
            return True

    return False


def find_common_dependencies() -> list[Path]:
    """
    查找所有文件的公共依赖（如 config.typ）。

    返回:
        list[Path]: 公共依赖文件路径列表
    """
    common_deps = []

    # config.typ 是全局配置，修改后所有页面都需要重建
    if CONFIG_FILE.exists():
        common_deps.append(CONFIG_FILE)

    # 可以在这里添加其他公共依赖
    # 例如：查找 content/_* 目录下的模板文件
    if CONTENT_DIR.exists():
        for item in CONTENT_DIR.iterdir():
            if item.is_dir() and item.name.startswith("_"):
                for typ_file in item.rglob("*.typ"):
                    common_deps.append(typ_file)

    return common_deps


# ============================================================================
# 辅助函数
# ============================================================================


def find_typ_files() -> list[Path]:
    """
    查找 content/ 目录下所有 .typ 文件，排除路径中包含以下划线开头的目录的文件。

    返回:
        list[Path]: .typ 文件路径列表
    """
    typ_files = []
    for typ_file in CONTENT_DIR.rglob("*.typ"):
        # 检查路径中是否有以下划线开头的目录
        parts = typ_file.relative_to(CONTENT_DIR).parts
        if not any(part.startswith("_") for part in parts):
            typ_files.append(typ_file)
    return typ_files


def get_file_output_path(typ_file: Path, type: Literal["pdf", "html"]) -> Path:
    """
    获取 .typ 文件的输出路径。

    参数:
        typ_file: .typ 文件路径 (相对于 content/)

    返回:
        Path: 文件输出路径 (在 _site/ 目录下)
    """
    relative_path = typ_file.relative_to(CONTENT_DIR)
    return SITE_DIR / relative_path.with_suffix(f".{type}")


def get_html_route(output: Path) -> str:
    """Return the unescaped site path, keeping .html on standalone pages."""
    relative = output.relative_to(SITE_DIR).as_posix()
    return "/" + (
        relative.removesuffix("index.html") if output.name == "index.html" else relative
    )


def run_typst_command(args: list[str]) -> bool:
    """
    运行 typst 命令。

    参数:
        args: typst 命令参数列表

    返回:
        bool: 命令是否成功执行
    """
    try:
        result = subprocess.run(
            ["typst"] + args,
            capture_output=True,
            text=True,
            encoding="utf-8",
            check=False,
        )
        if result.returncode != 0:
            print(f"  ❌ Typst 错误: {result.stderr.strip()}")
            return False
        return True
    except FileNotFoundError:
        print(
            "  ❌ 错误: 未找到 typst 命令。请确保已安装 Typst 并添加到 PATH 环境变量中。"
        )
        print("  📝 安装说明: https://typst.app/open-source/#download")
        return False
    except (OSError, UnicodeError) as e:
        print(f"  ❌ 执行 typst 命令时出错: {e}")
        return False


# ============================================================================
# 构建命令
# ============================================================================


def _compile_files(
    files: list[Path],
    force: bool,
    common_deps: list[Path],
    get_output_path_func,
    build_args_func,
    *,
    output_needs_refresh: Callable[[Path], bool] | None = None,
) -> BuildStats:
    """
    通用文件编译函数，减少重复代码。

    参数:
        files: 要编译的文件列表
        force: 是否强制重建
        common_deps: 公共依赖列表
        get_output_path_func: 获取输出路径的函数
        build_args_func: 构建编译参数的函数
        output_needs_refresh: 可选的产物刷新条件，用于检查标签链接等构建数据

    返回:
        BuildStats: 构建统计信息
    """
    stats = BuildStats()

    for typ_file in files:
        output_path = get_output_path_func(typ_file)

        # 增量编译检查
        if (
            not force
            and not needs_rebuild(typ_file, output_path, common_deps)
            and not (output_needs_refresh and output_needs_refresh(output_path))
        ):
            stats.skipped += 1
            continue

        output_path.parent.mkdir(parents=True, exist_ok=True)

        # 构建编译参数
        args = build_args_func(typ_file, output_path)

        if run_typst_command(args):
            stats.success += 1
        else:
            print(f"  ❌ {typ_file} 编译失败")
            stats.failed += 1

    return stats


# Treat literal settings as hints. Skip comments, raw examples and string literals.
TAG_INDEX_HINT = re.compile(
    r"(?<!`)(?P<ticks>`+)(?!`)[\s\S]*?(?<!`)(?P=ticks)(?!`)"
    r"|/\*[\s\S]*?\*/|//[^\n]*"
    r'|(?<![\w-])tag-index\s*:\s*"(?P<scope>[^"\\]*)"(?=\s*[,\)])'
    r'|"(?:\\.|[^"\\])*"'
)
TAG_ID = re.compile(r"[\w-]+(?:/[\w-]+)*")


def valid_tag_scope(scope: str) -> bool:
    return (
        scope.startswith("/")
        and scope.endswith("/")
        and not any(part in {".", ".."} for part in scope.split("/"))
        and "\\" not in scope
        and "//" not in scope
        and not PureWindowsPath(scope.strip("/")).drive
    )


def save_tag_data(path: Path, data: object) -> Path:
    encoded = json.dumps(data, ensure_ascii=False, sort_keys=True).encode("utf-8")
    if not path.exists() or path.read_bytes() != encoded:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(encoded)
    return path


def tag_page_data(output: Path, data: object) -> Path:
    key = sha256(output.as_posix().encode("utf-8")).hexdigest()
    return save_tag_data(TAG_CACHE_DIR / "pages" / (key + ".json"), data)


@dataclass
class TaggedPost:
    path: str
    title: str
    date: str
    tags: list[dict[str, str]]

    @property
    def url(self) -> str:
        return quote(self.path, safe="/")


class TagGroup(TypedDict):
    id: str
    name: str
    url: str
    posts: list[dict[str, str]]


def group_tags(posts: list[TaggedPost], scope: str) -> list[TagGroup]:
    """Group each article once per label, reusing the date order for every archive."""
    groups: dict[str, TagGroup] = {}
    for post in posts:
        if not post.path.startswith(scope):
            continue
        entry = {"title": post.title, "date": post.date, "url": post.url}
        for tag in post.tags:
            key, name = tag["key"], tag["name"]
            if key not in groups:
                slug = tag["id"]
                if not TAG_ID.fullmatch(slug):
                    raise ValueError(f"Invalid tag archive ID: {slug}")
                groups[key] = {
                    "id": slug,
                    "name": name,
                    "url": quote(f"{scope}tags/{slug}/", safe="/"),
                    "posts": [],
                }
            group = groups[key]
            group["name"] = min(name, group["name"])
            group["posts"].append(entry)
    return [groups[key] for key in sorted(groups)]


def html_compile_args(
    source: Path, output: Path, scope_file: Path, *inputs: str
) -> list[str]:
    route = get_html_route(output)
    page_path = (
        route.strip("/")
        if output.name == "index.html"
        else route[1:].removesuffix(".html")
    )
    return [
        "compile",
        "--root",
        ".",
        "--font-path",
        str(ASSETS_DIR),
        "--features",
        "html",
        "--format",
        "html",
        "--input",
        f"page-path={page_path}",
        "--input",
        f"tag-page-path={route}",
        "--input",
        f"tag-scopes=/{scope_file.as_posix()}",
        *[arg for value in inputs for arg in ("--input", value)],
        str(source),
        str(output),
    ]


def build_html(force: bool = False) -> bool:
    """Compile articles first, then render indexes and archives from their metadata."""
    SITE_DIR.mkdir(parents=True, exist_ok=True)
    outputs = {
        source: get_file_output_path(source, "html")
        for source in find_typ_files()
        if "pdf" not in source.stem.lower()
    }
    try:
        known_path = TAG_CACHE_DIR / "indexes.json"
        have_known_indexes = known_path.exists()
        known = (
            json.loads(known_path.read_text(encoding="utf-8"))
            if have_known_indexes
            else {}
        )
        hints = {}
        for source, output in outputs.items():
            candidates = {
                match["scope"]
                for match in TAG_INDEX_HINT.finditer(source.read_text(encoding="utf-8"))
                if match["scope"] and valid_tag_scope(match["scope"])
            }
            hint = known.get(source.as_posix())
            if len(candidates) == 1 and (
                not have_known_indexes
                or get_file_mtime(source) > get_file_mtime(output)
            ):
                hint = candidates.pop()
            if hint and valid_tag_scope(hint):
                hints[source] = hint
        initial_scopes = sorted(set(hints.values()))
        scope_file = save_tag_data(TAG_CACHE_DIR / "scopes.json", initial_scopes)
        common_deps = [
            *find_common_dependencies(),
            *Path("tufted-lib").rglob("*.typ"),
            Path(__file__),
        ]
        compiled = set()

        def article_args(source: Path, output: Path) -> list[str]:
            compiled.add(source)
            return html_compile_args(source, output, scope_file)

        scope_mtime = get_file_mtime(scope_file)

        def refresh_article_links(output: Path) -> bool:
            return scope_mtime > get_file_mtime(output) and bool(
                parse_html_metadata(output).get("article-tags")
            )

        print("正在构建 HTML 文件...")
        stats = _compile_files(
            [source for source in outputs if source not in hints],
            force,
            common_deps,
            outputs.__getitem__,
            article_args,
            output_needs_refresh=refresh_article_links,
        )
        print(f"✅ HTML 构建完成。{stats.format_summary()}")
        if stats.has_failures:
            return False
        metadata = {
            source: parse_html_metadata(output)
            for source, output in outputs.items()
            if source not in hints
        }
        return build_tags(
            outputs,
            hints,
            metadata,
            compiled,
            initial_scopes,
            scope_file,
            common_deps,
            force,
        )
    except (OSError, ValueError) as error:
        print(f"❌ 标签构建失败: {error}")
        return False


def build_tags(
    outputs: dict[Path, Path],
    hints: dict[Path, str],
    metadata: dict[Path, dict[str, str]],
    compiled: set[Path],
    initial_scopes: list[str],
    scope_file: Path,
    common_deps: list[Path],
    force: bool,
) -> bool:
    manifest = TAG_CACHE_DIR / "pages.json"
    previous = (
        set(json.loads(manifest.read_text(encoding="utf-8")))
        if manifest.exists()
        else set()
    )
    jobs = []

    def schedule(
        source: Path,
        output: Path,
        deps: list[Path],
        *inputs: str,
        force_page: bool = False,
    ) -> bool:
        if not force_page and not needs_rebuild(source, output, common_deps + deps):
            return False
        output.parent.mkdir(parents=True, exist_ok=True)
        jobs.append(html_compile_args(source, output, scope_file, *inputs))
        return True

    def run_jobs() -> bool:
        if not jobs:
            return True
        with ThreadPoolExecutor(max_workers=min(8, os.cpu_count() or 1)) as executor:
            results = list(executor.map(run_typst_command, jobs))
        jobs.clear()
        return all(results)

    def verified_indexes() -> dict[Path, str]:
        indexes = {
            source: scope
            for source, meta in metadata.items()
            if (scope := meta.get("tag-index"))
        }
        if any(not valid_tag_scope(scope) for scope in indexes.values()):
            raise ValueError("tag-index must be a site-root directory, e.g. /Blog/")
        if len(indexes) != len(set(indexes.values())):
            raise ValueError("Each tag-index directory must have only one index page")
        return indexes

    # Confirm hints before publishing archives. Only an incorrect hint or dynamic
    # configuration needs a second iteration.
    rendered = set()
    compiled_count = 0
    for _ in range(3):
        indexes = verified_indexes() | {
            source: scope for source, scope in hints.items() if source not in metadata
        }
        scopes = sorted(set(indexes.values()))
        save_tag_data(scope_file, scopes)
        posts = []
        for source, meta in metadata.items():
            tags = json.loads(meta.get("article-tags") or "[]")
            if tags and source not in indexes:
                posts.append(
                    TaggedPost(
                        get_html_route(outputs[source]),
                        meta.get("title", ""),
                        meta.get("date", ""),
                        tags,
                    )
                )
        posts.sort(key=lambda post: (post.date, post.url), reverse=True)
        groups = {scope: group_tags(posts, scope) for scope in scopes}
        navigation = {
            scope: [
                {
                    "id": group["id"],
                    "name": group["name"],
                    "url": group["url"],
                    "count": len(group["posts"]),
                }
                for group in groups[scope]
            ]
            for scope in scopes
        }
        nav_files = {}
        for source, scope in indexes.items():
            output = outputs[source]
            nav = tag_page_data(output, {"scope": scope, "items": navigation[scope]})
            nav_files[source] = nav
            if schedule(
                source,
                output,
                [nav],
                f"tag-navigation=/{nav.as_posix()}",
                force_page=(source not in rendered and (force or source in compiled)),
            ):
                rendered.add(source)
        compiled_count += len(jobs)
        if not run_jobs():
            return False
        for source in indexes:
            metadata[source] = parse_html_metadata(outputs[source])
        if verified_indexes() == indexes:
            break
    else:
        raise ValueError("Tag index configuration changed during rendering")

    # Apply authoritative scopes to articles affected by a speculative scope.
    if scopes != initial_scopes:
        for source, meta in metadata.items():
            if meta.get("article-tags") and source not in indexes:
                schedule(source, outputs[source], [scope_file], force_page=True)

    protected = set(outputs.values())
    planned = set()
    for source, scope in indexes.items():
        nav = nav_files[source]
        index_url = quote(get_html_route(outputs[source]), safe="/")
        for group in groups[scope]:
            destination = (
                SITE_DIR / scope.strip("/") / "tags" / group["id"] / "index.html"
            )
            relative = destination.relative_to(SITE_DIR)
            static = CONTENT_DIR / relative
            static_asset = (
                relative.parts[0] == "assets"
                and (ASSETS_DIR.joinpath(*relative.parts[1:])).is_file()
            )
            if (
                destination in protected
                or static.is_file()
                or static_asset
                or destination.as_posix() in planned
                or (destination.exists() and destination.as_posix() not in previous)
            ):
                raise ValueError(
                    f"Tag archive would overwrite an existing page: {destination}"
                )
            planned.add(destination.as_posix())
            state = tag_page_data(
                destination, {"scope": scope, "group": group, "index-url": index_url}
            )
            schedule(
                source,
                destination,
                [nav, state],
                f"tag-navigation=/{nav.as_posix()}",
                f"tag-archive=/{state.as_posix()}",
                force_page=force,
            )
    if jobs:
        save_tag_data(manifest, sorted(previous | planned))
        compiled_count += len(jobs)
        if not run_jobs():
            return False
    removed = 0
    for old in sorted(previous - planned):
        path = Path(old)
        if (
            path in protected
            or not path.is_relative_to(SITE_DIR)
            or ".." in path.parts
            or path == SITE_DIR
        ):
            continue
        relative = path.relative_to(SITE_DIR)
        if (CONTENT_DIR / relative).is_file() or (
            relative.parts[0] == "assets"
            and ASSETS_DIR.joinpath(*relative.parts[1:]).is_file()
        ):
            continue
        if path.exists():
            path.unlink()
            removed += 1
        parent = path.parent
        while parent != SITE_DIR and parent.exists() and not any(parent.iterdir()):
            parent.rmdir()
            parent = parent.parent
    save_tag_data(manifest, sorted(planned))
    save_tag_data(
        TAG_CACHE_DIR / "indexes.json",
        {source.as_posix(): scope for source, scope in indexes.items()},
    )
    if compiled_count or removed:
        print(
            f"✅ 标签聚合完成: {len(indexes)} 个索引，{len(planned)} 个标签页，"
            f"编译: {compiled_count}，清理: {removed}"
        )
    return True


def build_pdf(force: bool = False) -> bool:
    """
    编译文件名包含 "PDF" 的 .typ 文件为 PDF。

    参数:
        force: 是否强制重建所有文件
    """
    SITE_DIR.mkdir(parents=True, exist_ok=True)

    typ_files = find_typ_files()
    pdf_files = [f for f in typ_files if "pdf" in f.stem.lower()]

    if not pdf_files:
        return True

    print("正在构建 PDF 文件...")

    # 获取公共依赖
    common_deps = find_common_dependencies()

    def build_pdf_args(typ_file: Path, output_path: Path) -> list[str]:
        """构建 PDF 编译参数"""
        return [
            "compile",
            "--root",
            ".",
            "--font-path",
            str(ASSETS_DIR),
            str(typ_file),
            str(output_path),
        ]

    stats = _compile_files(
        pdf_files,
        force,
        common_deps,
        lambda typ_file: get_file_output_path(typ_file, "pdf"),
        build_pdf_args,
    )

    print(f"✅ PDF 构建完成。{stats.format_summary()}")
    return not stats.has_failures


def copy_assets() -> bool:
    """
    复制静态资源到输出目录。
    """
    if not ASSETS_DIR.exists():
        print(f"  ⚠ 静态资源目录 {ASSETS_DIR} 不存在。")
        return True

    SITE_DIR.mkdir(parents=True, exist_ok=True)
    target_dir = SITE_DIR / "assets"

    try:
        if target_dir.exists():
            shutil.rmtree(target_dir)
        shutil.copytree(ASSETS_DIR, target_dir)
        return True
    except OSError as e:
        print(f"  ❌ 复制静态资源失败: {e}")
        return False


def copy_content_assets(force: bool = False) -> bool:
    """
    复制 content 目录下的非 .typ 文件（如图片）到输出目录。
    支持增量复制：只复制修改过的文件。

    参数:
        force: 是否强制复制所有文件
    """
    SITE_DIR.mkdir(parents=True, exist_ok=True)

    if not CONTENT_DIR.exists():
        print(f"  ⚠ 内容目录 {CONTENT_DIR} 不存在，跳过。")
        return True

    try:
        copy_count = 0
        skip_count = 0

        for item in CONTENT_DIR.rglob("*"):
            # 跳过目录和 .typ 文件
            if item.is_dir() or item.suffix == ".typ":
                continue

            # 跳过以下划线开头的路径
            relative_path = item.relative_to(CONTENT_DIR)
            if any(part.startswith("_") for part in relative_path.parts):
                continue

            # 计算目标路径
            target_path = SITE_DIR / relative_path

            # 增量复制检查
            if (
                not force
                and target_path.exists()
                and get_file_mtime(item) <= get_file_mtime(target_path)
            ):
                skip_count += 1
                continue

            # 创建目标目录
            target_path.parent.mkdir(parents=True, exist_ok=True)

            # 复制文件
            shutil.copy2(item, target_path)
            copy_count += 1

        return True
    except OSError as e:
        print(f"  ❌ 复制内容资源文件失败: {e}")
        return False


def clean() -> bool:
    """
    清理网站产物和标签构建缓存。
    """
    print("正在清理生成的文件...")

    try:
        if SITE_DIR.exists():
            for item in SITE_DIR.iterdir():
                if item.is_dir():
                    shutil.rmtree(item)
                else:
                    item.unlink()
            print(f"  ✅ 已清理 {SITE_DIR}/ 目录。")
        else:
            print(f"  输出目录 {SITE_DIR} 不存在。")

        if TAG_CACHE_DIR.exists():
            shutil.rmtree(TAG_CACHE_DIR)
            print(f"  ✅ 已清理 {TAG_CACHE_DIR}/ 目录。")
        return True
    except OSError as e:
        print(f"  ❌ 清理失败: {e}")
        return False


def preview(port: int = 8000, open_browser_flag: bool = True) -> bool:
    """
    启动本地预览服务器。

    首先尝试使用 uvx livereload（支持实时刷新），
    如果失败则回退到 Python 内置的 http.server。

    参数:
        port: 服务器端口号，默认为 8000
        open_browser_flag: 是否自动打开浏览器，默认为 True
    """
    import webbrowser

    if not SITE_DIR.exists():
        print(f"  ⚠ 输出目录 {SITE_DIR} 不存在，请先运行 build 命令。")
        return False

    print("正在启动本地预览服务器（按 Ctrl+C 停止）...")
    print()

    if open_browser_flag:

        def open_browser():
            time.sleep(1.5)  # 等待服务器启动
            url = f"http://localhost:{port}"
            print(f"  🚀 正在打开浏览器: {url}")
            webbrowser.open(url)

        # 在后台线程中打开浏览器
        threading.Thread(target=open_browser, daemon=True).start()

    # 首先尝试 uvx livereload
    try:
        result = subprocess.run(
            ["uvx", "livereload", str(SITE_DIR), "-p", str(port)],
            check=False,
        )
        if result.returncode in (0, -signal.SIGINT, 128 + signal.SIGINT):
            return True
        print("  livereload 已退出，尝试 Python http.server...")
    except FileNotFoundError:
        print("  未找到 uv，尝试 Python http.server...")
    except KeyboardInterrupt:
        print("\n服务器已停止。")
        return True

    # 回退到 Python http.server
    try:
        print("使用 Python 内置 http.server...")
        result = subprocess.run(
            [
                sys.executable,
                "-m",
                "http.server",
                str(port),
                "--directory",
                str(SITE_DIR),
            ],
            check=False,
        )
        return result.returncode == 0
    except KeyboardInterrupt:
        print("\n服务器已停止。")
        return True
    except OSError as e:
        print(f"  ❌ 启动服务器失败: {e}")
        return False


def parse_html_metadata(html_path: Path) -> dict[str, str]:
    """
    解析 HTML 文件并返回元数据解析器实例。

    参数:
        html_path (Path): HTML 文件路径

    返回:
        HTMLMetadataParser: 包含解析结果的解析器实例
    """
    parser = HTMLMetadataParser()
    parser.feed(html_path.read_text(encoding="utf-8"))
    return parser.metadata


def get_site_url() -> str | None:
    """
    从生成的首页 HTML 文件中解析站点 URL。

    功能:
        从 _site/index.html 的 <link rel="canonical" href="..."> 提取 site-url。

    返回:
        str: 站点的根 URL（如 "https://example.com"），末尾不带斜杠。
            如果未配置或解析失败则返回 None。
    """
    index_html = SITE_DIR / "index.html"
    parser = parse_html_metadata(index_html)

    if parser.get("link"):
        return parser["link"].rstrip("/")

    return None


def get_feed_dirs() -> set[str]:
    """
    从 config.typ 配置文件中解析 RSS Feed 订阅源的配置信息。

    功能:
        解析 config.typ 中的 feed 配置块，提取目录列表。

    返回:
        set[str]: 要包含的文章目录列表，默认为空集合
    """
    if not CONFIG_FILE.exists():
        return set()

    try:
        content = CONFIG_FILE.read_text(encoding="utf-8")

        # 移除注释
        content = re.sub(r"//.*", "", content)
        content = re.sub(r"/\*[\s\S]*?\*/", "", content)

        match = re.search(r"feed-dir\s*:\s*\((.*?)\)", content, re.DOTALL)
        if match:
            return {
                c.strip("/")
                for c in re.findall(r'"([^"]*)"', match.group(1))
                if c and c.strip("/")
            }
    except (OSError, UnicodeError) as e:
        print(f"⚠️ 解析 feed-dir 失败: {e}")

    return set()


def extract_post_metadata(index_html: Path) -> tuple[str, str, str, datetime | None]:
    """
    从生成的 HTML 文件中提取文章的元数据信息。

    功能:
        提取文章元数据：
        1. 标题 (title): 从 <title> 标签提取
        2. 描述 (description): 从 <meta name="description"> 提取
        3. 链接 (link): 从 <link rel="canonical" href="..."> 提取
        4. 日期 (date): 依次尝试从以下来源获取：
            - HTML 中的 <meta name="date" content="...">
            - 文件夹名中的 YYYY-MM-DD 格式日期

    参数:
        index_html (Path): 文章的 index.html 文件路径

    返回:
        tuple[str, str, str, datetime | None]: 包含四个元素的元组：
            - str: 文章标题
            - str: 文章描述（可能为空字符串）
            - str: 文章链接（完整 URL）
            - datetime | None: 文章日期（带 UTC 时区），无法获取时为 None
    """
    parser = parse_html_metadata(index_html)

    title = parser["title"].strip()
    description = parser.get("description", "").strip()
    link = parser.get("link", "")
    date_obj = None

    # 尝试从 <meta name="date"> 解析日期
    if parser.get("date"):
        try:
            date_obj = datetime.strptime(parser["date"].split("T")[0], "%Y-%m-%d")
            date_obj = date_obj.replace(tzinfo=timezone.utc)
        except ValueError as e:
            print(f"⚠️ 文章 {index_html} 的日期无效，将尝试目录名日期: {e}")

    # 如果没找到日期，尝试从文件夹名提取 (YYYY-MM-DD)
    if not date_obj:
        date_match = re.search(r"(\d{4}-\d{2}-\d{2})", index_html.parent.name)
        if date_match:
            try:
                date_obj = datetime.strptime(date_match.group(1), "%Y-%m-%d")
                date_obj = date_obj.replace(tzinfo=timezone.utc)
            except ValueError:
                pass

    return title, description, link, date_obj


@dataclass
class FeedHTMLNode:
    tag: str
    attrs: list[tuple[str, str | None]] = field(default_factory=list)
    children: list["FeedHTMLNode | str"] = field(default_factory=list)


class FeedHTMLParser(HTMLParser):
    """Parse compiler-generated, explicitly closed HTML without browser execution."""

    VOID_TAGS = frozenset(
        {
            "area",
            "base",
            "br",
            "col",
            "embed",
            "hr",
            "img",
            "input",
            "link",
            "meta",
            "param",
            "source",
            "track",
            "wbr",
        }
    )
    OMIT_TAGS = frozenset({"script", "button", "iframe", "object", "embed"})
    OMIT_ATTRS = frozenset(
        {"hidden", "inert", "loading", "decoding", "srcset", "sizes"}
    )
    TEXT_STYLES = frozenset({"color", "font-weight", "font-style", "text-decoration"})

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.root = FeedHTMLNode("")
        self.stack = [self.root]
        self.article_section = None

    def handle_starttag(self, tag, attrs):
        # Preserve SVG's case-sensitive element and attribute names.
        source = self.get_starttag_text() or ""
        match = re.match(r"<([^\s/>]+)", source)
        original_tag = match.group(1) if match else tag
        names = re.findall(r"([^\s=/>]+)\s*=", source)
        spelling = {name.lower(): name for name in names}
        node = FeedHTMLNode(
            original_tag, [(spelling.get(name, name), value) for name, value in attrs]
        )
        self.stack[-1].children.append(node)
        if tag == "section" and self.stack[-1].tag == "article":
            self.article_section = self.article_section or node
        if tag not in self.VOID_TAGS:
            self.stack.append(node)

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if tag not in self.VOID_TAGS:
            self.handle_endtag(tag)

    def handle_endtag(self, tag):
        for index in range(len(self.stack) - 1, 0, -1):
            if self.stack[index].tag.lower() == tag:
                del self.stack[index:]
                break

    def handle_data(self, data):
        self.stack[-1].children.append(data)


def extract_post_content(index_html: Path, article_url: str) -> str:
    """Extract article HTML for readers without site CSS/JS; append margin notes.

    Input is trusted Typst output, not arbitrary untrusted HTML. MathML and SVG
    remain inline: rendering support depends on the reader. Fragment links point
    back to the original article, avoiding ID collisions between feed entries.
    """
    parser = FeedHTMLParser()
    parser.feed(index_html.read_text(encoding="utf-8"))
    notes = []
    manual_note_number = 0

    def standalone_manual_note(node):
        if not isinstance(node, FeedHTMLNode) or node.tag != "p":
            return None
        note = None
        for child in node.children:
            if isinstance(child, str) and not child.strip():
                continue
            if not isinstance(child, FeedHTMLNode):
                return None
            classes = dict(child.attrs).get("class", "").split()
            if "sidenote-anchor" in classes:
                continue
            if "sidenote-manual" in classes and note is None:
                note = child
                continue
            return None
        return note

    def render(node, in_note=False, in_svg=False):
        nonlocal manual_note_number
        if isinstance(node, str):
            return escape(node, quote=False)
        if note := standalone_manual_note(node):
            return (
                "<blockquote>"
                + "".join(render(child, True) for child in note.children)
                + "</blockquote>"
            )
        in_svg = in_svg or node.tag == "svg"
        attrs = dict(node.attrs)
        classes = attrs.get("class", "").split()
        if (
            node.tag in parser.OMIT_TAGS
            or (node.tag == "style" and not in_svg)
            or ("sidenote-anchor" in classes)
        ):
            return ""
        if (
            "marginnote" in classes
            and "sidenote-caption" not in classes
            and not in_note
        ):
            is_footnote = "sidenote-footnote" in classes
            if is_footnote:
                notes.append(f"<div>{render(node, True)}</div>")
                # Its existing numbered reference is already in the paragraph.
                return ""
            manual_note_number += 1
            number = manual_note_number
            notes.append(
                f'<div id="rss-note-{number}"><strong>[*{number}]</strong> '
                f"{render(node, True)}</div>"
            )
            return f'<sup><a href="#rss-note-{number}">[*{number}]</a></sup>'
        tag = "figcaption" if "sidenote-caption" in classes else node.tag
        output_attrs = []
        for name, value in node.attrs:
            if (
                name.lower().startswith("on")
                or (name == "class" and not in_svg)
                or name in parser.OMIT_ATTRS
            ):
                continue
            if name == "style" and not in_svg:
                # Preserve text emphasis and syntax colors, not website positioning.
                value = ";".join(
                    declaration
                    for declaration in (value or "").split(";")
                    if declaration.partition(":")[0].strip().lower()
                    in parser.TEXT_STYLES
                )
                if not value:
                    continue
            if name in {"href", "src", "poster", "xlink:href"} and value:
                # SVG fragment references must remain local to the inline graphic.
                if not (
                    in_svg and name in {"href", "xlink:href"} and value.startswith("#")
                ):
                    value = urljoin(article_url, value)
                embedded_image = name == "src" and value.startswith(
                    (
                        "data:image/png;",
                        "data:image/jpeg;",
                        "data:image/webp;",
                        "data:image/gif;",
                    )
                )
                if not embedded_image and urlsplit(value).scheme.lower() not in {
                    "",
                    "http",
                    "https",
                    "mailto",
                    "tel",
                }:
                    continue
            output_attrs.append(
                name if value is None else f'{name}="{escape(value, quote=True)}"'
            )
        opening = (
            "<" + tag + (" " + " ".join(output_attrs) if output_attrs else "") + ">"
        )
        if tag in parser.VOID_TAGS:
            return opening
        children = node.children
        if tag == "figure":
            children = []
            for child in node.children:
                if isinstance(child, FeedHTMLNode) and child.tag == "p":
                    content = [
                        part
                        for part in child.children
                        if not isinstance(part, str) or part.strip()
                    ]
                    if (
                        len(content) == 1
                        and isinstance(content[0], FeedHTMLNode)
                        and "sidenote-caption"
                        in dict(content[0].attrs).get("class", "").split()
                    ):
                        child = content[0]
                children.append(child)
        return (
            opening
            + "".join(render(child, in_note, in_svg) for child in children)
            + f"</{tag}>"
        )

    section = parser.article_section
    if section is None:
        return ""
    body = "".join(render(child) for child in section.children)
    return body + ("<hr>" + "".join(notes) if notes else "")


def collect_posts(dirs: set[str], site_url: str) -> list[dict]:
    """
    从指定的目录中收集所有文章的元数据。

    功能:
        遍历 _site 目录下指定目录中的所有子目录，提取每个文章的元数据信息。
        只处理目录（每个目录代表一篇文章），跳过普通文件。
        如果无法确定文章日期，则跳过该文章并输出警告。

    参数:
        dirs (set[str]): 要扫描的目录名称集合（如 {"Blog", "Docs"}）
        site_url (str): 站点的根 URL（如 "https://example.com"）

    返回:
        list[dict]: 文章数据字典列表，每个字典包含以下键：
            - title (str): 文章标题
            - description (str): 文章描述
            - dir (str): 文章所属分类（即目录名）
            - link (str): 文章的完整 URL
            - date (datetime): 文章日期对象（带时区）
            - content (str): 适合订阅阅读的正文 HTML
    """
    posts = []

    for d in dirs:
        dir_path = SITE_DIR / d

        for item in dir_path.iterdir():
            if not item.is_dir():
                continue

            index_html = item / "index.html"
            if not index_html.exists():
                continue

            title, description, link, date_obj = extract_post_metadata(index_html)
            link = link or urljoin(
                site_url.rstrip("/") + "/", item.relative_to(SITE_DIR).as_posix() + "/"
            )

            if not date_obj:
                print(f"⚠️ 无法确定文章 '{item.name}' 的日期，已跳过。")
                continue

            posts.append(
                {
                    "title": title,
                    "description": description,
                    "dir": d,
                    "link": link,
                    "date": date_obj,
                    "content": extract_post_content(index_html, link),
                }
            )

    return posts


def build_rss_xml(posts: list[dict], config: dict) -> str:
    """
    构建符合 RSS 2.0 规范的 XML 内容字符串。

    功能:
        使用 Python 标准库 xml.etree.ElementTree 根据文章数据和站点配置生成完整的 RSS Feed XML。
        保留 description 摘要，并用 content:encoded 输出正文 HTML。

    参数:
        posts (list[dict]): 文章数据列表，每个字典应包含:
            - title: 标题
            - description: 描述（可选）
            - link: 文章链接
            - date: datetime 对象
            - dir: 分类名称 (即路径名)
        config (dict): 站点配置字典，应包含:
            - site_url: 站点根 URL
            - site_title: 站点标题
            - site_description: 站点描述
            - lang: 语言代码（如 "zh", "en"）

    返回:
        str: 完整的 RSS 2.0 XML 字符串，包含 XML 声明和所有必要的命名空间。
    """
    import xml.etree.ElementTree as ET
    from email.utils import format_datetime

    # 注册 atom 命名空间前缀
    ATOM_NS = "http://www.w3.org/2005/Atom"
    ET.register_namespace("atom", ATOM_NS)
    CONTENT_NS = "http://purl.org/rss/1.0/modules/content/"
    ET.register_namespace("content", CONTENT_NS)

    # 创建 RSS 根元素（命名空间声明由 register_namespace 自动处理）
    rss = ET.Element("rss", version="2.0")

    # Channel 元数据
    channel = ET.SubElement(rss, "channel")
    ET.SubElement(channel, "title").text = config["site_title"]
    ET.SubElement(channel, "link").text = config["site_url"]
    ET.SubElement(channel, "description").text = config["site_description"]
    ET.SubElement(channel, "language").text = config["lang"]
    ET.SubElement(channel, "lastBuildDate").text = format_datetime(
        datetime.now(timezone.utc)
    )

    # 添加 atom:link 自链接
    atom_link = ET.SubElement(channel, f"{{{ATOM_NS}}}link")
    atom_link.set("href", f"{config['site_url']}/feed.xml")
    atom_link.set("rel", "self")
    atom_link.set("type", "application/rss+xml")

    # 添加文章条目
    for post in posts:
        item = ET.SubElement(channel, "item")

        ET.SubElement(item, "title").text = post["title"]
        ET.SubElement(item, "link").text = post["link"]
        ET.SubElement(item, "guid", isPermaLink="true").text = post["link"]
        ET.SubElement(item, "pubDate").text = format_datetime(post["date"])
        ET.SubElement(item, "category").text = post["dir"]

        # 仅在有描述时添加
        if des := post["description"]:
            ET.SubElement(item, "description").text = des
        if content := post.get("content"):
            ET.SubElement(item, f"{{{CONTENT_NS}}}encoded").text = content

    # 生成 XML 字符串
    ET.indent(rss, space="  ")
    xml_str = ET.tostring(rss, encoding="unicode", xml_declaration=False)

    return f'<?xml version="1.0" encoding="UTF-8"?>\n{xml_str}'


def generate_rss(site_url: str) -> bool:
    """
    生成网站的 RSS 订阅源文件。

    功能:
        完整的 RSS Feed 生成流程：
        1. 从 config.typ 读取目标目录（分类）
        2. 收集指定目录下的所有文章元数据
        3. 按日期排序
        4. 构建 RSS XML 并写入文件

    返回:
        bool: 生成是否成功。在以下情况返回 True：
            - 成功生成 RSS 文件
            - 未配置分类目录（删除旧 Feed）
            - 未找到任何文章（生成空 Feed）
        仅在发生异常时返回 False。
    """
    rss_file = SITE_DIR / "feed.xml"
    dirs = get_feed_dirs()

    if not dirs:
        rss_file.unlink(missing_ok=True)
        print("⚠️ 跳过 RSS 订阅源生成: 未配置任何目录。")
        return True

    # 检查是否至少有一个目录存在
    existing = {d for d in dirs if (SITE_DIR / d).is_dir()}
    missing = dirs - existing

    for d in missing:
        print(f"⚠️ 警告: 配置的目录 '{d}' 不存在。")

    # 收集文章
    posts = collect_posts(existing, site_url)

    if not posts:
        print("⚠️ 未找到任何文章，RSS 订阅源为空。")

    # 按日期降序排序
    posts = sorted(posts, key=lambda x: x["date"], reverse=True)

    # 获取配置信息
    index_html = SITE_DIR / "index.html"
    parser = parse_html_metadata(index_html)

    lang = parser["lang"]
    site_title = parser["title"].strip()
    site_description = parser.get("description", "").strip()

    config = {
        "site_url": site_url,
        "site_title": site_title,
        "site_description": site_description,
        "lang": lang,
    }

    # 构建 RSS XML
    try:
        rss_content = build_rss_xml(posts, config)
        rss_file.write_text(rss_content, encoding="utf-8")
        print(f"✅ RSS 订阅源生成成功: {rss_file} ({len(posts)} 篇文章)")
        return True
    except ValueError as e:
        print("❌ 错误: RSS 订阅源生成失败")
        print(f"   原因: feedgen 库报错 - {e}")
        print("   解决: 请检查 config.typ 中的必需配置字段（title 和 description）")
        return False
    except OSError as e:
        print("❌ 错误: 生成 RSS 订阅源时出错")
        print(f"   异常: {type(e).__name__}: {e}")
        return False


def generate_sitemap(site_url: str) -> bool:
    """
    使用 Python 标准库 xml.etree.ElementTree 生成 sitemap.xml。
    """
    import xml.etree.ElementTree as ET

    sitemap_path = SITE_DIR / "sitemap.xml"
    sitemap_ns = "http://www.sitemaps.org/schemas/sitemap/0.9"

    # 注册默认命名空间
    ET.register_namespace("", sitemap_ns)

    # 创建根元素
    urlset = ET.Element("urlset", xmlns=sitemap_ns)

    # 遍历 _site 目录
    for file_path in sorted(SITE_DIR.rglob("*.html")):
        rel_path = file_path.relative_to(SITE_DIR).as_posix()

        # 确定 URL 路径
        if rel_path == "index.html":
            url_path = ""
        elif rel_path.endswith("/index.html"):
            url_path = rel_path.removesuffix("index.html")
        elif rel_path.endswith(".html"):
            url_path = rel_path.removesuffix(".html") + "/"
        else:
            url_path = rel_path

        full_url = f"{site_url}/{url_path}"

        # 获取最后修改时间
        mtime = file_path.stat().st_mtime
        lastmod = datetime.fromtimestamp(mtime).strftime("%Y-%m-%d")

        # 创建 url 元素
        url_elem = ET.SubElement(urlset, "url")
        ET.SubElement(url_elem, "loc").text = full_url
        ET.SubElement(url_elem, "lastmod").text = lastmod

    # 生成 XML 字符串
    ET.indent(urlset, space="  ")
    xml_str = ET.tostring(urlset, encoding="unicode", xml_declaration=False)
    sitemap_content = f'<?xml version="1.0" encoding="UTF-8"?>\n{xml_str}'

    try:
        sitemap_path.write_text(sitemap_content, encoding="utf-8")
        print(f"✅ Sitemap 构建完成: 包含 {len(urlset)} 个页面")
        return True
    except (OSError, UnicodeError) as e:
        print(f"❌ Sitemap 构建失败: {e}")
        return False


def generate_robots_txt(site_url: str) -> bool:
    """
    Generate robots.txt pointing to the sitemap.
    """
    robots_content = f"""User-agent: *
Allow: /

Sitemap: {site_url}/sitemap.xml
"""

    try:
        (SITE_DIR / "robots.txt").write_text(robots_content, encoding="utf-8")
        return True
    except (OSError, UnicodeError) as e:
        print(f"❌ 生成 robots.txt 失败: {e}")
        return False


def build(force: bool = False) -> bool:
    """
    完整构建：HTML + PDF + 资源。

    参数:
        force: 是否强制重建所有文件
    """
    print("-" * 60)
    if force:
        clean()
        print("🛠️ 开始完整构建...")
    else:
        print("🚀 开始增量构建...")
    print("-" * 60)

    # 确保输出目录存在
    SITE_DIR.mkdir(parents=True, exist_ok=True)

    results = []

    print()
    results.append(build_html(force))
    results.append(build_pdf(force))
    print()

    results.append(copy_assets())
    results.append(copy_content_assets(force))

    if site_url := get_site_url():
        results.append(generate_sitemap(site_url))
        results.append(generate_robots_txt(site_url))
        results.append(generate_rss(site_url))
    else:
        (SITE_DIR / "feed.xml").unlink(missing_ok=True)

    print("-" * 60)
    if all(results):
        print("✅ 所有构建任务完成！")
        print(f"  📂 输出目录: {SITE_DIR.absolute()}")
    else:
        print("⚠ 构建完成，但有部分任务失败。")
    print("-" * 60)

    return all(results)


# ============================================================================
# 监听与命令行接口
# ============================================================================


def watch_snapshot() -> dict[Path, tuple[int, int]]:
    """Record the mtime and size of site inputs without scanning build outputs."""
    files = [CONFIG_FILE]
    for directory in (CONTENT_DIR, ASSETS_DIR, Path("tufted-lib")):
        files.extend(directory.rglob("*"))

    snapshot = {}
    for path in files:
        try:
            info = path.stat()
        except FileNotFoundError:
            # An editor may replace a file between listing and statting it.
            continue
        if S_ISREG(info.st_mode):
            snapshot[path] = (info.st_mtime_ns, info.st_size)
    return snapshot


def watch(port: int = 8000, open_browser_flag: bool = True) -> bool:
    """Build once, then rebuild on input changes while preview is running."""
    stop = threading.Event()
    snapshot = watch_snapshot()
    sources = set(find_typ_files())

    def rebuild() -> None:
        nonlocal sources
        try:
            current = set(find_typ_files())
            for source in sources - current:
                kind = "pdf" if "pdf" in source.stem.lower() else "html"
                get_file_output_path(source, kind).unlink(missing_ok=True)
            sources = current
            build()
        except Exception:
            logging.getLogger(__name__).exception("❌ 自动构建失败")

    def watch_changes() -> None:
        nonlocal snapshot
        pending = False
        while not stop.wait(0.25):
            try:
                current = watch_snapshot()
            except OSError as error:
                print(f"⚠ 无法扫描构建输入: {error}")
                continue
            if current != snapshot:
                snapshot = current
                pending = True
            elif pending:
                pending = False
                rebuild()

    rebuild()
    print("👀 正在监听 content/、assets/、tufted-lib/ 和 config.typ（按 Ctrl+C 停止）")
    worker = threading.Thread(target=watch_changes)
    worker.start()
    try:
        return preview(port, open_browser_flag)
    finally:
        stop.set()
        worker.join()


def create_parser() -> argparse.ArgumentParser:
    """
    创建命令行参数解析器。
    """
    parser = argparse.ArgumentParser(
        prog="build.py",
        description="Tufted Blog Template 构建脚本 - 将 content 中的 Typst 文件编译为 HTML 和 PDF",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
构建脚本默认只重新编译修改过的文件，可使用 -f/--force 选项强制完整重建：
    uv run build.py build --force
    或 python build.py build -f

使用 preview 命令启动本地预览服务器：
    uv run build.py preview
    或 python build.py preview -p 3000  # 使用自定义端口

更多信息请参阅 README.md
""",
    )

    subparsers = parser.add_subparsers(
        dest="command", title="可用命令", metavar="<command>"
    )

    build_parser = subparsers.add_parser("build", help="完整构建 (HTML + PDF + 资源)")
    build_parser.add_argument("-f", "--force", action="store_true", help="强制完整重建")

    html_parser = subparsers.add_parser("html", help="仅构建 HTML 文件")
    html_parser.add_argument("-f", "--force", action="store_true", help="强制完整重建")

    pdf_parser = subparsers.add_parser("pdf", help="仅构建 PDF 文件")
    pdf_parser.add_argument("-f", "--force", action="store_true", help="强制完整重建")

    subparsers.add_parser("assets", help="仅复制静态资源")
    subparsers.add_parser("clean", help="清理生成的文件")

    for command, help_text in (
        ("preview", "启动本地预览服务器"),
        ("watch", "启动本地预览服务器并监听源文件变化"),
    ):
        serve_parser = subparsers.add_parser(command, help=help_text)
        serve_parser.add_argument(
            "-p", "--port", type=int, default=8000, help="服务器端口号（默认: 8000）"
        )
        serve_parser.add_argument(
            "--no-open",
            action="store_false",
            dest="open_browser",
            help="不自动打开浏览器",
        )

    return parser


if __name__ == "__main__":
    parser = create_parser()
    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        sys.exit(0)

    # 确保在项目根目录运行
    script_dir = Path(__file__).parent.absolute()
    os.chdir(script_dir)

    if args.command in {"build", "html", "pdf", "watch"}:
        warn_if_typst_version_is_outdated()

    # 获取 force 参数
    force = getattr(args, "force", False)

    # 使用 match-case 执行对应的命令
    match args.command:
        case "build":
            success = build(force)
        case "html":
            success = build_html(force)
        case "pdf":
            success = build_pdf(force)
        case "assets":
            success = copy_assets()
        case "clean":
            success = clean()
        case "preview":
            success = preview(args.port, args.open_browser)
        case "watch":
            success = watch(args.port, args.open_browser)
        case _:
            print(f"❌ 未知命令: {args.command}")
            success = False

    sys.exit(0 if success else 1)
