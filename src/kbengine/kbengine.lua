local _M=class("KBEngine")
_M.PACKET_MAX_SIZE = 1500
_M.PACKET_MAX_SIZE_TCP = 1460
_M.PACKET_MAX_SIZE_UDP = 1472
_M.MESSAGE_ID_LENGTH = 2
_M.MESSAGE_LENGTH_LENGTH = 2
_M.CLIENT_NO_FLOAT = 0
_M.KBE_FLT_MAX=3.402823466e+38
_M.messages = {}
_M.moduledefs={}
_M.clientmessages={}
_M.bufferedCreateEntityMessage={}
_M.MAILBOX_TYPE_CELL = 0
_M.MAILBOX_TYPE_BASE = 1

function _M.messagesInit()
		 _M.messages={} 	
		 _M.messages["loginapp"] = {}
		 _M.messages["baseapp"] = {}
		 _M.messages["Loginapp_importClientMessages"]=KBEngine.Message.new(5,"importClientMessages", 0, 0,{},nil)
		 _M.messages["Baseapp_importClientMessages"]=KBEngine.Message.new(207,"importClientMessages", 0, 0,{},nil)
		 _M.messages["Baseapp_importClientEntityDef"]=KBEngine.Message.new(208,"importClientEntityDef", 0, 0,{},nil)
		 _M.messages["onImportClientMessages"]=KBEngine.Message.new(518,"onImportClientMessages", 0, 0,{},nil)
end

--默认参数
function _M.KBEngineArgs()
	_M.messagesInit()
	local args={}
	args.ip = "127.0.0.1"
	args.port = 20013
	args.updateHZ = 100
	--Reference: http://www.kbengine.org/docs/programming/clientsdkprogramming.html, client types
	args.clientType = 5
	-- 在Entity初始化时是否触发属性的set_*事件(callPropertysSetMethods)
	args.isOnInitCallPropertysSetMethods = true
	return args
end

function _M:serverErr(id)
		local e = KBEngine.app.serverErrs[id]
		
		if e == nil then
			return ""
		end

		return e.name .. " [" .. e.descr .. "]"
end

function _M:clearEntities(isAll)
		KBEngine.app.controlledEntities = {}
		if not isAll then
			local entity = KBEngine.app:player()
			for k,v in pairs(KBEngine.app.entities) do
				if(k ~= entity.id) then
				   if v.inWorld then
			    		v:leaveWorld()
			    	end
			    	v:onDestroy()
				end
			end
			KBEngine.app.entities = {}
			KBEngine.app.entities[entity.id] = entity		
		else
			for k,v in pairs(KBEngine.app.entities) do
				if v.inWorld then
			    	v:leaveWorld()
			    end
			    v:onDestroy()
			end
			KBEngine.app.entities = {}
		end
end		

function _M:reset()
		if self.entities ~= nil then
			self:clearEntities(true)
		end

		if self.socket then
			--todo
			--self.socket:close()
		end
		
		self.currserver = "loginapp"
		self.currstate = "create"
		
		--扩展数据
		self.serverdatas = ""
		
		--版本信息
		self.serverVersion = ""
		self.serverScriptVersion = ""
		self.serverProtocolMD5 = ""
		self.serverEntityDefMD5 = ""
		self.clientVersion = "0.9.12"
		self.clientScriptVersion = "0.1.0"
		
		--player的相关信息
		self.entity_uuid = nil
		self.entity_id = 0
		self.entity_type = ""

		--当前玩家最后一次同步到服务端的位置与朝向与服务端最后一次同步过来的位置		
		self.entityServerPos = KBEngine.Vector3.new(0.0, 0.0, 0.0)
		--客户端所有的实体
		self.entities = {}
		self.entityIDAliasIDList = {}
		self.controlledEntities = {}

		--空间的信息
		self.spacedata = {}
		self.spaceID = 0
		self.spaceResPath = ""
		self.isLoadedGeometry = false
		self.lastTickTime = os.time()
		self.lastTickCBTime = os.time()
		--当前组件类别， 配套服务端体系
		self.component = "client"
end

function _M.bindReader(argType)
	for k,v in pairs(KBEngine.datatype2id) do
		if v==argType then
			local reader=KBEngine.datatypes[k] or KBEngine.datatypes["BLOB"]
		    return reader	
		end
	end
end

function _M:player()
		return KBEngine.app.entities[KBEngine.app.entity_id]
end

