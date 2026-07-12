
#import "../index.typ": template, tufted

// 如需生成 RSS feed，必须填写 title、description 和 date 元数据
#show: template.with(
  title: "图像处理｜从卷积与 UNet的学习",
  description: "图像处理｜从卷积与 UNet的学习",
  date: datetime(year: 2026, month: 7, day: 10),
  category: "数学与算法",
  lang: "zh",
)


#let EE = math.class("normal", $bb(E)$)
#let post = $"post"$
#let const = $"const"$

= *Diffusion｜DDPM & DDIM 从加噪到采样的完整推导*

\#2026-7-12 \#DDPM \#DDIM \#Diffusion \#推导

#line(length: 100%, stroke: 0.6pt)

#tufted.margin-note[
  *阅读提示：* 这里是学习DDPM和DDIM非常重要的理解推导过程，有助于之后按照这个范式去学习的Flow Matching，因为思想是基于这种扩散来做的，不过引入了向量场去计算这里的降噪直线的性质和速度，也是我在理解流匹配出现问题时打算回到最开始的原理去学习一下这样，可能涉及到一些概率论的知识，包括先验和后验以及Bayes以及Markov的内容，可能有点困难，但是好好理解也还好。祝食用愉快～🪣
]
== *1 问题设定与符号*

扩散模型把数据生成写成「先逐步加噪，再学习去噪」。

- *前向（加噪）*：人为定义、完全已知的马尔可夫链
- *反向（去噪 / 采样）*：需要学习，因为不知道如何从纯噪声一步步回到数据分布

=== *常用符号*

#table(
  columns: (auto, 1fr),
  align: (left, left),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  table.header([*符号*], [*含义*]),
  [$x_0$], [干净样本（真实图像 / 数据）],
  [$x_t$], [第 $t$ 步加噪后的样本],
  [$t$], [时间步，取 $1, ..., T$；$T$ 通常很大（如 1000）],
  [$beta_t$], [第 $t$ 步噪声日程，取值在 $(0, 1)$，训练前固定],
  [$alpha_t$], [$1 - beta_t$，第 $t$ 步保留信号的比例],
  [$macron(alpha)_t$], [从 0 到 $t$ 累积信号系数，见下式],
  [$epsilon$], [标准高斯噪声，$epsilon ~ cal(N)(0, I)$],
  [$epsilon_theta (x_t, t)$], [神经网络预测的噪声],
  [$hat(x)_0$], [由网络估计得到的干净样本],
)

累积系数定义为：

$ macron(alpha)_t = product_(s = 1)^t alpha_s $

*关键事实*：噪声日程 ${beta_t}$（因而 $alpha_t$、$macron(alpha)_t$）在训练前就固定。 \
因此*一旦知道时间步 $t$，就知道这一时刻固定的加噪强度*：

- 信号系数：$sqrt(macron(alpha)_t)$
- 噪声系数：$sqrt(1 - macron(alpha)_t)$

与网络无关，可查表得到。

#line(length: 100%, stroke: 0.6pt)

== *2 前向过程*

=== *2.1 单步加噪*

$ q(x_t | x_(t - 1)) = cal(N)(x_t\; sqrt(alpha_t)\, x_(t - 1),\, beta_t I) $

含义：在 $x_(t - 1)$ 上按比例 $sqrt(alpha_t)$ 缩小信号，再加方差为 $beta_t$ 的高斯噪声。

=== *2.2 从 $x_0$ 一步跳到任意 $t$（边缘分布，闭式）*

反复代入单步公式，并用高斯的可加性，得到：

$ x_t = sqrt(macron(alpha)_t)\, x_0 + sqrt(1 - macron(alpha)_t)\, epsilon, quad epsilon ~ cal(N)(0, I) $

等价写成分布：

$ q(x_t | x_0) = cal(N)(x_t\; sqrt(macron(alpha)_t)\, x_0,\, (1 - macron(alpha)_t) I) $

同理：

$ q(x_(t - 1) | x_0) = cal(N)(x_(t - 1)\; sqrt(macron(alpha)_(t - 1))\, x_0,\, (1 - macron(alpha)_(t - 1)) I) $

