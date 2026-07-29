#import "../index.typ": template, tufted
#show: template.with(
  title: "Blog",
  description: "数学算法、个人评论、绘画方法心得与日记。",
)

// ── 可点击标签（蓝色）──
#let tag(target, body) = link(target)[#block(
  inset: (x: 10pt, y: 5pt),
  radius: 12pt,
  fill: rgb("#dbeafe"),
  stroke: 1pt + rgb("#3b82f6"),
)[#text(size: 1.1em, fill: rgb("#1d4ed8"), weight: "bold", style: "italic")[#body]]]

// ── 占位标签（灰色）──
#let tag-placeholder(body) = block(
  inset: (x: 10pt, y: 5pt),
  radius: 12pt,
  fill: luma(235),
  stroke: 1pt + luma(190),
)[#text(size: 1.1em, fill: luma(140), weight: "bold", style: "italic")[#body]]


// ── 系列卡片，支持自定义左边框颜色 ──
#let series-block(title: "", accent: rgb("#3b82f6"), body) = block(
  width: 100%,
  inset: 12pt,
  radius: 6pt,
  fill: luma(249),
  stroke: (left: 3pt + accent, rest: 0.5pt + luma(220)),
)[
  #text(size: 0.9em, weight: "bold", fill: accent)[📂 #title]
  #body
]



= *Blog*

#quote[
  If you enjoy my blog, feel free to bookmark the site:*
  #link("https://shiyilee11.github.io/Tufted-Blog-Template/Blog/")[shiyilee11.github.io/Blog]*.
  If you have any ideas or suggestions, don't hesitate to reach out via
  *#link("mailto:1747819157@qq.com")[email]*.
  I'd love to hear your feedback! 🙌
]

// ==================== 数学与算法 ====================
== *数学与算法* <math>

#tag(<ml>, [⚙️ 机器学习])
#tag(<transformer2>, [🤖 Transformer架构演进系列])
#tag(<transformer1>, [🤖 Transformer 反向传播 (Backpropagation)系列])
#tag(<linear>, [📐 数学推导])



#series-block(title: "机器学习", accent: rgb("#0ea5e9"))[

      #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 27),
    path: "7-27",
    title: "机器学习｜个人基础收获整理",
  )
] <ml>




#series-block(title: "Transformer架构演进", accent: rgb("#0ea5e9"))[


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
    title: "Transformer｜架构演进（0）：从Transformer架构到现代大模型导览",
  )
]<transformer2>

#series-block(title: "Transformer反向传播 (Backpropagation)", accent: rgb("#6366f1"))[
   #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 25),
    path: "5-25-tr",
    title: "Transformer｜反向传播 (Backpropagation)（6）：缩放因子与初始化哲学",
  ) 
   #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 22),
    path: "5-22-tr",
    title: "Transformer｜反向传播 (Backpropagation)（5）：残差连接与归一化的选择",
  ) 
   #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 21),
    path: "5-21-tr",
    title: "Transformer｜反向传播 (Backpropagation)（4）：Self-Attention联合推导与整体总结",
  ) 
  
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 20),
    path: "5-20-tr",
    title: "Transformer｜反向传播 (Backpropagation)（3）：以SwiGLU为例的前馈网络层推导",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 19),
    path: "5-19",
    title: "Transformer｜反向传播 (Backpropagation)（2）：两个特殊模块：Softmax 与 RMSNorm",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 18),
    path: "5-18",
    title: "Transformer｜反向传播 (Backpropagation)（1）：误差和梯度在 Linear 层的基础推导",
  )
] <transformer1>


#series-block(title: "数学推导", accent: rgb("#0ea5e9"))[

      #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 12),
    path: "7-12-1",
    title: "Diffusion｜DDPM & DDIM 从加噪到采样的完整推导",
  )

    #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 8),
    path: "6-8",
    title: "Transformer算法｜架构演进（拓展）：Vocab 系统——Unigram LM的subword概率收敛证明",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 13),
    path: "2026-05-13-strassen-matrix-blocking/",
    title: "线性代数｜矩阵分块优化与 Strassen 算法",
  )
] <linear>

// ==================== 实践与工具 ====================
== *实践与工具* <practice>

#tag(<tries>,[🚀 项目实践])

#tag(<realtry>, [💡 实践看法])

#tag-placeholder[🔧 工具分享（即将更新）]

#series-block(title: "项目实践", accent: rgb("#f59e0b"))[
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 28),
    path: "7-28",
    title: "检索工程实践｜大规模特定中医文献筛选及检索库搭建总结",
  )



  #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 3),
    path: "6-3",
    title: "cs336（2025）｜assignment 1：Transformer架构的测试实验",
  )
] <tries>



#series-block(title: "实践看法", accent: rgb("#f59e0b"))[


            #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 29),
    path: "7-29",
    title: "流匹配｜个人理解记录",
  )


          #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 20),
    path: "7-20",
    title: "Idea杂谈｜“How to read a paper？",
  )


        #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 12),
    path: "7-12",
    title: "MRGen （ICCV 2025 交大）  ｜精析基于Diffsion和UNet的医学图像分割跨模态的图像生成架构",
  )

      #tufted.blog-entry(
    date: datetime(year: 2026, month: 7, day: 10),
    path: "7-10",
    title: "图像处理｜从卷积与 UNet的学习",
  )

    #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 18),
    path: "6-18",
    title: "杂谈整理｜深度学习发展路径的MindMap",
  )


      #tufted.blog-entry(
    date: datetime(year: 2026, month: 6, day: 13),
    path: "6-13",
    title: "模型杂谈｜关于Diffusion Model",
  )

    #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 29),
    path: "5-29",
    title: "Pre-Train Framework｜深度表型数据适配的 Transformer 基础模型 ukbFound 架构与源码解析",
  )
  #tufted.blog-entry(
    date: datetime(year: 2026, month: 5, day: 20),
    path: "5-20-skill",
    title: "Skill｜基于上海交大最新 PaSaMaster构建优化文献检索 Skill 的设计",
  )
] <realtry>

#line(length: 100%, stroke: 0.6pt)

_*⚠️⚠️⚠️注意：下面原本的私人记录内容已移入个人文件夹，不在公开 Blog 页显示；其中更多是碎碎念记录或者一些练笔兴趣，涉及更多感性内容的讨论⚠️⚠️⚠️*_

// ==================== 个人文件夹 ====================
== *个人文件夹* <private>

#tag-placeholder[🔒 私人记录]
#tag-placeholder[🗂️ 输入密码后查看]

#series-block(title: "私人内容入口", accent: rgb("#ec4899"))[
  #text(fill: luma(110), style: "italic")[
    下面这部分内容已从公开 Blog 页中移出，不再展示文章标题与列表。
  ]

  #text(fill: luma(110), style: "italic")[
    如果你需要进入这部分内容，请打开下方入口并输入密码。
  ]

  #link("journal-gate-n4k7m2/")[
    #block(
      inset: (x: 14pt, y: 10pt),
      radius: 10pt,
      fill: rgb("#fff1f2"),
      stroke: 1pt + rgb("#ec4899"),
    )[
      #text(weight: "bold", fill: rgb("#be185d"))[进入个人文件夹]
    ]
  ]
]
