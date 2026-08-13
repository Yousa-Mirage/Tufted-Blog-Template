#import "../index.typ": template, tufted

// 如需生成 RSS feed，必须填写 title、description 和 date 元数据

\\\#show: template.with(
  title: "检索工程实践｜大规模特定中医文献筛选及检索库搭建总结",
  description: "检索工程实践｜大规模特定中医文献筛选及检索库搭建总结",
  date: datetime(year: 2026, month: 7, day: 20),
  category: "数学与算法",
  lang: "zh",
)
\\\



= *检索工程实践｜大规模特定中医文献筛选及检索库搭建总结*

\#2026-07-28 \#项目实践 \#总结 \#文献筛查

#line(length: 100%, stroke: 0.6pt)

#tufted.margin-note[
  为了服务我们中医相关项目的“循证医学”理念，减少过程中出现的差错，笔者从我们实验组原始收集的文献资料中分层筛选加过滤，最终基于元数据搭建了一套检索服务。这是一个面向大规模中医文献的工程化实践：把分散的 PDF、筛选结果、MinerU 识别结果和元数据，整理成可查询、可统计、可回溯到原始 PDF 页面和坐标的三层证据系统。祝食用愉快～😧
]

#line(length: 100%, stroke: 0.6pt)
#figure(caption: "网页前端展示")[
  #image("imgs/1.png", width: 40%)
]
== *引言：解决什么问题？*

#quote[
  基于项目的循证需求，需要得到特定主题的文献（寒热+表型），所以在开始前需要明确我们的问题：
]

+ 一个主题词，例如“寒热”“恶寒”“阳虚发热”，出现在哪些文献部位中？怎么快速从70w+的文献中查找到关键文献？
+ 不同类别的文献怎么处理？指南，论文，标准……这些层级如何划分？
+ 根据出现的不同类别，怎么因材施教：对不同的层用针对性的方法去解决
+ 怎么找到最适合每一层的筛选方法？既高效又高质量的筛出所需文献？
+ 怎么利用LLM来快速高效地对文献好坏进行判断？
+ 怎么获取与整理原始数据，搭建一个检索系统？
+ 怎么加速对单个词的检索？
+ 怎么可视化以及服务于频次统计与原文回溯？

#quote[
  目前笔者搭建了最初步的demo系统，从70w+的文献中筛查出来了2.5w左右的高精度符合要求的多来源文献资料，构建了我们的初级检索服务，在一个星期之内完成了整个项目的初步迭代并且做出了可用的服务。
]

#quote[
  _*以下是我的个人搭建过程总结：*_
]

#line(length: 100%, stroke: 0.6pt)

== *三层证据体系*

#quote[
  根据调查以及前期总结，我们把文献按来源和证据用途分为三个层级,不同来源的层级包含的内容的置信度是不同的：
]

#table(
  columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  table.header([*层级*], [*名称*], [*主要作用*]),
  [L1], [L1\_standard\_base], [标准、规范和基础性资料], [L2], [L2\_guideline\_textbook\_classic], [指南、教材、经典和临床知识体系], [L3], [L3\_paper\_evidence], [论文和研究型文献]
)

#quote[
  同时在这个文献筛选的工作中，分出三层不只是简单的目录分类，同时也是查询时的过滤维度。同时在检索的时候，用户可以查询全部三层，也可以只看论文，或者比较标准、经典资料与论文之间的频次和上下文差异。
]

#line(length: 100%, stroke: 0.6pt)

#quote[
  展示一下现在的结果，当前正式 SQLite 检索库的层级统计如下：
]

#table(
  columns: (1fr, 1fr),
  align: (left, right),
  table.header([*层级*], [*文档数*]),
  [L1 标准基础], [32], [L2 指南/教材/经典], [181], [L3 论文证据], [24,500], [合计], [24,713]
)

#line(length: 100%, stroke: 0.6pt)

== *第一阶段：筛选标准与追踪*

=== *通用流水线*

#quote[
  每个来源大致按以下顺序进入查询体系：
]

