
#import "../index.typ": template, tufted

// 如需生成 RSS feed，必须填写 title、description 和 date 元数据
#show: template.with(
  title: "Transformer｜架构演进（4）：Position Encoding 系统（1）——理解绝对位置编码",
  description: "从序列顺序问题出发，理解绝对位置编码的必要性、实现与局限。",
  date: datetime(year: 2026, month: 6, day: 10),
  category: "数学与算法",
  lang: "zh",
)


= Transformer｜架构演进（4）：Position Encoding 系统（1）——理解绝对位置编码

#tufted.post-meta(
  date: datetime(year: 2026, month: 6, day: 10),
  tags: ("Transformer", "位置编码"),
)


#line(length: 100%, stroke: 0.6pt)

#tufted.margin-note[
  *阅读提示：* 我们要进入一个重要的环节：位置编码，虽然它看起来没有Attention和FFN看起来那么重要，本质上有点类似于Vocab输入后的再加工环节，但是笔者认为当今大模型现在的进化快速，至今没人知道实际的原理是什么，而影响这个大黑盒的原因可以非常笼统地分为2面：原材料与模型本身。我们考虑去处理原材料，他可以是文本，图像，视频，各种实验数据，从原材料到模型本身去必须要经过一层加工部分，让模型尽可能逼近最佳地对原材料资源的获取，达到目的方向的资源上限，这会非常有挑战性。我们调侃数据处理工为一种dirty work的时候，需要想想它不可或缺的作用。话不多说，我们开始吧。祝食用愉快～🕶️
]

#line(length: 100%, stroke: 0.6pt)

== *导言*
#figure(caption: "正弦编码")[
  #image("imgs/1.png", width: 40%)
]
在 Vocab 系统里，我们讨论了模型如何把自然语言压缩成 token，再通过 embedding 和 LM Head 在“文本世界”和“向量世界”之间来回转换。

但 token 进入模型之后，还有一个非常关键的问题：

#quote[
  Transformer 怎么知道这些 token 的顺序？
]

Tokenizer 只告诉模型“有哪些 token”，embedding 只给每个 token 一个向量。但一句话的意义不仅取决于有哪些词，还取决于这些词出现的顺序。

比如：

```text
狗 咬 人
人 咬 狗
```

这两个句子包含的 token 很接近，但语义完全不同。

Self-Attention 本身并不天然知道顺序。如果不额外注入位置信息，Transformer 很难区分“谁在前，谁在后”。这就是 *Position Encoding / Positional Embedding* 要解决的问题。

从 2017 年原始 Transformer 到现代长上下文 LLM，位置编码经历了非常清晰的演化路线：从绝对位置，到相对位置，再到 RoPE 以及围绕 RoPE 的长上下文扩展。

#line(length: 100%, stroke: 0.6pt)

== *Position Encoding 的几大路线*

在正式讲绝对位置编码之前，先给出一张整体地图。

位置编码方法大致可以分成几类。

#line(length: 100%, stroke: 0.6pt)

=== *绝对位置编码*

这是最早、最直观的路线。

#quote[
  核心想法是：第 0 个位置、第 1 个位置、第 2 个位置……每个位置都有一个对应的位置向量。模型输入时，把 token embedding 和 position embedding 加起来。
]

典型方法包括：

- Sinusoidal Positional Encoding；
- Learned Absolute Position Embedding。

原始 Transformer 使用的是固定正弦位置编码。BERT、GPT-2 等模型则大量使用 learned absolute position embedding。

#line(length: 100%, stroke: 0.6pt)

=== *相对位置编码*

绝对位置编码告诉模型：这个 token 在第几个位置。

但语言中很多关系更像是相对关系。比如主语和谓语之间相隔多少 token，括号和括号之间距离多远，函数定义和调用之间间隔多长。

因此，后续出现了相对位置方法。它们不直接编码绝对位置，而是在 attention 里加入 query 和 key 之间的相对距离。

典型方法包括：

- Shaw et al. Relative Position Representations；
- Transformer-XL relative positional encoding；
- T5 Relative Position Bias。

