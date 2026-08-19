#import "../index.typ": template, tufted

// 如需生成 RSS feed，必须填写 title、description 和 date 元数据
#show: template.with(
  title: "Transformer｜架构演进（扩展）：Unigram LM 的 Subword 概率收敛证明",
  description: "围绕 Unigram LM，推导 Subword 概率更新与收敛过程，并联系 Tokenization 实践。",
  date: datetime(year: 2026, month: 6, day: 8),
  category: "数学与算法",
  lang: "zh",
)


= Transformer｜架构演进（扩展）：Unigram LM 的 Subword 概率收敛证明

#tufted.post-meta(
  date: datetime(year: 2026, month: 6, day: 8),
  tags: ("Transformer", "数学推导"),
)


#line(length: 100%, stroke: 0.6pt)
#tufted.margin-note[
  *阅读提示：* 这是拓展内容，仅作参考学习。祝食用愉快～🌧️
]

== 导言

#quote[
  前面讲 Unigram LM 的时候，我们说它和 BPE、WordPiece 的思路不太一样。
]

BPE 和 WordPiece 更像是“从小到大”构造子词：一开始是字符，然后不断合并。

Unigram LM 则更像是“从大到小”筛选子词：一开始准备一个较大的候选 subword 词表，然后通过概率模型判断哪些 subword 更重要，逐步删除贡献较小的 token。

这里自然会出现一个问题：

#quote[
  Unigram LM 怎么知道每个 subword 的概率应该是多少？
]

答案是：通常可以用 *EM 算法* 来估计。

#line(length: 100%, stroke: 0.6pt)

EM 的直觉是：一句话可以有很多种切分方式，而切分方式本身是不可观测的隐变量。我们看得到的是原始文本，看不到“这句话到底应该由哪一种 subword segmentation 生成”。所以 EM 会在两件事之间反复迭代：

- E-step：在当前参数下，估计每种切分方式有多可能；
- M-step：根据这些“软切分”的期望计数，重新估计每个 subword 的概率。

#quote[
  后续推导过程详细可见Vocab演进（1）补充部分
]

*但是在推导之前，注意到我们有一个假设：subword概率收敛，这又是为什么呢？*

我们会发现在这个收敛的过程本质上语料的log likelihood是不会下降的——它为什么不会越训练越差？

这就是 EM 最经典的性质：

#quote[
  *每次 EM 迭代后，数据的 log likelihood 不会下降。*
]

这保证了subword的概率必定收敛到一个值域内。

下面我们简要证明这个结论。

#line(length: 100%, stroke: 0.6pt)

== 优化目标

#quote[
  再回顾一下 Unigram LM优化的目标
]

假设有一个字符串或者句子 $x$。

在 Unigram LM 里，$x$ 可能有很多种合法切分方式。我们用 $z$ 表示其中一种切分。

例如：

```text
unbelievable
```

可能有切法：

```text
un + believe + able
un + believable
unbelievable
u + n + believe + able
```

这些不同的切分方式就是隐变量 $z$。

如果一个切分 $z$ 由若干 subword 组成：

$ z = (v_1 , v_2 , ..., v_m) $

那么在 Unigram LM 中，这个切分的概率通常写成：

$ P(z divides theta) = product_(i = 1)^m P(v_i) $

其中 $theta$ 就是所有 subword 的概率参数。

但训练数据里我们只看到 $x$，没有看到真实切分 $z$。所以 $x$ 的概率要对所有可能切分求和：

$ P(x divides theta) = sum_(z in Z(x)) P(x, z divides theta) $

这里 $Z(x)$ 表示 $x$ 的所有可能切分。

因此，整个语料的 log likelihood 是：

$ L(theta) = sum_x log P(x divides theta) $

展开后就是：

$ L(theta) = sum_x log sum_(z in Z(x)) P(x, z divides theta) $

我们发现难点就在这里：

#quote[
  *log 外面包着一个对隐变量 $z$ 的求和。*
]

这个结构直接优化很麻烦，会导致每次优化都要全部重算语料概率再去计数每个语料的贡献。

_*而EM 的优化核心思路就是：不直接优化这个难处理的 $L(theta)$，而是每一轮构造一个更容易优化的下界。*_

#line(length: 100%, stroke: 0.6pt)

== 下界

对每个 $x$，我们引入一个任意的分布 $q_x (z)$。

它表示：在当前讨论中，我们暂时认为切分 $z$ 的权重是多少。

