# Tower2slack

这个项目用来提供 hook 服务，将 [Tower](https://tower.im) 的 hook 数据转发到 [Slack](https://slack.com).

## 安装

本地开发需要依赖 [Elixir](http://elixir-lang.org/)

安装其他依赖:

`mix deps.get`


## 使用方式

1. 启动服务

    ```console
    mix run --no-halt
    ```

2. 将 tower 项目的 web hook url 设置为你服务器提供的 http 地址。
    假设你的 slack incoming web hook 地址是
     ```
     https://hooks.slack.com/services/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
    ``` 

    那么就换成

    ```
    http://YOUR_HOST:14326/services/T28DCF96F/BEFGB0UJD/Ge0s8ue2iOPkEtLLMv1uqfF8
    ```

3. tower 的 web hook 设置中，secret 一栏可以填 `#频道名` 或 `@用户名`

## 效果图

![](https://ruby-china-files.b0.upaiyun.com/photo/2016/11dde9cb0c846d4da8199a8485374493.png!large =313x)

将 Slack hook 地址 `https://hook.slack.com/...` 替换成 `http://YOUR_HOST:14326/...`

## 友情提示

由于国内、外网络原因，最好将服务部署到国外，这样网络方面的失败率会低一些。

## 鸣谢

这个项目参考了 [@lepture](https://github.com/lepture/) 写的 [python 版本](https://github.com/lepture/tower-slack).

![](https://ruby-china-files.b0.upaiyun.com/photo/2016/f8cb088cc16ffc7138401127880a108e.png!large =300x)

我们团队使用 [Tower](https://tower.io) + [Slack](https://slack.com) 作为日常的协作工具。
tower 提供了 web hook 的功能，可以将发生的事件通知给其他应用。Slack 也有 incomming bot 可以接收消息，自动发给团队成员。
理论上可以很好工作的，但两者的数据定义不一样，需要中间做一次格式转换。

因此我写了一个小服务，可以很作为一个 hook 代理，将收到的 notification 数据转换后发给 Slack.
项目地址：https://github.com/qhwa/tower2slack

## 友情提示

由于国内、外网络原因，最好将服务部署到国外，这样网络方面的失败率会低一些。