#tufted.margin-note[
  （注：这里是对pdf为原始格式的文献进行筛选的，笔者最开始获取的其实是已经转好的md文献，但是由于这是大前期的工作，当时得到的md文件效果不佳经常出现错行或者错位的情况，所以后续对这批文献的原始pdf全量重新转化和筛选了一次。可见数据好坏的重要性呢！）
]

+ 盘点原始 PDF，记录原始路径、标题、页数和来源。
+ 规范化 manifest，按 canonical PDF/path/title 去重，避免同一篇文献多次计数。
+ 根据来源路径、标题、标准号和文献类型判定 L1/L2/L3。
+ 用标题、路径和少量正文前缀做规则粗筛；paper 主要以标题做高吞吐召回，L1/L2 允许读取前缀。（分层处理）
+ 将 `KEEP_STRICT` 和 `KEEP_BROAD` 候选送入 LLM 或后续人工/内容复核；
+ 只对保留文献运行 MinerU，输出 Markdown、原始 PDF 映射和 block 元数据。
+ 做正文/目录/参考文献分类，生成 term-hit 和全文 FTS；通过 checkpoint 增量合并到 SQLite。

#line(length: 100%, stroke: 0.6pt)

=== *规则词和排除逻辑*

#quote[
  规则这里做了2个阶段的关键词匹配，不是简单搜索“寒热”两个字，同时在第二阶段还按语境进行了上下文精确筛选：
]

- 核心寒热证候：寒热错杂、上热下寒、表寒里热、虚寒证、虚热证、实寒证、实热证、寒湿证、湿热证、痰热证、血热证、热毒证等。
- 证候/表型：证候、证型、证素、表型、体质、舌象、脉象、四诊、症状、体征、分布、规律、特征、诊断等。
- 中医上下文：中医、病机、病证、伤寒论、金匮要略、内经、温病、太阳病、少阳病、卫气营血等。
- 研究提示：研究、分析、探讨、评价、进展、综述、理论、内涵、源流、规律、特征等。
- 症状入口：发热、恶寒、畏寒、寒热往来、肢冷、身热、寒战、低热、久热、潮热等；单独出现时不视为高精度寒热证据。

注：药物/方剂、治疗、疗效、护理、针灸、推拿、康复、医案/验案等词在严格筛选中是抑制信号；若同时有明确的寒热证候、经典理论或证型研究语境，部分文献保留到 `KEEP_BROAD`，交给后续终筛。流行性出血热等明确伪阳性、热回收/夏热冬冷等非医学寒热语境则直接排除。

#line(length: 100%, stroke: 0.6pt)

=== *补充： Aho-Corasick（pyahocorasick）*

#quote[
  Aho-Corasick（pyahocorasick）是一个“多关键词同时匹配”的快速字符串检索工具。它不是数据库，也不是语义模型，而是把大量关键词预先构造成自动机，然后对每篇文献只扫描一遍文本，就能同时找出所有命中的词。
]

在本项目中，它主要用于第二次 paper 宽召回：

- 同时匹配寒热核心词、症状词、证候词、舌脉表型词、中医语境词和研究语境词。
- 记录命中的关键词、文献层级、匹配片段和召回原因。
- 将命中的文献写入宽召回队列，交给后续 LLM 精筛。
- 同时生成关键词 postings，方便后续建立查询索引。

它带来的主要效果是：

+ 大幅减少重复扫描:如果有几百或几千个关键词，普通方法需要对每个词反复扫描全文；Aho-Corasick 可以把词表一次性编译，文献只需扫描一次
+ 提高大规模处理吞吐
+ 召回结果更完整
+ 便于后续解释和审查

每条结果会保留：命中词,匹配上下文,文献层级,召回原因,原始文档路径。因此可以知道一篇文章为什么进入队列，而不是只得到一个不可解释的分类结果。

+ 为后续查询索引提供基础数据：扫描过程中生成的 postings 可以作为倒排关系：关键词 -\> 文档 -\> 层级 -\> 标题 -\> 路径：这有助于后续实现词频统计、文档筛选和共现查询。

需要注意的是，Aho-Corasick 负责“快速、高召回地找出可能相关的文献”，不负责判断文章是否真正属于中医寒证候研究。因此它保留了一定误召回，再由规则和 LLM 做精筛。线上网页查询使用的 SQLite FTS5，则是另一套面向实时查询的索引工具。

