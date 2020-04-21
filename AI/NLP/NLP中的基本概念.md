# [NLP里面的一些基本概念](https://www.cnblogs.com/hapjin/p/7581335.html)

### 1，**corpus** 语料库

a computer-readable collection of text or speech 

### 2，**utterance** 发音

​	比如下面一句话：I do uh main- mainly business data processing 

​	uh 是 **fillers**，**填充词**（Words like uh and um are called fillers or filled pauses ）。The broken-off word main- is fragment called a **fragment** 

### 3，Types are the number of **distinct** words in a corpus  

​	给你一句话，这句话里面有多少个单词呢？ 标点符号算不算单词？有相同lemma的单词算不算重复的单词？比如“he is a boy and you are a girl”，这句话中 “is”和 "are"的lemma 都是 be。另外，这句话中 "a" 出现了两次。那这句话有多少个单词？这就要看具体的统计单词个数的方式了。

Tokens are the total number N of running words. 

### 4，Morphemes 

A Morpheme is the smallest division of text that has meaning. Prefxes and suffxes are examples of morphemes 

These are the smallest units of a word that is meaningful. 比如说：“bounded”，"bound"就是一个 morpheme，而Morphemes而包含了后缀 ed

### 5，Lemma（词根） 和 Wordform（词形）

Cat 和 cats 属于相同的词根，但是却是不同的词形。

Lemma 和 stem 有着相似的意思：

### 6，stem 

Stemming is the process of finding the word stem of a word 。比如，walking 、walked、walks 有着相同的stem，即： walk

与stem相关的一个概念叫做 lemmatization，它用来确定一个词的基本形式，这个过程叫做lemma。比如，单词operating，它的stem是 ope，它的lemma是operate 

Lemmatization is a more refined process than stemming and uses vocabulary and morphological techniques to find a lemma. This can result in more precise analysis in some situations 。

The lemmatization process determines the lemma of a word. **A lemma can be thought of as the dictionary form of a word**. 

（Lemmatization 要比 stemming 复杂，*但是它们都是为了寻找 单词的 “根”*）。但是Lemmatization 更复杂，它用到了一些词义分析(finding the morphological or vocabulary meaning of a token)

Stemming and lemmatization: These processes will alter the words to *get to* *their "roots".*  Similar to stemming is Lemmatization. This is the process of fnding its lemma, its form as found in a dictionary.  

Stemming is frequently viewed as a more primitive technique, where the attempt to get to the "root" of a word involves cutting off parts of the beginning and/or ending of a token. 

 Lemmatization can be thought of as a more sophisticated approach where effort is devoted to finding the morphological or vocabulary meaning of a token。

比如说 having 的 stem 是 hav，但是它的 lemma 是have

再比如说 was 和 been 有着不同的 stem，但是有着相同的 lemma : be

### 7，affix 词缀 （prefix 和 suffxes）

比如说：一个单词的 现在进行时，要加ing，那么 ing 就是一个后缀。

This precedes or follows the root of a word . 比如说，ation 就是 单词graduation的后缀。

### 8,tokenization （分词）

就是把一篇文章拆分成一个个的单词。The process of breaking text apart is called tokenization 

### 9，Delimiters （分隔符）

要把一个句子 分割成一个个的单词，就需要分隔符，常用的分隔符有：空格、tab键(\t)；还有 逗号、句号……这个要视具体的处理任务而定。

The elements of the text that determine where elements should be split are called Delimiters 。

### 10，categorization （归类）

把一篇文本，提取中心词，进行归类，来说明这篇文章讲了什么东西。比如写了一篇blog，需要将这篇blog的个人分类，方便以后查找。

This is the process of assigning some text element into one of the several possible groups.  

### 11,stopwords

某些NLP任务需要将一些常出现的“无意义”的词去掉，比如：统计一篇文章频率最高的100个词，可能会有大量的“is”、"a"、"the" 这类词，它们就是 stopwords。

Commonly used words might not be important for some NLP tasks such as general searches. These common words are called stopwords 

由于大部分文本都会包含 stopwords，因此文本分类时，最好去掉stopwords。关于stopwords的一篇[参考文章](http://www.ourren.com/en/2015/04/06/chinese-stopwords-for-nlp/)。

### 12，Normalization （归一化）

将一系列的单词 转化成 某种 统一 的形式，比如：将一句话的各个单词中，有大写、有小写，将之统一转成 小写。再比如，一句话中，有些单词是 缩写词，将之统一转换成全名。

Normalization is a process that converts a list of words to a more uniform sequence.

Normalization operations can include the following:（常用的归一化操作有如下几种）

converting characters to lowercase（大小写转换）,expanding abbreviation（缩略词变成全名）, removing stopwords（移除一些常见的“虚词”）, stemming, and lemmatization.（词干或者词根提取） 