*这一点极其重要*：不必真的走 $t$ 步，只要有 $x_0$ 和 $t$，就能直接采样 $x_t$。训练时也是这样构造输入的。

=== *2.3 由 $x_t$ 反解 $x_0$（代数闭式）*

把边缘公式变形：

$ x_0 = (x_t - sqrt(1 - macron(alpha)_t)\, epsilon) / sqrt(macron(alpha)_t) $

- 若 $epsilon$ 是*真噪声*，则 $x_0$ 精确
- 若换成网络输出 $epsilon_theta$，则得到的是*估计* $hat(x)_0$

表达式是闭式；数值是否精确取决于 $epsilon$ 是否为真。

#line(length: 100%, stroke: 0.6pt)

== *3 反向的核心目标*

生成时的处境：

- 手里有很噪的 $x_t$（从 $x_T ~ cal(N)(0, I)$ 开始往回走）
- 想得到稍微干净一点的 $x_(t - 1)$
- 若还知道真 $x_0$，则最合理的一步是用*条件后验*

$ q(x_(t - 1) | x_t, x_0) $

读法：

#quote[
  在已经观察到 $x_t$，并且知道原始图是 $x_0$ 的条件下，中间态 $x_(t - 1)$ 应服从什么分布。
]

真实采样时没有真 $x_0$，所以用网络估一个 $hat(x)_0$ 塞进去。 \
但首先必须把「有真 $x_0$ 时」的精确后验推出来——这就是 DDPM 反向步的理论骨架。

时间线示意：

```text
x0  --------►  x_{t-1}  --------►  x_t
已知（理想）      未知（要求）        已知
```

#line(length: 100%, stroke: 0.6pt)

== *4 Bayes 分解*

=== *4.1 问题：想要的分布不能直接抄*

前向模型直接给出的是：

- $q(x_t | x_(t - 1))$：从 $t - 1$ 加一步噪
- $q(x_t | x_0)$、$q(x_(t - 1) | x_0)$：从干净图跳到某时刻

*没有*直接给出 $q(x_(t - 1) | x_t, x_0)$。 \
所以需要用概率定义，把「难写的反向量」用「已知的前向量」表达出来。

=== *4.2 Bayes 公式（一般形式）*

对任意随机变量 $A, B, C$：

$ q(A | B, C) = (q(B | A, C)\, q(A | C)) / (q(B | C)) $

这不是额外物理假设，只是条件概率定义的改写。

令 $A = x_(t - 1)$，$B = x_t$，$C = x_0$，得到：

$ q(x_(t - 1) | x_t, x_0) = (q(x_t | x_(t - 1), x_0)\, q(x_(t - 1) | x_0)) / (q(x_t | x_0)) $

=== *4.3 Markov 性质带来的简化*

前向被定义成马尔可夫链：

$ x_0 -> x_1 -> dots.c -> x_(t - 1) -> x_t -> dots.c $

下一步只依赖当前步，不依赖更早历史。因此：

$ q(x_t | x_(t - 1), x_0) = q(x_t | x_(t - 1)) $

直觉：$x_t$ 是在 $x_(t - 1)$ 上加噪声得到的；一旦 $x_(t - 1)$ 固定，再告诉你 $x_0$ 是谁，都不会改变「从 $x_(t - 1)$ 到 $x_t$」这一步的加噪规律。

于是：

$ q(x_(t - 1) | x_t, x_0) = (q(x_t | x_(t - 1))\, q(x_(t - 1) | x_0)) / (q(x_t | x_0)) $

=== *4.4 分解后三项的角色*

关于 $x_(t - 1)$ 的依赖可以读成：

$ q(x_(t - 1) | x_t, x_0) prop q(x_t | x_(t - 1)) times q(x_(t - 1) | x_0) $

- *似然* $q(x_t | x_(t - 1))$：这个 $x_(t - 1)$ 加一步噪，能否解释当前的 $x_t$？
- *先验* $q(x_(t - 1) | x_0)$：从 $x_0$ 看，$t - 1$ 时刻本来应该像什么？
- *分母* $q(x_t | x_0)$：不含 $x_(t - 1)$，只负责归一化