#line(length: 100%, stroke: 0.6pt)

=== *STRICT、BROAD 和 LLM 的关系*

- `KEEP_STRICT`：高精度候选，通常同时有寒热核心词、证候/表型词和中医/研究语境。
- `KEEP_BROAD`：有明确相关线索但治疗性、症状性或标题歧义更强的候选，用于避免过早漏召回。
- `keep_all`：两类候选的并集，先按标题去重后再送终筛。
- LLM 终筛：模型为 `ecnu-max`；它主要排除药名伪阳性、动物实验、护理/疗效观察和非寒热证候中心文献，不负责替代最终学术判断。人工复核了一些上面关键词匹配得到的例子中选出来几个ACCEPT和REJECT的案例，作为few-shot喂给LLM作为参考去判断，之后挂起整个筛选流水线，从分层打标签，到分层次进入不同的筛选通道，输出之后统一进入LLM筛选通道，挂一个长线的screen效率会快很多！

#line(length: 100%, stroke: 0.6pt)

== *第二阶段：利用MinerU 转可追踪结构*

=== *只保留 Markdown 不够*

Markdown 适合阅读，但不适合精确定位。Markdown 不一定保留：

- 原始 PDF 页码；
- 文字在页面中的矩形坐标；
- 页面尺寸；
- 图片、公式和结构化元素；
- block 的页面顺序关系。

但这是我们需要的，因此我们的mineru识别结果同时保留：

```text

normalized.md

content_list.json

origin.pdf

layout.pdf

span.pdf

middle.json

model.json

images/
```

#line(length: 100%, stroke: 0.6pt)

=== *screen、状态和断点*

#quote[
  大批量 PDF 转换可能运行数小时，因此使用 screen 保持长任务。screen 只负责让进程在 SSH 断开后继续运行，真正的可恢复性来自：
]

- manifest；
- doc\_status.jsonl；
- batch\_meta/\*.json；
- normalized\_manifest.jsonl；
- summary\_latest.json；
- 每个 worker 的日志。

screen 解决“任务如何活着”，状态文件解决“任务如何恢复”。

#line(length: 100%, stroke: 0.6pt)

== *第三阶段：建立稳定的 Markdown 和 PDF 对应关系*

raw MinerU 输出包含 GPU、batch 和内部目录名，不适合直接暴露给业务层。因此建立稳定的 normalized 目录：

```text

md/

└── L3_paper_evidence/

└── batch_009/

└── 文献标题/

└── 文献标题.md
```

normalized Markdown 通常是指向 raw Markdown 的符号链接：

+ 业务层路径稳定；
+ 不重复复制大文件；
+ 查询结果可以同时返回 normalized 和 raw 路径。

#line(length: 100%, stroke: 0.6pt)

=== *补充：长文件名问题*

曾经有一篇长标题论文的 MinerU 日志显示 7/7 页处理成功，但批处理脚本报告 unresolved\_md=1。检查后发现：

- MinerU 实际生成了 Markdown；
- content\_list.json 也存在；
- PDF 可以被 pdfinfo 正常读取；
- 只有输出目录名和 Markdown 文件名被缩短；
- 原匹配逻辑只支持单向包含。

解决方案：

+ 使用已有 raw Markdown 和 content\_list 手工补建 normalized link 和 manifest row；
+ 修改匹配逻辑，允许足够长的生成 stem 作为 staged stem 的前缀。

_*这个问题说明：工具任务成功退出，不等于业务流水线已经完成；必须检查业务侧产物映射。*_

#line(length: 100%, stroke: 0.6pt)

== *第四阶段：从 content\_list 建立 block 级元数据*

=== *block 是？*

MinerU 从页面识别出的一个结构单元就是 block，可能是：

- 正文段落；
- 标题；
- 列表项；
- 公式；
- 页眉页脚；
- 参考文献条目；
- 表格或图像说明。

统一的 content\_blocks.jsonl 典型字段如下：

```json

{

"doc_id": "L3_paper_evidence/batch_009/example.pdf",

"title": "example",

"source_pdf": "/path/to/example.pdf",

"normalized_md": "/path/to/example.md",

"block_idx": 42,

"page_idx": 4,

"page_no": 5,

"bbox": [136, 216, 885, 374],

"type": "text",

"text": "当前 block 的文字",

"context_text": "相邻 block 组成的上下文",

"is_body": 1,

"body_reason": "body"

}
```

