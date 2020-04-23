此页显示使用库时最常见的用例。可用的模型允许许多不同的配置，并且在用例中具有很强的通用性。这里介绍了最简单的方法，展示了诸如问答、序列分类、命名实体识别等任务的用法。

这些示例利用`Auto Model`，这些类将根据给定的checkpoint实例化模型，并自动选择正确的模型体系结构。有关详细信息，请查看：`AutoModel`文档。请随意修改代码，使其更具体，并使其适应你的特定用例。

为了使模型能够在任务上良好地执行，必须从与该任务对应的checkpoint加载模型。这些checkpoint通常是在大量数据上预先训练的，并针对特定任务进行微调。这意味着：

- 并非所有模型都针对所有任务进行了微调。如果要对特定任务的模型进行微调，可以利用examples目录中的`run\$task.py`脚本。
- 微调模型是在特定的数据集上微调的。此数据集可能与你的用例和域重叠，也可能不重叠。如前所述，你可以利用示例脚本来微调模型，也可以创建自己的训练脚本。

为了对任务进行推理，库提供了几种机制：
– Pipelines:管道是非常易于使用的抽象，只需要两行代码。
– 直接将模型与Tokenizer(PyTorch/TensorFlow)结合使用来使用模型的完整推理。这种机制稍微复杂，但是更强大。

这里展示了两种方法。

> 请注意，这里介绍的所有任务都利用了在预训练模型针对特定任务进行微调后的模型。加载未针对特定任务进行微调的checkpoint时，将只加载transformer层，而不会加载用于该任务的附加层，从而随机初始化该附加层的权重。这将产生随机输出。

# 1、序列分类

序列分类是根据已经给定的类别然后对序列进行分类的任务。序列分类的一个例子是GLUE数据集，它就是完全基于该任务的。如果你想在GLUE序列分类任务上微调模型，可以利用`run_GLUE.py`或`run_tf_GLUE.py`脚本。

下面是一个使用管道进行情绪分析的例子：识别该序列是积极的还是消极的。它利用sst2上的微调模型，这是一个GLUE任务。

```python
from transformers import pipeline

nlp = pipeline("sentiment-analysis")

print(nlp("I hate you"))
print(nlp("I love you"))
```

这将返回一个标签(“积极”或“消极”)和一个分数，如下所示：

```python
[{'label': 'NEGATIVE', 'score': 0.9991129}]
[{'label': 'POSITIVE', 'score': 0.99986565}]
```

下面是一个使用模型进行序列分类的示例，以确定两个序列是否是彼此的解释。该过程如下：

- 从checkpoint名称实例化一个tokenizer和一个模型。该模型被识别为一个BERT模型，并用存储在checkpoint中的权重加载它。
- 从这两句话中构建一个序列，使用正确的特定于模型的分隔符标记类型id和注意力掩码(encode()和encode_plus()处理这个问题)
- 将这个序列传递到模型中，以便将其分类到两个可用的类中的一个：0(不是解释)和1(是解释)
- 计算结果的softmax获取类的概率
- 打印结果

Pytorch代码

```python
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

tokenizer = AutoTokenizer.from_pretrained("bert-base-cased-finetuned-mrpc")
model = AutoModelForSequenceClassification.from_pretrained("bert-base-cased-finetuned-mrpc")

classes = ["not paraphrase", "is paraphrase"]

sequence_0 = "The company HuggingFace is based in New York City"
sequence_1 = "Apples are especially bad for your health"
sequence_2 = "HuggingFace's headquarters are situated in Manhattan"

paraphrase = tokenizer.encode_plus(sequence_0, sequence_2, return_tensors="pt")
not_paraphrase = tokenizer.encode_plus(sequence_0, sequence_1, return_tensors="pt")

paraphrase_classification_logits = model(**paraphrase)[0]
not_paraphrase_classification_logits = model(**not_paraphrase)[0]

paraphrase_results = torch.softmax(paraphrase_classification_logits, dim=1).tolist()[0]
not_paraphrase_results = torch.softmax(not_paraphrase_classification_logits, dim=1).tolist()[0]

print("Should be paraphrase")
for i in range(len(classes)):
    print(f"{classes[i]}: {round(paraphrase_results[i] * 100)}%")

print("\nShould not be paraphrase")
for i in range(len(classes)):
    print(f"{classes[i]}: {round(not_paraphrase_results[i] * 100)}%")
```

