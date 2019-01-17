local _M = class("MainScene", cc.load("mvc").ViewBase)
local WorldScene=require("views/WorldScene")
function _M:onKicked(failedcode)
		--GUIDebugLayer.debug.ERROR_MSG("kick, disconnect!, reason=" + KBEngine.app.serverErr(failedcode));
end

function _M:onDisableConnect()
		--切换到场景
		--cc.director.runScene(new StartScene());			
end

function _M:onConnectStatus(success)
		-- if(!success)
		-- 	GUIDebugLayer.debug.ERROR_MSG("Connect(" + KBEngine.app.ip + ":" + KBEngine.app.port + ") is error! (连接错误)");
		-- else
		-- 	GUIDebugLayer.debug.INFO_MSG("Connect successfully, please wait...(连接成功，请等候...)");
end


function _M:onLoginSuccessfully()
		print("loginn success")
		local player=KBEngine.app:player()
		if player==nil then
			print("用户为nil")
		end
end

function _M:onLoginBaseapp()
    	--GUIDebugLayer.debug.INFO_MSG("Connect to loginBaseapp, please wait...(连接到网关， 请稍后...)");
end

function _M:onReqAvatarList(avatars)
		if #avatars.values > 0 then
			for i=1,#avatars.values do
				local avator=avatars.values[i]
				print("_M:onReqAvatarList:",avator.name,avator.dbid,avator.level)
			end
		else
			KBEngine.app.player():reqCreateAvatar(2,"test999")
			return
		end
		KBEngine.app.player():selectAvatarGame(avatars.values[1].dbid)
		WorldScene.new():showWithScene()
		
		--KBEngine.app.player():reqCreateAvatar(2,"test999")	
end

function _M:onVersionNotMatch(clientVersion, serverVersion)
    	-- GUIDebugLayer.debug.ERROR_MSG("Version not match(curr=" + clientVersion + ", srv=" + serverVersion + " )(版本不匹配)");	
        self.serverScriptVersion:setString("serverScriptVersion: "..KBEngine.app.serverScriptVersion)
        self.serverVersion:setString("serverVersion: " .. KBEngine.app.serverVersion)	    	
end

function _M:onScriptVersionNotMatch(clientScriptVersion, serverScriptVersion)
    	-- GUIDebugLayer.debug.ERROR_MSG("ScriptVersion not match(curr=" + clientScriptVersion + ", srv=" + serverScriptVersion + " )(脚本版本不匹配)");
        self.serverScriptVersion:setString("serverScriptVersion: " .. KBEngine.app.serverScriptVersion)
        self.serverVersion:setString("serverVersion: " .. KBEngine.app.serverVersion)	    	
end

function _M:onLoginFailed(failedcode)
		print("failedcode:",failedcode)
		-- if(failedcode == 20)
		-- {
		-- 	GUIDebugLayer.debug.ERROR_MSG("Login is failed(登陆失败), err=" + KBEngine.app.serverErr(failedcode) + ", " + KBEngine.app.serverdatas);
		-- }
		-- else
		-- {
		-- 	GUIDebugLayer.debug.ERROR_MSG("Login is failed(登陆失败), err=" + KBEngine.app.serverErr(failedcode));
		-- }    	
end

function _M:Loginapp_importClientMessages()

end

function _M:Baseapp_importClientMessages()
    	--GUIDebugLayer.debug.INFO_MSG("Baseapp_importClientMessages ...");
end
    	
function _M:Baseapp_importClientEntityDef()
    	--GUIDebugLayer.debug.INFO_MSG("Baseapp_importClientEntityDef ...");
end

function _M:installEvent()
		--common
		KBEngine.Event.register("onKicked", self, "onKicked")
		KBEngine.Event.register("onDisableConnect", self, "onDisableConnect")
		KBEngine.Event.register("onConnectStatus", self, "onConnectStatus")	    	
		--login
		KBEngine.Event.register("onCreateAccountResult", self, "onCreateAccountResult")
		KBEngine.Event.register("onLoginFailed", self, "onLoginFailed")
		KBEngine.Event.register("onVersionNotMatch", self, "onVersionNotMatch")
		KBEngine.Event.register("onScriptVersionNotMatch", self, "onScriptVersionNotMatch")
		KBEngine.Event.register("onLoginBaseappFailed", self, "onLoginBaseappFailed")
		KBEngine.Event.register("onLoginSuccessfully", self, "onLoginSuccessfully")
		KBEngine.Event.register("onLoginBaseapp", self, "onLoginBaseapp")
		KBEngine.Event.register("Loginapp_importClientMessages", self, "Loginapp_importClientMessages")
		KBEngine.Event.register("Baseapp_importClientMessages", self, "Baseapp_importClientMessages")
		KBEngine.Event.register("Baseapp_importClientEntityDef", self, "Baseapp_importClientEntityDef")
		
		--selavatars
		KBEngine.Event.register("onReqAvatarList", self, "onReqAvatarList")
		KBEngine.Event.register("onCreateAvatarResult", self, "onCreateAvatarResult")
		KBEngine.Event.register("onRemoveAvatar", self, "onRemoveAvatar")
