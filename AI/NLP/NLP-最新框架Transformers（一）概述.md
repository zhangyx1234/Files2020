[TOC]

Transformers是一个用于自然语言处理（NLP）的Python第三方库，实现Bert、GPT-2和XLNET等比较新的模型，支持TensorFlow和PyTorch。

该库在设计时考虑了两个强烈的目标：

- 尽可能容易且快速地使用：
  - 我们尽可能限制了要学习的面向对象抽象的类的数量，实际上几乎没有抽象，每个模型只需要使用三个标准类:配置、模型和tokenizer
  - 所有这些类都可以通过使用公共的`from_pretrained()`实例化方法从预训练实例以简单统一的方式初始化，该方法将负责从库中下载，缓存和加载相关类提供的预训练模型或你自己保存的模型。
  - 因此，这个库不是构建神经网络模块的工具箱。如果您想扩展/构建这个库，只需使用常规的Python/PyTorch模块，并从这个库的基类继承，以重用诸如模型加载/保存等功能。
- 提供性能与原始模型尽可能接近的最新模型：
  - 对于每种架构，我们至少提供一个示例，该示例再现了该架构的正式作者提供的结果
  - 代码通常尽可能地接近原始代码，这意味着一些PyTorch代码可能不那么pytorch化，因为这是转换TensorFlow代码后的结果。

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

### 1.3 OpenAI GPT原始标记分析流程

如果要实现`OpenAI GPT 的本文令牌化过程，则需要安装`ftfy``SpaCy`

```
pip install spacy ftfy==4.4.3
python -m spacy download en
```

如果您未安装`ftfy`和`SpaCy`，则penAI GPT令牌解析器将默认使用BERT的BasicTokenizer后跟Byte-Pair Encoding（对于大多数用法来说应该没问题，不用担心）。`进行令牌化，

### 1.4 有关模型下载的注意事项（连续集成或大规模部署）

如果您希望从我们的托管存储桶中下载大量模型（超过1,000个）（例如通过您的CI设置或大规模生产部署），请在您端缓存模型文件。它将更快，更便宜。如果您需要任何帮助，请随时与我们私下联系。

### 1.5 您要在移动设备上运行Transformer模型吗？

