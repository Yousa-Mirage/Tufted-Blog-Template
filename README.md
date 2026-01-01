# Tufted Blog Template

这是一个基于 [Typst](https://typst.app/) 和 [Tufted](https://github.com/vsheg/tufted) 的静态网站构建模板，手把手教你搭建简洁、美观的个人博客、作品集和简历设计。

![Tufted website](content/imgs/devices.webp)

> 如果你是纯萌新，可能会涉及到一些你从未接触到的新概念，甚至可能会第一次接触到终端和命令行，不要害怕，本项目不需要你有任何前置知识，很好上手。  
> 遇到不懂的概念或不会的操作，多看文档、多问 AI、多搜索。  
> 如果遇到任何问题，你可以：查看 [Wiki 文档](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki)、在 [Discussions](https://github.com/Yousa-Mirage/Tufted-Blog-Template/discussions) 中提问和讨论、在 [Issue](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues) 中提交反馈。

## ✨ 特点

- 🚀 使用 Typst 编写内容，简洁强大，编译极快
- 🎨 基于 Tufte CSS 设计，极简主义、内容至上，提供清晰、沉浸的阅读体验
- 📦 内置基于 Python 的跨平台构建脚本，支持增量编译
- 📝 支持生成 HTML 网页和 PDF 文档，支持链接到 PDF
- 🌐 内置 GitHub Actions 工作流，一键部署网站
- 📄 丰富的示例和文档，无需任何前置知识，简单学习 Typst 后即可开始编写

## 📦 环境准备（仅需一次）

本项目只依赖 Typst 和 Python 环境（推荐使用 uv 工具）。Typst 用于将 `.typ` 文件编译为 HTML 和 PDF，Python 脚本用于自动化构建流程。

### 0. 事前准备

为了进行版本管理、自动构建和拥有更好的编写体验，建议你自行准备这些项目：

- 了解什么是终端，能够在终端中运行命令（可参考 [Wiki 页](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/%E7%BB%88%E7%AB%AF%E4%B8%8E%E5%B7%A5%E4%BD%9C%E8%B7%AF%E5%BE%84)）
- 拥有一个 GitHub 账号，从而使用 GitHub Action 和 GitHub Pages 进行免费网站构建和部署，你将拥有一个免费的 `<your-github-username>.github.io` 域名作为你的网站地址
- 安装 Git 进行版本管理，以及将项目推送到 GitHub 仓库以运行自动构建和部署
- 使用 [VS Code](https://code.visualstudio.com/) 或其他你喜欢的代码编辑器，并安装 [Tinymist](https://github.com/Myriad-Dreamin/tinymist) 插件以获得 Typst 语言支持

### 1. 安装 Typst

> 如果你的系统已经安装 Typst CLI，可以跳过这一步。

Typst 是一种用于排版文档的标记语言，Typst 编译器读取带有标记的 `.typ` 文本文件，将这些文本文件编译为 PDF/HTML 文档。本项目基于 Typst 实验性的 HTML 导出功能构建网页。

我们要下载的便是 Typst 编译器。

- **方法 1：从 [Typst 下载页面](https://typst.app/open-source/#download)直接下载可执行程序。** 你需要下载压缩包，并将其解压到一个位于 `PATH` 环境变量中的文件夹中。
    - Windows 用户 (**推荐**) 可将其解压你喜欢的路径，然后将该路径添加到 `PATH` 环境变量中，具体操作可见 [Wiki 页](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/PATH-%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F)。
    - macOS / Linux 用户可将其解压到 `/usr/local/bin` 或其他已添加到 `PATH` 的目录中，具体操作可见 [Wiki 页](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/PATH-%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F)。
- **方法 2：使用包管理器安装。**
    - Windows：
        - 使用 winget：`winget install typst`
        - 使用 Scoop：`scoop install typst`
        - 使用 Chocolatey：`choco install typst`
    - macOS (**推荐**)：
        - 使用 Homebrew：`brew install typst`
    - Linux 使用你常用的包管理器安装 (**推荐**)。

完成后打开终端，输入并运行 `typst --version`，如果显示版本号则表示安装成功。

### 2. 安装 Python

> 如果你的系统已经安装 Python >= 3.6，也可以跳过这一步。

本项目使用一个 Python 脚本 `build.py` 来自动化构建流程。理论上只需要安装有 Python 就可以运行，不过为了避免各种 Python 环境问题，推荐使用 [**uv**](https://docs.astral.sh/uv/) 来运行脚本。uv 是一个速度极快的 Python 包和项目管理器，可以简化 Python 安装、环境依赖管理和脚本运行。

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

安装完成后，你可以在终端中运行 `uv --version` 来验证安装是否成功。一旦 uv 安装成功，你不再需要手动安装 Python、操心环境问题，uv 会搞定一切。

## 🚀 快速开始

整个模板工作流程如下所示：

```plaintext
使用本模板创建你的 GitHub 仓库 
  ↓
将你的仓库克隆到本地
  ↓
修改 .typ 文件
  ↓
运行 build.py
  ↓
本地预览（preview）
  ↓
满意后 git push 到你的 GitHub 仓库
  ↓
GitHub Actions 自动部署
  ↓
访问 username.github.io
```

### 0. 快速体验

我的个人网站 [Yousa-Mirage.github.io](https://yousa-mirage.github.io) 就是使用本模板搭建的<sub>（准确说本模板是从我的个人网站抽取出来的）</sub>。如果你只是想快速体验一下效果，可以直接访问我的网站。

### 1. 克隆项目

1. 点击本页面右上角的绿色按钮 [Use this template] -> Create a new repository，将这个模板复制到你自己的仓库中，**将仓库命名为 `<your-github-username>.github.io`**。
2. 然后将代码克隆到你的电脑上。首先你需要选择一个文件夹作为你的工作目录，然后**在该路径下**打开终端，运行以下命令（将 `<your-github-username>` 替换为你的 GitHub 用户名）：

```bash
git clone https://github.com/<your-github-username>/<your-github-username>.github.io.git
```

例如，如果我想要在 `D:\My-Website\` 目录下存放网站项目，则首先进入 `D:\`，在该路径下打开终端，然后运行：

```bash
git clone https://github.com/Yousa-Mirage/Yousa-Mirage.github.io.git
```

这会创建 `D:\Yousa-Mirage.github.io\` 文件夹，并将项目文件下载到该目录下。接下来你可以重命名该文件夹为你喜欢的名字，例如 `D:\My-Website\`。这就是我们以后的本地网站项目目录，我们将在其中编辑文档、运行构建脚本、与 GitHub 远程仓库相联系。

### 2. 构建网站

进入你的网站项目目录，**在当前路径下**打开终端并运行以下命令：

```bash
uv run build.py build
```

如果你没有安装 uv，也可以直接使用 Python 运行脚本：

```bash
python build.py build
```

如果你使用 macOS/Linux 并且安装了 `make`，也可以运行以下命令：

```bash
make build  # 只适用于 macOS/Linux
```

此命令会将 `content/` 下的 `.typ` 文件对应编译为 HTML 文件，并输出到 `_site/` 目录。`_site/` 目录就是你的网站在本地的样子。在你修改文件后，重新运行该命令即可**增量编译**。

### 3. 本地预览

> HTTP 服务器会占用当前终端窗口，因此推荐在该路径下打开一个新的终端窗口运行预览命令。

你可以运行以下命令启动本地预览服务器：

```bash
uv run build.py preview

# 或者直接使用 Python 运行
python build.py preview
```

<details>
<summary>预览命令说明</summary>

`preview` 会首先尝试运行 `uvx livereload _site`，这个命令使用 uv 运行了一个叫做 livereload 的工具，livereload 将 `_site/` 目录作为网站根目录，并在本地的 8000 端口启动 HTTP 实时服务器。如果你没有安装 uv，则会回退到使用 Python 内置的 HTTP 服务器：`python -m http.server 8000 --directory _site`。

预览服务器默认使用 `8000` 端口，你可以使用 `-p/--port` 参数指定其他端口，例如：

```bash
uv run build.py preview -p 12345
```

</details>

现在你可以打开浏览器，访问 `http://localhost:8000` 来查看默认网页。我在默认网页（即`content/` 中的内容）中编写了更多文档说明和示例内容，，你可以自行探索和修改。推荐在启动本地预览后，一边阅读网页文档，一边对照生成该页面的 `.typ` 源代码，从而更好地了解 `content/` 结构、Typst 内容以及如何编写你自己的网站。

### 4. 使用 Typst 编写网页与部署网站

在了解网页结构和如何编写后，你就可以将 `content/` 中的内容替换为你自己的内容，从而搭建你自己的网站。

1.  **修改配置**：编辑 `config.typ` 设置网站标题和导航栏，还可以在 `assets/` 下放置一个 `favicon.ico` 作为你网站的标签页图标。
2.  **添加文章**：在 `content/` 下创建新的 `.typ` 文件，可以参考目前的 `content/` 获得示例。
3.  **生成 PDF**：如果文件名中包含 `PDF` (如 `CV-PDF.typ`)，构建脚本会自动将其编译为 PDF 文件，此时你可以在网页中添加链接指向该 PDF。
4.  **部署网站**：在你的 GitHub 仓库中配置好 Pages，将修改后的内容推送到 GitHub，GitHub Actions 会自动构建、部署、更新网站。具体内容可参考 [Wiki 页](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/GitHub-Pages-%E9%83%A8%E7%BD%B2%E7%BD%91%E7%AB%99)。

## 📂 项目结构

```
Tufted-Blog-Template/
├── .github/workflows     # GitHub Actions 自动构建、部署
├── _site/                # 构建输出目录 (自动生成)
├── assets/               # 静态资源 (CSS, JS, 字体, 图标等)
├── content/              # 网站内容源文件 (.typ)
│   ├── index.typ             # 网站首页
|   ├── About/                # 关于页
│   ├── Blog/                 # 博客页
│   ├── CV/                   # 简历页
|   ├── Docs/                 # 编写文档页
│   └── .../                  # 可自行添加其他页面
├── build.py              # Python 构建脚本
├── config.typ            # 网站全局配置
└── Makefile              # Make 构建命令
```

## TODO 列表

- 优化公式前后的间距
- 参考文献直接显示在侧边栏
- 网页的交叉引用跳转
- 添加中英文页面切换功能

## 🔗 说明

本模板基于 Vsevolod Shegolev 开发的 Typst 包 [Tufted](https://github.com/vsheg/tufted)，并进行了一些样式和功能修改以更好的支持中文内容，主要包括：

- 修改部分文本样式以适应中文排版习惯
- 优化代码块样式，增加行号和复制功能
- 增加 Python 构建脚本，从而支持跨平台构建
- 增加 PDF 构建支持，允许编译 PDF 文档并链接到网页
- 增加了网站标签页图标支持
- 添加了详细的使用说明和代码注释，帮助用户快速开发

本模板项目基于 [MIT License](https://github.com/Yousa-Mirage/Tufted-Blog-Template/blob/main/LICENSE) 开源。

相关链接：

- [Tufted Typst on GitHub](https://github.com/vsheg/tufted)
- [Typst Universe](https://typst.app/universe/package/tufted)
- [Tufte CSS](https://edwardtufte.github.io/tufte-css/)
- [tufted.vsheg.com](https://tufted.vsheg.com) — Tufted 包作者提供的在线演示网站和简单文档