#line(length: 100%, stroke: 0.6pt)

=== *RoPE*

RoPE 是现代 LLM 中最重要的位置编码之一。

它在 attention 的 Q 和 K 上施加与位置有关的旋转。这样 attention score 天然带有相对位置信息。

典型代表包括：

- RoFormer / RoPE；
- LLaMA、Qwen、Mistral、DeepSeek 等大量现代 decoder-only LLM。

#line(length: 100%, stroke: 0.6pt)

=== *Attention Bias*

还有一类方法不显式给 hidden state 添加位置向量，直接给 attention score 加上位置偏置。代表方法是 ALiBi。

ALiBi在 attention score 里加一个和距离成比例的线性惩罚。距离越远，注意力分数越低。

它的目标是提升长度外推能力。

#line(length: 100%, stroke: 0.6pt)

=== *长上下文 RoPE Scaling*

#quote[
  现代长上下文模型中，RoPE 仍然很主流。但原始 RoPE 在训练长度之外会遇到外推问题。
]

于是出现了很多 RoPE scaling 方法，例如：

- Position Interpolation；
- NTK-aware Scaling；
- Dynamic NTK Scaling；
- YaRN；
- LongRoPE 等。

它们的核心目标是：在不完全重训模型的情况下，把上下文从 2K、4K、8K 扩展到 32K、128K 甚至更长。

#line(length: 100%, stroke: 0.6pt)

== *Position Encoding 的必要性*

要理解位置编码，先要理解一个事实：

#quote[
  Self-Attention 本身是 permutation equivariant 的。
]

简单说，如果我们不加位置编码，只把一组 token embedding 输入 self-attention，那么模型对这些 token 的顺序并不敏感。

Self-Attention 的核心计算是：

$ Q = X W_Q ,
quad
K = X W_K ,
quad
V = X W_V $

然后：

$ "Attention" (X)
=
"softmax" ((Q K^top)/sqrt(d_k)) V $

这里的 $X$ 是输入 token embedding 矩阵，每一行对应一个 token。

如果我们打乱输入 token 的顺序，本质上就是对 $X$ 的行做一个置换。Self-Attention 的输出也会跟着做同样的置换，但不会知道这个置换本身代表了什么顺序变化。

也就是说，attention 可以建模 token 之间的关系，但它不知道这些 token 原本处在第几个位置。

因此，Transformer 必须额外注入位置信息。

这就是位置编码的动机

#line(length: 100%, stroke: 0.6pt)

== *绝对位置编码的基本思想*

#quote[
  绝对位置编码是最直观的一类方法。
]

它给每个位置分配一个位置向量：

$ p_0 , p_1 , p_2 , ..., p_(L - 1) $

其中 $L$ 是最大序列长度。

假设第 $i$ 个 token 的 token embedding 是：

$ e_i $

它的位置向量是：

$ p_i $

那么输入 Transformer 的向量就是：

$ x_i = e_i + p_i $

也就是说，绝对位置编码采用的是“相加”方式：

```text
token embedding + position embedding → input representation
```

这样做以后，同一个 token 出现在不同位置时，进入模型的表示就不同。

例如，“巴黎”出现在句首和句尾时，token embedding 相同，但位置向量不同：

$ x_"巴黎 at pos 0" = e_"巴黎" + p_0 $

$ x_"巴黎 at pos 10" = e_"巴黎" + p_10 $

这就给模型提供了简单的顺序信息。

#line(length: 100%, stroke: 0.6pt)

=== *相加 or 拼接？*

#quote[
  一个自然问题是：为什么位置向量要和 token embedding 相加，而不是拼接？
]

如果拼接，可以写成：

$ x_i = [e_i ; p_i] $

这样似乎更清楚地区分了 token 信息和位置信息。

- 但原始 Transformer 选择相加，主要有几个原因。
  - 第一，相加不会改变 hidden size。Transformer block 内部所有矩阵都按照固定维度 $d_(m o d e l)$ 设计。如果拼接，维度会变成 $2 d$ 或者 $d + d_p$，后续所有投影矩阵都要改变。
  - 第二，相加是一种简单的特征融合。模型后面的线性层可以自己学习如何利用 token 信息和位置信息。
  - 第三，参数和计算更省。拼接会增加输入维度，从而增加后续 Q/K/V 投影和 FFN 的成本。

