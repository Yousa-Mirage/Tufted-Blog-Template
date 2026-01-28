# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "feedgen",
# ]
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
import html
import os
import re
import shutil
import subprocess
import sys
import threading
import time
import webbrowser
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

from feedgen.feed import FeedGenerator
from feedgen.entry import FeedEntry

# ============================================================================
# 配置
# ============================================================================

CONTENT_DIR = Path("content")  # 源文件目录
SITE_DIR = Path("_site")  # 输出目录
ASSETS_DIR = Path("assets")  # 静态资源目录
CONFIG_FILE = Path("config.typ")  # 全局配置文件


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
            if len(parts) > 0 and parts[0].startswith("_"):
                return True
            # content/ 下的其他文件不是依赖文件
            return False
        except ValueError:
            # 不在 content/ 目录下，视为依赖文件（如 config.typ）
            return True

    except Exception:
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
    except Exception:
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
                if dep_path.exists() and dep_path.suffix == ".typ" and is_dep_file(dep_path):
                    dependencies.add(dep_path)
            except Exception:
                pass

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


def needs_rebuild(source: Path, target: Path, extra_deps: list[Path] | None = None) -> bool:
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
        if item.is_file() and item.suffix != ".typ":
            if get_file_mtime(item) > target_mtime:
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


def get_html_output_path(typ_file: Path) -> Path:
    """
    获取 .typ 文件对应的 HTML 输出路径。

    参数:
        typ_file: .typ 文件路径 (相对于 content/)

    返回:
        Path: HTML 文件输出路径 (在 _site/ 目录下)
    """
    relative_path = typ_file.relative_to(CONTENT_DIR)
    return SITE_DIR / relative_path.with_suffix(".html")


def get_pdf_output_path(typ_file: Path) -> Path:
    """
    获取 .typ 文件对应的 PDF 输出路径。

    参数:
        typ_file: .typ 文件路径 (相对于 content/)

    返回:
        Path: PDF 文件输出路径 (在 _site/ 目录下)
    """
    relative_path = typ_file.relative_to(CONTENT_DIR)
    return SITE_DIR / relative_path.with_suffix(".pdf")


def run_typst_command(args: list[str]) -> bool:
    """
    运行 typst 命令。

    参数:
        args: typst 命令参数列表

    返回:
        bool: 命令是否成功执行
    """
    try:
        result = subprocess.run(["typst"] + args, capture_output=True, text=True, encoding="utf-8")
        if result.returncode != 0:
            print(f"  ❌ Typst 错误: {result.stderr.strip()}")
            return False
        return True
    except FileNotFoundError:
        print("  ❌ 错误: 未找到 typst 命令。请确保已安装 Typst 并添加到 PATH 环境变量中。")
        print("  📝 安装说明: https://typst.app/open-source/#download")
        return False
    except Exception as e:
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
) -> BuildStats:
    """
    通用文件编译函数，减少重复代码。

    参数:
        files: 要编译的文件列表
        force: 是否强制重建
        common_deps: 公共依赖列表
        get_output_path_func: 获取输出路径的函数
        build_args_func: 构建编译参数的函数

    返回:
        BuildStats: 构建统计信息
    """
    stats = BuildStats()

    for typ_file in files:
        output_path = get_output_path_func(typ_file)

        # 增量编译检查
        if not force and not needs_rebuild(typ_file, output_path, common_deps):
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