#line(length: 100%, stroke: 0.6pt)

== *5 条件后验的闭式推导*

目标：求出

$ q(x_(t - 1) | x_t, x_0) = cal(N)(x_(t - 1)\; tilde(mu)_t (x_t, x_0),\, tilde(beta)_t I) $

中的均值 $tilde(mu)_t$ 与方差 $tilde(beta)_t$。

=== *5.1 为何后验仍是高斯*

右边出现的三个分布都是高斯：

#table(
  columns: (1.2fr, 1.2fr, 1fr),
  align: (left, left, left),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  table.header([*分布*], [*均值*], [*方差（×$I$）*]),
  [$q(x_t | x_(t - 1))$], [$sqrt(alpha_t)\, x_(t - 1)$], [$beta_t$],
  [$q(x_(t - 1) | x_0)$], [$sqrt(macron(alpha)_(t - 1))\, x_0$], [$1 - macron(alpha)_(t - 1)$],
  [$q(x_t | x_0)$], [$sqrt(macron(alpha)_t)\, x_0$], [$1 - macron(alpha)_t$],
)

两个关于 $x_(t - 1)$ 的高斯因子相乘（log 密度相加 = 二次型相加），结果仍是高斯。 \
因此后验必为高斯，只需确定 $tilde(mu)_t$ 与 $tilde(beta)_t$。

=== *5.2 用精度加权求后验*

把 $x_(t - 1)$ 记为 $y$（多维时各坐标独立，一维推导即可推广）。

*来自似然 $q(x_t | y)$ 的约束*

$ x_t = sqrt(alpha_t)\, y + "噪声", quad "噪声方差" = beta_t $

反解成对 $y$ 的高斯约束：

$ y ~ cal(N)((x_t)/sqrt(alpha_t),\, (beta_t)/(alpha_t)) $

*来自先验 $q(y | x_0)$*

$ y ~ cal(N)(sqrt(macron(alpha)_(t - 1))\, x_0,\, 1 - macron(alpha)_(t - 1)) $

*两个高斯融合的经典公式*

若同一变量同时满足

$ y ~ cal(N)(mu_1, sigma_1^2), wide y ~ cal(N)(mu_2, sigma_2^2) $

则后验：

$ 1 / (sigma_post^2) = 1 / (sigma_1^2) + 1 / (sigma_2^2) $

$ mu_post = sigma_post^2 ((mu_1)/(sigma_1^2) + (mu_2)/(sigma_2^2)) $

代入：

$ mu_1 = (x_t)/sqrt(alpha_t), quad sigma_1^2 = (beta_t)/(alpha_t) $

$ mu_2 = sqrt(macron(alpha)_(t - 1))\, x_0, quad sigma_2^2 = 1 - macron(alpha)_(t - 1) $

=== *5.3 计算后验方差 $tilde(beta)_t$*

$ 1/(tilde(beta)_t) = (alpha_t)/(beta_t) + 1/(1 - macron(alpha)_(t - 1)) = (alpha_t (1 - macron(alpha)_(t - 1)) + beta_t)/(beta_t (1 - macron(alpha)_(t - 1))) $

分子化简（用 $beta_t = 1 - alpha_t$ 与 $macron(alpha)_t = alpha_t macron(alpha)_(t - 1)$）：

$ alpha_t (1 - macron(alpha)_(t - 1)) + beta_t = alpha_t - alpha_t macron(alpha)_(t - 1) + 1 - alpha_t = 1 - alpha_t macron(alpha)_(t - 1) = 1 - macron(alpha)_t $

因此：

$ 1/(tilde(beta)_t) = (1 - macron(alpha)_t)/(beta_t (1 - macron(alpha)_(t - 1))) $

$ tilde(beta)_t = (1 - macron(alpha)_(t - 1))/(1 - macron(alpha)_t)\, beta_t $