要求只有两个：

$ sum_z q_x (z) = 1 $

并且：

$ q_x (z) >= 0 $

现在我们对 $P(x divides theta)$ 做一个变形：

$ log P(x divides theta)
=
log sum_z P(x, z divides theta) $

乘上一个 $(q_x (z))/(q_x (z))$，得到：

$ log sum_z P(x, z divides theta)
=
log sum_z q_x (z) (P(x, z divides theta))/(q_x (z)) $

这一步只是代数变形，没有改变值。

接下来用 Jensen 不等式。

因为 $log$ 是凹函数，所以：

$ log sum_z q_x (z) y_z
>=
sum_z q_x (z) log y_z $

令：

$ y_z = (P(x, z divides theta))/(q_x (z)) $

就得到：

$ log sum_z q_x (z) (P(x, z divides theta))/(q_x (z))
>=
sum_z q_x (z) log (P(x, z divides theta))/(q_x (z)) $

因此：

$ log P(x divides theta)
>=
sum_z q_x (z) log (P(x, z divides theta))/(q_x (z)) $

对整个语料求和：

$ L(theta)
>=
sum_x sum_z q_x (z) log (P(x, z divides theta))/(q_x (z)) $

我们把右边记为：

$ cal(F) (q, theta)
=
sum_x sum_z q_x (z) log (P(x, z divides theta))/(q_x (z)) $

于是有：

$ L(theta) >= cal(F) (q, theta) $

这就是 EM 的关键：

#quote[
  *$cal(F) (q, theta)$ 是真实 log likelihood $L(theta)$ 的一个下界。*
]

EM 每一轮不是直接优化 $L$，而是先构造一个下界，然后优化这个下界。

#line(length: 100%, stroke: 0.6pt)

== 下界逼近

现在的问题变成：

#quote[
  我们应该怎么选 $q_x (z)$，才能让这个下界尽可能贴近真实的 $L(theta)$？
]

Jensen 不等式什么时候取等？

对于凹函数 $log$，当所有 $y_z$ 在 $q_x (z) > 0$ 的地方都相等时，取等。

也就是：

$ (P(x, z divides theta))/(q_x (z))
=
"constant" $

整理一下：

$ q_x (z)
prop
P(x, z divides theta) $

因为 $q_x (z)$ 必须归一化，所以：

$ q_x (z)
=
(P(x, z divides theta))/(sum_(z') P(x, z' divides theta)) $

而分母就是：

$ P(x divides theta) $

所以：

$ q_x (z)
=
(P(x, z divides theta))/(P(x divides theta))
=
P(z divides x, theta) $

也就是说，当 $q_x (z)$ 取当前模型参数下的后验分布时：

$ q_x (z) = P(z divides x, theta) $

下界和真实 log likelihood 完全贴合。

这就是 E-step 的数学含义：

#quote[
  *E-step 用当前参数 $theta^(o l d)$ 计算每种切分的后验概率，让下界在当前参数点和 $L$ 完全贴合。*
]

具体到 Unigram LM，就是给每一种可能的 subword 切分分配一个概率权重。

某个切分越符合当前 subword 概率，它的后验概率就越高。

#line(length: 100%, stroke: 0.6pt)

== 下界差距与 KL 散度

#quote[
  上面的 Jensen 推导已经说明了 $cal(F)$ 是下界。但还有一个更直观的方式可以看出为什么这个下界成立。
]

从：

$ cal(F) (q, theta)
=
sum_z q_x (z) log (P(x, z divides theta))/(q_x (z)) $

出发。

由于：

$ P(x, z divides theta)
=
P(z divides x, theta) P(x divides theta) $

代入：

$ cal(F) (q, theta)
=
sum_z q_x (z) log (P(z divides x, theta) P(x divides theta))/(q_x (z)) $

展开：

$ cal(F) (q, theta)
=
sum_z q_x (z) log P(x divides theta)
+
sum_z q_x (z) log (P(z divides x, theta))/(q_x (z)) $

因为 $log P(x divides theta)$ 和 $z$ 无关，而且 $sum_z q_x (z) = 1$，所以第一项就是：

$ log P(x divides theta) $

第二项可以写成负的 KL 散度：

$ -upright(K L) (q_x (z) bar.v.double P(z divides x, theta)) $

因此：

$ cal(F) (q, theta)
=
log P(x divides theta)
-
upright(K L) (q_x (z) bar.v.double P(z divides x, theta)) $