def build_html(force: bool = False) -> bool:
    """
    编译所有 .typ 文件为 HTML（文件名中包含 PDF 的除外）。

    参数:
        force: 是否强制重建所有文件
    """
    typ_files = find_typ_files()

    # 排除标记为 PDF 的文件
    html_files = [f for f in typ_files if "pdf" not in f.stem.lower()]

    if not html_files:
        print("  ⚠️ 未找到任何 HTML 文件。")
        return True

    print("正在构建 HTML 文件...")

    # 获取公共依赖
    common_deps = find_common_dependencies()

    def build_html_args(typ_file: Path, output_path: Path) -> list[str]:
        """构建 HTML 编译参数"""
        try:
            rel_path = typ_file.relative_to(CONTENT_DIR)

            if rel_path.name == "index.typ":
                # index.typ uses the parent directory name as the path
                # content/Blog/index.typ -> "Blog"
                # content/index.typ -> "" (Homepage)
                page_path = rel_path.parent.as_posix()
                if page_path == ".":
                    page_path = ""
            else:
                # Common files use the filename as the path
                # content/about.typ -> "about"
                page_path = rel_path.with_suffix("").as_posix()
        except ValueError:
            page_path = ""

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
            str(typ_file),
            str(output_path),
        ]

    stats = _compile_files(
        html_files,
        force,
        common_deps,
        get_html_output_path,
        build_html_args,
    )

    print(f"✅ HTML 构建完成。{stats.format_summary()}")
    return not stats.has_failures


def build_pdf(force: bool = False) -> bool:
    """
    编译文件名包含 "PDF" 的 .typ 文件为 PDF。

    参数:
        force: 是否强制重建所有文件
    """
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
        get_pdf_output_path,
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

    target_dir = SITE_DIR / "assets"

    try:
        if target_dir.exists():
            shutil.rmtree(target_dir)
        shutil.copytree(ASSETS_DIR, target_dir)
        return True
    except Exception as e:
        print(f"  ❌ 复制静态资源失败: {e}")
        return False


def copy_content_assets(force: bool = False) -> bool:
    """
    复制 content 目录下的非 .typ 文件（如图片）到输出目录。
    支持增量复制：只复制修改过的文件。

    参数:
        force: 是否强制复制所有文件
    """
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
            if not force and target_path.exists():
                if get_file_mtime(item) <= get_file_mtime(target_path):
                    skip_count += 1
                    continue

            # 创建目标目录
            target_path.parent.mkdir(parents=True, exist_ok=True)

            # 复制文件
            shutil.copy2(item, target_path)
            copy_count += 1

        return True
    except Exception as e:
        print(f"  ❌ 复制内容资源文件失败: {e}")
        return False


def clean() -> bool:
    """
    清理生成的文件。
    """
    print("正在清理生成的文件...")

    if not SITE_DIR.exists():
        print(f"  输出目录 {SITE_DIR} 不存在，无需清理。")
        return True

    try:
        # 删除 _site 目录下的所有内容
        for item in SITE_DIR.iterdir():
            if item.is_dir():
                shutil.rmtree(item)
            else:
                item.unlink()

        print(f"  ✅ 已清理 {SITE_DIR}/ 目录。")
        return True
    except Exception as e:
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
        return result.returncode == 0
    except FileNotFoundError:
        print("  未找到 uv，尝试 Python http.server...")
    except KeyboardInterrupt:
        print("\n服务器已停止。")
        return True

    # 回退到 Python http.server
    try:
        print("使用 Python 内置 http.server...")
        result = subprocess.run(
            [sys.executable, "-m", "http.server", str(port), "--directory", str(SITE_DIR)],
            check=False,
        )
        return result.returncode == 0
    except KeyboardInterrupt:
        print("\n服务器已停止。")
        return True
    except Exception as e:
        print(f"  ❌ 启动服务器失败: {e}")
        return False


def get_site_url() -> str:
    """
    从 config.typ 配置文件中解析站点 URL。
    
    功能:
        通过正则表达式从 config.typ 中提取 site-url 字段的值。
        如果配置文件不存在或解析失败，则返回空字符串。
    
    返回:
        str: 站点的根 URL（如 "https://example.com"），末尾不带斜杠。
             如果未配置或解析失败则返回空字符串。
    """
    if not CONFIG_FILE.exists():
        return ""

    try:
        content = CONFIG_FILE.read_text(encoding="utf-8")
        # Look for site-url: "..."
        if match := re.search(r'site-url\s*:\s*"([^"]*)"', content):
            return match.group(1).strip().rstrip("/")
    except Exception as e:
        print(f"⚠️ Warning: Failed to parse site-url from config.typ: {e}")

    return ""


