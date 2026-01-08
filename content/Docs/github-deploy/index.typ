#import "../index.typ": template, tufted
#show: template.with(title: "GitHub 网站部署")

= GitHub 网站部署

你已经能在本地预览网站了，现在是时候把它发布到互联网上，让所有人都能访问了！

我在模板中准备好了 `.github/workflows/deploy.yml`，你可以使用 GitHub Actions 轻松将网站部署到 GitHub Pages。你只需要：

1. 转到你的 GitHub 仓库；
2. 导航至 _Settings_，然后点击 _Pages_；
3. *在 _Build and deployment_ 下, 选择 _GitHub Actions_ 作为源。*

现在，每次你推送代码到 main 分支时，你的网站都会自动构建和部署。

阅读 #link("https://github.com/Yousa-Mirage/Tufted-Blog-Template/wiki/GitHub-Pages-%E9%83%A8%E7%BD%B2%E7%BD%91%E7%AB%99")[Wiki - GitHub Pages 部署网站] 以了解更多。