当然，相加也有代价：token 信息和位置信息会混在一起，不再显式分离。这也是后续一些论文重新思考 absolute position embedding 的原因。

但从工程角度看，相加非常简单稳定，因此成为最早的主流做法。

#line(length: 100%, stroke: 0.6pt)

== *Sinusoidal Positional Encoding*

2017 年的 *Attention Is All You Need* 使用的是固定正弦位置编码。

它不是可学习参数，而是一个确定函数。

公式是：

$ P E(p o s, 2 i) = sin((p o s)/(10000^(2 i \/ d_(m o d e l)))) $

$ P E(p o s, 2 i + 1) = cos((p o s)/(10000^(2 i \/ d_(m o d e l)))) $

这里：

- $p o s$ 是位置索引；
- $i$ 是维度索引；
- $d_(m o d e l)$ 是模型隐藏维度。

它的设计方式是：每两个维度组成一组正弦/余弦波，不同维度使用不同频率。

低维使用较高频率，可以区分局部位置；高维使用较低频率，可以表示更长范围的位置变化。

#line(length: 100%, stroke: 0.6pt)

=== *构造流程*

可以把正弦位置编码的构造过程拆成四步。
#figure(caption: "前50个位置在不同 embedding 维度上的正弦位置编码值")[
  #image("imgs/2.png", width: 40%)
]
==== *1. 先确定最大长度和 hidden size*

假设模型最大长度是 $L$，hidden size 是 $d$。

我们要构造一个位置编码矩阵：

$ P in RR^(L times d) $

其中第 $p o s$ 行就是位置 $p o s$ 的位置向量。

==== *2. 每个位置都要生成一个 $d$ 维向量*

对于每个位置：

$ p o s = 0, 1, 2, ..., L - 1 $

都要生成：

$ P E(p o s) in RR^d $

==== *3. 每两个维度使用一组 sin/cos*

第 $2 i$ 维使用 sine：

$ P E(p o s, 2 i) = sin(p o s dot.op omega_i) $

第 $2 i + 1$ 维使用 cosine：

$ P E(p o s, 2 i + 1) = cos(p o s dot.op omega_i) $

其中：

$ omega_i = 10000^(-2 i \/ d) $

==== *4. 把位置向量加到 token embedding 上*

如果 token embedding 是：

$ e_(p o s) $

位置编码是：

$ p_(p o s) $

输入 Transformer 的向量就是：

$ x_(p o s) = e_(p o s) + p_(p o s) $

这样，同一个 token 出现在不同位置时，最终输入向量不同。

#line(length: 100%, stroke: 0.6pt)

=== *不同频率？*

#quote[
  如果只用一种频率，位置编码会很容易出现周期性混淆。
]
可以把正弦位置编码的构造过程拆成四步。
#figure(caption: "正弦位置编码不同维度对应不同频率，不同频率覆盖不同位置尺度。")[
  #image("imgs/3.png", width: 40%)
]
例如只用：

$ sin(p o s) $

那么随着 $p o s$ 增大，sin 值会不断周期性重复。不同位置可能得到相同或非常接近的值。

但语言里的位置关系既有局部关系，也有长距离关系。

模型既需要知道：

- 当前 token 和前一个 token 的关系；
- 当前 token 和几十个 token 前的关系；
- 当前 token 和几百、几千 token 前的关系。

所以正弦位置编码使用了一组频率。

高频维度变化快，适合区分局部位置；低频维度变化慢，适合表达长距离位置。

这就是多频率设计的核心价值。

#line(length: 100%, stroke: 0.6pt)

=== *相对偏移*

#quote[
  只用 sine 也能表示周期变化，为什么还要 cosine？
]

一个重要原因是：sin 和 cos 可以组成二维旋转空间。

对于某个频率 $omega$，位置 $p o s$ 的编码可以写成：

