## 灰胸山雀 The Tufted Titmouse

灰胸山雀（*Baeolophus bicolor*）是一种小巧活泼的鸣禽，原生于北美东部的落叶林。其显著特征包括独特的灰色羽冠、乌黑的大眼睛和两侧锈红色的羽毛。这些鸟类是灵巧的觅食者，也是后院喂食器的常客。冬季时，它们常与山雀和䴓组成混合鸟群活动。其鸣声清脆如哨音，似在反复鸣唱 "*peter-peter-peter*"。

![Tufted Titmouse](tufted-titmouse.webp)

我们可以用 Logistic 增长方程来模拟它们的种群动态：

$$
\frac{dP}{dt} = rP \left(1 - \frac{P}{K}\right)
$$

其中 $P$ 表示种群，$r$ 表示内在增长率，$K$ 表示其栖息地的承载能力。