*含义*：已知两端 $x_0$ 与 $x_t$ 之后，中间点 $x_(t - 1)$ 的不确定度通常*小于*单步新加噪声 $beta_t$；前面的分式是修正因子。

#line(length: 100%, stroke: 0.6pt)

=== *5.4 计算后验均值 $tilde(mu)_t$*

$ tilde(mu)_t = tilde(beta)_t (sqrt(alpha_t)/(beta_t)\, x_t + sqrt(macron(alpha)_(t - 1))/(1 - macron(alpha)_(t - 1))\, x_0) $

将

$ tilde(beta)_t = ((1 - macron(alpha)_(t - 1)) beta_t)/(1 - macron(alpha)_t) $

乘入。

*$x_t$ 的系数：*

$ tilde(beta)_t dot sqrt(alpha_t)/(beta_t) = (sqrt(alpha_t)\, (1 - macron(alpha)_(t - 1)))/(1 - macron(alpha)_t) $

*$x_0$ 的系数：*

$ tilde(beta)_t dot sqrt(macron(alpha)_(t - 1))/(1 - macron(alpha)_(t - 1)) = (beta_t sqrt(macron(alpha)_(t - 1)))/(1 - macron(alpha)_t) $

于是：

$ tilde(mu)_t (x_t, x_0) = (sqrt(macron(alpha)_(t - 1))\, beta_t)/(1 - macron(alpha)_t)\, x_0 + (sqrt(alpha_t)\, (1 - macron(alpha)_(t - 1)))/(1 - macron(alpha)_t)\, x_t $

=== *5.5 汇总：有真 $x_0$ 时的精确后验*

$ q(x_(t - 1) | x_t, x_0) = cal(N)(x_(t - 1)\; tilde(mu)_t (x_t, x_0),\, tilde(beta)_t I) $

其中

$ tilde(mu)_t (x_t, x_0) = (sqrt(macron(alpha)_(t - 1))\, beta_t)/(1 - macron(alpha)_t)\, x_0 + (sqrt(alpha_t)\, (1 - macron(alpha)_(t - 1)))/(1 - macron(alpha)_t)\, x_t $

$ tilde(beta)_t = (1 - macron(alpha)_(t - 1))/(1 - macron(alpha)_t)\, beta_t $

*这是真正的 Bayes 后验*：在前向过程固定且 $x_0$ 为真时，公式精确、闭式。

#line(length: 100%, stroke: 0.6pt)

== *6 后验均值与方差的含义*

把 $tilde(mu)_t$ 想成：

#quote[
  在「从 $x_0$ 出发、到 $x_t$ 结束」的加噪轨迹上，$t - 1$ 时刻最可能落在哪里。
]

- 更信 $x_0$：均值往 $sqrt(macron(alpha)_(t - 1))\, x_0$ 靠
- 更信 $x_t$：均值往「把当前噪图倒退一步」靠

两项是*精度加权*意义下的折中（高斯桥 / 布朗桥在中间时刻的条件均值）。

$tilde(beta)_t$ 则是这座「桥」上中间点的剩余方差：两端钉死后，中间不再完全自由。

#line(length: 100%, stroke: 0.6pt)

== *7 真实采样：用估计的 x0 代替真 x0*

=== *7.1 理想情况*

若知道真 $x_0$：

$ x_(t - 1) = tilde(mu)_t (x_t, x_0) + sqrt(tilde(beta)_t)\, z, quad z ~ cal(N)(0, I) $

这是精确从 $q(x_(t - 1) | x_t, x_0)$ 抽样。 \
从 $t = T$ 做到 $t = 1$，相当于在「$x_0$ 已知」的条件世界里模拟前向过程的时间反转。

=== *7.2 现实：只有 $x_t$，没有 $x_0$*

网络学习预测噪声（DDPM 常见做法）：

$ epsilon_theta (x_t, t) approx epsilon $

由边缘公式反解估计干净样本：

$ hat(x)_0 = (x_t - sqrt(1 - macron(alpha)_t)\, epsilon_theta (x_t, t)) / sqrt(macron(alpha)_t) $

说明：