TensorFlow代码

```python
from transformers import AutoTokenizer, TFAutoModelForSequenceClassification
import tensorflow as tf

tokenizer = AutoTokenizer.from_pretrained("bert-base-cased-finetuned-mrpc")
model = TFAutoModelForSequenceClassification.from_pretrained("bert-base-cased-finetuned-mrpc")

classes = ["not paraphrase", "is paraphrase"]

sequence_0 = "The company HuggingFace is based in New York City"
sequence_1 = "Apples are especially bad for your health"
sequence_2 = "HuggingFace's headquarters are situated in Manhattan"

paraphrase = tokenizer.encode_plus(sequence_0, sequence_2, return_tensors="tf")
not_paraphrase = tokenizer.encode_plus(sequence_0, sequence_1, return_tensors="tf")

paraphrase_classification_logits = model(paraphrase)[0]
not_paraphrase_classification_logits = model(not_paraphrase)[0]

paraphrase_results = tf.nn.softmax(paraphrase_classification_logits, axis=1).numpy()[0]
not_paraphrase_results = tf.nn.softmax(not_paraphrase_classification_logits, axis=1).numpy()[0]

print("Should be paraphrase")
for i in range(len(classes)):
    print(f"{classes[i]}: {round(paraphrase_results[i] * 100)}%")

print("\nShould not be paraphrase")
for i in range(len(classes)):
    print(f"{classes[i]}: {round(not_paraphrase_results[i] * 100)}%")
```

这将输出以下结果：

```cn
Should be paraphrase
not paraphrase: 10%
is paraphrase: 90%

Should not be paraphrase
not paraphrase: 94%
is paraphrase: 6%
```

### 抽取式问答

抽取式问答是从给定问题的文本中抽取答案的任务。问答数据集的一个例子是SQuAD数据集，它完全基于该任务。如果你想在团队任务中微调模型，可以利用`run_SQuAD.py`。

下面是一个使用管道进行问答的示例：从给定问题的文本中提取答案。它利用了一个小队的微调模型。

```python
from transformers import pipeline

nlp = pipeline("question-answering")

context = r"""
Extractive Question Answering is the task of extracting an answer from a text given a question. An example of a
question answering dataset is the SQuAD dataset, which is entirely based on that task. If you would like to fine-tune
a model on a SQuAD task, you may leverage the `run_squad.py`.
"""

print(nlp(question="What is extractive question answering?", context=context))
print(nlp(question="What is a good example of a question answering dataset?", context=context))
```

这将返回从文本中提取的答案，一个置信度，以及“开始”和“结束”值，这些值是提取的答案在文本中的位置。

```python
{'score': 0.622232091629833, 'start': 34, 'end': 96, 'answer': 'the task of extracting an answer from a text given a question.'}
{'score': 0.5115299158662765, 'start': 147, 'end': 161, 'answer': 'SQuAD dataset,'}
```

下面是一个使用模型和Tokenizer回答问题的示例。该过程如下：
– 从checkpoint名称实例化一个tokenizer和一个模型。该模型被识别为一个BERT模型，并用存储在checkpoint中的权重加载它。
– 定义一段文本和几个问题。
– 遍历问题并根据文本和当前问题构建一个序列，使用正确的模型特定分隔符标记类型id和注意力掩码将此序列传递到模型中。这将输出整个序列标记(问题和文本)的开始位置和结束位置的一系列分数。
– 计算结果的softmax以获得从标记的开始位置和停止位置对应的概率
– 将这些标记转换为字符串。
– 打印结果

Pytorch代码

