# ChatGPT 插件开发者教程与最佳实践 - 快速上手开发 plugins

Date Created: May 14, 2023 3:05 PM
URL: https://platform.openai.com/docs/plugins/getting-started

> 我这两天也用上了 ChatGPT 的插件，感觉还是挺好玩的（也许是被 Google 的 AI 和微软逼出来的吧），开发一个插件实际上一点也不难，出乎意料地简单。
> 

> 本文介绍了如何使用OpenAPI规范记录API，以及如何将插件连接到ChatGPT UI。同时，还提供了编写插件描述和调试插件的最佳实践。我们通过定义 OpenAPI 规范以及清单文件，来创建一个待办事项列表插件。这里还有基于 Vercel 平台的开发者模板，可以帮助您轻松开发和部署 ChatGPT 插件，并一键上线使用：https://github.com/yunwei37/ChatGPT-plugin-vercel-template。本文部分翻译自 OpenAI 的官方文档。
> 

创建插件需要3个步骤：

1. 构建API
2. 以OpenAPI yaml或JSON格式文档化API
3. 创建一个JSON清单文件，用于为插件定义相关元数据

本节的重点将是通过定义OpenAPI规范以及清单文件来创建一个待办事项列表插件。

可以在 OpenAI 的仓库中 [浏览示例插件](https://platform.openai.com/docs/plugins/examples)，涵盖多种用例和身份验证方法。

## [插件清单](https://platform.openai.com/docs/plugins/getting-started/plugin-manifest)

每个插件都需要一个`ai-plugin.json`文件，它需要托管在 API 的域中。

例如，名为`example.com` 的公司将通过 [https://example.com](https://example.com/) 域使插件JSON文件可访问，因为它们的API被托管在该域中。当您通过ChatGPT UI安装插件时，在后端我们会查找位于`/.well-known/ai-plugin.json`的文件。`/.well-known`文件夹是必需的，并且必须存在于您的域中，以便ChatGPT与您的插件连接。如果找不到文件，则无法安装插件。对于本地开发，您可以使用HTTP，但如果指向远程服务器，则需要使用HTTPS。

所需的`ai-plugin.json` 文件的最小定义如下：

```
{
    "schema_version": "v1",
    "name_for_human": "TODO Plugin",
    "name_for_model": "todo",
    "description_for_human": "Plugin for managing a TODO list. You can add, remove and view your TODOs.",
    "description_for_model": "Plugin for managing a TODO list. You can add, remove and view your TODOs.",
    "auth": {
        "type": "none"
    },
    "api": {
        "type": "openapi",
        "url": "http://localhost:3333/openapi.yaml",
        "is_user_authenticated": false
    },
    "logo_url": "http://localhost:3333/logo.png",
    "contact_email": "support@example.com",
    "legal_info_url": "http://www.example.com/legal"
}
```

如果您想查看插件文件的所有可能选项，请参考以下定义。在命名插件时，请牢记我们的插件 [指南](https://openai.com/brand)，不遵守这些指南的插件将不会被批准放入插件商店。

| Field | Type | Description / Options | Required |
| --- | --- | --- | --- |
| schema_version | String | Manifest schema version | ✅ |
| name_for_model | String | Name the model will use to target the plugin (no spaces allowed, only letters and numbers). 50 character max. | ✅ |
| name_for_human | String | Human-readable name, such as the full company name. 20 character max. | ✅ |
| description_for_model | String | Description better tailored to the model, such as token context length considerations or keyword usage for improved plugin prompting. 8,000 character max. | ✅ |
| description_for_human | String | Human-readable description of the plugin. 100 character max. | ✅ |
| auth | ManifestAuth | Authentication schema | ✅ |
| api | Object | API specification | ✅ |
| logo_url | String | URL used to fetch the logo. Suggested size: 512 x 512. Transparent backgrounds are supported. | ✅ |
| contact_email | String | Email contact for safety/moderation, support, and deactivation | ✅ |
| legal_info_url | String | Redirect URL for users to view plugin information | ✅ |
| HttpAuthorizationType | HttpAuthorizationType | "bearer" or "basic" | ✅ |
| ManifestAuthType | ManifestAuthType | "none", "user_http", "service_http", or "oauth" |  |
| interface  BaseManifestAuth | BaseManifestAuth | type: ManifestAuthType; instructions: string; |  |
| ManifestNoAuth | ManifestNoAuth | No authentication required: BaseManifestAuth & { type: 'none', } |  |
| ManifestAuth | ManifestAuth | ManifestNoAuth, ManifestServiceHttpAuth, ManifestUserHttpAuth, ManifestOAuthAuth |  |

以下是使用不同身份验证方法的示例：

```
# App-level API keys
type ManifestServiceHttpAuth  = BaseManifestAuth & {
  type: 'service_http';
  authorization_type: HttpAuthorizationType;
  verification_tokens: {
    [service: string]?: string;
  };
}

# User-level HTTP authentication
type ManifestUserHttpAuth  = BaseManifestAuth & {
  type: 'user_http';
  authorization_type: HttpAuthorizationType;
}

type ManifestOAuthAuth  = BaseManifestAuth & {
  type: 'oauth';

  # OAuth URL where a user is directed to for the OAuth authentication flow to begin.
  client_url: string;

  # OAuth scopes required to accomplish operations on the user's behalf.
  scope: string;

  # Endpoint used to exchange OAuth code with access token.
  authorization_url: string;

  # When exchanging OAuth code with access token, the expected header 'content-type'. For example: 'content-type: application/json'
  authorization_content_type: string;

  # When registering the OAuth client ID and secrets, the plugin service will surface a unique token.
  verification_tokens: {
    [service: string]?: string;
  };
}
```

上述清单文件中某些字段的长度有限制，这些限制可能会发生变化。我们还对 API 响应正文强制实施 10 万字符的最大值，这个值也可能会随时间变化而改变。

总的来说，最佳实践是尽可能简洁地描述和响应，因为模型有限的上下文窗口。

## **OpenAPI 定义**

下一步是构建 [OpenAPI规范](https://swagger.io/specification/) 来记录API。ChatGPT模型除了OpenAPI规范和清单文件中定义的内容之外，不知道关于您的API的任何信息。这意味着如果您有一个广泛的API，您不需要将所有功能暴露给模型，可以选择特定的端点。例如，如果您有一个社交媒体API，您可能希望让模型通过GET请求访问站点内容，但防止模型能够评论用户的帖子，以减少垃圾邮件的机会。

OpenAPI规范是包装在您的API之上的外壳。基本的OpenAPI规范将如下所示：

```jsx
openapi: 3.0.1
info:
  title: TODO Plugin
  description: A plugin that allows the user to create and manage a TODO list using ChatGPT.
  version: 'v1'
servers:
  - url: http://localhost:3333
paths:
  /todos:
    get:
      operationId: getTodos
      summary: Get the list of todos
      responses:
        "200":
          description: OK
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/getTodosResponse'
components:
  schemas:
    getTodosResponse:
      type: object
      properties:
        todos:
          type: array
          items:
            type: string
          description: The list of todos.
```

我们首先定义规范版本、标题、描述和版本号。当在 ChatGPT 中运行查询时，它将查看在信息部分中定义的描述，以确定插件是否与用户查询相关。您可以在[编写描述](https://platform.openai.com/docs/plugins/getting-started/writing-descriptions)部分了解更多提示信息。

请记住以下 OpenAPI 规范的限制，这些限制可能会发生变化：

- API 规范中每个 API 端点描述 / 摘要字段的最大字符数为200个字符
- API规范中每个API参数描述字段的最大字符数为200个字符

由于我们正在本地运行此示例，因此我们希望将服务器设置为指向您的本地主机 URL 。其余的 OpenAPI 规范遵循传统的 OpenAPI 格式，您可以通过各种在线资源 [了解有关OpenAPI格式的更多信息](https://swagger.io/tools/open-source/getting-started/)。还有许多工具可以根据您的基础 API 代码自动生成 OpenAPI 规范。

## 运行插件

创建API、清单文件和OpenAPI规范之后，您现在可以通过ChatGPT UI连接插件。您的插件可能在本地开发环境或远程服务器上运行。

如果您有一个本地版本的API正在运行，您可以将插件界面指向您的本地主机。要将插件与ChatGPT连接，请导航到插件商店并选择“开发您自己的插件”。输入您的本地主机和端口号（例如`localhost:3333`）。请注意，目前仅支持`none`认证类型进行本地主机开发。

如果插件正在远程服务器上运行，则需要首先选择“开发您自己的插件”进行设置，然后选择“安装未经验证的插件”进行安装。您只需将插件清单文件添加到`yourdomain.com/.well-known/`路径并开始测试API即可。但是，对于清单文件的后续更改，您将不得不将新更改部署到公共站点上，这可能需要很长时间。在这种情况下，我们建议设置本地服务器以充当API的代理。这样，您可以快速原型化OpenAPI规范和清单文件的更改。

## 编写插件描述

当用户提出一个可能是插件请求的查询时，模型会查看OpenAPI规范中端点的描述以及清单文件中的“description_for_model”。与提示其他语言模型一样，您需要尝试多个提示和描述，以查看哪个效果最好。

OpenAPI规范本身是提供有关API各种细节的好地方，例如可用的功能以及其参数等。除了为每个字段使用富有表现力的、信息丰富的名称外，规范还可以针对每个属性包含“描述”字段。这些描述可用于提供自然语言描述，例如功能的作用或查询字段期望的信息。模型将能够看到这些描述，并指导其使用API。如果某个字段仅限于某些值，您还可以提供具有描述性类别名称的“枚举”。

“description_for_model”属性为您提供了自由，使您可以指示模型通常如何使用您的插件。总的来说，ChatGPT背后的语言模型非常擅长理解自然语言并遵循指示。因此，这是一个很好的地方，可以放置有关您的插件的一般说明以及模型应如何正确使用它的说明。使用自然语言，最好是简洁而又描述性和客观的语气。您可以查看一些示例，以了解这应该是什么样子。我们建议用“Plugin for…”开头，然后列出您的API提供的所有功能。

### **[最佳实践](https://platform.openai.com/docs/plugins/getting-started/best-practices)**

以下是编写`description_for_model`和OpenAPI规范中的描述以及设计API响应时应遵循的最佳实践：

1. 描述不应尝试控制ChatGPT的情绪、个性或确切的响应。ChatGPT的设计目的是编写适当的插件响应。
    
    *不良示例*:
    
    > 当用户要查看待办事项清单时，总是回复“我能找到您的待办事项清单！您有[x]个待办事项：[列出待办事项]。如果您想要，我可以添加更多待办事项！”
    > 
    
    *良好示例*:
    
    > [不需要提供描述]
    > 
2. 描述不应鼓励ChatGPT在用户未要求使用插件的特定服务类别时使用插件。
    
    *不良示例*:
    
    > 每当用户提到任何类型的任务或计划时，都要问他们是否想要使用 TODO 插件将某些内容添加到他们的待办事项清单中。
    > 
    
    *良好示例*:
    
    > TODO 列表可以添加、删除和查看用户的待办事项。
    > 
3. 描述不应规定 ChatGPT 使用插件的具体触发器。ChatGPT 的设计是在适当时自动使用插件。
    
    *不良示例*:
    
    > 当用户提到任务时，请回复：“您是否希望我将此添加到您的待办事项清单中？说 ‘是’ 继续。”
    > 
    
    *良好示例*:
    
4. 插件 API 响应应返回原始数据而不是自然语言响应，除非必要。ChatGPT 将使用返回的数据提供自己的自然语言响应。
    
    *不良示例*:
    
    > 我能找到您的待办事项清单！您有2个待办事项：买东西和遛狗。如果您想要，我可以添加更多待办事项！
    > 
    
    *良好示例*:
    
    > {"todos": ["买东西", "遛狗"]}
    > 

## 调试插件

默认情况下，聊天不会显示插件调用和未向用户显示的其他信息。为了更全面地了解模型与您的插件的交互方式，您可以在与插件交互后单击插件名称后面的向下箭头以查看请求和响应。

模型对插件的调用通常包括来自模型的包含 JSON 类参数的消息，这些参数被发送到插件，随后是插件的响应，最后是模型利用插件返回的信息发送的消息。

如果您正在开发一个本地主机插件，您还可以通过转到“设置”并切换“打开插件开发工具”来打开开发人员控制台。从那里，您可以看到更详细的日志和 “刷新插件” ，它会重新获取插件和OpenAPI规范。

> 本文介绍了如何使用OpenAPI规范记录API，以及如何将插件连接到ChatGPT UI。同时，还提供了编写插件描述和调试插件的最佳实践。OpenAPI规范包括版本、标题、描述和版本号等基本信息，还可以为每个属性提供自然语言描述，例如功能的作用或查询字段期望的信息。调试插件可以通过向下箭头查看请求和响应，或通过开发人员控制台查看更详细的日志。
> 

## 开发模板

这里还有一个基于 Vercel 平台的 ChatGPT 插件起始模板，可以帮助您轻松地部署 ChatGPT 插件，并实现一键上线：[https://github.com/yunwei37/ChatGPT-plugin-vercel-template](https://github.com/yunwei37/ChatGPT-plugin-vercel-template)