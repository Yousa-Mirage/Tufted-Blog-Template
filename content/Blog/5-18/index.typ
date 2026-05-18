#import "../index.typ": template, tufted

// 如需生成 RSS feed，必须填写 title、description 和 date 元数据
#show: template.with(
  title: "Transformer｜反向传播 (Backpropagation)（1）：误差和梯度在Linear层的基础推导",
  description: "Transformer｜反向传播 (Backpropagation)（1）：误差和梯度在Linear层的基础推导",
  date: datetime(year: 2026, month: 5, day: 18),
  category: "数学算法",
  lang: "zh",
)



#let boxeq(body) = rect(
  stroke: 1.2pt + rgb("#4a90d9"),
  fill: rgb("#f0f6ff"),
  inset: 10pt,
  radius: 4pt,
)[#body]


= Transformer｜反向传播 (Backpropagation)（1）：误差和梯度在Linear层的基础推导

#tufted.margin-note[
  *阅读前提*：本文假设你对 Transformer 的基本架构有一定了解，虽然是基础内容，但最好具有一点点线性代数、微积分基础理解起来会比较容易。如果你还不熟悉，笔者建议先了解一下Transformer 的前向传播流程再回来。本篇文章会非常详细地拆解反向传播的流程(主要基于个人的理解来表述)，祝食用愉快～😊
]

#line(length: 100%, stroke: 0.6pt)

== 导言

#quote[
  在讲 Transformer 之前，我们先退回到一个简单的场景。一个最朴素的神经网络，做的事情就是：
]

#figure(caption: "神经网络")[
  #image("imgs/sjwl.png", width: 50%)
]

```
输入 → 一堆数学运算 → 输出 → 和正确答案比较 → 得到误差

```

这个"从输入到输出"的过程，叫做*前向传播（Forward Pass）*。

但光知道"错了"没有用。我们需要知道：*网络里的哪些参数该对这个错误负责，负多少责？（就像犯了事之后要追责然后纠正错误一样）*

这就引出了*反向传播（Backward Pass）*：把误差从输出端，一层一层地往回传，沿途计算每一个参数应该承担的责任大小。

#line(length: 100%, stroke: 0.6pt)

让我们用一个生活类比来说：

```
前向传播：一道菜从厨房端到了餐桌，客人说"这道菜不好吃"
反向传播：追查责任链——是服务员端错了？是厨师炒错了？
          还是采购员买的食材有问题？一路追到源头
```

在最早的神经网络里，这个"追查"过程是这样的：

```
输出层的误差
  → 往回传给倒数第二层
      → 再往回传给倒数第三层
          → 一直传到第一层
```

每一层的参数，都根据传到自己这里的误差，计算出自己的梯度，然后用梯度更新自己。

#line(length: 100%, stroke: 0.6pt)

这个机制在简单的全连接网络里就已经存在。而Transformer 做的事情，本质上和这个没有区别——只是网络的结构更复杂，中间多了 Attention、RMSNorm、残差连接等模块，但*每一层的反向传播，都遵循同样的链式法则*。

所以这篇文章要分享的事情很简单：

#quote[
  *从 Transformer 最后一层的输出（logits）出发，推导出反向传播最核心的两个公式。这两个公式，会在 Transformer 的每一个线性层里反复使用。*
]

#tufted.margin-note[
  #image("imgs/t.png", width: 50%)
]

#tufted.margin-note[*Transformer经典架构*]


#line(length: 100%, stroke: 0.6pt)

== 误差和梯度

#quote[
  在开始推导之前，先欢迎我们的两个主角登场👏
]

=== 误差 $Delta$

误差是一个在网络里*从后往前流动的信号*。

它的数学身份是：损失 $L$ 对某个*中间计算结果*的导数。

$ Delta_y = (partial L)/(partial y) $

它回答的问题是：*"如果这个中间结果变化一点点，损失会怎么变？"*

误差不是一个参数，它是一个临时的信号，每次训练完一个 batch 就消失了。它存在的唯一目的，是把"犯了多大的错"这件事，一层一层地传递到网络的每一个角落。

#line(length: 100%, stroke: 0.6pt)

=== 梯度 $(partial L)/(partial W)$