$ mat(delim: "[", sin(p o s omega);
cos(p o s omega)) $

当位置增加一个偏移 $k$ 时：

$ sin((p o s + k) omega)
=
sin(p o s omega) cos(k omega) + cos(p o s omega) sin(k omega) $

$ cos((p o s + k) omega)
=
cos(p o s omega) cos(k omega) - sin(p o s omega) sin(k omega) $

这说明：

$ P E(p o s + k) $

可以由：

$ P E(p o s) $

通过一个只和偏移 $k$ 有关的线性变换得到。

更具体地说，在每个频率对应的二维子空间里，位置增加 $k$ 相当于旋转一个角度 $k omega$。

这就是正弦位置编码非常重要的性质：

#quote[
  它虽然是绝对位置编码，但天然包含相对偏移结构。
]

_*这也是后来 RoPE 的思想来源之一。RoPE 更进一步，不是把 sin/cos 加到 token embedding 上，而是直接在 Q/K 空间里做旋转，让 attention score 显式依赖相对距离。*_

#line(length: 100%, stroke: 0.6pt)

=== *从傅立叶视角理解正弦位置编码*

正弦位置编码也可以从傅立叶特征的角度理解。

傅立叶分析的核心思想是：复杂信号可以由不同频率的正弦和余弦基函数组合表示。

换句话说，sin/cos 是一组非常基础的“频率基”。

在位置编码里，我们并不是要还原一个连续信号，而是要把离散位置 $p o s$ 映射到一个高维空间。使用多频率 sin/cos，相当于给位置加了一组 Fourier features：

$ p o s |-> [sin(p o s omega_1), cos(p o s omega_1), ..., sin(p o s omega_m), cos(p o s omega_m)] $

这种映射有几个好处。

==== *1. 把一维位置映射到高维周期特征*

原始位置只是一个整数：

$ p o s = 17 $

这个整数本身很难让神经网络直接利用。

傅立叶特征把它展开成多个频率下的响应。模型可以通过后续线性层组合这些频率，学习复杂的位置模式。

==== *2. 多尺度表示*

不同频率对应不同尺度。

高频捕捉短距离差异，低频捕捉长距离趋势。

这和傅立叶表示中“高频表示细节，低频表示整体结构”的直觉一致。

==== *3. 有利于外推*

因为正弦位置编码是函数形式，不是有限参数表。只要给定任意位置 $p o s$，都可以计算：

$ P E(p o s) $

这让它在形式上可以外推到比训练长度更长的位置。

不过要注意：

#quote[
  函数能计算更长位置，不代表模型一定能正确使用更长位置。
]

模型是否具备长上下文能力，还取决于训练长度、训练数据、attention pattern、优化过程和任务监督。

#line(length: 100%, stroke: 0.6pt)

=== *为什么底数是 10000？*

原始 Transformer 里使用的是：

$ 10000^(2 i \/ d_(m o d e l)) $

这个 10000 其实算是一个经验设计。它的作用是控制频率范围。

频率为：

$ omega_i = 10000^(-2 i \/ d) $

- 当 $i$ 较小时，$omega_i$ 较大，波长较短。
- 当 $i$ 较大时，$omega_i$ 较小，波长较长。

因此，10000 决定了最低频和最高频之间的跨度。

- 如果底数太小，不同频率之间跨度不够，长距离位置可能区分不好。
- 如果底数太大，低频维度变化太慢，部分维度在训练长度内几乎不变化，利用率可能降低。

所以 10000 可以理解为一种让频率覆盖从局部到全局的尺度选择。

后来 RoPE 中也有类似的 base 参数，例如很多模型使用：

$ theta = 10000 $

或者为了长上下文改成更大的 base，例如某些模型会使用更大的 rope theta。

_*这说明位置编码里的频率范围，其实是长上下文能力的一个重要部分。*_

#line(length: 100%, stroke: 0.6pt)

== *Learned Absolute Position Embedding*

#quote[
  后来很多模型没有使用固定正弦函数，而是直接学习一个位置 embedding table。
]