function _M:findEntity(entityID)
		
		return KBEngine.app.entities[entityID]
end

function _M:addSpaceGeometryMapping(spaceID, respath)
		KBEngine.INFO_MSG("KBEngineApp::addSpaceGeometryMapping: spaceID(" .. spaceID .. "), respath(" .. respath ..")!")
		KBEngine.app.spaceID = spaceID
		KBEngine.app.spaceResPath = respath
		KBEngine.Event.fire("addSpaceGeometryMapping", respath)

end

function _M:clearSpace(isAll)
		KBEngine.app.entityIDAliasIDList = {}
		KBEngine.app.spacedata = {}
		KBEngine.app:clearEntities(isAll)
		KBEngine.app.isLoadedGeometry = false
		KBEngine.app.spaceID = 0
end

function _M:updatePlayerToServer()
		local player = KBEngine.app:player()
		if player == nil or (player.inWorld == false) or (KBEngine.app.spaceID == 0) or player.isControlled then
			return
		end

		if player.entityLastLocalPos:distance(player.position) > 0.001 or player.entityLastLocalDir:distance(player.direction) > 0.001 then
			--记录玩家最后一次上报位置时自身当前的位置
			player.entityLastLocalPos.x = player.position.x
			player.entityLastLocalPos.y = player.position.y
			player.entityLastLocalPos.z = player.position.z
			player.entityLastLocalDir.x = player.direction.x
			player.entityLastLocalDir.y = player.direction.y
			player.entityLastLocalDir.z = player.direction.z	
			
			local bundle = KBEngine.Bundle.new()
			bundle:newMessage(KBEngine.messages.Baseapp_onUpdateDataFromClient)
			bundle:writeFloat(player.position.x)
			bundle:writeFloat(player.position.y)
			bundle:writeFloat(player.position.z)
			bundle:writeFloat(player.direction.x)
			bundle:writeFloat(player.direction.y)
			bundle:writeFloat(player.direction.z)
			bundle:writeUint8(player.isOnGround)
			bundle:writeUint32(KBEngine.app.spaceID)
			bundle:send()

		end

		--开始同步所有被控制了的entity的位置
		for i,v in ipairs(KBEngine.app.controlledEntities) do
			local entity = KBEngine.app.controlledEntities[i]
			local position = entity.position
			local direction = entity.direction
			local posHasChanged = entity.entityLastLocalPos:distance(position) > 0.001

			if posHasChanged or dirHasChanged then
				entity.entityLastLocalPos = position
				entity.entityLastLocalDir = direction

				local bundle = KBEngine.Bundle.new()
				bundle:newMessage(KBEngine.messages.Baseapp_onUpdateDataFromClientForControlledEntity)
				bundle:writeInt32(entity.id)
				bundle:writeFloat(position.x)
				bundle:writeFloat(position.y)
				bundle:writeFloat(position.z)

				bundle:writeFloat(direction.x)
				bundle:writeFloat(direction.y)
				bundle:writeFloat(direction.z)
				bundle:writeUint8(entity.isOnGround)
				bundle:writeUint32(KBEngine.app.spaceID)
				bundle:send()
			end
		end


end

function _M:ctor(kbengineArgs)
		_M.app=self
		self:reset()
		self:installEvents()
		self.args = kbengineArgs
		self.username="kbe"
		self.password="kbe"
		self.clientdatas=""
		self.encryptedKey = ""
		self.loginappMessageImported = false
		self.baseappMessageImported = false
		self.serverErrorsDescrImported = false
		self.entitydefImported = false
		self.serverErrs={}
		self.entityclass = {}
		self.ip=self.args.ip
		self.port=self.args.port
		self.baseappIP=""
		self.baseappPort=0
		local function update()
			self:update()
		end
		KBEngine.idInterval = KBEngine.Timer.onTimer(update,kbengineArgs.updateHZ/1000);
     	
end

