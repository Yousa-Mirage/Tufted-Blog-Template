# Tufted Blog Template

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/Yousa-Mirage/Tufted-Blog-Template?style=social)](https://github.com/Yousa-Mirage/Tufted-Blog-Template/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Yousa-Mirage/Tufted-Blog-Template)
[![Typst](https://img.shields.io/badge/typst-239DAD.svg?&logo=typst&logoColor=white)](https://typst.app/)

[简体中文](README.md) | [English](README_en.md)

</div>

This is a static website building template based on [Typst](https://typst.app/) and [Tufted](https://github.com/vsheg/tufted), providing step-by-step guidance to build a clean and beautiful personal website, blog, and resume.

If you want to quickly experience the website style, you can visit [Demo Website](https://tufted-blog.pages.dev/).
Update log available at [Changelog](CHANGELOG_en.md) .

![Tufted website](content/imgs/devices.webp)

> If you are a complete beginner, you may encounter some new concepts and might be using the terminal and command line for the first time. Don't be afraid, this project requires no prior knowledge and is very beginner-friendly.  
> When you encounter unfamiliar concepts or operations, read the documentation, ask AI, and search online.  
> If you encounter any issues, you can: check the [Wiki Documentation](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki), ask questions and discuss in [Discussions](https://github.com/Yousa-Mirage/Tufted-Blog-Template/discussions), or submit feedback in [Issues](https://github.com/Yousa-Mirage/Tufted-Blog-Template/issues).

## ✨ Features

- 🚀 Write content using Typst, simple and powerful, with extremely fast compilation
- 🎨 Design based on Tufte CSS, minimalist and content-first, providing a clear and immersive reading experience
- 📦 Built-in cross-platform build script based on Python, supporting incremental compilation
- 📝 Support for generating both HTML pages and PDF documents, with support for linking to PDFs
- 🌐 Built-in GitHub Actions workflow for one-click website deployment
- 🌙 Support light/dark mode automatic selection and one-click switching
- 🕒 Support article publication/update dates with optional geo-aware local time and place display
- 🔁 Built-in `run.sh` local workflow for initial build, preview, dependency hints, and automatic rebuilds
- 📄 Rich examples and documentation, no prior knowledge required, start writing after [learning Typst basics](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/Typst-%E5%BF%AB%E9%80%9F%E5%85%A5%E9%97%A8%E8%B5%84%E6%96%99)

## 📦 Environment Setup (One-time Only)

This project only depends on Typst and Python (using uv for Python is recommended). Typst is used to compile web pages, and the Python script is used to automate the build process.

### 0. Prerequisites

To enable version control, automated builds, and a better writing experience, it's recommended to prepare the following:

- Have a GitHub account
- Understand what a terminal is and be able to run commands in the terminal (see [Wiki page](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/%E7%BB%88%E7%AB%AF%E4%B8%8E%E5%B7%A5%E4%BD%9C%E8%B7%AF%E5%BE%84))
- Install Git for code management and remote pushing (see [Wiki page](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/Git-%E5%85%A5%E9%97%A8%E6%8C%87%E5%8D%97))
- Use [VS Code](https://code.visualstudio.com/) or your preferred code editor, and install the [Tinymist](https://github.com/Myriad-Dreamin/tinymist) plugin for Typst language support (see [Wiki page](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/Typst-%E5%BF%AB%E9%80%9F%E5%85%A5%E9%97%A8%E8%B5%84%E6%96%99))

### 1. Install Typst

> If your system already has Typst CLI installed, you can skip this step.

[Typst](https://typst.app/) is an emerging modern markup language typesetting system designed to be a modern alternative to LaTeX, while being simpler to learn, faster to compile, and more user-friendly. This project uses Typst's experimental HTML export feature to compile `.typ` plain text source files into web pages.

- **Method 1: Download the executable directly from the [Typst download page](https://typst.app/open-source/#download).** You need to download the archive and extract it to a folder that is in your `PATH` environment variable.
  - Windows users (**recommended**) can extract it to a path of your choice, then add that path to the `PATH` environment variable, see [Wiki page](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/PATH-%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F) for details.
  - macOS / Linux users can extract it to `/usr/local/bin` or another directory already added to `PATH`, see [Wiki page](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/PATH-%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F) for details.
- **Method 2: Install using a package manager.**
  - Windows:
    - Using winget: `winget install typst`
    - Using Scoop: `scoop install typst`
    - Using Chocolatey: `choco install typst`
  - macOS (**recommended**):
    - Using Homebrew: `brew install typst`
  - Linux: Use your usual package manager to install (**recommended**).

After installation, open a terminal and run `typst --version`. If it displays the version number, the installation was successful.

### 2. Install Python

> If your system already has Python >= 3.6 installed, you can skip this step.

This project uses a Python script `build.py` to automate the build process. Theoretically, you only need to have Python installed to run it, but to avoid various Python environment issues, it's recommended to use [**uv**](https://docs.astral.sh/uv/) to run the script. uv is an extremely fast Python package and project manager that simplifies Python installation, dependency management, and script execution.

You can install uv following the instructions below:

- Windows: Open a terminal and run the following command:

    ```bash
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    ```

- macOS/Linux: Open a terminal and run the following command:

    ```bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ```

- Or use other methods mentioned in the [official documentation](https://docs.astral.sh/uv/getting-started/installation).

After installation, you can run `uv --version` in the terminal to verify the installation was successful. Once uv is installed, you no longer need to manually install Python or worry about environment issues—uv will handle everything.

## 🚀 Quick Start

The entire template workflow is as follows:

```plaintext
Create your GitHub repository using this template
  ↓
Clone your repository locally
  ↓
Modify .typ files
  ↓
Run build.py
  ↓
Local preview
  ↓
When satisfied, git push to your GitHub repository
  ↓
GitHub Actions automatically deploys
  ↓
Visit username.github.io
```

### 1. Clone the Project

1. Click the green button [Use this template] -> Create a new repository in the upper right corner of this page to copy this template to your own repository, **and (very important) name the repository `<your-github-username>.github.io`**.
2. Clone your own repository code to your computer. First, you need to choose a folder as your working directory, then open a terminal **in that path** and run the following command (replace `<your-github-username>` with your GitHub username):

```bash
git clone https://github.com/<your-github-username>/<your-github-username>.github.io.git
```

For example, if I want to store the website project in the `D:\My-Website\` directory, first navigate to `D:\`, open a terminal in that path, and then run:

```bash
git clone https://github.com/Yousa-Mirage/Yousa-Mirage.github.io.git
```

This will create the `D:\Yousa-Mirage.github.io\` folder and download the project files to that directory. You can then rename the folder to your preferred name, such as `D:\My-Website\`. This will be our local website project directory going forward, where we'll edit documents, run build scripts, and interact with the GitHub remote repository.

### 2. Build the Website

Navigate to your website project directory, open a terminal **in the current path**, and run the following command:

```bash
uv run build.py build
```

If you don't have uv installed, you can run the script directly with Python:

```bash
python build.py build
```

This command will compile the `.typ` files in `content/` to HTML files and output them to the `_site/` directory. The `_site/` directory is what your website looks like locally. After modifying files, run this command again for **incremental compilation**.

### 3. Local Preview

> The HTTP server will occupy the current terminal window, so it's recommended to open a new terminal window in that path to run the preview command.
>
> 💡 **Quick workflow tip**: You can run `uv run build.py preview` in one terminal and then run `uv run build.py build` in another terminal to compile your changes. The web page will automatically refresh, allowing for real-time preview without the need to repeatedly run the `preview` command to restart the server.

You can run the following command to start a local preview server:

```bash
uv run build.py preview

# Or run directly with Python
python build.py preview
```

On macOS and Linux, you can also use the helper script:

```bash
./run.sh
./run.sh -p 3000
```

`run.sh` checks for required tools and prints installation commands when something is missing. It does not install anything automatically. After the initial build, it starts the preview server and watches `content/`, `tufted-lib/`, `assets/`, and `config.typ`; saving a source file triggers an incremental rebuild.

<details>
<summary>Preview Command Explanation</summary>

`preview` will first try to run `uvx livereload _site`. This command uses uv to run a tool called livereload, which uses the `_site/` directory as the website root and starts an HTTP live server on local port 8000. If you don't have uv installed, it will fall back to using Python's built-in HTTP server: `python -m http.server 8000 --directory _site`.

The preview server uses port `8000` by default, but you can specify a different port using the `-p/--port` parameter, for example:

```bash
uv run build.py preview -p 12345
```

</details>

The browser should open automatically, or you can manually open a browser and visit `http://localhost:8000` to view the default web page. I've written more documentation and example content in the default web page (i.e., the content in `content/`), which you can explore and modify on your own.

The local website content you see should be identical to the [Demo Website](https://little-yousa-mirage.github.io/).

You can refer to the content and resources on the [Wiki page](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/Typst-%E5%BF%AB%E9%80%9F%E5%85%A5%E9%97%A8%E8%B5%84%E6%96%99) to learn about Typst.

### 4. Write Web Pages with Typst and Deploy the Website

After understanding the web page structure and how to write, you can replace the content in `content/` with your own content to build your own website.

1. **Modify Configuration**: Edit `config.typ` to set the website title and navigation bar. You can also place a `favicon.ico` file in `assets/` as your website's tab icon.
2. **Add Articles**: Create new `.typ` files in `content/`. You can refer to the current `content/` for examples.
   To display article dates, pass ISO 8601 strings to the page template:

    ```typst
    #show: template.with(
      title: "My Article",
      date: "2026-05-06T21:00:00+08:00",
      date_geo: "31.8206,117.2272",
      updated: auto,
      updated_geo: "31.8206,117.2272",
    )
    ```

   `date_geo` and `updated_geo` are optional `"lat,lng"` coordinates. When present, the browser formats the time for that location and tries to show a place name; if the network lookup fails, the page keeps the date-only fallback.
3. **Generate PDFs**: If the filename contains `PDF` (e.g., `CV-PDF.typ`), the build script will automatically compile it into a PDF file, and you can add links in the web page pointing to that PDF.
4. **Deploy Website**: Configure Pages in your GitHub repository, push the modified content to GitHub, and GitHub Actions will automatically build, deploy, and update the website. For details, see the [Wiki page](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/GitHub-Pages-%E9%83%A8%E7%BD%B2%E7%BD%91%E7%AB%99).

### 5. Project Updates

This template provides an `Update` GitHub Actions workflow for importing feature updates from the upstream template repository (which is this repository). For details, please refer to the [Wiki page](https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/更新项目).

## 📂 Project Structure

```plaintext
Tufted-Blog-Template/
├── .github/workflows      # GitHub Actions for automated build and deployment
├── _site/                 # Build output directory (auto-generated)
├── assets/                # Static resources (CSS, JS, fonts, icons, etc.)
│   ├── tufted.css             # Main stylesheet
│   ├── custom.css             # Custom stylesheet (user-editable)
│   ├── code-blocks.js         # Code line numbers and copy functionality
│   ├── date-location.js       # Article date and optional location display
│   └── format-headings.js     # Heading formatting
├── content/               # Website content source files (.typ)
│   ├── index.typ              # Website homepage
│   ├── Blog/                  # Blog pages
│   ├── CV/                    # Resume pages
│   ├── Docs/                  # Documentation pages
│   └── .../                   # Add or modify other pages as needed
├── tufted-lib/            # Typst style library and feature modules
│   ├── tufted.typ             # Main template and configuration
│   ├── layout.typ             # Page layout definitions
│   ├── math.typ               # Mathematics formula handling
│   ├── date.typ               # Article date display helpers
│   ├── figures.typ            # Image and chart handling
│   ├── refs.typ               # Reference and bibliography handling
│   └── notes.typ              # Footnotes and margin notes handling
├── build.py               # Python build script
└── config.typ             # Website global configuration
```

## 🔗 Notes

This template is based on the Typst package [Tufted](https://github.com/vsheg/tufted) developed by [Vsevolod Shegolev](http://vsheg.com/), with some style and functionality modifications to better support Chinese content, including:

- Modified some text styles to adapt to Chinese typesetting conventions
- Fine-tuned a large number of style details, enhanced dark mode, and optimized the display effects of various elements
- Optimized code block styles, added line numbers and copy functionality
- Added Python build script for cross-platform build support
- Added PDF build support, allowing compilation of PDF documents and linking to web pages
- Added website favicon support
- Added detailed usage instructions and code comments to help users quickly develop

This template project is open source under the [MIT License](https://github.com/Yousa-Mirage/Tufted-Blog-Template/blob/main/LICENSE).

Related links:

- [Tufted Typst on GitHub](https://github.com/vsheg/tufted)
- [Typst Universe](https://typst.app/universe/package/tufted)
- [Tufte CSS](https://edwardtufte.github.io/tufte-css/)
- [tufted.vsheg.com](https://tufted.vsheg.com) — Online demo website and simple documentation provided by the Tufted package author