梯度是损失 $L$ 对某个*可学习参数* $W$ 的导数。

$ (partial L)/(partial W) $

它回答的问题是：*"如果把这个参数调大一点点，损失会怎么变？"*

梯度是我们真正想要的东西。有了所有参数的梯度，就可以告诉优化器（Optimizer，比如 Adam）：

$ W <- W - "lr" times (partial L)/(partial W) $

往梯度的反方向走一小步，损失就会减小，模型就会变得更聪明。

_*我们推导的全部目的，就是计算每一个参数层的梯度。误差的传播，是达到这个目的的手段。*_

#line(length: 100%, stroke: 0.6pt)

== 从 Loss 出发

=== 交叉熵

我们的模型预测了：

$ y_(p r e d) = "Softmax" ("logits") = [0.70, med 0.20, med 0.10] $

假设对应 $["chair" , med "throne" , med "floor"]$。

而正确答案是 throne，用 one-hot 向量表示：

$ y_(g t) = [0, med 1, med 0] $

#line(length: 100%, stroke: 0.6pt)

损失函数用交叉熵：

$ L = - sum_j y_(g t, j) dot.op log(y_(p r e d, j)) = - log(0.20) approx 1.61 $

数字越大，说明模型错得越离谱。现在我们要从这个 $L$ 出发，往回追责。

#line(length: 100%, stroke: 0.6pt)

=== 误差：Softmax + 交叉熵的联合梯度

Softmax 和交叉熵损失联合求导，有一个非常优雅的结果：

$ Delta_"logits" = y_(p r e d) - y_(g t) $

代入数字：

$ Delta_"logits" = [0.70, med 0.20, med 0.10] - [0, med 1, med 0] = [+ 0.70, med - 0.80, med + 0.10] $

我们解读一下这三个数字：

```
+0.70（chair）：  chair 的分数给高了，需要降低
-0.80（throne）： throne 的分数给低了，需要提高
+0.10（floor）：  floor 的分数也稍微高了一点，需要小幅降低
```

_*这就是反向传播的起点。*_

#line(length: 100%, stroke: 0.6pt)

== 核心推导：线性层的连接

现在我们拿着 $Delta_"logits"$，来到了它的上一层——*输出投影层*（Language Model Head）。

这一层做的事情是：

$ "logits" = h dot.op W_(l m) $

- $h$：最后一个 Transformer Block 的输出，形状 $[1 times d]$，比如 $d = 4$（为了方便展示）
- $W_(l m)$：输出投影矩阵，形状 $[d times V]$，$V$ 是词表大小，比如 $V = 3$
- $"logits"$：对每个词的原始打分，形状 $[1 times V]$

用具体的形状写出来：

$ [1 times 3] = [1 times 4] dot.op [4 times 3] $

#line(length: 100%, stroke: 0.6pt)

=== 展开矩阵乘法，看清每一条线

把 $"logits" = h dot.op W_(l m)$ 展开，每个 logit 的计算是：

$ "logit"_j = sum_(k = 1)^4 h_k dot.op W_(l m, k j) $

用图来看每一条连接：

```
              W的第1列     W的第2列     W的第3列
              (chair)      (throne)     (floor)

h₁ ────→   × W₁₁  ────→  × W₁₂  ────→  × W₁₃
h₂ ────→   × W₂₁  ────→  × W₂₂  ────→  × W₂₃
h₃ ────→   × W₃₁  ────→  × W₃₂  ────→  × W₃₃
h₄ ────→   × W₄₁  ────→  × W₄₂  ────→  × W₄₃
               ↓               ↓               ↓
          logit_chair    logit_throne    logit_floor
```

每个 $W_(k j)$ 是连接 $h_k$ 和 $"logit"_j$ 之间的那个bridge。

现在我们已经知道了 $Delta_"logits" = [+ 0.70, med - 0.80, med + 0.10]$。

_*那现在我们要问两个问题。*_

#line(length: 100%, stroke: 0.6pt)

=== 问题 A：$W_(l m)$ 的梯度是多少？

*以 $W_(1, "throne")$（连接 $h_1$ 和 $"logit"_"throne"$ 的权重）为例。*