function _M:onmessage(data)
		if self.readStream==nil then
		   self.readStream=KBEngine.MemoryStream.new(data)
		else
		   self.readStream:writeBuf(data)	   	
		end
		while self.readStream.wpos>self.readStream.rpos do
			  local readPos=self.readStream.rpos	
			  local msgid = self.readStream:readUint16()
			  
			  local msgHandler = KBEngine.clientmessages[msgid]
			  if msgHandler==nil then
			  	 KBEngine.ERROR_MSG("KBEngineApp::onmessage["..KBEngine.app.currserver.. "]: not found msg(" ..msgid ..")!")
			  	self.readStream=KBEngine.MemoryStream.new() 
			  	break  
			  end
			  local msglen = msgHandler.length
			  if msglen == -1 then
					msglen = self.readStream:readUint16()					
					-- 扩展长度
					if msglen == 65535 then
						msglen = self.readStream:readUint32()
					end
			  end
			  if self.readStream:getLength()>=msglen then
				 local stream=self.readStream:getStream(msglen)
			  	 msgHandler:handleMessage(stream)
			  	 self.readStream:clearReadBuff()
			  else
			  	 self.readStream.rpos=readPos
			  	 return
			  end
		end
end


function _M:onRemoteMethodCall_(eid, stream)
		local entity = KBEngine.app.entities[eid]
		if entity == nil then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onRemoteMethodCall: entity(" .. eid .. ") not found!")
			return
		end
		
		local methodUtype = 0
		if KBEngine.moduledefs[entity.className].useMethodDescrAlias then
			methodUtype = stream:readUint8()
		else
			methodUtype = stream:readUint16()
		end
		
		local methoddata = KBEngine.moduledefs[entity.className].methods[methodUtype]
		local args = {}
		local argsdata = methoddata[4]
		for i=1,#argsdata do
			args[#args+1]=argsdata[i]:createFromStream(stream)
		end

		if entity[methoddata[3]]~=nil then
			entity[methoddata[3]](entity, unpack(args))
		else
			KBEngine.ERROR_MSG("KBEngineApp::Client_onRemoteMethodCall: entity(" .. eid ..") not found method(" ..methoddata[3] .. ")!")
		end

end


function _M:getentityclass(entityType)
		local runclass = KBEngine.app.entityclass[entityType]
		if runclass == nil then
			runclass = KBEngine[entityType]
			if runclass == nil then
				KBEngine.ERROR_MSG("KBEngineApp::getentityclass: entityType(" ..entityType ..") is error!")
				return runclass
			else
				KBEngine.app.entityclass[entityType] = runclass
			end
		end
		return runclass
end


function _M:connect(ip,port)
		if ip then self.ip=ip end
		if port then self.port=port end

		if self.socket==nil then
				local function onStatus(state)
					if state=="SOCKET_TCP_CONNECTED" then
					   KBEngine.Event.fire("onConnectionState", true)
					   if KBEngine.app.socket.onopen then
					   		KBEngine.app.socket.onopen(self)	
					   end	
					end			
						
				end

				local function onMessage(event)					
					if self.socket.onmessage then
					   self.socket.onmessage(self,event.data)	
					end
				end
				
				local socket=KBEngine.Socket.new()
				self.socket=socket
				self.socket.onStatus=onStatus
				self.socket.onMessage=onMessage
		end
		self.socket:connect(self.ip,self.port,false)
end

function _M:disconnect()
		self.socket:disconnect()
end

function _M:send(data)
		self.socket:send(data)
end

function _M:hello()
		local bundle = KBEngine.Bundle.new()
		if KBEngine.app.currserver == "loginapp" then			
			bundle:newMessage(KBEngine.messages.Loginapp_hello)
		else
			bundle:newMessage(KBEngine.messages.Baseapp_hello)
		end
		bundle.save=true
		bundle:writeString(KBEngine.app.clientVersion)
		bundle:writeString(KBEngine.app.clientScriptVersion)
		bundle:writeBlob(KBEngine.app.encryptedKey)
		bundle:send()
end


function _M:onImportClientMessagesCompleted()
		KBEngine.INFO_MSG("KBEngineApp::onImportClientMessagesCompleted: successfully!")
		KBEngine.app.socket.onmessage = KBEngine.app.onmessage 
		KBEngine.app:hello()
		
		if KBEngine.app.currserver == "loginapp" then

			if not KBEngine.app.serverErrorsDescrImported then
				KBEngine.INFO_MSG("KBEngine::onImportClientMessagesCompleted(): send importServerErrorsDescr!")
				KBEngine.app.serverErrorsDescrImported = true
				local bundle = KBEngine.Bundle.new()								
				bundle:newMessage(KBEngine.messages.Loginapp_importServerErrorsDescr)
				bundle:send()
			end
							
			if KBEngine.app.currstate == "login" then
				KBEngine.app.login_loginapp(false)
			elseif KBEngine.app.currstate == "resetpassword" then
				KBEngine.app.resetpassword_loginapp(false)
			else
				KBEngine.app.createAccount_loginapp(false)
			end
			KBEngine.app.loginappMessageImported = true
		
		else
		
			KBEngine.app.baseappMessageImported = true
			
			if not KBEngine.app.entitydefImported then
				KBEngine.INFO_MSG("KBEngineApp::onImportClientMessagesCompleted: start importEntityDef ...")
				local bundle =KBEngine.Bundle.new()
				bundle:newMessage(KBEngine.messages.Baseapp_importClientEntityDef)
				bundle:send(KBEngine.app)
				KBEngine.Event.fire("Baseapp_importClientEntityDef")
			else			
				KBEngine.app:onImportEntityDefCompleted()
			end
		end
end


function _M:onImportEntityDefCompleted()
		KBEngine.INFO_MSG("KBEngineApp::onImportEntityDefCompleted: successfully!")
		KBEngine.app.entitydefImported = true
		KBEngine.app:login_baseapp(false)
end


function _M:onUpdatePropertys_(eid, stream)
		local entity = KBEngine.app.entities[eid]
		
		if entity == nil then
			local entityMessage = KBEngine.bufferedCreateEntityMessage[eid]
			if entityMessage~=nil  then
				KBEngine.ERROR_MSG("KBEngineApp::Client_onUpdatePropertys: entity(" .. eid .. ") not found!")
				return
			end
			
			local stream1 = KBEngine.MemoryStream.new(stream.buffer)
			stream1.wpos = stream.wpos
			stream1.rpos = stream.rpos - 4
			KBEngine.bufferedCreateEntityMessage[eid] = stream1
			return
		end
		
		local currModule = KBEngine.moduledefs[entity.className]
		
		local pdatas = currModule.propertys
		while stream:length()>0 do
			local utype = 0
			if currModule.usePropertyDescrAlias then
				utype = stream:readUint8()
			else
				utype = stream:readUint16()
			end
			local propertydata = pdatas[utype]
			if propertydata==nil then return end
			local setmethod = propertydata[6]
			local flags = propertydata[7]
			local val = propertydata[5]:createFromStream(stream)
			local oldval = entity[propertydata[3]]
			KBEngine.INFO_MSG("KBEngineApp::Client_onUpdatePropertys: " .. entity.className .. "(id=" .. eid  .. " " .. propertydata[3] .. ", val=" .. KBEngine.toString(val) .. ")!")
			
			entity[propertydata[3]] = val
			if setmethod ~= nil and setmethod~="null" then			
				--base类属性或者进入世界后cell类属性会触发set_*方法
				if flags == 0x00000020 and flags == 0x00000040 then				
					if entity.inited then
						setmethod(entity,oldval)						
					end				
				else				
					if entity.inWorld then
						setmethod(entity,oldval)
					end
				end
			end

		end

end

function _M:onOpenBaseapp()

		KBEngine.INFO_MSG("KBEngineApp::onOpenBaseapp: successfully!")
		KBEngine.app.currserver = "baseapp"
		if not KBEngine.app.baseappMessageImported then
			local bundle = KBEngine.Bundle.new()
			bundle:newMessage(KBEngine.messages.Baseapp_importClientMessages)
			bundle:send(KBEngine.app)
			KBEngine.app.socket.onmessage = KBEngine.app.Client_onImportClientMessages  
			KBEngine.Event.fire("Baseapp_importClientMessages")
		else
			KBEngine.app:onImportClientMessagesCompleted()
		end
end

function _M:login_baseapp(noconnect)
		if noconnect then
			KBEngine.Event.fire("onLoginBaseapp")
			KBEngine.INFO_MSG("KBEngineApp::login_baseapp: start connect to "..KBEngine.app.baseappIp..":"..KBEngine.app.baseappPort.."!")
			KBEngine.app:connect(KBEngine.app.baseappIp,KBEngine.app.baseappPort)
			if KBEngine.app.socket then
				KBEngine.app.socket.onopen = KBEngine.app.onOpenBaseapp
			end
		else
			local bundle = KBEngine.Bundle.new()
			bundle:newMessage(KBEngine.messages.Baseapp_loginBaseapp)
			bundle:writeString(KBEngine.app.username)
			bundle:writeString(KBEngine.app.password)
			bundle:send()
		end
end

function _M:installEvents()
	KBEngine.Event.register("createAccount", self, "createAccount")
	KBEngine.Event.register("login", self, "login")
	KBEngine.Event.register("reLoginBaseapp", self, "reLoginBaseapp")
	KBEngine.Event.register("bindAccountEmail", self, "bindAccountEmail")
	KBEngine.Event.register("newPassword", self, "newPassword")
end

function _M:uninstallEvents()
	KBEngine.Event.deregister("reLoginBaseapp", self)
	KBEngine.Event.deregister("login", self)
	KBEngine.Event.deregister("createAccount", self)
end

function _M:login(username, password, datas)
	KBEngine.app:reset()
	KBEngine.app.username = username
	KBEngine.app.password = password
	KBEngine.app.clientdatas = datas
	KBEngine.app:login_loginapp(true)
end

function _M:login_loginapp(noconnect)
		if noconnect then
			KBEngine.INFO_MSG("KBEngineApp::login_loginapp: start connect to "..KBEngine.app.ip .. ":" ..KBEngine.app.port.. "!")
			KBEngine.app:connect(KBEngine.app.ip,KBEngine.app.port)			
			KBEngine.app.socket.onopen = KBEngine.app.onOpenLoginapp_login 		
		else
			
			local bundle = KBEngine.Bundle.new()
			bundle:newMessage(KBEngine.messages.Loginapp_login)
			bundle:writeInt8(KBEngine.app.args.clientType)
			bundle:writeBlob(KBEngine.app.clientdatas)
			bundle:writeString(KBEngine.app.username)
			bundle:writeString(KBEngine.app.password)
			bundle:send()
		end
end

		
function _M:onOpenLoginapp_login() 
		KBEngine.INFO_MSG("KBEngineApp::onOpenLoginapp_login: successfully!")
		KBEngine.Event.fire("onConnectionState", true)
		KBEngine.app.currserver = "loginapp"
		KBEngine.app.currstate = "login"
		if not KBEngine.app.loginappMessageImported then		
			local bundle = KBEngine.Bundle.new()			
			bundle:newMessage(KBEngine.messages.Loginapp_importClientMessages)
			bundle:send()
			KBEngine.app.socket.onmessage = KBEngine.app.Client_onImportClientMessages
			KBEngine.INFO_MSG("KBEngineApp::onOpenLoginapp_login: start importClientMessages ...")
			KBEngine.Event.fire("Loginapp_importClientMessages")
			
		else
			KBEngine.app:onImportClientMessagesCompleted()
		end
end


function _M:createAccount(username, password, datas) 
		KBEngine.app.username = username
		KBEngine.app.password = password
		KBEngine.app.clientdatas = datas
		KBEngine.app:createAccount_loginapp(true)
end
	
function _M:createAccount_loginapp(noconnect)
		if noconnect then
			KBEngine.INFO_MSG("KBEngineApp::createAccount_loginapp: start connect to ws://" .. KBEngine.app.ip .. ":" .. KBEngine.app.port .. "!")
			KBEngine.app:connect(KBEngine.app.ip,KBEngine.app.port)
			KBEngine.app.socket.onopen = KBEngine.app.onOpenLoginapp_createAccount
			
		else
			local bundle = KBEngine.Bundle.new()
			bundle:newMessage(KBEngine.messages.Loginapp_reqCreateAccount)
			bundle:writeString(KBEngine.app.username)
			bundle:writeString(KBEngine.app.password)
			bundle:writeBlob(KBEngine.app.clientdatas)
			bundle:send(KBEngine.app)
		end
end

function _M:update()
	if KBEngine.app.socket == nil then return end
	local dateObject = os.time()		
    if((dateObject - KBEngine.app.lastTickTime) / 1000 > 15) then
    	--如果心跳回调接收时间小于心跳发送时间，说明没有收到回调
		-- 此时应该通知客户端掉线了
    	if KBEngine.app.lastTickCBTime < KBEngine.app.lastTickTime then
				KBEngine.ERROR_MSG("sendTick: Receive appTick timeout!")
				KBEngine.app.socket.close()  
		end

		if KBEngine.app.currserver == "loginapp" then
			if KBEngine.messages.Loginapp_onClientActiveTick~=nil then			
					local bundle = KBEngine.Bundle.new()
					bundle:newMessage(KBEngine.messages.Loginapp_onClientActiveTick)
					bundle:send(KBEngine.app)
			end
		else
			if KBEngine.messages.Baseapp_onClientActiveTick~=nil then
					local bundle = KBEngine.Bundle.new()
					bundle:newMessage(KBEngine.messages.Baseapp_onClientActiveTick)
					bundle:send()
			end
					
		end
		KBEngine.app.lastTickTime = os.time()

    end
    KBEngine.app:updatePlayerToServer()

end

function _M:onOpenLoginapp_createAccount()

		KBEngine.Event.fire("onConnectionState", true)
		KBEngine.INFO_MSG("KBEngineApp::onOpenLoginapp_createAccount: successfully!")
		KBEngine.app.currserver = "loginapp"
		KBEngine.app.currstate = "createAccount"
		
		if not KBEngine.app.loginappMessageImported then
			local bundle = KBEngine.Bundle.new()
			bundle:newMessage(KBEngine.messages.Loginapp_importClientMessages)
			bundle:send(KBEngine.app)
			KBEngine.app.socket.onmessage = KBEngine.app.Client_onImportClientMessages  
			KBEngine.INFO_MSG("KBEngineApp::onOpenLoginapp_createAccount: start importClientMessages ...")
			KBEngine.Event.fire("Loginapp_importClientMessages")
			
		else
			KBEngine.app:onImportClientMessagesCompleted()
		end
end

function _M:getAoiEntityIDFromStream(stream)
		local id = 0
		if #KBEngine.app.entityIDAliasIDList > 255 then
			id = stream:readInt32()
		else
			local aliasID = stream:readUint8()
			-- 如果为0且客户端上一步是重登陆或者重连操作并且服务端entity在断线期间一直处于在线状态
			-- 则可以忽略这个错误, 因为cellapp可能一直在向baseapp发送同步消息， 当客户端重连上时未等
			-- 服务端初始化步骤开始则收到同步信息, 此时这里就会出错。
			if #KBEngine.app.entityIDAliasIDList <= aliasID then
				return 0
			end
		
			id = KBEngine.app.entityIDAliasIDList[aliasID+1]
		end
		
		return id
end


function _M:_updateVolatileData(entityID, x, y, z, yaw, pitch, roll, isOnGround)
		local entity = KBEngine.app.entities[entityID]
		if entity == nil then
			-- 如果为0且客户端上一步是重登陆或者重连操作并且服务端entity在断线期间一直处于在线状态
			-- 则可以忽略这个错误, 因为cellapp可能一直在向baseapp发送同步消息， 当客户端重连上时未等
			-- 服务端初始化步骤开始则收到同步信息, 此时这里就会出错。			
			KBEngine.ERROR_MSG("KBEngineApp::_updateVolatileData: entity(" .. entityID .. ") not found!")
			return
		end
		
		-- 小于0不设置
		if isOnGround >= 0 then
			entity.isOnGround = (isOnGround > 0)
		end
		
		local changeDirection = false
		
		if roll ~= KBEngine.KBE_FLT_MAX then
			changeDirection = true
			entity.direction.x = KBEngine.int82angle(roll, false)
		end

		if pitch ~= KBEngine.KBE_FLT_MAX then
			changeDirection = true
			entity.direction.y = KBEngine.int82angle(pitch, false)
		end

		if yaw ~= KBEngine.KBE_FLT_MAX then
		
			changeDirection = true
			entity.direction.z = KBEngine.int82angle(yaw, false)
		end

		local done = false
		if changeDirection ==true then
			KBEngine.Event.fire("set_direction", entity)		
			done = true
		end

		local positionChanged = false
		if(x ~= KBEngine.KBE_FLT_MAX and y ~= KBEngine.KBE_FLT_MAX or z ~= KBEngine.KBE_FLT_MAX) then
			positionChanged = true
		end
		if x==KBEngine.KBE_FLT_MAX then x = 0.0 end
		if y==KBEngine.KBE_FLT_MAX then y = 0.0 end
		if z==KBEngine.KBE_FLT_MAX then z = 0.0 end

		if positionChanged then
			entity.position.x = x + KBEngine.app.entityServerPos.x
			entity.position.y = y + KBEngine.app.entityServerPos.y
			entity.position.z = z + KBEngine.app.entityServerPos.z
			
			done = true
			KBEngine.Event.fire("updatePosition", entity)
		end

		if done then
			entity:onUpdateVolatileData()
		end

end

function _M.INFO_MSG(...)
	--print("INFO_MSG:",...)
end

function _M.DEBUG_MSG(...)
	--print("DEBUG_MSG:",...)
end	

function _M.ERROR_MSG(...)
	print("ERROR_MSG:",...)
end

function _M.WARNING_MSG(...)
	print("WARNING_MSG:",...)
end

return _M