形式是：

$ P in RR^(L_(m a x) times d) $

其中 $L_(m a x)$ 是最大上下文长度。

第 $i$ 个位置的位置向量就是：

$ p_i = P_i $

输入仍然是：

$ x_i = e_i + p_i $

这种方法叫 *Learned Absolute Position Embedding*。

BERT、GPT-2 等模型都采用了类似思想。

它的好处是非常直接：位置向量由模型自己学习，不需要人为指定 sin/cos 频率。只要训练数据足够，模型可以学到对任务最有用的位置模式。

在固定长度任务中，learned absolute position embedding 通常非常有效。

比如 BERT 的最大位置长度通常是 512。对于很多分类、抽取、句子匹配任务，512 以内的 learned absolute position embedding 足够好。

GPT-2 使用 learned position embedding，在固定上下文窗口内也表现稳定。

#line(length: 100%, stroke: 0.6pt)

=== *Learned Position Embedding 的 forward 过程*

#quote[
  既然这是一个可学习参数，那么你是否好奇它在整个模型的训练过程中是怎么被训练的呢？往下看，先看forward过程。
]

假设输入序列是：

```text
法国 的 首都 是 巴黎
```

它的 token embedding 是：

$ e_0 , e_1 , e_2 , e_3 , e_4 $

对应的位置 embedding 是：

$ p_0 , p_1 , p_2 , p_3 , p_4 $

那么模型真正输入的是：

$ x_0 = e_0 + p_0 $

$ x_1 = e_1 + p_1 $

$ x_2 = e_2 + p_2 $

$ x_3 = e_3 + p_3 $

$ x_4 = e_4 + p_4 $

这些 $x_i$ 进入 Transformer，经过多层 attention 和 FFN，最后产生 loss。

#line(length: 100%, stroke: 0.6pt)

=== *Learned Position Embedding 的 backward 过程*

训练时，loss 会对输入向量 $x_(p o s)$ 产生梯度：

$ (partial L)/(partial x_(p o s)) $

因为：

$ x_(p o s) = e_(t o k e n) + p_(p o s) $

所以对 token embedding 和 position embedding 的梯度是相同路径分出来的：

$ (partial L)/(partial e_(t o k e n)) + = (partial L)/(partial x_(p o s)) $

$ (partial L)/(partial p_(p o s)) + = (partial L)/(partial x_(p o s)) $

也就是说，位置向量 $p_(p o s)$ 会根据它所在位置对最终预测的影响被更新。

如果位置 0 经常承担句首角色，位置 1 经常承担句子早期上下文角色，那么这些位置 embedding 会逐渐学到和这些位置功能相关的表示。

#line(length: 100%, stroke: 0.6pt)

=== *位置向量会被哪些信号更新？*

以 causal LM 为例，假设训练句子是：

```text
法国 的 首都 是 巴黎
```

模型会预测每个位置的下一个 token。

位置 0 的输入会影响后面多个预测；位置 3 的输入会直接影响预测“巴黎”。

因此，位置 embedding 的更新来自所有经过该位置输入向量的 loss 信号。

如果位置 $p o s$ 在很多训练样本中出现，它对应的位置向量 $p_(p o s)$ 会不断被更新。

- 训练后，不同位置可能形成不同功能：
  - 靠前位置可能学习到句首、prefix、prompt 开始的统计特征；
  - 中间位置学习普通上下文位置；
  - 靠近最大长度的位置，如果训练中出现较少，可能学习不足。

同时这解释了 learned absolute position embedding 的一个重要问题：

#quote[
  它只会学到训练中出现过的位置分布。
]

如果训练时很少出现接近最大长度的位置，这些位置的 embedding 会训练不足。

而如果推理时使用超过训练长度的位置，那些位置根本没有 learned embedding。

#line(length: 100%, stroke: 0.6pt)

=== *Learned Absolute 在训练长度以内的效果*

Learned position embedding 的优势是灵活。

正弦位置编码预先规定了位置向量的结构，而 learned position embedding 让模型自己决定每个位置应该是什么向量。

