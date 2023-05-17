# LangChain and Semantic Kernel

## Commons

Semantic Kernel 和 LangChain 可帮助开发人员：

- 管理对话历史记录，这是ChatCompletionAPI 希望开发人员弄清楚的。
- 根据意图规划方法。
- 为该方法实现“链接”
- 管理Memory和服务连接要求（即对话历史记录、外部 API 等）

## LangChain vs Semantic Kernel

LangChain目前是“最成熟”（但相当新的）拥有大型开源社区的。第一次提交是在 2022 年10月。

- 它支持Python和TypeScript，其中Python具有更多功能[2]。
- 大多数在线文章都使用Jupyter笔记本 演示 LangChain，LangChai也不把自己被称为“SDK”，它是为习惯于使用笔记本的ML工程师构建的。
- 应用程序开发人员需要弄清楚如何组织代码和使用 LangChain，软件工程方面的组织相对SK 显得差了很多。
- LangChain由Harrison Chase[3]创立，他的职业是ML工程师，更多是从ML 工程师角度架构应用。
- LangChain开源社区的贡献非常活跃，目前已经有29k star。
- 采用MIT开源协议

Semantic Kernel（SK）是相对“较新的”，但它是为开发人员构建的。第一次提交是在 2023 年 2 月。

- 它主要面向 C# 开发人员，它也支持 Python，（功能另请参阅功能奇偶校验文档[4]）。
- 因为它是为开发人员构建的，所以它被称为轻量级 SDK，可帮助开发人员将代码组织到内置于 Planner 中的技能、记忆和连接器中（在此处阅读更多内容）。
- 示例代码中有很多业务流程协调程序 Web 服务的示例。
- SK由一个以软件开发工程能力超强的组织（微软）创立。开源社区规模也相当活跃，目前已经有5.7k star。
- 它是由微软创立的，文档方面做的也非常好，它有一个官方的支持页面[5]和LinkedIn学习课程[6]。
- 由于 SK 在构建时考虑了应用，因此有一个 MS Graph连接器工具包[7]，适用于需要与日历、电子邮件、OneDrive 等集成的方案。

## Run semantic-kernel

https://github.com/microsoft/semantic-kernel/blob/main/python/README.md

```py
import semantic_kernel as sk
from semantic_kernel.connectors.ai.open_ai import OpenAITextCompletion, AzureTextCompletion

kernel = sk.Kernel()

# Prepare OpenAI service using credentials stored in the `.env` file
api_key, org_id = sk.openai_settings_from_dot_env()
kernel.config.add_text_completion_service("dv", OpenAITextCompletion("text-davinci-003", api_key, org_id))

# Alternative using Azure:
# deployment, api_key, endpoint = sk.azure_openai_settings_from_dot_env()
# kernel.config.add_text_completion_service("dv", AzureTextCompletion(deployment, endpoint, api_key))

# Wrap your prompt in a function
prompt = kernel.create_semantic_function("""
1) A robot may not injure a human being or, through inaction,
allow a human being to come to harm.

2) A robot must obey orders given it by human beings except where
such orders would conflict with the First Law.

3) A robot must protect its own existence as long as such protection
does not conflict with the First or Second Law.

Give me the TLDR in exactly 5 words.""")

# Run your prompt
print(prompt()) # => Robots must not harm humans.

# Create a reusable function with one input parameter
summarize = kernel.create_semantic_function("{{$input}}\n\nOne line TLDR with the fewest words.")

# Summarize the laws of thermodynamics
print(summarize("""
1st Law of Thermodynamics - Energy cannot be created or destroyed.
2nd Law of Thermodynamics - For a spontaneous process, the entropy of the universe increases.
3rd Law of Thermodynamics - A perfect crystal at zero Kelvin has zero entropy."""))

# Summarize the laws of motion
print(summarize("""
1. An object at rest remains at rest, and an object in motion remains in motion at constant speed and in a straight line unless acted on by an unbalanced force.
2. The acceleration of an object depends on the mass of the object and the amount of force applied.
3. Whenever one object exerts a force on another object, the second object exerts an equal and opposite on the first."""))

# Summarize the law of universal gravitation
print(summarize("""
Every point mass attracts every single other point mass by a force acting along the line intersecting both points.
The force is proportional to the product of the two masses and inversely proportional to the square of the distance between them."""))
```

## other

LLM创建软件的九项原则，称之为Schillace Laws of Semantic AI[8]https://learn.microsoft.com/zh-cn/semantic-kernel/howto/schillacelaws

## reference 

- https://www.cnblogs.com/shanyou/p/17338785.html
- https://github.com/microsoft/semantic-kernel/blob/main/python/README.md
- https://www.libhunt.com/compare-langchain-vs-semantic-kernel