- *表达式*：闭式代数变形
- *数值*：估计值，因为 $epsilon_theta != epsilon$
- *大 $t$ 时*：$macron(alpha)_t -> 0$，分母小，噪声预测的一点误差会被放大，$hat(x)_0$ 往往很糊

然后*假装* $hat(x)_0$ 就是真 $x_0$，代入后验：

$ x_(t - 1) = tilde(mu)_t (x_t, hat(x)_0) + sqrt(tilde(beta)_t)\, z, quad z ~ cal(N)(0, I) $

（实现里方差有时改用 $beta_t$ 等变体，原理相同。）

=== *7.3 误差*

#table(
  columns: (1.1fr, 1.1fr, 1fr),
  align: (left, left, left),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  table.header([*步骤*], [*数学身份*], [*误差来源*]),
  [$tilde(mu)_t$、$tilde(beta)_t$ 公式], [Bayes 后验的精确闭式], [无],
  [$hat(x)_0$], [由 $epsilon_theta$ 闭式反解], [网络近似],
  [代入后的「后验」], [仍写成高斯], [$x_0$ 错了，整个条件分布偏了],
  [再加 $sqrt(tilde(beta)_t)\, z$], [按该高斯抽样], [额外随机性],
)

#line(length: 100%, stroke: 0.6pt)

== *8 与噪声预测参数化的等价写法*

把

$ hat(x)_0 = (x_t - sqrt(1 - macron(alpha)_t)\, epsilon_theta) / sqrt(macron(alpha)_t) $

代入 $tilde(mu)_t$，合并 $x_t$ 与 $epsilon_theta$ 的系数（用 $macron(alpha)_t = alpha_t macron(alpha)_(t - 1)$、$beta_t = 1 - alpha_t$），得到 DDPM 论文常用形式：

$ x_(t - 1) = 1/sqrt(alpha_t) (x_t - (1 - alpha_t)/sqrt(1 - macron(alpha)_t)\, epsilon_theta (x_t, t)) + sigma_t z $

其中 $sigma_t$ 常取 $sqrt(tilde(beta)_t)$ 或 $sqrt(beta_t)$。

*逐项含义：*

+ $epsilon_theta (x_t, t)$：网络认为 $x_t$ 里混了多少噪声
+ $display((1 - alpha_t)/sqrt(1 - macron(alpha)_t)) epsilon_theta$：要从 $x_t$ 里去掉「本步对应」的那部分噪声
+ 除以 $sqrt(alpha_t)$：对应前向 $x_t = sqrt(alpha_t)\, x_(t - 1) + dots.c$ 的尺度还原
+ $+sigma_t z$：按后验方差再注入噪声，避免方差塌缩、保持正确随机性

这与「先估 $hat(x)_0$ 再代入 $tilde(mu)$」完全等价，只是实现上少一个中间变量。

#line(length: 100%, stroke: 0.6pt)

== *9 训练目标*

DDPM 并不直接拟合后验参数；它拟合前向里的噪声（与预测 $x_0$ 本质等价）：

$ cal(L) = EE_(x_0, epsilon, t) [norm(epsilon - epsilon_theta (x_t, t))^2] $

其中

$ x_t = sqrt(macron(alpha)_t)\, x_0 + sqrt(1 - macron(alpha)_t)\, epsilon $

在一定简化下，这与「让学习到的反向高斯转移贴近真实反向」的 KL 相关。

*关键推论*： \
训练只依赖边缘 $q(x_t | x_0)$，*不依赖*你采样时一步走多远、是否马尔可夫。 \
因此只要采样时仍匹配同一套边缘噪声水平，就可以换采样器——这是 DDIM 能「不重训、只改采样」的根源。

#line(length: 100%, stroke: 0.6pt)

== *10 精确 / 闭式 / 估计：一张表分清*

