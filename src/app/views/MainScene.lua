
local MainScene = class("MainScene", cc.load("mvc").ViewBase)
function MainScene:onCreate()
		KBEngine.Event.fire("createAccount","kbe2017","kbe", "kbengine_cocos2d_js_demo");   	
    	KBEngine.Event.fire("login","kbe","kbe", "kbengine_cocos2d_js_demo");
    	--KBEngine.Event.register("onReqAvatarList", self, "onReqAvatarList");
end

function MainScene:onReqAvatarList(avatars)
		for i=1,#avatars.values do
			local avator=avatars.values[i]
			print("MainScene:onReqAvatarList:",avator.name,avator.dbid,avator.level)
		end
			
end
return MainScene