```python
from transformers import AutoTokenizer, AutoModelForQuestionAnswering
import torch

tokenizer = AutoTokenizer.from_pretrained("bert-large-uncased-whole-word-masking-finetuned-squad")
model = AutoModelForQuestionAnswering.from_pretrained("bert-large-uncased-whole-word-masking-finetuned-squad")

text = r"""
&#x1f917; Transformers (formerly known as pytorch-transformers and pytorch-pretrained-bert) provides general-purpose
architectures (BERT, GPT-2, RoBERTa, XLM, DistilBert, XLNet…) for Natural Language Understanding (NLU) and Natural
Language Generation (NLG) with over 32+ pretrained models in 100+ languages and deep interoperability between
TensorFlow 2.0 and PyTorch.
"""

questions = [
    "How many pretrained models are available in Transformers?",
    "What does Transformers provide?",
    "Transformers provides interoperability between which frameworks?",
]

for question in questions:
    inputs = tokenizer.encode_plus(question, text, add_special_tokens=True, return_tensors="pt")
    input_ids = inputs["input_ids"].tolist()[0]

    text_tokens = tokenizer.convert_ids_to_tokens(input_ids)
    answer_start_scores, answer_end_scores = model(**inputs)

    answer_start = torch.argmax(
        answer_start_scores
    )  # Get the most likely beginning of answer with the argmax of the score
    answer_end = torch.argmax(answer_end_scores) + 1  # Get the most likely end of answer with the argmax of the score

    answer = tokenizer.convert_tokens_to_string(tokenizer.convert_ids_to_tokens(input_ids[answer_start:answer_end]))

    print(f"Question: {question}")
    print(f"Answer: {answer}\n")
```

TensorFlow代码

```python
from transformers import AutoTokenizer, TFAutoModelForQuestionAnswering
import tensorflow as tf

tokenizer = AutoTokenizer.from_pretrained("bert-large-uncased-whole-word-masking-finetuned-squad")
model = TFAutoModelForQuestionAnswering.from_pretrained("bert-large-uncased-whole-word-masking-finetuned-squad")

text = r"""
&#x1f917; Transformers (formerly known as pytorch-transformers and pytorch-pretrained-bert) provides general-purpose
architectures (BERT, GPT-2, RoBERTa, XLM, DistilBert, XLNet…) for Natural Language Understanding (NLU) and Natural
Language Generation (NLG) with over 32+ pretrained models in 100+ languages and deep interoperability between
TensorFlow 2.0 and PyTorch.
"""

questions = [
    "How many pretrained models are available in Transformers?",
    "What does Transformers provide?",
    "Transformers provides interoperability between which frameworks?",
]

for question in questions:
    inputs = tokenizer.encode_plus(question, text, add_special_tokens=True, return_tensors="tf")
    input_ids = inputs["input_ids"].numpy()[0]

    text_tokens = tokenizer.convert_ids_to_tokens(input_ids)
    answer_start_scores, answer_end_scores = model(inputs)

    answer_start = tf.argmax(
        answer_start_scores, axis=1
    ).numpy()[0]  # Get the most likely beginning of answer with the argmax of the score
    answer_end = (
        tf.argmax(answer_end_scores, axis=1) + 1
    ).numpy()[0]  # Get the most likely end of answer with the argmax of the score
    answer = tokenizer.convert_tokens_to_string(tokenizer.convert_ids_to_tokens(input_ids[answer_start:answer_end]))

    print(f"Question: {question}")
    print(f"Answer: {answer}\n")
```

这将输出预测答案后的问题：

```python
Question: How many pretrained models are available in Transformers?
Answer: over 32 +

Question: What does Transformers provide?
Answer: general - purpose architectures

Question: Transformers provides interoperability between which frameworks?
Answer: tensorflow 2 . 0 and pytorch
```

### 语言建模

语言建模是将一个模型与一个特定领域的语料库相匹配的任务。所有流行的基于transformer的模型都是使用语言建模的变体来训练的，例如掩码语言建模的BERT、因果语言建模的GPT-2。