如果任务长度固定，训练数据充足，learned absolute position embedding 可以直接优化到任务最需要的位置模式。

比如 BERT 的很多任务都在 512 token 内，模型只需要学好：

$ p_0 , p_1 , ..., p_511 $

在这种固定窗口内，learned position embedding 通常很有效。

它不需要满足 sin/cos 结构，也不需要具备外推性质，只需要在训练窗口内服务好任务目标。这就是它的优势。

#line(length: 100%, stroke: 0.6pt)

=== *正弦编码和 Learned 编码的对比*

可以从几个维度比较这两种绝对位置编码。

#table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  align: (left, left, left, left, left, left),
  table.header([*方法*], [*参数*], [*结构偏置*], [*训练长度内表现*], [*长度外推*], [*典型模型*]),
  [Sinusoidal PE], [无参数], [强，多频率 Fourier 特征], [稳定], [形式上可外推], [原始 Transformer], [Learned Absolute PE], [有参数], [弱，完全从数据学], [训练长度内强], [较弱], [BERT、GPT-2]
)

#line(length: 100%, stroke: 0.6pt)

== *绝对位置编码在 Encoder 和 Decoder 中的不同表现*

#quote[
  绝对位置编码在 encoder-only 和 decoder-only 模型中有不同特点。
]

#line(length: 100%, stroke: 0.6pt)

=== *Encoder-only 模型*

BERT 这类 encoder-only 模型通常使用双向 attention。输入长度相对固定，很多任务也在 512 token 内完成。

因此 learned absolute position embedding 在 BERT 中非常自然。对于分类、抽取、匹配任务，这通常就足够。

#line(length: 100%, stroke: 0.6pt)

=== *Decoder-only 模型*

GPT 类 decoder-only 模型是自回归生成。它每次根据前文预测下一个 token。

早期 GPT / GPT-2 使用 learned absolute position embedding，也可以工作。

但随着上下文窗口不断变长，learned absolute position embedding 的限制就更明显。

如果训练窗口是 1024，那么模型对 1024 之后的位置没有自然定义。即使扩展表，也需要额外训练。

这也是为什么现代 decoder-only LLM 后来更倾向 RoPE、ALiBi 或其他更适合长度扩展的方案。

#line(length: 100%, stroke: 0.6pt)

== *绝对位置编码为什么会被后续方法取代？*

绝对位置编码解决了 Transformer 的第一个问题：没有顺序感。但它没有很好解决第二个问题：如何建模 token 之间的相对距离。

在短序列任务中，绝对位置足够好。但在长文本、代码、对话、工具调用、长文档 QA 中，模型更需要知道：

#quote[
  当前 token 和另一个 token 相隔多远，它们之间的相对关系是什么。
]

这个问题更贴近 attention 的结构。

因为 attention 本来就是在计算 token 与 token 之间的关系。

所以，位置编码的第二阶段自然走向了 relative positional encoding。

#line(length: 100%, stroke: 0.6pt)

== *从绝对位置到现代长上下文*

- 可以把位置编码的演化理解成这样：
  - 首先，原始 Transformer 用正弦绝对位置编码解决“Transformer 不知道顺序”的问题。
  - 然后，BERT、GPT-2 等模型使用 learned absolute position embedding，在固定长度预训练中获得更灵活的位置表示。
  - 接着，研究者发现绝对位置不擅长表达相对距离，于是出现 Shaw、Transformer-XL、T5 这类 relative position 方法。
  - 再后来，RoPE 把绝对位置和相对位置结合得更优雅：它用绝对位置旋转 Q/K，但 attention score 里自然出现相对位置信息。
  - 最后，随着上下文扩展到 32K、128K、1M+，RoPE 本身也需要 scaling，于是出现 Position Interpolation、NTK Scaling、YaRN 等长上下文扩展方法。
- 这说明位置编码的核心问题一直在变化：
  - 早期：模型如何知道顺序？
  - 中期：模型如何知道相对距离？
  - 现代：模型如何在极长上下文中稳定使用远距离信息？

#line(length: 100%, stroke: 0.6pt)

