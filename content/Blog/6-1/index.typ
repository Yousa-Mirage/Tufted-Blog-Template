#import "../index.typ": template, tufted

// 如需生成 RSS feed，必须填写 title、description 和 date 元数据
#show: template.with(
  title: "Transformer｜反向传播 (Backpropagation)（5）：残差连接与归一化的选择",
  description: "Transformer｜反向传播 (Backpropagation)（5）：残差连接与归一化的选择",
  date: datetime(year: 2026, month: 6, day: 1),
  category: "杂谈",
  lang: "zh",
)