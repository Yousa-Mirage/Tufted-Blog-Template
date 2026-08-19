#import "../index.typ": template, tufted

// 如需生成 RSS feed，必须填写 title、description 和 date 元数据
#show: template.with(
  title: "线性代数｜矩阵分块优化与 Strassen 算法",
  description: "从传统矩阵乘法出发，理解分块矩阵、Strassen 七次乘法公式、复杂度下降的原因，以及快速矩阵乘法的后续发展。",
  date: datetime(year: 2026, month: 5, day: 13),
  category: "数学与算法",
  lang: "zh",
)

= 线性代数｜矩阵分块优化与 Strassen 算法

#tufted.post-meta(
  date: datetime(year: 2026, month: 5, day: 13),
  tags: ("线性代数", "算法"),
)

#tufted.margin-note[
  这篇文章整理自“线性代数：探究（2）”。核心问题是：矩阵乘法能不能不再停留在 $O(n^3)$？
]

Strassen 算法由 Volker Strassen 在 1969 年提出，是矩阵快速乘法中一个非常经典的突破。它的关键不是改变矩阵乘法的定义，而是重新组织计算过程：用更多加减法换取更少的递归乘法次数。

== 传统矩阵乘法

对两个 $n times n$ 矩阵 $A$ 与 $B$，乘积 $C = A B$ 的第 $i$ 行第 $j$ 列元素为：

$
  C_(i j) = sum_(k=1)^n A_(i k) B_(k j)
$

这个公式直接对应三重循环，因此朴素算法的时间复杂度是 $O(n^3)$。当矩阵规模很大时，乘法次数会迅速成为主要瓶颈。

== 矩阵分块思想

分块矩阵的做法是把一个大矩阵切成若干个子矩阵，然后把每个子矩阵当成“元素”进行运算。对于两个 $n times n$ 矩阵，可以先按 2×2 方式分块：

$
  A = mat(
    A_(11), A_(12);
    A_(21), A_(22)
  ), quad
  B = mat(
    B_(11), B_(12);
    B_(21), B_(22)
  ), quad
  C = mat(
    C_(11), C_(12);
    C_(21), C_(22)
  )
$

按照普通分块乘法，四个结果块分别是：

$
  C_(11) &= A_(11) B_(11) + A_(12) B_(21) \
  C_(12) &= A_(11) B_(12) + A_(12) B_(22) \
  C_(21) &= A_(21) B_(11) + A_(22) B_(21) \
  C_(22) &= A_(21) B_(12) + A_(22) B_(22)
$

这样计算仍然需要 8 次子矩阵乘法和若干次加法。若递归地使用这种分块方式，递推式为：

$
  T(n) = 8 T(n / 2) + O(n^2) = O(n^3)
$

也就是说，单纯分块并没有改变复杂度指数。

== Strassen 的关键问题

真正的问题变成了：能不能只用 7 次子矩阵乘法，再通过加减法组合出同样的四个结果块？

乘法比加减法更贵。若把递归乘法次数从 8 降到 7，递推式就会变成：

$
  T(n) = 7 T(n / 2) + O(n^2)
$

由主定理可得：

$
  T(n) = O(n^(log_2 7)) approx O(n^2.807)
$

这就是 Strassen 算法带来的核心改进。

#figure(caption: "Volker Strassen。")[
  #image("imgs/strassen.png", width: 180pt)
]

== 七个中间矩阵

Strassen 的做法是先构造 7 个中间矩阵：

$
  M_1 &= (A_(11) + A_(22))(B_(11) + B_(22)) \
  M_2 &= (A_(21) + A_(22)) B_(11) \
  M_3 &= A_(11) (B_(12) - B_(22)) \
  M_4 &= A_(22) (B_(21) - B_(11)) \
  M_5 &= (A_(11) + A_(12)) B_(22) \
  M_6 &= (A_(21) - A_(11))(B_(11) + B_(12)) \
  M_7 &= (A_(12) - A_(22))(B_(21) + B_(22))