也就是：

$ log P(x divides theta)
=
cal(F) (q, theta)
+
upright(K L) (q_x (z) bar.v.double P(z divides x, theta)) $

而 KL 散度永远非负：

$ upright(K L) (q bar.v.double p) >= 0 $

所以：

$ log P(x divides theta) >= cal(F) (q, theta) $

这再次说明 $cal(F)$ 是下界。

并且，当：

$ q_x (z) = P(z divides x, theta) $

KL 散度为 0，下界取等。

这就是 E-step 为什么要选后验分布的原因：

#quote[
  *它让 KL gap 变成 0，让下界贴到真实目标函数上。*
]

#line(length: 100%, stroke: 0.6pt)

== 期望计数归一化

E-step 之后，我们得到了每种切分的后验概率 $q_x (z)$。

接下来 M-step 固定 $q_x (z)$，最大化下界：

$ cal(F) (q, theta) $

在 Unigram LM 中，一个切分 $z$ 的概率是其中所有 subword 概率的乘积：

$ P(z divides theta) = product_(v in z) P(v) $

取 log 后：

$ log P(z divides theta) = sum_v c(v, z) log P(v) $

其中 $c(v, z)$ 表示 subword $v$ 在切分 $z$ 中出现了多少次。

代入下界后，和 $theta$ 有关的部分可以写成：

$ sum_x sum_z q_x (z) sum_v c(v, z) log P(v) $

交换求和顺序：

$ sum_v
(
sum_x sum_z q_x (z) c(v, z)
)
log P(v) $

括号里的量就是 subword $v$ 的期望计数，记为：

$ E [v]
=
sum_x sum_z q_x (z) c(v, z) $

所以 M-step 要最大化的是：

$ sum_v E [v] log P(v) $

约束是所有 subword 概率和为 1：

$ sum_v P(v) = 1 $

这是一个标准的带约束优化问题。

用拉格朗日乘子：

$ cal(J)
=
sum_v E [v] log P(v)
+
lambda(sum_v P(v) - 1) $

对 $P(v)$ 求导：

$ (partial cal(J))/(partial P(v))
=
(E [v])/(P(v)) + lambda $

令导数为 0：

$ (E [v])/(P(v)) + lambda = 0 $

得到：

$ P(v) = - (E [v])/lambda $

利用归一化约束：

$ sum_v P(v) = 1 $

代入：

$ sum_v - (E [v])/lambda = 1 $

所以：

$ -1/lambda sum_v E [v] = 1 $

得到：

$ lambda = - sum_v E [v] $

因此：

$ P(v) = (E [v])/(sum_(v') E [v']) $

这就是 Unigram LM 中常见的 M-step 更新公式：

$ P(v) = (E [v])/(sum_(v') E [v']) $

它的含义非常直观：

#quote[
  一个 subword 在所有可能切分中的期望出现次数越多，它的新概率就越大。
]

#line(length: 100%, stroke: 0.6pt)

== $L$非下降趋势

现在我们把 E-step 和 M-step 串起来。

设旧参数是：

$ theta^(o l d) $

E-step 计算：

$ q_x (z) = P(z divides x, theta^(o l d)) $

于是下界在旧参数处和真实 likelihood 贴合：

$ cal(F) (q, theta^(o l d)) = L(theta^(o l d)) $

接着 M-step 固定 $q$，选择新参数：

$ theta^(n e w)
=
arg max_theta cal(F) (q, theta) $

所以一定有：

$ cal(F) (q, theta^(n e w))
>=
cal(F) (q, theta^(o l d)) $

另一方面，因为 $cal(F)$ 永远是 $L$ 的下界，所以：

$ L(theta^(n e w))
>=
cal(F) (q, theta^(n e w)) $

把三步连起来：

$ L(theta^(n e w))
>=
cal(F) (q, theta^(n e w))
>=
cal(F) (q, theta^(o l d))
=
L(theta^(o l d)) $

因此：

$ L(theta^(n e w)) >= L(theta^(o l d)) $

这就是 EM 单调性的证明。

每一轮迭代之后，真实 log likelihood 要么变大，要么不变，不会下降。

#line(length: 100%, stroke: 0.6pt)

== subword 收敛

#quote[
  既然每一轮都不下降，那它会不会一直涨到无穷大？subword收敛又是在这个基础上怎么看的?
]

不会。