def get_feed_config() -> dict:
    """
    从 config.typ 配置文件中解析 RSS Feed 订阅源的配置信息。
    
    功能:
        解析 config.typ 中的 feed 配置块，提取 filename、limit 和 categories 字段。
        使用括号计数法处理嵌套结构，确保正确解析多行配置。
    
    返回:
        dict: RSS Feed 配置字典，包含以下键：
            - filename (str): RSS 文件名，默认为 "feed.xml"
            - limit (int | None): 限制输出的文章数量，None 表示不限制
            - categories (list[str]): 要包含的文章分类列表，默认为空列表
    """
    config = {"filename": "feed.xml", "limit": None, "categories": []}
    if not CONFIG_FILE.exists():
        return config

    try:
        content = CONFIG_FILE.read_text(encoding="utf-8")
        
        match_start = re.search(r"feed:\s*\(", content)
        if match_start:
            start_idx = match_start.end()
            open_parens = 1
            feed_block = ""
            
            # 向后遍历，通过计数括号来处理嵌套结构
            for char in content[start_idx:]:
                if char == '(':
                    open_parens += 1
                elif char == ')':
                    open_parens -= 1
                
                if open_parens == 0:
                    break
                feed_block += char
            
            feed_block_clean = re.sub(r"//.*", "", feed_block) 
            # Match filename: "..."
            if fn_match := re.search(r'filename:\s*"([^"]*)"', feed_block_clean):
                config["filename"] = fn_match.group(1).strip()
            
            # Match limit: 20
            if limit_match := re.search(r"limit:\s*(\d+)", feed_block_clean):
                config["limit"] = int(limit_match.group(1))
            
            # Match categories: ("...", "...")
            if cat_match := re.search(r"categories:\s*\(([^)]*)\)", feed_block_clean, re.DOTALL):
                cats = re.findall(r'"([^"]*)"', cat_match.group(1))
                if cats:
                    config["categories"] = cats

    except Exception as e:
        print(f"⚠️ Warning: Failed to parse feed config from config.typ: {e}")
        
    return config

def get_site_language() -> str:
    """
    从 config.typ 配置文件中解析网站语言代码。
    
    功能:
        通过正则表达式从 config.typ 中提取 lang 字段的值。
        用于设置网站的主要语言，影响 HTML lang 属性和 RSS Feed。
    
    返回:
        str: 语言代码（如 "zh", "en" 等），默认返回 "zh"。
    """
    if not CONFIG_FILE.exists():
        return "zh"

    try:
        content = CONFIG_FILE.read_text(encoding="utf-8")
        # Look for lang: "..."
        if match := re.search(r'lang\s*:\s*"([^"]*)"', content):
            return match.group(1).strip()
    except Exception as e:
        print(f"⚠️ Warning: Failed to parse lang from config.typ: {e}")

    return "zh"

def get_site_title() -> str:
    """
    从 config.typ 配置文件中解析网站标题。
    
    功能:
        通过正则表达式从 config.typ 中提取 title 字段的值。
        网站标题将用于 RSS Feed 的 channel title。
    
    返回:
        str: 网站标题字符串，默认返回 "Blog"。
    """
    if not CONFIG_FILE.exists():
        return "Blog"

    try:
        content = CONFIG_FILE.read_text(encoding="utf-8")
        # Look for title: "..."
        if match := re.search(r'title\s*:\s*"([^"]*)"', content):
            return match.group(1).strip()
    except Exception as e:
        print(f"⚠️ Warning: Failed to parse title from config.typ: {e}")

    return "Blog"