$

然后用它们组合出结果矩阵的四个分块：

$
  C_(11) &= M_1 + M_4 - M_5 + M_7 \
  C_(12) &= M_3 + M_5 \
  C_(21) &= M_2 + M_4 \
  C_(22) &= M_1 - M_2 + M_3 + M_6
$

这里最关键的是：每个 $M_k$ 都被设计成同时携带多个有用项，而多余项会在最终加减组合中互相抵消。

== 为什么这组公式成立

以 $C_(11)$ 为例，展开 Strassen 的组合：

$
  M_1 + M_4 - M_5 + M_7
  &= (A_(11) B_(11) + A_(11) B_(22) + A_(22) B_(11) + A_(22) B_(22)) \
  &+ (A_(22) B_(21) - A_(22) B_(11)) \
  &- (A_(11) B_(22) + A_(12) B_(22)) \
  &+ (A_(12) B_(21) + A_(12) B_(22) - A_(22) B_(21) - A_(22) B_(22)) \
  &= A_(11) B_(11) + A_(12) B_(21) \
  &= C_(11)
$

可以看到，所有不属于 $C_(11)$ 的项都被抵消了，最后只剩下普通分块乘法中需要的两项。

== 从代数角度看：张量分解

如果把 $2 times 2$ 矩阵乘法看成一个双线性问题，它等价于计算四个双线性形式：

$
  C_(11) &= a_(11) b_(11) + a_(12) b_(21) \
  C_(12) &= a_(11) b_(12) + a_(12) b_(22) \
  C_(21) &= a_(21) b_(11) + a_(22) b_(21) \
  C_(22) &= a_(21) b_(12) + a_(22) b_(22)
$

这也可以理解为对矩阵乘法张量 $cal(T)$ 做低秩分解

朴素分块乘法对应秩为 8 的分解，而 Strassen 找到了一组秩为 7 的分解。对 2×2 分块矩阵乘法而言，7 次乘法已经是最优的：不能用 6 次或更少的乘法完成同样的双线性计算。

== 手动构造的直觉

Strassen 公式看起来像魔术，但背后有一些可以理解的构造直觉。

第一，$M_1 = (A_(11) + A_(22))(B_(11) + B_(22))$ 同时包含 $A_(11)B_(11)$ 和 $A_(22)B_(22)$ 这两个对角项。一次乘法携带了两个最终结果需要的信息。

第二，$M_2 = (A_(21) + A_(22))B_(11)$ 只涉及 $B$ 的一个子块，展开后能为 $C_(21)$ 提供一部分所需项。

第三，$M_3 = A_(11)(B_(12) - B_(22))$ 使用差分，让多出来的项在后续组合里被抵消。

所以它的思路不是“少算某些项”，而是把多个项打包在一起，再靠代数加减把不需要的部分消掉。

== 实际使用时的取舍

Strassen 算法在理论上降低了复杂度指数，但实际实现时还要考虑工程开销。

- *递归终止*：当子矩阵规模小于阈值时，通常切回朴素乘法，避免递归成本过高。
- *缓存友好*：分块有助于让子矩阵进入 CPU Cache，减少 Cache Miss。
- *数值稳定性*：Strassen 使用更多加减法，可能放大浮点舍入误差。
- *内存开销*：算法需要额外保存 $M_1$ 到 $M_7$ 等中间矩阵。
- *非 2 的幂规模*：实际矩阵尺寸不一定刚好适合二分，常见处理方式是补零或使用混合策略。

== 伪代码

```python
def strassen(A, B):
    n = len(A)
    if n <= THRESHOLD:
        return naive_multiply(A, B)

    A11, A12, A21, A22 = split(A)
    B11, B12, B21, B22 = split(B)

    M1 = strassen(A11 + A22, B11 + B22)
    M2 = strassen(A21 + A22, B11)
    M3 = strassen(A11, B12 - B22)
    M4 = strassen(A22, B21 - B11)
    M5 = strassen(A11 + A12, B22)
    M6 = strassen(A21 - A11, B11 + B12)
    M7 = strassen(A12 - A22, B21 + B22)

    C11 = M1 + M4 - M5 + M7
    C12 = M3 + M5
    C21 = M2 + M4
    C22 = M1 - M2 + M3 + M6

    return combine(C11, C12, C21, C22)
```