== *小结*

绝对位置编码是 Transformer 位置建模的起点。它的基本思想非常简单：给每个位置一个位置向量，然后和 token embedding 相加。

原始 Transformer 使用固定正弦位置编码。它通过多频率 sin/cos 函数，为每个位置生成一个结构化位置向量。它的一个重要性质是，对于固定偏移 $k$，$P E(p o s + k)$ 可以由 $P E(p o s)$ 线性表示，这让模型有机会学习相对位置关系。

后来的 BERT、GPT-2 等模型大量使用 learned absolute position embedding。它在训练长度内灵活有效，但最大长度固定，长度外推能力较弱。

绝对位置编码的贡献是明确的：它让 Transformer 获得顺序感。

但它的局限也很明显：相对距离建模不直接，位置和内容纠缠，learned absolute 难以外推到更长上下文。

所以，位置编码的演化自然走向了下一阶段：相对位置编码。

#line(length: 100%, stroke: 0.6pt)

== *笔者的话*

#quote[
  这里是位置编码的第一部分，简单介绍了一下比较有代表性的2种编码方式，后续会聚焦于更加常用的方法。虽然这里绝对位置编码看起来已经较为落后，但是他的编码方式在一些特定领域的任务上还是展现出一定的效果，以巧妙的方式与应用场景结合。
]

#line(length: 100%, stroke: 0.6pt)

== *参考文献与延伸阅读*

+ Vaswani et al., 2017. *Attention Is All You Need.*\
原始 Transformer 论文，提出 sinusoidal positional encoding。\
#link("https://arxiv.org/abs/1706.03762")[https://arxiv.org/abs/1706.03762]
+ Devlin et al., 2018. *BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding.*\
BERT 使用 learned absolute position embeddings，典型最大长度为 512。\
#link("https://arxiv.org/abs/1810.04805")[https://arxiv.org/abs/1810.04805]
+ Radford et al., 2019. *Language Models are Unsupervised Multitask Learners.*\
GPT-2 使用 learned absolute position embeddings。\
#link("https://cdn.openai.com/better-language-models/language_models_are_unsupervised_multitask_learners.pdf")[https://cdn.openai.com/better-language-models/language\_models\_are\_unsupervised\_multitask\_learners.pdf]
+ Shaw et al., 2018. *Self-Attention with Relative Position Representations.*\
相对位置编码经典工作
#link("https://arxiv.org/abs/1803.02155")[https://arxiv.org/abs/1803.02155]
+ Dai et al., 2019. *Transformer-XL: Attentive Language Models Beyond a Fixed-Length Context.*\
使用相对位置机制支持跨 segment 长程建模。\
#link("https://arxiv.org/abs/1901.02860")[https://arxiv.org/abs/1901.02860]
+ Raffel et al., 2020. *Exploring the Limits of Transfer Learning with a Unified Text-to-Text Transformer.*\
T5 使用 relative position bias。\
#link("https://arxiv.org/abs/1910.10683")[https://arxiv.org/abs/1910.10683]
+ Su et al., 2021. *RoFormer: Enhanced Transformer with Rotary Position Embedding.*\
提出 RoPE，现代 LLM 中广泛使用。\
#link("https://arxiv.org/abs/2104.09864")[https://arxiv.org/abs/2104.09864]
+ Press et al., 2022. *Train Short, Test Long: Attention with Linear Biases Enables Input Length Extrapolation.*\
提出 ALiBi。\
#link("https://arxiv.org/abs/2108.12409")[https://arxiv.org/abs/2108.12409]
+ Chen et al., 2023. *Extending Context Window of Large Language Models via Positional Interpolation.*\
RoPE 长上下文扩展中的 Position Interpolation。\
#link("https://arxiv.org/abs/2306.15595")[https://arxiv.org/abs/2306.15595]
+ Peng et al., 2023. *YaRN: Efficient Context Window Extension of Large Language Models.*\
RoPE 长上下文扩展方法。\
#link("https://arxiv.org/abs/2309.00071")[https://arxiv.org/abs/2309.00071]
