
local MainScene = class("MainScene", cc.load("mvc").ViewBase)
function MainScene:onCreate()
		--KBEngine.Event.fire("createAccount","kbe2017","kbe", "kbengine_cocos2d_js_demo");   	
    	KBEngine.Event.fire("login","kbe","kbe", "kbengine_cocos2d_js_demo");
    	--KBEngine.Event.register("onReqAvatarList", self, "onReqAvatarList");
    	KBEngine.Event.register("onLoginSuccessfully", self, "onLoginSuccessfully");

end

function MainScene:onLoginSuccessfully()
		print("loginn success")
		local player=KBEngine.app:player()
		dump(player)
		if player==nil then
			print("用户为nil")
		end
end

function MainScene:onReqAvatarList(avatars)
		for i=1,#avatars.values do
			local avator=avatars.values[i]
			print("MainScene:onReqAvatarList:",avator.name,avator.dbid,avator.level)
		end
			
end
return MainScene
