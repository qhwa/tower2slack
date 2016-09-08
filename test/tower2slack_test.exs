defmodule Tower2slackTest do
  use ExUnit.Case
  doctest Tower2slack

  test "parse messages from Tower" do
    data = Poison.decode!(~s/{"action":"created","data":{"project":{"guid":"8326a5e69712479184f53cea924f8a74","name":"熟悉Tower"},"topic":{"guid":"dc37670ca1744f74b67e98e1b375052a","title":"测试话题","updated_at":"2016-09-08T12:49:57Z","handler":{"guid":"7544ba908d2a4108a0df79d65c9061d4","nickname":"五柳"}}}}/)

    assert Tower2slack.transform_tower(data, "topics") == %{attachments: [%{"author_link" => "https://tower.im/members/7544ba908d2a4108a0df79d65c9061d4/", "author_name" => "五柳", "color" => "good", "mrkdwn_in" => ["text"], "text" => "在项目《<https://tower.im/projects/8326a5e69712479184f53cea924f8a74/|熟悉Tower>》中创建了 讨论 <https://tower.im/projects/8326a5e69712479184f53cea924f8a74/messages/dc37670ca1744f74b67e98e1b375052a/|测试话题>"}]}
  end
end