#table(
  columns: (1.3fr, 0.9fr, 1fr),
  align: (left, left, left),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  table.header([*量*], [*是否闭式*], [*是否精确*]),
  [噪声日程 $macron(alpha)_t$、$tilde(beta)_t$], [是（日程给定）], [是（定义）],
  [真后验公式 $tilde(mu)_t (dot, x_0)$、$tilde(beta)_t$], [是], [代入真 $x_0$ 时精确],
  [$hat(x)_0$], [形式闭式], [否，网络估计],
  [代入 $hat(x)_0$ 后的均值], [公式仍闭式], [近似],
  [实际采到的 $x_(t - 1)$], [从近似高斯抽样], [随机近似，不是唯一真值],
)

#line(length: 100%, stroke: 0.6pt)

== *11 DDPM 的限制*

+ *马尔可夫*：$p(x_(t - 1) | x_t)$，必须一步步 \
  $T -> T - 1 -> dots.c -> 0$，不能随意跳到很远的更早时刻而不改公式含义。
+ *随机*：每步 $+sigma_t z$。步数砍太少时，随机误差与离散化误差都难被后续步纠正。

因此 DDPM 往往需要成百上千步才能得到好样本；硬减步数质量下降明显。

#line(length: 100%, stroke: 0.6pt)

== *12 DDIM*

=== *12.1 核心思想*

Song et al. 引入*非马尔可夫*的推断过程族，使得：

+ *边缘* $q(x_t | x_0)$ 仍与 DDPM 相同：

$ q(x_t | x_0) = cal(N)(sqrt(macron(alpha)_t)\, x_0,\, (1 - macron(alpha)_t) I) $

→ 同一套 $epsilon_theta$，*不用重训*。

+ 给定 $x_t$ 后，可以构造到*任意更早噪声水平* $x_s$（$s < t$，不必 $s = t - 1$）的转移。

=== *12.2 直观图像*

前向在「真 $x_0$ + 真噪声方向 $epsilon$」下：

$ x_t = sqrt(macron(alpha)_t)\, x_0 + sqrt(1 - macron(alpha)_t)\, epsilon $

同一 $x_0$、同一 $epsilon$ 在任意更早时刻 $s$ 上「应该」是：

$ x_s = sqrt(macron(alpha)_s)\, x_0 + sqrt(1 - macron(alpha)_s)\, epsilon $

DDIM 用网络估 $hat(x)_0$ 与 $epsilon_theta$（二者线性相关、信息等价），再把「预测的干净图 + 同一噪声方向」投影到目标时刻的噪声强度上。 \
于是不必经过每一个中间整数时间步。

=== *12.3 与 DDPM 的关系*

- *DDPM*：像每一步都在局部后验里抖一下，再走一小格
- *DDIM*：像先估终点方向，再沿概率流 / 噪声 ODE 落到更低噪声水平；可大步、可全确定

#line(length: 100%, stroke: 0.6pt)

== *13 统一更新式与 sigma 的两种极端*

从 $t$ 到 $t - 1$ 的 DDIM 一般形式（把 $t - 1$ 换成任意 $s < t$ 同理）：

$ hat(x)_0 = (x_t - sqrt(1 - macron(alpha)_t)\, epsilon_theta (x_t, t)) / sqrt(macron(alpha)_t) $

$ x_(t - 1) = sqrt(macron(alpha)_(t - 1))\, hat(x)_0 + sqrt(1 - macron(alpha)_(t - 1) - sigma_t^2)\, epsilon_theta (x_t, t) + sigma_t z $

=== *13.1 三项分别是什么*

+ $sqrt(macron(alpha)_(t - 1))\, hat(x)_0$ \
  把「预测的干净图」放到 $t - 1$ 时刻应有的信号尺度。
+ $sqrt(1 - macron(alpha)_(t - 1) - sigma_t^2)\, epsilon_theta (x_t, t)$ \
  沿*同一噪声方向*，补上 $t - 1$ 时刻应有的噪声中与 $epsilon_theta$ 共线的确定性部分。
+ $sigma_t z$ \
  新鲜随机噪声；控制随机性大小。

=== *13.2 两个极端*

- $sigma_t = 0$：完全确定性（常说的 DDIM 采样）
- $sigma_t = sqrt(tilde(beta)_t)$：可退化为 DDPM 的随机更新

中间取值则在「更确定」与「更随机」之间插值。