bbox 是 PDF 页面坐标中的矩形，通常为 x0、y0、x1、y1。系统同时保存 page\_idx 和从 1 开始的 page\_no，避免不同工具的页码基准不一致。

#line(length: 100%, stroke: 0.6pt)

=== *上下文如何生成？*

命中一个 block 时，系统在同一页取：

- 前一个有文字的 block；
- 当前 block；
- 后一个有文字的 block。

这形成 context\_text，会比只返回一个词所在的短字符串更适合人工判断。

#line(length: 100%, stroke: 0.6pt)

=== *term-hit*

#quote[
  term-hit 是某个预定义术语在某个 block 中的命中记录，通常包含：
]

- 术语和类别；
- 文档和 block；
- 页码和 bbox；
- occurrence count；
- 上下文。

多模式匹配器优先尝试 Aho-Corasick，不可用时退化为按长度排序的正则表达式。这样可以一次扫描 block 文本，而不是对每个词重复扫描全文。

用户输入未预建的词时仍然可以走 block 文本搜索。

#line(length: 100%, stroke: 0.6pt)

== *第五阶段：正文分类，排除目录和参考文献污染*

=== *正文过滤？*

不做正文分类时，下面内容会产生明显误判：

- 目录章节名；
- 封面大标题；
- 书目信息；
- 页眉页脚；
- 页码；
- 参考文献；
- 脚注；
- 标题和摘要中的重复词。

“寒热”出现在参考文献标题中，并不等于正文讨论了寒热。

#line(length: 100%, stroke: 0.6pt)

系统对 block 写入 is\_body 和 body\_reason，并统一用于：

- 单词频次；
- 文档统计；
- 多词共现；
- contribution frequency；
- API 上下文返回。

当前全库分类统计：

#table(
  columns: (1fr, 1fr),
  align: (left, right),
  table.header([*分类*], [*blocks*]),
  [正文 body], [929,479], [目录 toc], [4,454], [参考文献 reference], [86,831], [封面/前置内容 front\_matter], [829,346], [结构性内容 structural], [394,064], [总计], [2,244,174]
)

#line(length: 100%, stroke: 0.6pt)

分类综合使用：

- block type；
- 标题模式；
- 目录结构；
- “参考文献”等章节标题；
- 页眉页脚和页码特征；
- 文档前置区域；
- block 顺序。

分类不是声称 100% 正确的语义理解器，而是保留 reason 的可审计规则分类器。

#line(length: 100%, stroke: 0.6pt)

== *第六阶段：把共现定义落实到同一个 block*

#quote[
  我们要实现多术语共现检查的时候，共现不能定义为“同一篇文章都出现过”。正确的定义是：
  多个词必须在同一个正文 metadata block 中同时出现，才算共现。
]

paper 也按同一个 block 处理，不跨全文合并。
如果一个 block 中：

```text

寒热出现 3 次

发热出现 5 次
```

这个 block 的共同贡献频次是：

```text

min(3, 5) = 3
```

文档级贡献频次是所有共同 block 的贡献频次之和。

这样不会因为某一个词在文档其他位置大量出现而虚高共现贡献。API 返回：

- 共同文档；
- 共同 block 上下文；
- 每个词在 block 中的次数；
- block 和文档级 contribution；
- L1/L2/L3 分层统计。

#line(length: 100%, stroke: 0.6pt)

== *第七阶段：构建 SQLite 查询服务*

=== *SQLite*

#quote[
  当前规模约为 2,244,174 个 blocks、24,713 篇文档。SQLite 的现实优势是：
]

- 不需要部署数据库集群；
- 索引文件容易备份和替换；
- 查询服务可以只读打开；
- SQLite FTS5 提供倒排索引；
- API 和数据库位于同一台服务器；
- 对研究型项目和低并发内部使用足够可靠。

#line(length: 100%, stroke: 0.6pt)

=== *主库表*

