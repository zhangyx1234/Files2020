Transformers是一个用于自然语言处理（NLP）的Python第三方库，实现Bert、GPT-2和XLNET等比较新的模型，支持TensorFlow和PyTorch。

# 1、安装

### 1.1 依赖：

​	Python 3.6+ and PyTorch 1.1.0

### 1.2 安装

 （1）pip安装	

```
pip install transformers
```

（2） 源码：

To install from source, clone the repository and install with:

```
git clone https://github.com/huggingface/transformers.git
cd transformers
pip install .
```

### 1.3 OpenAI GPT原始标记工作流程

如果要实现本文`OpenAI GPT 的原始标记化过程，则需要安装`ftfy``SpaCy`

```
pip install spacy ftfy==4.4.3
python -m spacy download en
```

如果您未安装`ftfy`和`SpaCy`，则penAI GPT令牌生成器将默认使用BERT的BasicTokenizer后跟Byte-Pair Encoding（对于大多数用法来说应该没问题，不用担心）。`进行令牌化，

### 1.4 有关模型下载的注意事项（连续集成或大规模部署）

如果您希望从我们的托管存储桶中下载大量模型（超过1,000个）（例如通过您的CI设置或大规模生产部署），请在您端缓存模型文件。它将更快，更便宜。如果您需要任何帮助，请随时与我们私下联系。

### 1.5 您要在移动设备上运行Transformer模型吗？

您应该查看我们的[swift-coreml-transformers](https://github.com/huggingface/swift-coreml-transformers)回购。

它包含了一套工具来转换PyTorch或TensorFlow 2.0训练的变压器模型（目前包含`GPT-2`，`DistilGPT-2`，`BERT`和`DistilBERT`）以CoreML模型运行在iOS设备上。

在将来的某个时候，您将能够从PyTorch中的预训练或微调模型无缝过渡到在CoreML中进行生产，或者在CoreML中对模型或应用程序进行原型设计，然后从PyTorch研究其超参数或体系结构。超级刺激！