=== *13.3 少步采样怎么做*

取时间子序列

$ tau_S > tau_(S - 1) > dots.c > tau_1 $

（例如从 1000 步日程里抽 50 个点），每步用同一公式做

$ x_(tau_i) --> x_(tau_(i - 1)) $

每跳一次，用新的状态重新估 $hat(x)_0$，大步误差被逐步校正。 \
确定性路径（$sigma = 0$）进一步减少随机抖动，少步时往往明显好于硬砍步数的 DDPM。

#line(length: 100%, stroke: 0.6pt)

== *14 加速*

DDIM 加速*不是*因为多训了数据信息，而是采样时显式利用了三样东西：

+ *已知日程 ${macron(alpha)_t}$* \
  任意目标噪声强度的尺度都可查表。
+ *已知（估出）$epsilon_theta (x_t, t)$ 或 $hat(x)_0$* \
  知道该往哪张干净图、沿哪个噪声方向走。
+ *因此反向不必是「只依赖 $x_t$ 的马尔可夫小步 + 强制随机」* \
  可以是 $x_t -> x_s$ 的大步，甚至完全确定。 \
  训练不用改，因为训练只看边缘 $q(x_t | x_0)$。

#line(length: 100%, stroke: 0.6pt)

== *log 密度配方法*

只保留与 $x_(t - 1)$ 有关的项。一维记号 $y = x_(t - 1)$。

$ log q(x_t | y) = -1/(2 beta_t) (x_t - sqrt(alpha_t)\, y)^2 + const $

$ log q(y | x_0) = -1/(2(1 - macron(alpha)_(t - 1))) (y - sqrt(macron(alpha)_(t - 1))\, x_0)^2 + const $

相加后 $y$ 的二次项系数（精度）为：

$ (alpha_t)/(beta_t) + 1/(1 - macron(alpha)_(t - 1)) = (1 - macron(alpha)_t)/(beta_t (1 - macron(alpha)_(t - 1))) $

故

$ tilde(beta)_t = (1 - macron(alpha)_(t - 1))/(1 - macron(alpha)_t)\, beta_t $

一次项配出均值，结果与精度加权相同：

$ tilde(mu)_t = (sqrt(macron(alpha)_(t - 1))\, beta_t)/(1 - macron(alpha)_t)\, x_0 + (sqrt(alpha_t)\, (1 - macron(alpha)_(t - 1)))/(1 - macron(alpha)_t)\, x_t $

#line(length: 100%, stroke: 0.6pt)

== *符号速查*

$ alpha_t = 1 - beta_t, quad macron(alpha)_t = product_(s = 1)^t alpha_s $

$ x_t = sqrt(macron(alpha)_t)\, x_0 + sqrt(1 - macron(alpha)_t)\, epsilon $

$ hat(x)_0 = (x_t - sqrt(1 - macron(alpha)_t)\, epsilon_theta (x_t, t)) / sqrt(macron(alpha)_t) $

$ tilde(mu)_t = (sqrt(macron(alpha)_(t - 1))\, beta_t)/(1 - macron(alpha)_t)\, x_0 + (sqrt(alpha_t)\, (1 - macron(alpha)_(t - 1)))/(1 - macron(alpha)_t)\, x_t $

$ tilde(beta)_t = (1 - macron(alpha)_(t - 1))/(1 - macron(alpha)_t)\, beta_t $

*DDPM 一步：*

$ x_(t - 1) = 1/sqrt(alpha_t) (x_t - (1 - alpha_t)/sqrt(1 - macron(alpha)_t)\, epsilon_theta) + sigma_t z $

*DDIM 一步：*

$ x_(t - 1) = sqrt(macron(alpha)_(t - 1))\, hat(x)_0 + sqrt(1 - macron(alpha)_(t - 1) - sigma_t^2)\, epsilon_theta + sigma_t z $

#line(length: 100%, stroke: 0.6pt)


== *笔者的话*

#quote[
  看完的话不妨看看流匹配吧，也是一个火热的方向。相信我，理解完这一篇之后，你就没有那么大的负担了～
]