您应该查看我们的[swift-coreml-transformers](https://github.com/huggingface/swift-coreml-transformers)回购。

它包含了一套工具来转换PyTorch或TensorFlow 2.0训练的变压器模型（目前包含`GPT-2`，`DistilGPT-2`，`BERT`和`DistilBERT`）以CoreML模型运行在iOS设备上。

在将来的某个时候，您将能够从PyTorch中的预训练或微调模型无缝过渡到在CoreML中进行生产，或者在CoreML中对模型或应用程序进行原型设计，然后从PyTorch研究其超参数或体系结构。超级刺激！

# 2、快速入门

### 2.1 主要概念

该库针对每种模型围绕三种类型的类构建：

- **模型类 model classes**目前在库中提供的8个模型架构的PyTorch模型(torch.nn.Modules)，例如BertModel
- **配置类 configuration classes**，它存储构建模型所需的所有参数，例如BertConfig。您不必总是自己实例化这些配置，特别是如果您使用的是未经任何修改的预训练的模型，创建模型将自动负责实例化配置(它是模型的一部分)
-  **tokenizer classes**，它存储每个模型的词汇表，并在要输送到模型的词汇嵌入索引列表中提供用于编码/解码字符串的方法，例如BertTokenizer

所有这些类都可以从经过预训练的实例中实例化，并使用两种方法在本地保存：

- `from_pretrained()`允许您从一个预训练版本实例化一个模型/配置/tokenizer，这个预训练版本可以由库本身提供(目前这里列出了27个模型)，也可以由用户在本地(或服务器上)存储，
- `save_pretrained()`允许您在本地保存模型/配置/tokenizer，以便可以使用`from_pretraining()`重新加载它。

我们将通过一些简单的快速入门示例来结束本快速入门之旅，以了解如何实例化和使用这些类。本文档的其余部分分为两部分：

- “ **主要类别”**部分详细介绍了三种主要类别（配置，模型，tokenizer）的常见功能/方法/属性，以及一些作为培训实用程序提供的与优化相关的类别，
-  **包引用**部分详细描述了每个模型体系结构的每个类的所有变体，特别是调用它们时它们期望的输入和输出。

### 2.2 快速浏览：用法

这是两个示例，展示了一些`Bert`和`GPT2`类以及预训练的模型。

##### BERT example

让我们首先使用`BertTokenizer`从文本字符串准备一个标记化的输入（要输入给BERT的标记嵌入索引列表）

```
import torch
from transformers import BertTokenizer, BertModel, BertForMaskedLM

# OPTIONAL: if you want to have more information on what's happening under the hood, activate the logger as follows
import logging
logging.basicConfig(level=logging.INFO)

# Load pre-trained model tokenizer (vocabulary)
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')

# Tokenize input
text = "[CLS] Who was Jim Henson ? [SEP] Jim Henson was a puppeteer [SEP]"
tokenized_text = tokenizer.tokenize(text)

# Mask a token that we will try to predict back with `BertForMaskedLM`
masked_index = 8
tokenized_text[masked_index] = '[MASK]'
assert tokenized_text == ['[CLS]', 'who', 'was', 'jim', 'henson', '?', '[SEP]', 'jim', '[MASK]', 'was', 'a', 'puppet', '##eer', '[SEP]']

# Convert token to vocabulary indices
indexed_tokens = tokenizer.convert_tokens_to_ids(tokenized_text)
# Define sentence A and B indices associated to 1st and 2nd sentences (see paper)
segments_ids = [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1]

# Convert inputs to PyTorch tensors
tokens_tensor = torch.tensor([indexed_tokens])
segments_tensors = torch.tensor([segments_ids])
```

让我们看看如何使用`BertModel`隐藏状态对输入进行编码：

```
# Load pre-trained model (weights)
model = BertModel.from_pretrained('bert-base-uncased')

# Set the model in evaluation mode to deactivate the DropOut modules
# This is IMPORTANT to have reproducible results during evaluation!
model.eval()

# If you have a GPU, put everything on cuda
tokens_tensor = tokens_tensor.to('cuda')
segments_tensors = segments_tensors.to('cuda')
model.to('cuda')

# Predict hidden states features for each layer
with torch.no_grad():
    # See the models docstrings for the detail of the inputs
    outputs = model(tokens_tensor, token_type_ids=segments_tensors)
    # Transformers models always output tuples.
    # See the models docstrings for the detail of all the outputs
    # In our case, the first element is the hidden state of the last layer of the Bert model
    encoded_layers = outputs[0]
# We have encoded our input sequence in a FloatTensor of shape (batch size, sequence length, model hidden dimension)
assert tuple(encoded_layers.shape) == (1, len(indexed_tokens), model.config.hidden_size)
```

以及如何用于`BertForMaskedLM`预测屏蔽标记：

```
# Load pre-trained model (weights)
model = BertForMaskedLM.from_pretrained('bert-base-uncased')
model.eval()

# If you have a GPU, put everything on cuda
tokens_tensor = tokens_tensor.to('cuda')
segments_tensors = segments_tensors.to('cuda')
model.to('cuda')

# Predict all tokens
with torch.no_grad():
    outputs = model(tokens_tensor, token_type_ids=segments_tensors)
    predictions = outputs[0]

# confirm we were able to predict 'henson'
predicted_index = torch.argmax(predictions[0, masked_index]).item()
predicted_token = tokenizer.convert_ids_to_tokens([predicted_index])[0]
assert predicted_token == 'henson'
```

##### OpenAI GPT-2 

这是一个快速入门示例，该示例使用`GPT2Tokenizer`和`GPT2LMHeadModel`类以及OpenAI的预训练模型来预测文本提示中的下一个标记。

首先，我们使用以下命令从文本字符串准备标记化的输入 `GPT2Tokenizer`

```
import torch
from transformers import GPT2Tokenizer, GPT2LMHeadModel

# OPTIONAL: if you want to have more information on what's happening, activate the logger as follows
import logging
logging.basicConfig(level=logging.INFO)

# Load pre-trained model tokenizer (vocabulary)
tokenizer = GPT2Tokenizer.from_pretrained('gpt2')

# Encode a text inputs
text = "Who was Jim Henson ? Jim Henson was a"
indexed_tokens = tokenizer.encode(text)

# Convert indexed tokens in a PyTorch tensor
tokens_tensor = torch.tensor([indexed_tokens])
```

让我们看看如何使用它`GPT2LMHeadModel`来在文本之后生成下一个标记：

```
# Load pre-trained model (weights)
model = GPT2LMHeadModel.from_pretrained('gpt2')

# Set the model in evaluation mode to deactivate the DropOut modules
# This is IMPORTANT to have reproducible results during evaluation!
model.eval()

# If you have a GPU, put everything on cuda
tokens_tensor = tokens_tensor.to('cuda')
model.to('cuda')

# Predict all tokens
with torch.no_grad():
    outputs = model(tokens_tensor)
    predictions = outputs[0]

# get the predicted next sub-word (in our case, the word 'man')
predicted_index = torch.argmax(predictions[0, -1, :]).item()
predicted_text = tokenizer.decode(indexed_tokens + [predicted_index])
assert predicted_text == 'Who was Jim Henson? Jim Henson was a man'
```

可以在[文档中](https://huggingface.co/transformers/quickstart.html#documentation)找到每种模型架构（Bert，GPT，GPT-2，Transformer-XL，XLNet和XLM）的每个模型类的示例。

##### 使用过去的模型

GPT-2以及其他一些模型（GPT，XLNet，Transfo-XL，CTRL）都使用`past`或`mems`属性，当使用顺序解码时，可以使用或属性来防止重新计算键/值对。它在生成序列时很有用，因为注意力机制的很大一部分得益于以前的计算。

这是一个使用 带 past 的 GPT2LMHeadModel`和argmax解码的完整示例（仅应作为示例，因为argmax解码会带来很多重复）：

```
from transformers import GPT2LMHeadModel, GPT2Tokenizer
import torch

tokenizer = GPT2Tokenizer.from_pretrained("gpt2")
model = GPT2LMHeadModel.from_pretrained('gpt2')

generated = tokenizer.encode("The Manhattan bridge")
context = torch.tensor([generated])
past = None

for i in range(100):
    print(i)
    output, past = model(context, past=past)
    token = torch.argmax(output[..., -1, :])

    generated += [token.tolist()]
    context = token.unsqueeze(0)

sequence = tokenizer.decode(generated)

print(sequence)
```

该模型仅需要单个令牌作为输入，因为所有先前令牌的键/值对都包含在中`past`。

# 3、术语表

每种模型都不同，但与其他模型相似。因此，大多数模型使用相同的输入，此处将在用法示例中进行详细说明。

### 3.1 输入id

输入id通常是传递给模型作为输入的唯一必需参数。它们是token的索引，作为模型输入的序列tokens的数字表示。

每个标记器的工作方式不同，但基本机制保持不变。这是一个使用BERT标记器的示例，它是一个[WordPiece](https://arxiv.org/pdf/1609.08144.pdf)标记器：

```
from transformers import BertTokenizer
tokenizer = BertTokenizer.from_pretrained("bert-base-cased")

sequence = "A Titan RTX has 24GB of VRAM"
```

tokenizer负责将序列拆分为令牌生成器词汇表中可用的令牌。

```
# Continuation of the previous script
tokenized_sequence = tokenizer.tokenize(sequence)
assert tokenized_sequence == ['A', 'Titan', 'R', '##T', '##X', 'has', '24', '##GB', 'of', 'V', '##RA', '##M']
```

然后可以将这些令牌转换为模型可以理解的ID。有几种方法可用于此目的，推荐的方法是encode或encode_plus，它们利用[Rusting face / tokenizers](https://github.com/huggingface/tokenizers)的Rust实现来实现 最佳性能。

```
# Continuation of the previous script
encoded_sequence = tokenizer.encode(sequence)
assert encoded_sequence == [101, 138, 18696, 155, 1942, 3190, 1144, 1572, 13745, 1104, 159, 9664, 2107, 102]
```

该编码和encode_plus方法自动给特殊的ID的模型使用添加“special tokens” 。                                                                                            

### 3.2 注意力掩码

注意力掩码是将序列批处理在一起时使用的可选参数。此参数向模型指示应该注意哪些令牌，哪些不应该注意。

例如，考虑以下两个序列：

```
from transformers import BertTokenizer
tokenizer = BertTokenizer.from_pretrained("bert-base-cased")

sequence_a = "This is a short sequence."
sequence_b = "This is a rather long sequence. It is at least longer than the sequence A."

encoded_sequence_a = tokenizer.encode(sequence_a)
assert len(encoded_sequence_a) == 8

encoded_sequence_b = tokenizer.encode(sequence_b)
assert len(encoded_sequence_b) == 19
```

这两个序列的长度不同，因此不能按原样放在同一张量中。需要将第一个序列填充到第二个序列的长度，或者将第二个序列截短到第一个序列的长度。

在第一种情况下，ID列表将通过填充索引扩展：

```
# Continuation of the previous script
padded_sequence_a = tokenizer.encode(sequence_a, max_length=19, pad_to_max_length=True)

assert padded_sequence_a == [101, 1188, 1110, 170, 1603, 4954,  119, 102,    0,    0,    0,    0,    0,    0,    0,    0,   0,   0,   0]
assert encoded_sequence_b == [101, 1188, 1110, 170, 1897, 1263, 4954, 119, 1135, 1110, 1120, 1655, 2039, 1190, 1103, 4954, 138, 119, 102]
```

然后可以将它们转换为PyTorch或TensorFlow中的张量。注意掩码是一个二进制张量，指示填充索引的位置，以便模型不会注意它们。对于 [`BertTokenizer`](https://huggingface.co/transformers/model_doc/bert.html#transformers.BertTokenizer)，请`1`指示应注意的值，而`0`指示已填充的值。

方法[`encode_plus()`](https://huggingface.co/transformers/main_classes/tokenizer.html#transformers.PreTrainedTokenizer.encode_plus)可用于直接获取注意模版：

```
# Continuation of the previous script
sequence_a_dict = tokenizer.encode_plus(sequence_a, max_length=19, pad_to_max_length=True)

assert sequence_a_dict['input_ids'] == [101, 1188, 1110, 170, 1603, 4954, 119, 102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
assert sequence_a_dict['attention_mask'] == [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```

### 3.3 词语类型id

一些模型的目的是进行序列分类或问题解答。这些要求将两个不同的序列编码在相同的输入ID中。它们通常由特殊标记分隔，例如分类器标记和分隔符标记。例如，BERT模型按如下方式构建其两个序列输入：

```
from transformers import BertTokenizer
tokenizer = BertTokenizer.from_pretrained("bert-base-cased")

# [CLS] SEQ_A [SEP] SEQ_B [SEP]

sequence_a = "HuggingFace is based in NYC"
sequence_b = "Where is HuggingFace based?"

encoded_sequence = tokenizer.encode(sequence_a, sequence_b)
assert tokenizer.decode(encoded_sequence) == "[CLS] HuggingFace is based in NYC [SEP] Where is HuggingFace based? [SEP]"
```

对于某些模型而言，这足以了解一个序列在何处结束，而另一序列在何处开始。但是，其他模型（例如BERT）具有附加机制，即段ID。令牌类型ID是一个二进制掩码，用于标识模型中的不同序列。

我们可以利用[`encode_plus()`](https://huggingface.co/transformers/main_classes/tokenizer.html#transformers.PreTrainedTokenizer.encode_plus)它为我们输出令牌类型ID：

```
# Continuation of the previous script
encoded_dict = tokenizer.encode_plus(sequence_a, sequence_b)

assert encoded_dict['input_ids'] == [101, 20164, 10932, 2271, 7954, 1110, 1359, 1107, 17520, 102, 2777, 1110, 20164, 10932, 2271, 7954, 1359, 136, 102]
assert encoded_dict['token_type_ids'] == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1]
```

第一个序列，即用于问题的“上下文”，其所有标记均由表示`0`，而问题的所有标记均由表示`1`。某些模型（例如）[`XLNetModel`](https://huggingface.co/transformers/model_doc/xlnet.html#transformers.XLNetModel)使用以表示的附加令牌`2`。

### 3.4 位置标识id

模型使用位置ID来识别哪个令牌在哪个位置。与将每个令牌的位置嵌入其中的RNN相反，转换器不知道每个令牌的位置。为此创建了职位ID。

它们是可选参数。如果没有位置ID传递给模型，则它们将自动创建为绝对位置嵌入。

在范围内选择绝对位置嵌入。一些模型使用其他类型的位置嵌入，例如正弦形位置嵌入或相对位置嵌入。`[0, config.max_position_embeddings - 1]`