def get_site_description() -> str:
    """
    从 config.typ 配置文件中解析网站描述信息。
    
    功能:
        通过正则表达式从 config.typ 中提取 description 字段的值。
        网站描述将用于 RSS Feed 的 channel description。
    
    返回:
        str: 网站描述字符串，如果未配置则返回空字符串。
    """
    if not CONFIG_FILE.exists():
        return ""

    try:
        content = CONFIG_FILE.read_text(encoding="utf-8")
        # Look for description: "..."
        if match := re.search(r'description\s*:\s*"([^"]*)"', content):
            return match.group(1).strip()
    except Exception as e:
        print(f"⚠️ Warning: Failed to parse description from config.typ: {e}")

    return ""

def generate_sitemap() -> bool:
    """
    Generate sitemap.xml for the website.
    """
    base_url = get_site_url()
    if not base_url:
        print("⚠️ 跳过 Sitemap 构建: config.typ 中未配置 'site-url'。")
        return True

    sitemap_path = SITE_DIR / "sitemap.xml"
    urls = []

    # Walk through the _site directory
    for file_path in SITE_DIR.rglob("*.html"):
        # Calculate relative path from _site
        rel_path = file_path.relative_to(SITE_DIR).as_posix()

        # Determine URL path
        if rel_path == "index.html":
            url_path = ""
        elif rel_path.endswith("/index.html"):
            url_path = rel_path.removesuffix("index.html")
        elif rel_path.endswith(".html"):
            url_path = rel_path.removesuffix(".html") + "/"
        else:
            url_path = rel_path

        full_url = f"{base_url}/{url_path}"

        # Get last modification time
        mtime = file_path.stat().st_mtime
        lastmod = datetime.fromtimestamp(mtime).strftime("%Y-%m-%d")

        urls.append(f"""  <url>
    <loc>{html.escape(full_url)}</loc>
    <lastmod>{lastmod}</lastmod>
  </url>""")

    newline = "\n"
    sitemap_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
{newline.join(sorted(urls))}
</urlset>"""

    try:
        sitemap_path.write_text(sitemap_content, encoding="utf-8")
        print(f"✅ Sitemap 构建完成: 包含 {len(urls)} 个页面")
        return True
    except Exception as e:
        print(f"❌ Sitemap 构建失败: {e}")
        return False


def generate_robots_txt() -> bool:
    """
    Generate robots.txt pointing to the sitemap.
    """
    site_url = get_site_url()
    if not site_url:
        return True

    robots_content = f"""User-agent: *
Allow: /