end

function _M:onCreate()
		self:setContentSize(display.size)
		local csize=self:getContentSize()
		local bg = cc.TMXTiledMap:create("img/2/start.tmx")
		bg:setAnchorPoint(0.5,0.5)
		bg:setPosition(csize.width/2,csize.height/2)
		bg:addTo(self)
		self.logo = UIImage.new("ui/logo.png")
		self.logo:setPosition(csize.width/2,csize.height-100)
		self.logo:addTo(self)
		
		local color=cc.c3b(0,255,0)
		local fontSize=18
		local serverVersion=display.newLabel("serverVersion:",fontSize,color)
		serverVersion:setAnchorPoint(0,1)
		serverVersion:setPosition(5,csize.height)
		serverVersion:addTo(self)
		
		local serverScriptVersion=display.newLabel("serverScriptVersion:",fontSize,color)
		serverScriptVersion:setAnchorPoint(0,1)
		serverScriptVersion:setPosition(serverVersion:getPositionX(),serverVersion:getPositionY()-20)
		serverScriptVersion:addTo(self)
		
		local clientVersion=display.newLabel("clientVersion:"..KBEngine.app.clientVersion,fontSize,color)
		clientVersion:setAnchorPoint(0,1)
		clientVersion:setPosition(serverVersion:getPositionX(),serverScriptVersion:getPositionY()-20)
		clientVersion:addTo(self)
		
		local clientScriptVersion=display.newLabel("clientScriptVersion:"..KBEngine.app.clientScriptVersion,fontSize,color)
		clientScriptVersion:setAnchorPoint(0,1)
		clientScriptVersion:setPosition(serverVersion:getPositionX(),clientVersion:getPositionY()-20)
		clientScriptVersion:addTo(self)
		self.serverVersion=serverVersion
		self.serverScriptVersion=serverScriptVersion
		self.clientVersion=clientVersion
		self.clientScriptVersion=clientScriptVersion
		
		self.usernamebox =cc.EditBox:create(cc.size(288, 34),cc.Scale9Sprite:create("res/ui/login_input.png"))
		self.usernamebox:setPosition(csize.width/2,csize.height/2-50)
		self.usernamebox:setFontColor(cc.c3b(0, 0, 0))
		self.usernamebox:setFontSize(20)
		self.usernamebox:setPlaceHolder("Input username")
		self.usernamebox:addTo(self)

		self.passwordbox =cc.EditBox:create(cc.size(288, 34),cc.Scale9Sprite:create("res/ui/login_input.png"))
		self.passwordbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		self.passwordbox:setPosition(csize.width/2,csize.height/2-100)
		self.passwordbox:setFontColor(cc.c3b(0, 0, 0))
		self.passwordbox:setPlaceHolder("Input password")
		self.passwordbox:addTo(self)
		
		local function loginBt(sender)
			local name=self.usernamebox:getText()
			local password=self.passwordbox:getText()
			KBEngine.Event.fire("login",name,password, "kbengine_cocos2d_lua_demo")
		end
		local loginbt=UIButton.newButton("res/ui/btn_up.png",loginBt)
		loginbt:setTitle("Login")
		loginbt:setPosition(csize.width/2-100,csize.height/2-150)
		loginbt:addTo(self)
		local function registerBt(sender)
			local name=self.usernamebox:getText()
			local password=self.passwordbox:getText()
			KBEngine.Event.fire("createAccount",name,password, "kbengine_cocos2d_lua_demo")
		end
		local registbt=UIButton.newButton("res/ui/btn_up.png",registerBt)
		registbt:setTitle("Register")
		registbt:setPosition(csize.width/2+100,csize.height/2-150)
		registbt:addTo(self)

		self:installEvent()
		self:enableNodeEvents()
		--KBEngine.Event.fire("createAccount","test10001","test10001","kbengine_cocos2d_lua_demo")

end

function _M:onCleanup()
		--KBEngine.Event.deregister(self)
end


return _M
