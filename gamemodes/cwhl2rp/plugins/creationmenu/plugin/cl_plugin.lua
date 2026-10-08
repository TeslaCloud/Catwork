--- Adds the Left-Side Menu plugin's `community_name`, `community_link`, `community_button_enable`, `forum_name`,
-- `forum_link` and `forum_button_enable` config keys to the client's system config menu.

config.AddToSystem('#CommunityName', 'community_name', '#CommunityNameDesc')
config.AddToSystem('#CommunityLink', 'community_link', '#CommunityLinkDesc')
config.AddToSystem('#CommunityButtonEnable', 'community_button_enable', '#CommunityButtonEnableDesc')

config.AddToSystem('#ForumName', 'forum_name', '#ForumNameDesc')
config.AddToSystem('#ForumLink', 'forum_link', '#ForumLinkDesc')
config.AddToSystem('#ForumButtonEnable', 'forum_button_enable', '#ForumButtonEnableDesc')