语言建模在预训练之外也很有用，例如将模型分布转换为特定领域：使用在非常大的语料库上训练的语言模型，然后将其微调到新闻数据集或科学论文上，例如LysandreJik/arxiv nlp(https://huggingface.co/lysandre/arxiv-nlp)。

#### 掩码语言建模

掩码语言建模是用掩码标记对序列中的标记进行掩码，并提示模型用适当的标记填充该掩码的任务。这允许模型同时处理右上下文(掩码右侧的标记)和左上下文(掩码左侧的标记)。这样的训练为需要双向背景的下游任务(如SQuAD)奠定了坚实的基础。

下面是使用管道来替换序列中的掩码的示例：

```python
from transformers import pipeline

nlp = pipeline("fill-mask")
print(nlp(f"HuggingFace is creating a {nlp.tokenizer.mask_token} that the community uses to solve NLP tasks."))
```

这将在Tokenizer词汇表中输出填充了掩码的序列、置信度得分以及标记id：

```python
[
    {'sequence': '<s> HuggingFace is creating a tool that the community uses to solve NLP tasks.</s>', 'score': 0.15627853572368622, 'token': 3944},
    {'sequence': '<s> HuggingFace is creating a framework that the community uses to solve NLP tasks.</s>', 'score': 0.11690319329500198, 'token': 7208},
    {'sequence': '<s> HuggingFace is creating a library that the community uses to solve NLP tasks.</s>', 'score': 0.058063216507434845, 'token': 5560},
    {'sequence': '<s> HuggingFace is creating a database that the community uses to solve NLP tasks.</s>', 'score': 0.04211743175983429, 'token': 8503},
    {'sequence': '<s> HuggingFace is creating a prototype that the community uses to solve NLP tasks.</s>', 'score': 0.024718601256608963, 'token': 17715}
]
```

下面是一个使用模型和Tokenizer进行掩码语言建模的示例。该过程如下：
– 从checkpoint名称实例化一个tokenizer和一个模型。该模型被识别为一个DistilBERT模型，并用存储在checkpoint中的权重加载它。
– 定义一个带掩码标记的序列，不使用单词而是选择`tokenizer.mask_token`进行放置(进行掩码)。
– 将该序列编码为id，并在该id列表中找到掩码标记的位置。
– 在掩码标记的索引处检索预测：此张量与词汇表的大小相同，值是每个标记的分数。模型对他认为在这种情况下可能出现的标记会给出更高的分数。
– 使用PyTorch `topk`或TensorFlow `top_k`方法检索前5个标记。
– 用预测的标记替换掩码标记并打印结果

Pytorch代码

```python
from transformers import AutoModelWithLMHead, AutoTokenizer
import torch

tokenizer = AutoTokenizer.from_pretrained("distilbert-base-cased")
model = AutoModelWithLMHead.from_pretrained("distilbert-base-cased")

sequence = f"Distilled models are smaller than the models they mimic. Using them instead of the large versions would help {tokenizer.mask_token} our carbon footprint."

input = tokenizer.encode(sequence, return_tensors="pt")
mask_token_index = torch.where(input == tokenizer.mask_token_id)[1]

token_logits = model(input)[0]
mask_token_logits = token_logits[0, mask_token_index, :]

top_5_tokens = torch.topk(mask_token_logits, 5, dim=1).indices[0].tolist()

for token in top_5_tokens:
    print(sequence.replace(tokenizer.mask_token, tokenizer.decode([token])))
```

TensorFlow代码

```python
from transformers import TFAutoModelWithLMHead, AutoTokenizer
import tensorflow as tf

tokenizer = AutoTokenizer.from_pretrained("distilbert-base-cased")
model = TFAutoModelWithLMHead.from_pretrained("distilbert-base-cased")

sequence = f"Distilled models are smaller than the models they mimic. Using them instead of the large versions would help {tokenizer.mask_token} our carbon footprint."

input = tokenizer.encode(sequence, return_tensors="tf")
mask_token_index = tf.where(input == tokenizer.mask_token_id)[0, 1]

token_logits = model(input)[0]
mask_token_logits = token_logits[0, mask_token_index, :]

top_5_tokens = tf.math.top_k(mask_token_logits, 5).indices.numpy()

for token in top_5_tokens:
    print(sequence.replace(tokenizer.mask_token, tokenizer.decode([token])))
```

这将打印五个序列，其中前五个标记由模型预测：

```python
Distilled models are smaller than the models they mimic. Using them instead of the large versions would help reduce our carbon footprint.
Distilled models are smaller than the models they mimic. Using them instead of the large versions would help increase our carbon footprint.
Distilled models are smaller than the models they mimic. Using them instead of the large versions would help decrease our carbon footprint.
Distilled models are smaller than the models they mimic. Using them instead of the large versions would help offset our carbon footprint.
Distilled models are smaller than the models they mimic. Using them instead of the large versions would help improve our carbon footprint.
```

#### 因果语言建模

因果语言建模是根据一系列的标记来预测标记的任务。在这种情况下，模型只关注左边的上下文(掩码左边的标记)。这样的训练对于生成任务来说是有作用的。

目前还没有进行因果语言建模/生成的管道。
下面是一个使用Tokenizer和模型的示例。利用`generate()`方法按照PyTorch中的初始序列生成标记，并在TensorFlow中创建一个简单的循环。

Pytorch代码

```python
from transformers import AutoModelWithLMHead, AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained("gpt2")
model = AutoModelWithLMHead.from_pretrained("gpt2")

sequence = f"Hugging Face is based in DUMBO, New York City, and is"

input = tokenizer.encode(sequence, return_tensors="pt")
generated = model.generate(input, max_length=50)

resulting_string = tokenizer.decode(generated.tolist()[0])
print(resulting_string)
```

TensorFlow代码

```python
from transformers import TFAutoModelWithLMHead, AutoTokenizer
import tensorflow as tf

tokenizer = AutoTokenizer.from_pretrained("gpt2")
model = TFAutoModelWithLMHead.from_pretrained("gpt2")

sequence = f"Hugging Face is based in DUMBO, New York City, and is"
generated = tokenizer.encode(sequence)

for i in range(50):
    predictions = model(tf.constant([generated]))[0]
    token = tf.argmax(predictions[0], axis=1)[-1].numpy()
    generated += [token]

resulting_string = tokenizer.decode(generated)
print(resulting_string)
```

这将从原始序列输出(希望)的对应字符串，使用top_p/tok_k分布获取`generate()`采样的结果：

```python
Hugging Face is based in DUMBO, New York City, and is a live-action TV series based on the novel by John
Carpenter, and its producers, David Kustlin and Steve Pichar. The film is directed by!
```

### 命名实体识别

命名实体识别(NER)是根据类别对标记进行分类的任务，例如将标记标识为个人、组织或位置。命名实体识别数据集的一个例子是CoNLL-2003数据集，它完全基于该任务。如果你想对NER任务的模型进行微调，可以利用`ner/run_ner.py`(PyTorch)、`ner/run_pl_ner.py`(利用PyTorch lightning)或`ner/run_tf_ner.py`(TensorFlow)脚本。

下面是一个使用管道进行命名实体识别的示例，试图将标记标识为属于9个类之一：

- O, 不是命名实体
- B-MIS, 一个杂项实体的开头
- I-MIS, 杂项实体
- B-PER, 一个人名的开头
- I-PER, 人名
- B-ORG, 一个组织的开头
- I-ORG, 组织
- B-LOC, 一个地点的开头
- I-LOC, 地点

它利用CoNLL-2003上一个经过微调的模型，由dbmdz的@stefan-it进行了微调。

```python
from transformers import pipeline

nlp = pipeline("ner")

sequence = "Hugging Face Inc. is a company based in New York City. Its headquarters are in DUMBO, therefore very" \
           "close to the Manhattan Bridge which is visible from the window."

print(nlp(sequence))
```

这将输出上面定义的9个类中标识为实体的所有单词的列表。以下是预期结果：

```python
[
    {'word': 'Hu', 'score': 0.9995632767677307, 'entity': 'I-ORG'},
    {'word': '##gging', 'score': 0.9915938973426819, 'entity': 'I-ORG'},
    {'word': 'Face', 'score': 0.9982671737670898, 'entity': 'I-ORG'},
    {'word': 'Inc', 'score': 0.9994403719902039, 'entity': 'I-ORG'},
    {'word': 'New', 'score': 0.9994346499443054, 'entity': 'I-LOC'},
    {'word': 'York', 'score': 0.9993270635604858, 'entity': 'I-LOC'},
    {'word': 'City', 'score': 0.9993864893913269, 'entity': 'I-LOC'},
    {'word': 'D', 'score': 0.9825621843338013, 'entity': 'I-LOC'},
    {'word': '##UM', 'score': 0.936983048915863, 'entity': 'I-LOC'},
    {'word': '##BO', 'score': 0.8987102508544922, 'entity': 'I-LOC'},
    {'word': 'Manhattan', 'score': 0.9758241176605225, 'entity': 'I-LOC'},
    {'word': 'Bridge', 'score': 0.990249514579773, 'entity': 'I-LOC'}
]
```

注意“Hugging Face”是如何被确定为一个组织，“New York City”，“DUMBO”和“Manhattan Bridge”是如何被确定为地点的。

下面是一个使用模型和Tokenizer进行命名实体识别的示例。
该过程如下：
– 从checkpoint名称实例化一个tokenizer和一个模型。该模型被识别为一个BERT模型，并用存储在checkpoint中的权重加载它。
– 定义用于训练模型的标签列表。
– 定义一个包含已知实体的序列，例如“Hugging Face”作为一个组织，“New York City”作为一个位置。
– 将单词拆分为标记，以便它们可以映射到预测。我们使用一个小技巧，首先对序列进行完全的编码和解码，这样就留下了一个包含特殊标记的字符串。
– 将该序列编码为id(自动添加特殊标记)。
– 通过将输入传递到模型并获得第一个输出来检索预测。这将导致每个标记在9个可能的类上分布。我们使用argmax来检索每个标记最可能的类。
– 将每个标记及其预测到一起并打印出来。

Pytorch代码

```python
from transformers import AutoModelForTokenClassification, AutoTokenizer
import torch

model = AutoModelForTokenClassification.from_pretrained("dbmdz/bert-large-cased-finetuned-conll03-english")
tokenizer = AutoTokenizer.from_pretrained("bert-base-cased")

label_list = [
    "O",       # 不是命名实体
    "B-MISC",  # 一个杂项实体的开头
    "I-MISC",  # 杂项
    "B-PER",   # 一个人名的开头
    "I-PER",   # 人名
    "B-ORG",   # 一个组织的开头
    "I-ORG",   # 组织
    "B-LOC",   # 一个地点的开头
    "I-LOC"    # 地点
]

sequence = "Hugging Face Inc. is a company based in New York City. Its headquarters are in DUMBO, therefore very" \
           "close to the Manhattan Bridge."

# Bit of a hack to get the tokens with the special tokens
tokens = tokenizer.tokenize(tokenizer.decode(tokenizer.encode(sequence)))
inputs = tokenizer.encode(sequence, return_tensors="pt")

outputs = model(inputs)[0]
predictions = torch.argmax(outputs, dim=2)

print([(token, label_list[prediction]) for token, prediction in zip(tokens, predictions[0].tolist())])
```

TensorFlow代码

```python
from transformers import TFAutoModelForTokenClassification, AutoTokenizer
import tensorflow as tf

model = TFAutoModelForTokenClassification.from_pretrained("dbmdz/bert-large-cased-finetuned-conll03-english")
tokenizer = AutoTokenizer.from_pretrained("bert-base-cased")

label_list = [
    "O",       # 不是命名实体
    "B-MISC",  # 一个杂项实体的开头
    "I-MISC",  # 杂项
    "B-PER",   # 一个人名的开头
    "I-PER",   # 人名
    "B-ORG",   # 一个组织的开头
    "I-ORG",   # 组织
    "B-LOC",   # 一个地点的开头
    "I-LOC"    # 地点
]

sequence = "Hugging Face Inc. is a company based in New York City. Its headquarters are in DUMBO, therefore very" \
           "close to the Manhattan Bridge."

#用特殊的标记来获取标记的一点技巧
tokens = tokenizer.tokenize(tokenizer.decode(tokenizer.encode(sequence)))
inputs = tokenizer.encode(sequence, return_tensors="tf")

outputs = model(inputs)[0]
predictions = tf.argmax(outputs, axis=2)

print([(token, label_list[prediction]) for token, prediction in zip(tokens, predictions[0].numpy())])
```

这将输出映射到其预测的每个标记的列表。与管道不同的是，这里每个标记都有一个预测，因为我们没有删除“O”类，这意味着在该标记上找不到特定的实体。以下数组应为输出：

```python
[('[CLS]', 'O'), ('Hu', 'I-ORG'), ('##gging', 'I-ORG'), ('Face', 'I-ORG'), ('Inc', 'I-ORG
```