*第一步*：$W_(1, "throne")$ 如何影响 $"logit"_"throne"$？

$ "logit"_"throne" = h_1 dot.op W_(1, "throne") + h_2 dot.op W_(2, "throne") + h_3 dot.op W_(3, "throne") + h_4 dot.op W_(4, "throne") $

对 $W_(1, "throne")$ 求偏导：

$ (partial med "logit"_"throne")/(partial W_(1, "throne")) = h_1 $

#line(length: 100%, stroke: 0.6pt)

*第二步*：$"logit"_"throne"$ 如何影响损失 $L$？

这就是误差的定义：

$ (partial L)/(partial med "logit"_"throne") = Delta_"logits, throne" = - 0.80 $

#line(length: 100%, stroke: 0.6pt)

*第三步*：链式法则，把两步连起来：

$ (partial L)/(partial W_(1, "throne")) = (partial L)/(partial med "logit"_"throne") dot.op (partial med "logit"_"throne")/(partial W_(1, "throne")) = (- 0.80) times h_1 $

*对所有的 $k$ 和 $j$ 做同样的操作：*

$ (partial L)/(partial W_(k j)) = Delta_("logits" , j) times h_k $

#line(length: 100%, stroke: 0.6pt)

把所有 $k times j$ 个结果整理成矩阵：

$ (partial L)/(partial W_(l m)) = mat(delim: "[", h_1; h_2; h_3; h_4) dot.op mat(delim: "[", +0.70, -0.80, +0.10) = mat(delim: "[", h_1 times 0.70, h_1 times(- 0.80), h_1 times 0.10; h_2 times 0.70, h_2 times(- 0.80), h_2 times 0.10; h_3 times 0.70, h_3 times(- 0.80), h_3 times 0.10; h_4 times 0.70, h_4 times(- 0.80), h_4 times 0.10) $
写成矩阵公式：

#boxeq[$ (partial L)/(partial W_(l m)) = h^T dot.op Delta_"logits" $]

*语言理解*：

```
W_{kj} 的梯度 = h_k × Δ_logits,j

h_k 越大：这个权重当时经手的输入信号越强，责任越大
Δ_j 越大： 这个权重连接的输出误差越大，责任越大
两者相乘，就是这个权重此刻的梯度
```

#line(length: 100%, stroke: 0.6pt)

=== 问题 B：把误差继续往前传

$W_(l m)$ 的梯度已经有了，交给优化器。

但反向传播还没结束——$h$ 是从更前面的层算出来的，我们还要继续往前追责。（是的，坏人不止停留在表面😠）

为此，我们需要算出 $Delta_h$，即 $h$ 的误差。

*以 $h_1$ 为例。*

$h_1$ 不像 $W_(1, "throne")$ 那样只影响一个输出，它通过 $W_(l m)$ 的第一行，影响了*所有三个* logit：

$ "logit"_"chair" = h_1 dot.op W_(1, 1) + ... $
$ "logit"_"throne" = h_1 dot.op W_(1, 2) + ... $
$ "logit"_"floor" = h_1 dot.op W_(1, 3) + ... $

#line(length: 100%, stroke: 0.6pt)

所以 $h_1$ 的总误差，要把三条路上的贡献全部加起来：

$ (partial L)/(partial h_1) = (partial L)/(partial "logit"_"chair") dot.op W_(1, 1) + (partial L)/(partial "logit"_"throne") dot.op W_(1, 2) + (partial L)/(partial "logit"_"floor") dot.op W_(1, 3) $

$ = Delta_"chair" dot.op W_(1, 1) + Delta_"throne" dot.op W_(1, 2) + Delta_"floor" dot.op W_(1, 3) $

$ = (+ 0.70) dot.op W_(1, 1) + (- 0.80) dot.op W_(1, 2) + (+ 0.10) dot.op W_(1, 3) $

#line(length: 100%, stroke: 0.6pt)

用图来看这个"汇聚"的过程：

```
Δ_chair  (+0.70) ──× W₁₁──┐
                             ├──→ ∂L/∂h₁
Δ_throne (-0.80) ──× W₁₂──┤
                             │
Δ_floor  (+0.10) ──× W₁₃──┘
```