#table(
  columns: (1fr, 1fr),
  align: (left, left),
  table.header([*表*], [*作用*]),
  [documents], [文档、层级、PDF、Markdown 和 page\_count], [blocks], [block 文本、页面、bbox、上下文和正文分类], [hits], [预建 term-hit], [term\_vocab], [术语、类别和 body-only 聚合统计], [blocks\_fts], [三字以上任意文本的 trigram FTS5], [metadata], [schema、构建时间和全库统计]
)

#line(length: 100%, stroke: 0.6pt)

=== *HTTP API 和网页端*

服务是一个独立 HTTP server

#quote[
  目前网页端的结果展示策略是：
]

- 每篇文献默认展示 4 个命中；
- 点击后展开该文献的全部命中；
- 查询词高亮；
- 多词使用不同颜色；
- 点击 block 后显示对应 PDF 页面和 bbox；
- 可以打开原始 PDF 和规范化 Markdown。

#line(length: 100%, stroke: 0.6pt)

=== *PDF 回溯*

每个命中 block 带有 page\_no、bbox、pdf\_url、preview\_url 和 preview\_info\_url。服务用 pdftoppm 渲染对应页面，再根据原始页面尺寸和预览图尺寸换算 bbox。

Markdown 是阅读视图，content\_list.json 才是 PDF 定位的主要事实来源。

#line(length: 100%, stroke: 0.6pt)

== *查询加速*

=== *metadata term-hit*

预建术语优先查 hits 表，使用 term、term\_norm 和 doc 索引。这条路径适合稳定的寒热术语统计。

#line(length: 100%, stroke: 0.6pt)

=== *SQLite FTS5 trigram*

三字及以上未知词使用：

```sql

CREATE VIRTUAL TABLE blocks_fts USING fts5(

text_norm,

tokenize='trigram'

);
```

它不依赖词表，可以搜索任意三字以上字符串。实测：

- 高血压前期：约 6 ms；
- 麻黄附子细辛汤：约 19 ms；
- 重症病例：约数毫秒。

#line(length: 100%, stroke: 0.6pt)

=== *字符级 FTS5 旁路索引*

FTS5 trigram 对少于三个字符的中文查询不适合。原 fallback 是：

```sql

WHERE text_norm LIKE '%肝郁%'
```

这会扫描大量 blocks。新方案建立——连续 CJK 文本转换为字符 token：

```text

原文：肝郁化热

索引：肝 郁 化 热

查询："肝 郁"
```

CJK 连续段之间插入 break token，避免跨越标点、拉丁字母或其他非连续内容。

查询链路是：

```text

短中文词

-> 转成字符 phrase

-> charfts 倒排索引得到候选 block_id

-> 回主 blocks 表

-> LIKE 精确校验

-> 计算频次、文档聚合和上下文
```

旁路索引只收录正文 block，使用同一个 block\_id 关联主库；查询服务按需 attach 旁路库，不会拖慢普通 trigram 查询。

实际 API 测试：

#table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  align: (left, left, right, right, right, right),
  table.header([*查询词*], [*match mode*], [*文档数*], [*blocks*], [*总出现次数*], [*中位耗时*]),
  [肝郁], [block\_substring\_charfts], [837], [4,593], [7,036], [约 85 ms], [寒热], [block\_substring\_charfts], [1,256], [18,701], [26,490], [约 292 ms], [气虚], [block\_substring\_charfts], [1,591], [20,432], [31,044], [约 331 ms]
)

旁路 FTS 本身在子集测试中约为 1–4 ms；API 总耗时还包括正文过滤、频次聚合、文档排序、上下文和 PDF URL 组装。

#line(length: 100%, stroke: 0.6pt)

== *小结*

+ 先建立唯一文献清单，再做任何重处理。
+ 筛选阶段追求高召回，精确性留给后续内容判断。
+ 原始 PDF、Markdown 和结构化 block 三种视图分别服务于定位、阅读和检索。
+ 正文分类到检索系统的过程
+ 共现必须落到可审计的最小单元

#line(length: 100%, stroke: 0.6pt)

== *笔者的话*

#quote[
  是一次做工程项目的经验总结，这是一次很有趣的实践，我花了几乎整整一个星期去做它，非常不错。但革命尚未成功，笔者仍需努力～💪
]