== 后续发展：不断逼近 $omega = 2$

矩阵乘法复杂度通常用指数 $omega$ 表示。朴素算法是 $omega = 3$，Strassen 将它降到 $log_2 7 approx 2.807$。后续研究沿着张量分解、边界秩、Laser 方法等路线继续推进。

#figure(caption: "Laser 方法相关示意。")[
  #image("imgs/laser-method.png", width: 420pt)
]

一个简化的发展脉络如下：

#figure(caption: "快速矩阵乘法部分里程碑。")[
  #table(
    columns: (auto, auto, 1fr),
    [*年份*], [*指数上界*], [*代表方法*],
    [1969], [$omega < 2.807$], [Strassen：2×2 分块，7 次乘法],
    [1978], [$omega < 2.796$], [Pan：更大分块],
    [1979], [$omega < 2.78$], [Bini 等：近似秩与边界秩],
    [1990], [$omega < 2.3755$], [Coppersmith-Winograd 方法],
    [2014], [$omega < 2.3728639$], [Le Gall：进一步优化],
    [2023], [$omega < 2.371866$], [Duan、Wu、Zhou：组合损失分析],
    [2024], [$omega < 2.371339$], [Alman 等：更多非对称性分析],
  )
]

这里的终极问题是：是否存在本质上二次复杂度的矩阵乘法算法，也就是 $omega = 2$？目前这仍然是理论计算机科学中的开放问题。

== AI 辅助算法发现：AlphaTensor

DeepMind 的 AlphaTensor 把矩阵乘法算法发现建模为一个单人博弈，用强化学习寻找张量分解。它在一些小规模矩阵乘法问题上发现了超过已有算法的具体乘法方案，说明算法设计不一定只能依靠人工直觉。

#tufted.full-width[
  #figure(caption: "AlphaTensor 将算法发现转化为张量分解搜索。")[
    #image("imgs/alphatensor-overview.png")
  ]
]

#tufted.full-width[
  #figure(caption: "AlphaTensor 在若干矩阵尺寸上发现了新的乘法算法。")[
    #image("imgs/alphatensor-result.png")
  ]
]

== 小结

1.*Strassen 推导本质*:将矩阵乘法转化为张量分解问题，创造性地找到秩为 7 的分解

2.*发展路线*

$ "Strassen" (2.807) -> "Laser" (2.376) -> "Le Gall" (2.372) -> "Alman " (2.371) -> dots.c $

3.*大模型时代的新方向*：AI（AlphaTensor）自动发现小矩阵最优算法，有望超越人类直觉。

4.*终极目标*：$omega = 2$（仍是开放问题）

#quote[
  简而言之：Strassen 的公式是通过*将矩阵乘法转化为张量分解问题，创造性地找到秩为 7 的分解*而得到的。后续算法沿着同一思路，在更大的张量上使用更精妙的分析（Laser 方法），不断逼近理论下界 $omega = 2$。
]

== 延伸阅读

- #link("https://arxiv.org/abs/2210.10173")[Duan, Wu, Zhou: Faster Matrix Multiplication via Asymmetric Hashing]
- #link("https://arxiv.org/abs/2307.07970")[Williams, Xu, Xu, Zhou: New Bounds for Matrix Multiplication: from Alpha to Omega]
- #link("https://arxiv.org/abs/2404.16349")[Alman, Duan, Williams, Xu, Xu, Zhou: More Asymmetry Yields Faster Matrix Multiplication]
- #link("https://www.nature.com/articles/s41586-022-05172-4")[Nature: Discovering faster matrix multiplication algorithms with reinforcement learning]