因为对于每个观测样本 $x$，概率满足：

$ 0 <= P(x divides theta) <= 1 $

所以：

$ log P(x divides theta) <= 0 $

因此整个语料的 log likelihood：

$ L(theta) = sum_x log P(x divides theta) $

也有上界，最多不会超过 0。

- 所以我们有两个事实：
  + $L(theta)$ 单调不减；
  + $L(theta)$ 有上界。

单调递增有上界，于是 $L(theta)$ 这个数值序列一定会收敛。

*不过要注意，这里说的是 log likelihood 的值收敛。实际参数是否收敛到唯一点，还需要额外条件。*

#line(length: 100%, stroke: 0.6pt)

== 收敛非全局最优

EM 还有一个很重要的限制：

#quote[
  *EM 保证 likelihood 不下降，但不保证找到全局最优。*
]

原因是隐变量模型的 likelihood 通常不是凸函数，可能有多个局部最优点。

不同初始化可能会导致不同结果。

在 Unigram LM 里，这意味着：

- 初始候选 subword 词表会影响最终结果；
- 初始概率会影响收敛路径；
- pruning 策略会影响哪些 token 被保留；
- 最终词表不一定是全局最优词表。

所以 EM 的保证是比较温和的：

#quote[
  每一步不会变差，最后会收敛到一个稳定点，但这个稳定点可能只是局部最优。
]

这也是为什么实际训练 SentencePiece / Unigram tokenizer 时，候选词表构造、vocab size、character coverage、pruning 轮次等工程细节都很重要。

#line(length: 100%, stroke: 0.6pt)

== 与 tokenizer

#quote[
  这部分数学推导看起来有点抽象，但它其实解释了 Unigram LM tokenizer 的核心机制。
]

在 BPE 里，tokenizer 通过频率合并来构造词表。

而在 Unigram LM 里，tokenizer 更像是在做概率建模：

- 每个 subword 有一个概率；
- 每句话有多种可能切分；
- 每种切分都有一个后验概率；
- E-step 估计这些切分的软权重；
- M-step 根据软计数更新 subword 概率；
- 低贡献 token 会在后续 pruning 中被删除。

这也是为什么 Unigram LM 天然适合 subword regularization。

因为它不只是给出一种确定切分，而是保留了“多种切分可能性”的概率结构。

例如：

```text
internationalization
```

可以有多种切分：

```text
international + ization
inter + national + ization
internationalization
```

训练模型时可以按概率采样不同切分，让模型不要过度依赖某一种固定 segmentation。

这就是 Kudo 在 Subword Regularization 中强调的思想：利用 segmentation ambiguity 作为一种噪声和数据增强，提高模型鲁棒性。

#line(length: 100%, stroke: 0.6pt)

== 小结

Unigram LM 之所以可以用 EM 训练，是因为 tokenization 中存在一个天然隐变量：切分方式 $z$。

我们看得到文本 $x$，但看不到它“应该”采用哪一种 subword 切分。EM 通过后验概率对所有切分进行软计数，再用这些期望计数更新 subword 概率。

数学上，EM 每一轮都会构造一个 log likelihood 的下界：

$ cal(F) (q, theta) $

E-step 让这个下界在当前参数处和真实目标函数贴合；M-step 最大化这个下界。于是有：

$ L(theta^(n e w))
>=
cal(F) (q, theta^(n e w))
>=
cal(F) (q, theta^(o l d))
=
L(theta^(o l d)) $

所以：

$ L(theta^(n e w)) >= L(theta^(o l d)) $

再加上 $L$ 本身有上界，因此 EM 的 log likelihood 会收敛。

但它只保证收敛到局部最优，不保证全局最优。

#quote[
  *即：EM 在 Unigram LM 中做的事，就是在所有可能切分之间分配概率责任，再根据这些软责任更新 subword 概率；它每轮都不会降低 likelihood，因此训练过程稳定，但最终结果仍然依赖初始化和剪枝策略。*
]

#line(length: 100%, stroke: 0.6pt)

== 笔者的话

#quote[
  对每一个问题发现了之后去尽量弄明白是件比较好的习惯。如果你愿意的的话，就请打破砂锅尽情的问吧，狠狠地打破！
]

#line(length: 100%, stroke: 0.6pt)

== 关联

- Transformer｜架构演进（1）：Vocab 系统（1）——Tokenizer 与 Vocabulary Size： Unigram LM补充部分
