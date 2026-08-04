#import "../index.typ": template, tufted

// 如需生成 RSS feed，必须填写 title、description 和 date 元数据
#show: template.with(
  title: "机器学习｜深度学习到监督学习",
  description: "机器学习｜深度学习到监督学习",
  date: datetime(year: 2026, month: 7, day: 20),
  category: "数学与算法",
  lang: "zh",
)


= 机器学习｜深度学习到监督学习

\#2026-8-4 \#深度学习

#tufted.margin-note[
吴恩达讲解的后续一parts，都是比较基础的内容。祝食用愉快～😋
]
#line(length: 100%, stroke: 0.6pt)

=== 1. 神经网络与前向传播 (Neural Networks & Forward Propagation)

- *神经元与大脑 (Neurons & Brain)：* 生物神经元通过树突接收信号，在细胞体处理，并通过轴突输出。人工神经网络（ANN）受此启发，利用数学单元（神经元）模拟该过程，以解决非线性复杂任务（如图像识别、需求预测等）。
- *单层前向传播：*
每个神经元接收输入向量 $arrow(x)$，与其对应的权重向量 $arrow(w)$ 进行点积，加上偏置 $b$，再通过激活函数 $g(z)$ 得到输出 $a$（激活值）。
对于第 $l$ 层的第 $j$ 个神经元，其计算公式为：
$ z_j^([l]) = arrow(w)_j^([l]) dot.op arrow(a)^([l - 1]) + b_j^([l]) $
$ a_j^([l]) = g(z_j^([l])) $
其中，$arrow(a)^([l - 1])$ 为前一层的输出向量（输入层 $arrow(a)^([0]) = arrow(x)$）。
- *通用前向传播与高效矩阵乘法 (Vectorization)：*
在代码和计算硬件中，通过矩阵化可以实现并行加速。设 $W^([l])$ 为第 $l$ 层的权重矩阵（每一列代表一个神经元的权重向量），$arrow(b)^([l])$ 为偏置向量：
$ arrow(z)^([l]) = W^([l] T) arrow(a)^([l - 1]) + arrow(b)^([l]) $
$ arrow(a)^([l]) = g(arrow(z)^([l])) $
在 TensorFlow 中，数据通常以张量（Tensors）形式流动

=== 2. 激活函数的选择与多分类问题

- *为什么需要激活函数？*
若不使用非线性激活函数，无论叠加多少层神经网络，其整体输出依然是输入的线性组合，无法拟合非线性边界。
- *常用激活函数：*
  - *Sigmoid 函数：* 用于二分类输出层。
$ g(z) = 1/(1 + e^(-z)) in(0, 1) $
  - *ReLU (Rectified Linear Unit) 函数：* 隐层默认首选，能有效缓解梯度消失，计算极快。
$ g(z) = max(0, z) $
- *多分类与 Softmax：*
当分类类别 $C > 2$ 时，输出层采用 *Softmax 激活函数*，将输出转化为对应各个类别的概率分布。对于第 $i$ 个类别的预测概率 $a_i$：
$ a_i = P(y = i | arrow(x)) = (e^(z_i))/(sum_(j = 1)^C e^(z_j)) $
  - *数值稳定性改进（Softmax 的改进实现）：*
在 TensorFlow 中，若直接计算 $e^(z_i)$ 极易发生数值溢出（极小或极大）。改进的做法是在损失函数中使用 `from_logits=True`，让 TensorFlow 将 Softmax 运算与交叉熵损失函数（Cross-Entropy Loss）在数学上进行合并简化，以提高计算精度。
- *多输出分类 (Multi-label Classification)：*
区分于多分类（多选一），多输出分类旨在预测一个样本同时拥有的多个标签。例如：一张图像中是否同时包含【行人、车辆、交通灯】。其实现方式为在输出层设置多个 Sigmoid 神经元，分别对应各个标签的二分类。

=== 3. 深度学习优化

- *高级优化算法 (Adam Optimizer)：*
相比于传统梯度下降（固定学习率 $alpha$），*Adam (Adaptive Moment Estimation)* 算法能够针对每个参数动态调整学习率。若某参数的梯度始终朝向同一方向，Adam 会加速其更新；若梯度频繁震荡，则会减小其步长，从而极大地加快了训练收敛速度。
- *额外层类型（如卷积层 CNN）：*
全连接层（Dense）参数量大，容易过拟合。在处理图像等空间相关数据时，引入*卷积层 (Convolutional Layer)*，通过局部感受野和权重共享，极大减少了参数量并保留了空间拓扑结构。

=== 4. 树模型与集成学习 (Decision Trees & Ensemble Methods)

除了神经网络，树模型是处理*表格数据 (Tabular Data)* 最强有力的工具。

- *单决策树构建流程：*
  + *测量纯度 (Purity)：* 使用 *信息熵 (Entropy)* 评估结点的混乱程度。设 $p_1$ 为样本中正例的比例：
$ H(p_1) = - p_1 log_2 (p_1) -(1 - p_1) log_2 (1 - p_1) $
  + *选择分割：信息增益 (Information Gain, IG)：* 选择能使分裂后子节点熵降幅最大的特征进行分裂。
$ I G(T, a) = H(p_"root") -((N_"left")/(N_"root") H(p_"left") + (N_"right")/(N_"root") H(p_"right")) $
  + *分类与连续特征处理：*
    - *离散特征：* 若是多分类特征，可采用 *独热编码 (One-hot Encoding)* 转化为二进制特征。
    - *连续特征：* 对其进行排序，测试不同的分裂阈值（如 $x < v$），选择信息增益最大的阈值。
  + *回归树 (Regression Trees)：* 分割标准不再是信息熵，而是使分裂后子节点的方差（Variance）或均方误差（MSE）降到最低，叶子节点预测值为该叶子内所有样本的均值。
- *集成学习 (Ensemble Methods)：*
  - *带替换的采样 (Bootstrap / Sampling with Replacement)：* 从大小为 $m$ 的数据集中，有放回地随机抽取 $m$ 个样本，形成新数据集。约有 $63.2 %$ 的原始样本会被抽中。
  - *随机森林 (Random Forest)：* 构建多棵决策树（Bagging思想）。在构建每棵树时，不仅使用有放回抽样训练数据，还会在每个分裂节点*随机选择一个特征子集*，进一步降低树之间的相关性，抑制过拟合。
  - *XGBoost (Extreme Gradient Boosting)：* 极其高效的梯度提升树算法。它采用 Boosting 思想，串行构建决策树，每棵新树都旨在拟合当前模型的残差，并引入了二阶泰勒展开和正则化惩罚项来控制模型复杂度，是目前表格数据建模的工业级利器。
- *模型选择：神经网络 vs 决策树：*
  - *决策树/集成树：* 适合结构化/表格数据；训练极快；可解释性强；无需特征缩放。
  - *神经网络：* 适合非结构化数据（图像、语音、自然语言处理等）；支持迁移学习；适合多任务学习。