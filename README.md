# Tufted Blog Template

这是一个基于 [Typst](https://typst.app/) 和 [Tufted](https://github.com/vsheg/tufted) 的静态网站构建模板，手把手教你搭建简洁、美观的个人博客、作品集和简历设计。

![Tufted website](content/imgs/devices.webp)

## ✨ 特点

- 🚀 使用 Typst 编写内容，语法简洁，功能强大，编译极快
- 🎨 基于 Tufte CSS 设计，极简主义、内容至上，提供清晰、沉浸的深度阅读体验
- 📦 内置构建脚本，新手友好，支持跨平台
- 📝 支持生成 HTML 网页和 PDF 文档，支持链接到 PDF
- 🌐 内置 GitHub Pages 部署支持，一键发布网站

## 📦 依赖安装（仅需一次）

> 如果你是纯小白用户，这部分可能会涉及到很多你从未接触到的新概念，放心，都不难理解。  
> 甚至可能会第一次接触到终端和命令行，不要害怕，它们只是和计算机交流的一种方式。  
> 遇到不懂的概念或不会的操作，多问 AI 多搜索。

本项目只依赖 Typst 和 Python 环境（推荐使用 uv 工具）。Typst 用于将 `.typ` 文件编译为 HTML 和 PDF，Python 脚本用于自动化构建流程。

### 1. 安装 Typst

Typst 是一种用于排版文档的标记语言，Typst 编译器读取并解释带有标记的 `.typ` 文本文件，将这些文本文件编译为 PDF/HTML 文档。本项目基于 Typst 实验性的 HTML 导出功能构建网页。我们要下载的便是 Typst 编译器。

- **方法 1（推荐）：从 [Typst 下载页面](https://typst.app/open-source/#download)直接下载可执行程序。** 你需要下载压缩文件，并将其解压到一个位于 `PATH` 环境变量中的文件夹中。
    - Windows 用户可将其解压到 `D:\typst\` 或你喜欢的其他路径，然后将该路径添加到 `PATH` 环境变量中，具体操作可询问 AI。
    - macOS / Linux 用户可将其解压到 `/usr/local/bin` 或其他已添加到 `PATH` 的目录中，具体操作可询问 AI。
- **方法 2：使用包管理器安装。**
    - Windows：
        - 使用 winget：`winget install typst`
        - 使用 Scoop：`scoop install typst`
        - 使用 Chocolatey：`choco install typst`
    - macOS：
        - 使用 Homebrew：`brew install typst`
    - Linux 使用你常用的包管理器安装。

完成后打开终端，输入并运行 `typst --version`，如果显示版本号则表示安装成功。

### 2. 安装 uv

> 如果你的系统已经安装 Python，也可以跳过这一步不安装 uv。

本项目使用一个 Python 脚本 `build.py` 来自动化构建流程。理论上只需要安装有 Python 就可以运行，不过为了最大程度简化环境依赖问题，推荐使用 [**uv**](https://docs.astral.sh/uv/) 来运行脚本。uv 是一个速度极快的 Python 包和项目管理器，可以简化 Python 安装、环境依赖管理和脚本运行。

你可以按照下面的说明安装 uv：

- Windows：打开终端，运行以下命令：
    ```bash
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    ```
- macOS/Linux：打开终端，运行以下命令：
    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```
- 或使用[官方文档](https://docs.astral.sh/uv/getting-started/installation)提到的其他方法。

安装完成后，你可以在终端中运行 `uv --version` 来验证安装是否成功。一旦 uv 安装成功，你不再需要手动安装 Python、操心版本和环境问题，uv 会搞定一切。

### 额外项目

为了进行版本管理、自动构建和拥有更好的编写体验，建议你自行设置这些项目：

- 拥有一个 GitHub 账号，从而使用 GitHub Pages 进行免费网站部署
- 安装 Git 进行版本管理，以及将项目推送到 GitHub 仓库以运行自动构建和部署
- 使用 [VS Code](https://code.visualstudio.com/) 或其他你喜欢的代码编辑器，并安装 [Tinymist](https://github.com/Myriad-Dreamin/tinymist) 插件以获得 Typst 语言支持

## 🚀 快速开始

### 1. 克隆项目

1. 点击本页面右上角的绿色按钮 [Use this template] -> Create a new repository，将这个模板复制到你自己的 GitHub 账号下的仓库中，将仓库命名为 `<your-github-username>.github.io`。
2. 然后将代码克隆到你的电脑上。首先你需要选择一个文件夹作为你的工作目录，然后**在该路径下打开终端**，运行以下命令（将 `<your-github-username>` 替换为你的 GitHub 用户名）：

  ```bash
  git clone https://github.com/<your-github-username>/<your-github-username>.github.io.git
  ```

例如，如果我想要在 `D:\My-Website\` 目录下存放网站项目，则首先进入 `D:\`，在该路径下打开终端，然后运行：

```bash
git clone https://github.com/Yousa-Mirage/Yousa-Mirage.github.io.git
```

这会创建 `D:\Yousa-Mirage.github.io\` 文件夹，并将项目文件下载到该目录下。接下来你可以重命名该文件夹为你喜欢的名字，例如 `D:\My-Website\`。这就是我们以后的本地网站项目目录，我们将在其中编辑文档、运行构建脚本、与 GitHub 远程仓库相联系。

### 2. 构建网站

进入你的网站项目目录，在终端中运行以下命令：

```bash
uv run build.py build
```

如果你没有安装 uv，也可以直接使用 Python 运行脚本：

```bash
python build.py build
```

如果你安装了 `make`，也可以运行以下命令（只在 macOS/Linux 上工作）：

```bash
make build
```

此命令会将 `content/` 下的 `.typ` 文件对应编译为 HTML 文件，并输出到 `_site/` 目录。`_site/` 目录就是你的网站在本地的样子。在你完成修改后，每次运行该命令即可重新构建网站。

### 3. 本地预览

如果你安装了 uv，你可以运行以下命令启动本地预览服务器（这个命令使用 uv 运行了一个叫做 livereload 的工具，livereload 将 `_site/` 目录作为网站根目录，并在本地的 8000 端口启动 HTTP 实时服务器）：

```bash
uvx livereload _site -p 8000
```

如果你没有安装 uv，也可以使用 Python 自带的 HTTP 服务器。在终端中运行以下命令：

```bash
python -m http.server 8000 --directory _site
```

现在你可以打开浏览器，访问 `http://localhost:8000` 来查看你的网站。

### 4. 使用 Typst 编写网页与部署网站

1.  **修改配置**：编辑 `config.typ` 设置网站标题和导航栏。
2.  **添加文章**：在 `content/**/` 下创建新的 `.typ` 文件。
3.  **生成 PDF**：如果文件名包含 `PDF` (如 `CV-PDF.typ`)，构建脚本会自动将其编译为 PDF 文件，此时你可以在网页中添加链接指向该 PDF。
4.  **部署网站**：在你的 GitHub 仓库中配置好 Pages，将修改后的内容推送到 GitHub，GitHub Actions 会自动构建、部署、更新网站。

默认 `content/` 中包含进一步的文档说明和示例页面，你可以自行探索和修改。推荐在启动本地预览后，一边阅读网页一边对照生成该网页的 `.typ` 源代码，从而更好地了解 Typst 文本内容和如何编写你自己的网站。

在了解网页结构和如何编写后，你就可以将 `content/` 中的内容替换为你自己的内容，从而搭建你自己的网站。

## 📂 项目结构

```
Tufted-Blog-Template/
├── .github/workflows     # GitHub Actions 自动构建、部署
├── _site/                # 构建输出目录 (自动生成)
├── assets/               # 静态资源 (CSS, JS, 字体等)
├── content/              # 网站内容源文件 (.typ)
│   ├── index.typ           # 网站首页
|   ├── About/              # 关于页
│   ├── Blog/               # 博客页
│   ├── CV/                 # 简历页
|   ├── Docs/               # 编写文档页
│   └── .../                # 可自行添加其他页面
├── build.py              # Python 构建脚本
├── config.typ            # 网站全局配置
└── Makefile              # Make 构建命令
```

## 🔗 说明

本模板基于 Vsevolod Shegolev 开发的 Typst 包 [Tufted](https://github.com/vsheg/tufted)，并进行了一些样式和功能修改以更好的支持中文内容，主要包括：

- 修改部分文本样式以适应中文排版习惯
- 优化代码块样式，增加行号和复制功能
- 增加 Python 构建脚本，从而支持跨平台构建
- 增加 PDF 构建支持，允许编译 PDF 文档并链接到网页
- 增加网站标签页图标支持
- 添加了大量详细的使用说明和代码注释，帮助用户快速上手

本模板项目基于 [MIT License](https://github.com/Yousa-Mirage/Tufted-Blog-Template/blob/main/LICENSE) 开源。

相关链接：

- [Tufted Typst on GitHub](https://github.com/vsheg/tufted)
- [Typst Universe](https://typst.app/universe/package/tufted)
- [Tufte CSS](https://edwardtufte.github.io/tufte-css/) — used for styling, loaded automatically from a CDN
- [tufted.vsheg.com](https://tufted.vsheg.com) — live demo and simple docs