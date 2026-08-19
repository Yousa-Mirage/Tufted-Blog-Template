#import "../index.typ": template, tufted

#show: template.with(
  title: "Blog",
  description: "技术学习、论文解读、项目实践与个人记录。",
)

// 可点击的系列标签。
#let tag(target, body) = link(target)[
  #html.span(class: "blog-tag", body)
]

// 尚无内容的占位标签。
#let tag-placeholder(body) = html.span(
  class: "blog-tag blog-tag-placeholder",
  body,
)

// 将同一主题的文章收纳在一张卡片中。tone 对应 custom.css 中的配色。
#let series-block(title: "", tone: "blue", body) = html.div(
  class: "series-card series-card-" + tone,
  {
    html.div(class: "series-card-title", [📂 #title])
    body
  },
)

= Blog

#quote[
  这里主要整理技术学习、论文阅读与项目实践。文章按主题归档，系列内按时间倒序排列；较私人的随笔与日常记录收在页面末尾的个人文件夹中。
]

// ==================== 技术学习 ====================
== 技术学习 <learning>

#html.div(class: "blog-tags", [
  #tag(<ml>, [⚙️ 机器学习])
  #tag(<transformer-architecture>, [🤖 Transformer 架构演进])
  #tag(<transformer-backprop>, [🔁 Transformer 反向传播])
  #tag(<generative-models>, [🧩 计算机视觉与生成模型])
  #tag(<math>, [📐 数学推导])
])

#series-block(title: "机器学习", tone: "blue")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 8, day: 6),
    path: "8-6",
    title: "机器学习｜无监督学习、推荐系统与强化学习",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 8, day: 5),
    path: "8-5",
    title: "机器学习｜系统工程与实践",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 8, day: 4),
    path: "8-4",
    title: "机器学习｜神经网络、监督学习与树模型",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 27),
    path: "7-27",
    title: "机器学习｜基础知识学习笔记",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 18),
    path: "6-18",
    title: "深度学习｜发展脉络与学习路线图",
  )
] <ml>

#series-block(title: "Transformer 架构演进", tone: "blue")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 14),
    path: "6-14",
    title: "Transformer｜架构演进（6）：Position Encoding 系统（3）——从 RoPE 到长上下文 Scaling",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 12),
    path: "6-12",
    title: "Transformer｜架构演进（5）：Position Encoding 系统（2）——相对位置编码",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 10),
    path: "6-10",
    title: "Transformer｜架构演进（4）：Position Encoding 系统（1）——理解绝对位置编码",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 9),
    path: "6-9",
    title: "Transformer｜架构演进（3）：Vocab 系统（3）——高效词表、词表适配与 Tokenizer-free",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 7),
    path: "6-7",
    title: "Transformer｜架构演进（2）：Vocab 系统（2）——Embedding、LM Head 与 Tied Embedding",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 4),
    path: "6-4-tr",
    title: "Transformer｜架构演进（1）：Vocab 系统（1）——Tokenizer 与 Vocabulary Size",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 2),
    path: "6-2",
    title: "Transformer｜架构演进（0）：从 Transformer 架构到现代大模型导览",
  )
] <transformer-architecture>

#series-block(title: "Transformer 反向传播（Backpropagation）", tone: "indigo")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 25),
    path: "5-25-tr",
    title: "Transformer｜反向传播（Backpropagation）（6）：缩放因子 √dₖ 与初始化哲学",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 22),
    path: "5-22-tr",
    title: "Transformer｜反向传播（Backpropagation）（5）：残差连接与归一化的选择",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 21),
    path: "5-21-tr",
    title: "Transformer｜反向传播（Backpropagation）（4）：Self-Attention 联合推导与整体总结",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 20),
    path: "5-20-tr",
    title: "Transformer｜反向传播（Backpropagation）（3）：以 SwiGLU 为例的前馈网络层推导",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 19),
    path: "5-19",
    title: "Transformer｜反向传播（Backpropagation）（2）：两个特殊模块——Softmax 与 RMSNorm",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 18),
    path: "5-18",
    title: "Transformer｜反向传播（Backpropagation）（1）：误差和梯度在 Linear 层的基础推导",
  )
] <transformer-backprop>

#series-block(title: "计算机视觉与生成模型", tone: "cyan")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 29),
    path: "7-29",
    title: "流匹配｜原理与个人理解",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 12),
    path: "7-12-1",
    title: "Diffusion｜DDPM & DDIM 从加噪到采样的完整推导",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 10),
    path: "7-10",
    title: "图像处理｜卷积与 U-Net 学习笔记",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 13),
    path: "6-13",
    title: "扩散模型｜基本原理与发展脉络",
  )
] <generative-models>

#series-block(title: "数学推导", tone: "cyan")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 8),
    path: "6-8",
    title: "Transformer｜架构演进（扩展）：Unigram LM 的 Subword 概率收敛证明",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 13),
    path: "2026-05-13-strassen-matrix-blocking",
    title: "线性代数｜矩阵分块优化与 Strassen 算法",
  )
] <math>

// ==================== 论文、工程与工具 ====================
== 论文、工程与工具 <practice>

#html.div(class: "blog-tags", [
  #tag(<projects>, [🚀 工程与工具])
  #tag(<papers>, [📚 论文与模型解析])
  #tag(<agentic-ai>, [🤖 Agentic AI])
  #tag(<methods>, [💡 学习方法])
])

#series-block(title: "工程与工具", tone: "amber")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 28),
    path: "7-28",
    title: "工程实践｜大规模中医文献筛选与检索库搭建",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 3),
    path: "6-3",
    title: "CS336（2025）｜Assignment 1：Transformer 架构测试实验",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 20),
    path: "5-20-skill",
    title: "Skill｜基于 PaSaMaster 的文献检索 Skill 设计与优化",
  )
] <projects>

#series-block(title: "论文与模型解析", tone: "amber")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 12),
    path: "7-12",
    title: "论文解读｜MRGen：基于扩散模型与 U-Net 的跨模态医学图像生成",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 29),
    path: "5-29",
    title: "预训练框架｜适配深度表型数据的 Transformer 基础模型 ukbFound：架构与源码解析",
  )
] <papers>

#series-block(title: "Agentic AI", tone: "amber")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 8, day: 14),
    path: "8-14",
    title: "Agentic AI（2）｜阿里云智能体安全报告解读",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 8, day: 12),
    path: "8-12",
    title: "Agentic AI（1）｜个人完整框架解读",
  )
] <agentic-ai>

#series-block(title: "学习方法", tone: "amber")[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 20),
    path: "7-20",
    title: "学习方法｜如何阅读一篇论文？",
  )
] <methods>

#line(length: 100%, stroke: 0.6pt)

// ==================== 个人文件夹 ====================
== 个人文件夹 <private>

#html.div(class: "blog-tags", [
  #tag-placeholder[🔒 私人记录]
  #tag-placeholder[🗂️ 输入密码后查看]
])

#series-block(title: "私人内容入口", tone: "rose")[
  #text(fill: luma(110), style: "italic")[
    随笔、绘画记录和日常内容已移入个人文件夹，不在公开目录展示文章标题。
  ]

  #link("journal-gate-n4k7m2/")[
    #html.span(class: "private-folder-link", [进入个人文件夹])
  ]
]
