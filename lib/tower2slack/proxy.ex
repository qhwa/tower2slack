defmodule Tower2slack.Proxy do

  @moduledoc """
  转发 Tower.im 的 webhook 数据到 Slack
  @see https://api.slack.com/incoming-webhooks
  """

  @defaults %{
    icon_url: "https://tower.im/assets/mobile/icon/icon@512-84fa5f6ced2a1bd53a409013f739b7ba.png",
    channel:  "#test"
  }

  def forward(data, event_type, url) do
    transform_tower(data, event_type) |> deliver(url)
  end

  @doc """
  将 Tower 的 hook 数据结构转换成 Slack 的格式.

  Returns Slack payload

  ## Exmaple:
  
  iex> Tower2slack.Proxy.transform_tower(%{
  ...>  "action" => "created",
  ...>  "data" => %{
  ...>    "project" => %{
  ...>      "guid" => "8326a5e69712479184f53cea924f8a74",
  ...>      "name" => "熟悉 tower"
  ...>    },
  ...>    "todo" => %{
  ...>      "guid" => "bf40ff9e0ee44fd5b21b4ae0eaafd1ab",
  ...>      "title" => "testst",
  ...>      "updated_at" => "2016-09-08T09:29:55Z",
  ...>      "handler" => %{
  ...>        "guid" => "7544ba908d2a4108a0df79d65c9061d4",
  ...>        "nickname" => "wuliu"
  ...>      },
  ...>      "due_at" => nil
  ...>    },
  ...>    "todolist" => %{
  ...>      "guid" => "37cece9ad4164a769637c7807e27d927",
  ...>      "title" => "teststest"
  ...>    }
  ...>  }
  ...>}, "todos")
  %{attachments: [%{"author_link" => "https://tower.im/members/7544ba908d2a4108a0df79d65c9061d4/", "author_name" => "wuliu", "color" => "good", "mrkdwn_in" => ["text"], "text" => "在项目《<https://tower.im/projects/8326a5e69712479184f53cea924f8a74/|熟悉 tower>》中创建了 任务 <https://tower.im/projects/8326a5e69712479184f53cea924f8a74/todos/bf40ff9e0ee44fd5b21b4ae0eaafd1ab/|testst>"}]}


  {"action":"archived","data":{"project":{"guid":"8326a5e69712479184f53cea924f8a74","name":"熟悉Tower"},"topic":{"guid":"fe5ca04772754f7182d50d4e8f8af17c","title":"欢迎来到 Tower","updated_at":"2016-09-08T12:46:54Z","handler":{"guid":"7544ba908d2a4108a0df79d65c9061d4","nickname":"五柳"}}}}
  """
   
  def transform_tower(msg, event) do
    %{"action" => action, "data" => data} = msg
    %{"project" => %{
        "guid"  => project_guid,
        "name"  => project_name
      },
    } = data

    subject = Map.get(data, subject_key(event))
    %{"guid" => subject_guid, "title" => subject_title} = subject

    attachment  = %{"color" => get_color(action)}
    subject_url = get_subject_url(project_guid, event, subject_guid)

    author     = Map.get(subject, "handler")
    attachment = case author do
      nil -> attachment
      _   -> Map.merge(attachment, %{
        "author_name" => Map.get(author, "nickname"),
        "author_link" => "https://tower.im/members/#{Map.get(author, "guid")}/"
      })
    end

    text = "在项目《<#{project_url(project_guid)}|#{project_name}>》中#{caption(action)} #{caption(event)} <#{subject_url}|#{subject_title}>"

    text = case action do
      "assigned" ->
        %{"assignee" => %{ "nickname" => nickname }} = subject
        "#{text} 给 *#{nickname}%"

      _ -> text
    end

    text = case Map.get(data, "comment") do
      nil -> text
      comment ->
        content = comment.content
        lines = content |> String.strip |> String.split("\r\n")
        "#{text}\n> #{lines[0]} ..."
    end

    attachment = attachment
      |> Map.put("text", text)
      |> Map.put("mrkdwn_in", ["text"])

    %{attachments: [attachment]}
  end

  defp subject_key(type) do
    case type do
      _ -> String.replace(type, ~r/e?s$/, "")
    end
  end

  defp caption(action) do
    case action do
      "created"          -> "创建了"
      "updated"          -> "更新了"
      "deleted"          -> "删除了"
      "commented"        -> "评论了"
      "archived"         -> "归档了"
      "unarchived"       -> "激活了"
      "started"          -> "开始处理"
      "paused"           -> "暂停处理"
      "reopen"           -> "重新打开了"
      "completed"        -> "完成了"
      "deadline_changed" -> "更新截止时间"
      "sticked"          -> "置顶了"
      "unsticked"        -> "取消置顶"
      "recovered"        -> "恢复了"
      "assigned"         -> "指派"
      "unassigned"       -> "取消指派"
      "documents"        -> "文档"
      "topics"           -> "讨论"
      "todos"            -> "任务"
      "todolists"        -> "任务清单"
      "attachments"      -> "文件"
      _                  -> action
    end
  end

  defp get_color(action) do
    "good"
  end

  defp project_url(guid) do
    "https://tower.im/projects/#{guid}/"
  end

  defp get_subject_url(project_guid, type, subjetc_guid) do
    base = project_url(project_guid)
    case type do
      "topics"    -> "#{base}messages/#{subjetc_guid}/"
      "documents" -> "#{base}docs/#{subjetc_guid}/"
      _           -> "#{base}#{type}/#{subjetc_guid}/"
    end
  end

  @doc """
  将 payload 发到 Slack。会加上默认设置。
  """
  def deliver(payload, url) do
    %{body: "ok", status_code: 200} = HTTPoison.post!(
      url,
      Poison.encode!(Map.merge(@defaults, payload)),
      [{:"content-type", "application/json"}]
    )

    :ok
  end

end