#line(length: 100%, stroke: 0.6pt)

对所有 $k$ 做同样的操作，整理成矩阵：

$ Delta_h = mat(delim: "[", Delta_"chair" dot.op W_(1 comma 1) + Delta_"throne" dot.op W_(1 comma 2) + Delta_"floor" dot.op W_(1 comma 3); Delta_"chair" dot.op W_(2 comma 1) + Delta_"throne" dot.op W_(2 comma 2) + Delta_"floor" dot.op W_(2 comma 3); Delta_"chair" dot.op W_(3 comma 1) + Delta_"throne" dot.op W_(3 comma 2) + Delta_"floor" dot.op W_(3 comma 3); Delta_"chair" dot.op W_(4 comma 1) + Delta_"throne" dot.op W_(4 comma 2) + Delta_"floor" dot.op W_(4 comma 3))^T $

写成矩阵公式：

#boxeq[$ Delta_h = Delta_"logits" dot.op W_(l m)^T $]

*直觉总结*：

```
前向传播：h 通过 W_lm 扩散成 logits
反向传播：logits 的误差通过 W_lm^T 收拢回 h

W^T 是 W 的"原路返回"版本
前向时 W 的第 k 行决定 h_k 如何影响所有输出
反向时 W^T 的第 k 行（即 W 的第 k 列）决定所有误差如何汇聚回 h_k
```

#line(length: 100%, stroke: 0.6pt)

== 两个公式，一个对称结构

#quote[
  让我们看看我们得到了什么战利品：
]

$ (partial L)/(partial W) = h^T dot.op Delta_"logits" wide $

$ Delta_h = Delta_"logits" dot.op W^T wide $

#line(length: 100%, stroke: 0.6pt)

*对称性*：

```
计算 W 的梯度：把输入 h 转置，放在 Δ 的左边
计算 h 的误差：把参数 W 转置，放在 Δ 的右边
Δ 始终在中间，是两个公式共同的核心
```

*检查*：

```
∂L/∂W 的形状 必须和 W 完全一致
Δ_h 的形状   必须和 h 完全一致
形状不对，一定哪里算错了
```

#line(length: 100%, stroke: 0.6pt)

== Transformer 反向传播的连接层

这不是只在输出层才用的特殊公式。Transformer 里几乎每一个有参数的地方，本质上都是一个线性层，都会用到这两个公式：

```
输出投影层 W_lm：
  ∂L/∂W_lm = h^T · Δ_logits
  Δ_h = Δ_logits · W_lm^T

Self-Attention 的 Q/K/V 投影：
  ∂L/∂W_Q = x^T · Δ_Q
  Δ_x = Δ_Q · W_Q^T

FFN 的每一层：
  ∂L/∂W_1 = x^T · Δ_z
  Δ_x = Δ_z · W_1^T
```

形式完全一样，只是每次 $x$、$W$、$Delta$ 换了具体的名字而已。

#line(length: 100%, stroke: 0.6pt)

= 小结

- 2个传播公式的推导以及理解

$ (partial L)/(partial W) = h^T dot.op Delta_"logits" wide "（参数的梯度，交给优化器）" $

$ Delta_h = Delta_"logits" dot.op W^T wide "（输入的误差，继续往前传）" $

#quote[
  掌握了这两个公式，你就掌握了 Transformer 反向传播推导的大部分内容。剩下的是针对特殊的Softmax、RMSNorm、残差连接这些非线性部分，以及Attention多token交联的特殊推导，但它们的推导思路也完全一样：链式法则，一步一步往回追。这是大模型基于Transformer架构学习优化的根本方式。
]

#line(length: 100%, stroke: 0.6pt)

#figure(caption: "误差在Trasnformer可学习参数的表示")[
  #image("imgs/h.png", width: 50%)
]

#line(length: 100%, stroke: 0.6pt)

= 笔者的话

后续将分模块介绍FFN，Attenion，RMSNorm等Transformer经典架构的传反向播过程，以及将通过这里的探讨对Pre与Post-Norm的设计的选择等问题做一些探究～

= 参考资料

- Laurent Bou´,_Deep learning for pedestrians: backpropagation in Transformers_
- Stanford lecture,_cs336(2025-2026)_