Sitemap: {site_url}/sitemap.xml
"""

    try:
        (SITE_DIR / "robots.txt").write_text(robots_content, encoding="utf-8")
        return True
    except Exception as e:
        print(f"❌ 生成 robots.txt 失败: {e}")
        return False


def extract_post_metadata(item: Path, index_file: Path) -> tuple[str, str, datetime | None]:
    """
    从文章目录和 index.typ 文件中提取文章的元数据信息。
    
    功能:
        按优先级顺序提取文章元数据：
        1. 标题 (title): 从 index.typ 的 title 字段或一级标题提取，默认使用目录名
        2. 描述 (description): 从 index.typ 的 description 字段提取
        3. 日期 (date): 依次尝试从以下来源获取：
           - index.typ 中的 date: datetime(...) 语法
           - 文件夹名中的 YYYY-MM-DD 格式日期
           - 文件的修改时间戳
    
    参数:
        item (Path): 文章所在的目录路径
        index_file (Path): 文章的 index.typ 文件路径
    
    返回:
        tuple[str, str, datetime | None]: 包含三个元素的元组：
            - str: 文章标题
            - str: 文章描述（可能为空字符串）
            - datetime | None: 文章日期（带 UTC 时区），无法获取时为 None
    """
    title = item.name
    description = ""
    date_obj = None

    if index_file.exists():
        try:
            content = index_file.read_text(encoding="utf-8")
            # 预处理：移除注释
            content_clean = re.sub(r'/\*[\s\S]*?\*/', '', content)
            content_clean = re.sub(r'//.*', '', content_clean)
            
            # 1. 尝试解析 date: datetime(...)
            date_block_match = re.search(
                r'date:\s*datetime\s*\((?P<inner>[^)]+)\)', 
                content_clean, 
                re.IGNORECASE | re.DOTALL
            )

            if date_block_match:
                inner_content = date_block_match.group("inner")
                y = re.search(r'year:\s*(\d{4})', inner_content)
                m = re.search(r'month:\s*(\d{1,2})', inner_content)
                d = re.search(r'day:\s*(\d{1,2})', inner_content)
                
                # 也支持位置参数 datetime(2024, 10, 30)
                pos_match = re.search(r'(\d{4}),\s*(\d{1,2}),\s*(\d{1,2})', inner_content)
                
                if y and m and d:
                    date_obj = datetime(int(y.group(1)), int(m.group(1)), int(d.group(1)), tzinfo=timezone.utc)
                elif pos_match:
                    date_obj = datetime(int(pos_match.group(1)), int(pos_match.group(2)), int(pos_match.group(3)), tzinfo=timezone.utc)
            
            # 2. 匹配 title: "..." 或一级标题
            if title_match := re.search(r'title:\s*"((?:\\.|[^"\\])*)"', content_clean):
                title = title_match.group(1).replace('\\"', '"').replace('\\\\', '\\').strip()
            elif head_match := re.search(r"^=\s+(.+)$", content_clean, re.MULTILINE):
                title = head_match.group(1).strip()
            
            # 3. 匹配 description: "..."
            if desc_match := re.search(r'description:\s*"((?:\\.|[^"\\])*)"', content_clean):
                description = desc_match.group(1).replace('\\"', '"').replace('\\\\', '\\').strip()
        except Exception as e:
            print(f"⚠️ 警告: 解析 {index_file} 时出错: {e}")

    # 4. 如果没找到日期，尝试从文件夹名提取 (YYYY-MM-DD)
    if not date_obj:
        date_match = re.search(r"(\d{4}-\d{2}-\d{2})", item.name)
        if date_match:
            try:
                date_obj = datetime.strptime(date_match.group(1), "%Y-%m-%d").replace(tzinfo=timezone.utc)
            except ValueError:
                pass

    # 5. 最后保底：使用文件修改时间
    if not date_obj:
        try:
            # 优先使用 index.typ，如果没找到则使用文件夹
            target_path = index_file if index_file.exists() else item
            date_obj = datetime.fromtimestamp(target_path.stat().st_mtime, tz=timezone.utc)
        except Exception:
            pass

    return title, description, date_obj


def collect_posts(categories: list[str]) -> list[dict]:
    """
    从指定的分类目录中收集所有文章的元数据。
    
    功能:
        遍历指定分类目录下的所有子目录，提取每个文章的元数据信息。
        只处理目录（每个目录代表一篇文章），跳过普通文件。
        如果无法确定文章日期，则跳过该文章并输出警告。
    
    参数:
        categories (list[str]): 要扫描的分类目录名称列表（如 ["Blog", "Docs"]）
    
    返回:
        list[dict]: 文章数据字典列表，每个字典包含以下键：
            - title (str): 文章标题
            - description (str): 文章描述
            - category (str): 文章所属分类
            - link (str): 文章的完整 URL
            - date (datetime): 文章日期对象（带时区）
    """
    BASE_URL = get_site_url()
    posts = []

    for cat in categories:
        cat_dir = CONTENT_DIR / cat
        if not cat_dir.exists():
            continue

        for item in cat_dir.iterdir():
            if not item.is_dir():
                continue

            index_file = item / "index.typ"
            title, description, date_obj = extract_post_metadata(item, index_file)

            if not date_obj:
                print(f"⚠️ 无法确定文章 '{item.name}' 的日期，已跳过。")
                continue

            relative_link = f"/{cat}/{item.name}/"
            full_link = f"{BASE_URL}{relative_link}"

            posts.append({
                "title": title,
                "description": description,
                "category": cat,
                "link": full_link,
                "date": date_obj,
            })

    return posts


def build_rss_xml(posts: list[dict], config: dict, lang: str) -> str:
    """
    构建符合 RSS 2.0 规范的 XML 内容字符串。
    
    功能:
        使用 feedgen 库根据文章数据和站点配置生成完整的 RSS Feed XML。
        按日期降序排序文章，使用 feedgen 的 API 自动处理 XML 转义和格式化。
        支持条件输出 description 标签（仅在有描述时输出）。
    
    参数:
        posts (list[dict]): 文章数据列表，每个字典应包含:
            - title: 标题
            - description: 描述（可选）
            - link: 文章链接
            - date: datetime 对象
            - category: 分类名称
        config (dict): 站点配置字典，应包含:
            - base_url: 站点根 URL
            - site_title: 站点标题
            - site_description: 站点描述
            - rss_filename: RSS 文件名
        lang (str): 语言代码（如 "zh", "en"）
    
    返回:
        str: 完整的 RSS 2.0 XML 字符串，包含 XML 声明和所有必要的命名空间。
    """
    BASE_URL = config["base_url"]
    site_title = config["site_title"]
    site_description = config["site_description"]
    rss_file_name = config["rss_filename"]
    
    # 创建 FeedGenerator 对象
    fg = FeedGenerator()
    fg.id(BASE_URL)
    fg.title(site_title)
    fg.link(href=BASE_URL, rel='alternate')
    fg.description(site_description)
    fg.language(lang)
    
    # 添加自链接（RSS Feed 自身的链接）
    rss_url = f"{BASE_URL}/{rss_file_name}"
    fg.link(href=rss_url, rel='self', type='application/rss+xml')
    
    # 添加文章条目
    for post in posts:
        fe = fg.add_entry()
        fe.id(post["link"])
        fe.title(post["title"])
        fe.link(href=post["link"])
        fe.published(post["date"])
        
        # 仅在有描述时添加
        if post["description"]:
            fe.description(post["description"])
        
        # 添加分类信息
        fe.category(term=post["category"])
    
    # 生成 RSS 2.0 格式的 XML 字符串
    rss_content = fg.rss_str(pretty=True).decode('utf-8')
    
    return rss_content


def generate_rss() -> bool:
    """
    生成网站的 RSS 订阅源文件。
    
    功能:
        完整的 RSS Feed 生成流程：
        1. 检查 site-url 配置（必需）
        2. 从 config.typ 读取 Feed 配置（文件名、限制数量、分类）
        3. 收集指定分类下的所有文章元数据
        4. 按日期排序并限制输出数量（如果配置了 limit）
        5. 构建 RSS XML 并写入文件
    
    返回:
        bool: 生成是否成功。在以下情况返回 True：
            - 成功生成 RSS 文件
            - 未配置 site-url（跳过生成）
            - 未找到任何分类目录（跳过生成）
            - 未找到任何文章（生成空 Feed）
          仅在发生异常时返回 False。
    """
    BASE_URL = get_site_url()
    if not BASE_URL:
        print("⚠️ 跳过 RSS 订阅源生成: config.typ 中未配置 'site-url'。")
        return True
    
    feed_config = get_feed_config()
    categories = feed_config["categories"]
    rss_file_name = feed_config["filename"]
    RSS_FILE = SITE_DIR / rss_file_name
    
    if not categories:
        print("⚠️ 跳过 RSS 订阅源生成: 未配置任何分类目录。")
        return True

    # 检查是否至少有一个目录存在
    if not any((CONTENT_DIR / cat).exists() for cat in categories):
        print("⚠️ 跳过 RSS 订阅源生成: 配置的分类目录都不存在。")
        return True

    print("正在生成 RSS 订阅源...")
    
    # 收集文章
    posts = collect_posts(categories)
    
    if not posts:
        print("⚠️ 未找到任何文章，RSS 订阅源为空。")
        return True

    # 按日期降序排序
    posts = sorted(posts, key=lambda x: x["date"], reverse=True)

    # 限制输出文章数量
    if feed_config["limit"]:
        posts = posts[:feed_config["limit"]]

    # 获取配置信息
    lang = get_site_language()
    site_title = get_site_title()
    site_description = get_site_description()
    
    config = {
        "base_url": BASE_URL,
        "site_title": site_title,
        "site_description": site_description,
        "rss_filename": rss_file_name,
    }
    
    # 构建 RSS XML
    try:
        rss_content = build_rss_xml(posts, config, lang)
        RSS_FILE.write_text(rss_content, encoding="utf-8")
        print(f"  ✅ RSS 订阅源生成成功: {RSS_FILE} ({len(posts)} 篇文章)")
        return True
    except ValueError as e:
        print(f"❌ 错误: RSS 订阅源生成失败")
        print(f"   原因: feedgen 库报错 - {e}")
        print("   解决: 请检查 config.typ 中的必需配置字段（title 和 description）")
        return False
    except Exception as e:
        print(f"❌ 错误: 生成 RSS 订阅源时出错")
        print(f"   异常: {type(e).__name__}: {e}")
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
    results.append(generate_sitemap())
    results.append(generate_robots_txt())
    results.append(generate_rss())

    print("-" * 60)
    if all(results):
        print("✅ 所有构建任务完成！")
        print(f"  📂 输出目录: {SITE_DIR.absolute()}")
    else:
        print("⚠ 构建完成，但有部分任务失败。")
    print("-" * 60)

    return all(results)


# ============================================================================
# 命令行接口
# ============================================================================


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

    subparsers = parser.add_subparsers(dest="command", title="可用命令", metavar="<command>")

    build_parser = subparsers.add_parser("build", help="完整构建 (HTML + PDF + 资源)")
    build_parser.add_argument("-f", "--force", action="store_true", help="强制完整重建")

    html_parser = subparsers.add_parser("html", help="仅构建 HTML 文件")
    html_parser.add_argument("-f", "--force", action="store_true", help="强制完整重建")

    pdf_parser = subparsers.add_parser("pdf", help="仅构建 PDF 文件")
    pdf_parser.add_argument("-f", "--force", action="store_true", help="强制完整重建")

    subparsers.add_parser("assets", help="仅复制静态资源")
    subparsers.add_parser("clean", help="清理生成的文件")

    preview_parser = subparsers.add_parser("preview", help="启动本地预览服务器")
    preview_parser.add_argument(
        "-p", "--port", type=int, default=8000, help="服务器端口号（默认: 8000）"
    )
    preview_parser.add_argument(
        "--no-open", action="store_false", dest="open_browser", help="不自动打开浏览器"
    )
    preview_parser.set_defaults(open_browser=True)

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

    # 获取 force 参数
    force = getattr(args, "force", False)

    # 使用 match-case 执行对应的命令
    match args.command:
        case "build":
            success = build(force)
        case "html":
            SITE_DIR.mkdir(parents=True, exist_ok=True)
            success = build_html(force)
        case "pdf":
            SITE_DIR.mkdir(parents=True, exist_ok=True)
            success = build_pdf(force)
        case "assets":
            SITE_DIR.mkdir(parents=True, exist_ok=True)
            success = copy_assets()
        case "clean":
            success = clean()
        case "preview":
            success = preview(getattr(args, "port", 8000), getattr(args, "open_browser", True))
        case _:
            print(f"❌ 未知命令: {args.command}")
            success = False

    sys.exit(0 if success else 1)
