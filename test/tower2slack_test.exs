defmodule Tower2slackTest do
  use ExUnit.Case
  doctest Tower2slack.Proxy

  test "parse messages from Tower" do
    data = Poison.decode!(~s/{"action":"created","data":{"project":{"guid":"8326a5e69712479184f53cea924f8a74","name":"熟悉Tower"},"topic":{"guid":"dc37670ca1744f74b67e98e1b375052a","title":"测试话题","updated_at":"2016-09-08T12:49:57Z","handler":{"guid":"7544ba908d2a4108a0df79d65c9061d4","nickname":"五柳"}}}}/)

    assert Tower2slack.Proxy.transform_tower(data, "topics") == %{attachments: [%{"author_link" => "https://tower.im/members/7544ba908d2a4108a0df79d65c9061d4/", "author_name" => "五柳", "color" => "good", "mrkdwn_in" => ["text"], "text" => "在项目《<https://tower.im/projects/8326a5e69712479184f53cea924f8a74/|熟悉Tower>》中创建了 讨论 <https://tower.im/projects/8326a5e69712479184f53cea924f8a74/messages/dc37670ca1744f74b67e98e1b375052a/|测试话题>"}]}
  end

  test "parse topic messages" do
    data = Poison.decode!(~s/{"action":"commented","data":{"project":{"guid":"0fb7607b028d485fb49009db4b139bbf","name":"hook test"},"topic":{"guid":"fd9538e4028046638e53925a37ad35b0","title":"slack is awesome!","updated_at":"2016-09-09T05:20:47Z","handler":{"guid":"7544ba908d2a4108a0df79d65c9061d4","nickname":"五柳"}},"comment":{"guid":"0c455a8fa61d44f8a44f66c96f8e62b3","content":" :laughing: "}}}/)

    assert Tower2slack.Proxy.transform_tower(data, "topics") == %{attachments: [%{"author_link" => "https://tower.im/members/7544ba908d2a4108a0df79d65c9061d4/", "author_name" => "五柳", "color" => "good", "mrkdwn_in" => ["text"], "text" => "在项目《<https://tower.im/projects/0fb7607b028d485fb49009db4b139bbf/|hook test>》中评论了 讨论 <https://tower.im/projects/0fb7607b028d485fb49009db4b139bbf/messages/fd9538e4028046638e53925a37ad35b0/|slack is awesome!>\n> :laughing:"}]}
  end

  test "parse assignee" do
    data = Poison.decode!(~s/{"action":"assigned","data":{"project":{"guid":"0fb7607b028d485fb49009db4b139bbf","name":"hook test"},"topic":{"guid":"fd9538e4028046638e53925a37ad35b0","title":"slack is awesome!","updated_at":"2016-09-09T05:20:47Z","handler":{"guid":"7544ba908d2a4108a0df79d65c9061d4","nickname":"五柳"}},"comment":{"guid":"0c455a8fa61d44f8a44f66c96f8e62b3","content":" :laughing: "}, "assignee":{"nickname":"qhwa"}}}/)
    
    assert Tower2slack.Proxy.transform_tower(data, "topics") == %{attachments: [%{"author_link" => "https://tower.im/members/7544ba908d2a4108a0df79d65c9061d4/", "author_name" => "五柳", "color" => "good", "mrkdwn_in" => ["text"], "text" => "在项目《<https://tower.im/projects/0fb7607b028d485fb49009db4b139bbf/|hook test>》中指派 讨论 <https://tower.im/projects/0fb7607b028d485fb49009db4b139bbf/messages/fd9538e4028046638e53925a37ad35b0/|slack is awesome!> 给 *qhwa*\n> :laughing:"}]}
  end
end
