# Tower2slack

这个项目用来提供 hook 服务，将 [Tower](https://tower.im) 的 hook 数据转发到 [Slack](https://slack.com).

## 安装

本地开发需要依赖 [Elixir](http://elixir-lang.org/)

安装其他依赖:

`mix deps.get`


## 使用

```console
mix run --no-halt
```

将 Slack hook 地址 `https://hook.slack.com/...` 替换成 `http://YOUR_HOST:14326/...`


## 鸣谢

这个项目参考了 [@lepture](https://github.com/lepture/) 写的 [python 版本](https://github.com/lepture/tower-slack).
