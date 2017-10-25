local _M=KBEngine or {}
function _M:Client_onReloginBaseappFailed(stream)
		KBEngine.ERROR_MSG("KBEngineApp::Client_onReloginBaseappFailed: failedcode(" .. KBEngine.app.serverErrs[failedcode].name .. ")!")
		KBEngine.Event.fire("onReloginBaseappFailed", failedcode)
end

function _M:Client_onEntityLeaveWorldOptimized(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream);
		KBEngine.app:Client_onEntityLeaveWorld(eid);
end

function _M:Client_onRemoteMethodCallOptimized(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream);
		KBEngine.app:onRemoteMethodCall_(eid, stream);
end

function _M:Client_onUpdatePropertysOptimized(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		KBEngine.app:onUpdatePropertys_(eid, stream)
end

function _M:Client_onSetEntityPosAndDir(stream)
		local eid = stream:readInt32()
		local entity = KBEngine.app.entities[eid]
		if entity == nil then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onSetEntityPosAndDir: entity(" .. eid .. ") not found!")
			return
		end
		
		entity.position.x = stream:readFloat()
		entity.position.y = stream:readFloat()
		entity.position.z = stream:readFloat()
		entity.direction.x = stream:readFloat()
		entity.direction.y = stream:readFloat()
		entity.direction.z = stream:readFloat()
		
		--记录玩家最后一次上报位置时自身当前的位置
		entity.entityLastLocalPos.x = entity.position.x
		entity.entityLastLocalPos.y = entity.position.y
		entity.entityLastLocalPos.z = entity.position.z
		entity.entityLastLocalDir.x = entity.direction.x
		entity.entityLastLocalDir.y = entity.direction.y
		entity.entityLastLocalDir.z = entity.direction.z	
				
		entity:set_direction(entity.direction)
		entity:set_position(entity.position)
end

function _M:Client_onUpdateBasePos(x, y, z)
		KBEngine.app.entityServerPos.x = x
		KBEngine.app.entityServerPos.y = y
		KBEngine.app.entityServerPos.z = z
end

function _M:Client_onUpdateBaseDir(stream)

end

function _M:Client_onUpdateBasePosXZ(x, z)
		KBEngine.app.entityServerPos.x = x
		KBEngine.app.entityServerPos.z = z
end

function _M:Client_onUpdateData(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		local entity = KBEngine.app.entities[eid]
		if entity == nil then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onUpdateData: entity(" .. eid .. ") not found!")
			return
		end
end

function _M:Client_onUpdateData_ypr(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local y = stream:readInt8()
		local p = stream:readInt8()
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, y, p, r, -1)
end

function _M:Client_onUpdateData_yp(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local y = stream:readInt8()
		local p = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, y, p, KBEngine.KBE_FLT_MAX, -1)
end

function _M:Client_onUpdateData_yr(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local y = stream:readInt8()
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, y, KBEngine.KBE_FLT_MAX, r, -1)
end

function _M:Client_onUpdateData_pr(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local p = stream:readInt8()
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, p, r, -1)
end

function _M:Client_onUpdateData_y(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local y = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, y, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, -1)
end

function _M:Client_onUpdateData_p(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local p = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, p, KBEngine.KBE_FLT_MAX, -1)
end


function _M:Client_onUpdateData_r(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, r, -1)
end

function _M:Client_onUpdateData_xz(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], KBEngine.KBE_FLT_MAX, xz[2], KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, 1)
end

function _M:Client_onUpdateData_xz_ypr(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()

		local y = stream:readInt8()
		local p = stream:readInt8()
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], KBEngine.KBE_FLT_MAX, xz[2], y, p, r, 1)
end

function _M:Client_onUpdateData_xz_yp(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()

		local y = stream:readInt8()
		local p = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], KBEngine.KBE_FLT_MAX, xz[2], y, p, KBEngine.KBE_FLT_MAX, 1)
end

function _M:Client_onUpdateData_xz_yr(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()

		local y = stream:readInt8()
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], KBEngine.KBE_FLT_MAX, xz[2], y, KBEngine.KBE_FLT_MAX, r, 1)
end

function _M:Client_onUpdateData_xz_pr(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()

		local p = stream:readInt8()
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], KBEngine.KBE_FLT_MAX, xz[2], KBEngine.KBE_FLT_MAX, p, r, 1)
end

function _M:Client_onUpdateData_xz_y(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()

		local y = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], KBEngine.KBE_FLT_MAX, xz[2], y, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, 1)
end

function _M:Client_onUpdateData_xz_p(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()

		local p = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], KBEngine.KBE_FLT_MAX, xz[2], KBEngine.KBE_FLT_MAX, p, KBEngine.KBE_FLT_MAX, 1)
end

function _M:Client_onUpdateData_xz_r(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()

		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], KBEngine.KBE_FLT_MAX, xz[2], KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, r, 1)
end

function _M:Client_onUpdateData_xyz(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()
		local y = stream:readPackY()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], y, xz[2], KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, 0)
end

function _M:Client_onUpdateData_xyz_ypr(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()
		local y = stream:readPackY()
		
		local yaw = stream:readInt8()
		local p = stream:readInt8()
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], y, xz[2], yaw, p, r, 0)
end

function _M:Client_onUpdateData_xyz_yp(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()
		local y = stream:readPackY()
		
		local yaw = stream:readInt8()
		local p = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], y, xz[2], yaw, p, KBEngine.KBE_FLT_MAX, 0)
end

function _M:Client_onUpdateData_xyz_yr(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()
		local y = stream:readPackY()
		
		local yaw = stream:readInt8()
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], y, xz[2], yaw, KBEngine.KBE_FLT_MAX, r, 0)
end

function _M:Client_onUpdateData_xyz_pr(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()
		local y = stream:readPackY()
		
		local p = stream:readInt8()
		local r = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, x, y, z, KBEngine.KBE_FLT_MAX, p, r, 0)

end
function _M:Client_onUpdateData_xyz_y(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()
		local y = stream:readPackY()
		
		local yaw = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], y, xz[2], yaw, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, 0)
end

function _M:Client_onUpdateData_xyz_p(stream)
		local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		
		local xz = stream:readPackXZ()
		local y = stream:readPackY()
		
		local p = stream:readInt8()
		
		KBEngine.app:_updateVolatileData(eid, xz[1], y, xz[2], KBEngine.KBE_FLT_MAX, p, KBEngine.KBE_FLT_MAX, 0)
end

function _M:Client_onUpdateData_xyz_r(stream)
	    local eid = KBEngine.app:getAoiEntityIDFromStream(stream)
		local xz = stream:readPackXZ()
		local y = stream:readPackY()
		local p = stream:readInt8()
		KBEngine.app:_updateVolatileData(eid, xz[2], y, xz[2], r, KBEngine.KBE_FLT_MAX, KBEngine.KBE_FLT_MAX, 0)
end

function _M:Client_initSpaceData(stream)
			
		KBEngine.app:clearSpace(false)
		KBEngine.app.spaceID = stream:readInt32()
		while stream:length() > 0 do
			local key = stream:readString()
			local value = stream:readString()
			KBEngine.app:Client_setSpaceData(KBEngine.app.spaceID, key, value)
		end
		
		 -- KBEngine.INFO_MSG("KBEngineApp::Client_initSpaceData: spaceID(".. KBEngine.app.spaceID .. "), datas(" .. KBEngine.app.spacedata:toString() .. ")!")
end

function _M:Client_setSpaceData(spaceID, key, value)
		KBEngine.INFO_MSG("KBEngineApp::Client_setSpaceData: spaceID(" .. spaceID.. "), key(" .. key .. "), value(" .. value .. ")!")
		KBEngine.app.spacedata[key] = value
		if key == "_mapping" then
			KBEngine.app:addSpaceGeometryMapping(spaceID, value)
		end
		
		KBEngine.Event.fire("onSetSpaceData", spaceID, key, value)
end
function _M:Client_delSpaceData(spaceID, key)
		KBEngine.INFO_MSG("KBEngineApp::Client_delSpaceData: spaceID(" .. spaceID .. "), key(" .. key .. ")!")
		KBEngine.app.spacedata[key]=nil
		KBEngine.Event.fire("onDelSpaceData", spaceID, key)
end

function _M:Client_onReqAccountResetPasswordCB(failedcode)
		if failedcode ~=0 then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onReqAccountResetPasswordCB: " .. KBEngine.app.username .. " is failed! code=" .. KBEngine.app.serverErrs[failedcode].name .. "!");
			return;
		end

		KBEngine.INFO_MSG("KBEngineApp::Client_onReqAccountResetPasswordCB: " .. KBEngine.app.username .. " is successfully!");
end

function _M:Client_getSpaceData(spaceID, key)
		return KBEngine.app.spacedata[key]
end

function _M:Client_onReqAccountBindEmailCB(failedcode)
	if failedcode ~= 0 then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onReqAccountBindEmailCB: " .. KBEngine.app.username .. " is failed! code=" .. KBEngine.app.serverErrs[failedcode].name .. "!");
			return;
	end

	KBEngine.INFO_MSG("KBEngineApp::Client_onReqAccountBindEmailCB: " .. KBEngine.app.username .. " is successfully!");
end

function _M:Client_onReqAccountNewPasswordCB(failedcode)
		if failedcode ~= 0 then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onReqAccountNewPasswordCB: " .. KBEngine.app.username .. " is failed! code=" .. KBEngine.app.serverErrs[failedcode].name .. "!");
			return;
		end

		KBEngine.INFO_MSG("KBEngineApp::Client_onReqAccountNewPasswordCB: " .. KBEngine.app.username .. " is successfully!");
end

function _M:Client_onReloginBaseappSuccessfully(stream)
		KBEngine.app.entity_uuid = stream:readUint64()
		KBEngine.DEBUG_MSG("KBEngineApp::Client_onReloginBaseappSuccessfully: " .. KBEngine.app.username)
		KBEngine.Event.fire("onReloginBaseappSuccessfully")
end

function _M:Client_onAppActiveTickCB(stream)
		KBEngine.app.lastTickCBTime = os.time()
end

function _M:Client_onCreateAccountResult(stream)
		local retcode = stream:readUint16()
		local datas = stream:readBlob()
		
		if retcode ~= 0 then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onCreateAccountResult: " .. KBEngine.app.username .. " create is failed! code=" .. KBEngine.app.serverErrs[retcode].name .. "!")
			return
		end

		KBEngine.Event.fire("onCreateAccountResult", retcode, datas)
		KBEngine.INFO_MSG("KBEngineApp::Client_onCreateAccountResult: " .. KBEngine.app.username .. " create is successfully!")
end

function _M:Client_onLoginSuccessfully(stream)
		local accountName = stream:readString()
		KBEngine.app.username = accountName
		KBEngine.app.baseappIp = stream:readString()
		KBEngine.app.baseappPort = stream:readUint16()
		KBEngine.app.serverdatas = stream:readBlob()
		
		KBEngine.INFO_MSG("KBEngineApp::Client_onLoginSuccessfully: accountName("..accountName.. "), addr(".. 
				KBEngine.app.baseappIp .. ":"..KBEngine.app.baseappPort .."), datas("..#KBEngine.app.serverdatas .. ")!")		
		KBEngine.app:disconnect()
		KBEngine.app:login_baseapp(true)
end

function _M:Client_onLoginFailed(args)
		local failedcode = args:readUint16()
		KBEngine.app.serverdatas = args:readBlob()
		KBEngine.ERROR_MSG("KBEngineApp::Client_onLoginFailed: failedcode(" .. KBEngine.app.serverErrs[failedcode].name .. "), datas(" .. KBEngine.app.serverdatas .. ")!")
		KBEngine.Event.fire("onLoginFailed", failedcode)
end

function _M:Client_onCreatedProxies(rndUUID, eid, entityType)
		KBEngine.INFO_MSG("Client_onCreatedProxies",rndUUID, eid, entityType)
		local entity = KBEngine.app.entities[eid]
		KBEngine.app.entity_uuid = rndUUID
		KBEngine.app.entity_id = eid
		
		if entity == nil then
			local runclass = KBEngine.app:getentityclass(entityType)
			if(runclass == nil) then
				return
			end

			local entity = runclass.new()
			entity.id = eid
			entity.className = entityType
			entity.base = KBEngine.Mailbox.new()
			entity.base.id = eid
			entity.base.className = entityType
			entity.base.type = KBEngine.MAILBOX_TYPE_BASE
			
			KBEngine.app.entities[eid] = entity
			
			local entityMessage = KBEngine.bufferedCreateEntityMessage[eid]
			if entityMessage ~=nil then
				KBEngine.app:Client_onUpdatePropertys(entityMessage)
				KBEngine.bufferedCreateEntityMessage[eid]=nil
			end
				
			entity:__init__()
			entity.inited = true
			
			if KBEngine.app.args.isOnInitCallPropertysSetMethods then
				entity:callPropertysSetMethods()
			end
		
		else
		
			local entityMessage = KBEngine.bufferedCreateEntityMessage[eid]
			if entityMessage ~= nil then
				KBEngine.app:Client_onUpdatePropertys(entityMessage)
				KBEngine.bufferedCreateEntityMessage[eid]=nil
			end
		end
end

function _M:Client_onLoginBaseappFailed(failedcode)
		 local infoObject=KBEngine.app.serverErrs[failedcode] or {}
		 local infoName=infoObject.name or ""
		 KBEngine.ERROR_MSG("KBEngineApp::Client_onLoginBaseappFailed: failedcode(" ..failedcode..infoName .. ")!")
		 KBEngine.Event.fire("onLoginBaseappFailed", failedcode)
end

function _M:Client_onRemoteMethodCall(stream)
		local eid = stream:readInt32()
		KBEngine.app:onRemoteMethodCall_(eid, stream)
end

function _M:Client_onEntityEnterWorld(stream)
		local eid = stream:readInt32()
		if KBEngine.app.entity_id > 0 and eid ~= KBEngine.app.entity_id then
			table.insert(KBEngine.app.entityIDAliasIDList,eid)
		end
		
		local entityType
		if #KBEngine.moduledefs > 255 then
			entityType = stream:readUint16()
		else
			entityType = stream:readUint8()
		end
		
		local isOnGround=0
		if stream:length() > 0 then
			isOnGround = stream:readInt8()
		end
		--dump(KBEngine.moduledefs)
		print("entityTypeentityTypeentityType:",entityType)
		entityType = KBEngine.moduledefs[entityType].name
		KBEngine.INFO_MSG("KBEngineApp::Client_onEntityEnterWorld: " ..entityType .. "(" .. eid .. "), spaceID(" .. KBEngine.app.spaceID .. "), isOnGround(" .. KBEngine.toString(isOnGround) .. ")!")
		local entity = KBEngine.app.entities[eid]
		if entity==nil then
			local entityMessage = KBEngine.bufferedCreateEntityMessage[eid]
			if entityMessage == nil then
				KBEngine.ERROR_MSG("KBEngineApp::Client_onEntityEnterWorld: entity(" .. eid .. ") not found!")
				return
			end

			local runclass = KBEngine.app:getentityclass(entityType)
			if runclass == nil then
				return
			end

			local entity = runclass.new()
			entity.id = eid
			entity.className = entityType
			
			entity.cell = KBEngine.Mailbox.new()
			entity.cell.id = eid
			entity.cell.className = entityType
			entity.cell.type = KBEngine.MAILBOX_TYPE_CELL
			KBEngine.app.entities[eid] = entity

			KBEngine.app:Client_onUpdatePropertys(entityMessage)			
			KBEngine.bufferedCreateEntityMessage[eid]=nil

			entity.isOnGround = isOnGround > 0
			entity:__init__()
			entity.inited = true
			entity.inWorld = true
			entity:enterWorld()

			if KBEngine.app.args.isOnInitCallPropertysSetMethods then
				entity:callPropertysSetMethods()
			end

			entity:set_direction(entity.direction)
			entity:set_position(entity.position)

		else
			if not entity.inWorld then
				entity.cell = KBEngine.Mailbox.new()
				entity.cell.id = eid
				entity.cell.className = entityType
				entity.cell.type = KBEngine.MAILBOX_TYPE_CELL
				--[[
				安全起见， 这里清空一下
				如果服务端上使用giveClientTo切换控制权
				之前的实体已经进入世界， 切换后的实体也进入世界， 这里可能会残留之前那个实体进入世界的信息
				]]
				KBEngine.app.entityIDAliasIDList = {}
				KBEngine.app.entities = {}
				KBEngine.app.entities[entity.id] = entity
				entity:set_direction(entity.direction)
				entity:set_position(entity.position)

				KBEngine.app.entityServerPos.x = entity.position.x
				KBEngine.app.entityServerPos.y = entity.position.y
				KBEngine.app.entityServerPos.z = entity.position.z
				
				entity.isOnGround = isOnGround > 0
				entity.inWorld = true
				entity:enterWorld()
				
				if KBEngine.app.args.isOnInitCallPropertysSetMethods then
					entity:callPropertysSetMethods()
				end
			end

		end
end

function _M:Client_onEntityLeaveWorld(eid)
	local entity = KBEngine.app.entities[eid]
	if entity == nil then
		KBEngine.ERROR_MSG("KBEngineApp::Client_onEntityLeaveWorld: entity("..eid..") not found!")
		return
	end
	if entity.inWorld then
			entity:leaveWorld()
	end

	if KBEngine.app.entity_id > 0 and eid ~= KBEngine.app.entity_id then
		local newArray0 = {}
		for i=1,#KBEngine.app.controlledEntities do
			if KBEngine.app.controlledEntities[i] ~= eid then
				table.insert(newArray0,KBEngine.app.controlledEntities[i])
			else
				KBEngine.Event.fire("onLoseControlledEntity")				
			end
		end
		KBEngine.app.controlledEntities = newArray0
		KBEngine.app.entities[eid]=nil

		local newArray = {}
		for i=1,#KBEngine.app.entityIDAliasIDList do
			if KBEngine.app.entityIDAliasIDList[i] ~= eid then
					table.insert(newArray,KBEngine.app.entityIDAliasIDList[i])					
			end
		end
		KBEngine.app.entityIDAliasIDList = newArray
	else
		KBEngine.app:clearSpace(false)
		entity.cell = nil	

	end

end

function _M:Client_onEntityEnterSpace(stream)
		local eid = stream:readInt32()
		KBEngine.app.spaceID = stream:readUint32()
		local isOnGround = true
		
		if stream:length() > 0 then
			isOnGround = stream:readInt8()
		end

		local entity = KBEngine.app.entities[eid]
		if entity == nil then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onEntityEnterSpace: entity(" .. eid .. ") not found!")
			return
		end
		
		entity.isOnGround = isOnGround
		KBEngine.app.entityServerPos.x = entity.position.x
		KBEngine.app.entityServerPos.y = entity.position.y
		KBEngine.app.entityServerPos.z = entity.position.z
		entity:enterSpace()

end
function _M:Client_onEntityLeaveSpace(eid)
		local entity = KBEngine.app.entities[eid]
		if entity == nil then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onEntityLeaveSpace: entity(" .. eid .. ") not found!")
			return
		end
		
		KBEngine.app:clearSpace(false)
		entity:leaveSpace()
end

function _M:Client_onUpdatePropertys(stream)
		local eid = stream:readInt32()
		KBEngine.app:onUpdatePropertys_(eid,stream)
end

function _M:Client_onEntityDestroyed(eid)
		KBEngine.INFO_MSG("KBEngineApp::Client_onEntityDestroyed: entity(" .. eid .. ")!")
		
		local entity = KBEngine.app.entities[eid]
		if entity == nil then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onEntityDestroyed: entity(" .. eid .. ") not found!")
			return
		end

		if entity.inWorld then
			if KBEngine.app.entity_id == eid then
				KBEngine.app:clearSpace(false)
			end
			entity:leaveWorld()
		end
			
		KBEngine.app.entities[eid]=nil
end

function _M:Client_onStreamDataStarted(stream)

end
function _M:Client_onStreamDataRecv(stream)

end

function _M:Client_onStreamDataCompleted(stream)

end

function _M:Client_onKicked(stream)
	KBEngine.ERROR_MSG("KBEngineApp::Client_onKicked: failedcode(" .. KBEngine.app.serverErrs[failedcode].name .. ")!")
		KBEngine.Event.fire("onKicked", failedcode)
end

function _M:Client_onImportClientMessages(data)
		local stream=KBEngine.MemoryStream.new(data)
		local msgid = stream:readUint16()
		if msgid~=KBEngine.messages.onImportClientMessages.id then return end
		local msglen = stream:readUint16()
		local msgcount = stream:readUint16()
		KBEngine.INFO_MSG("KBEngineApp::onImportClientMessages: start("..msgcount .. ") ...!")
		while msgcount > 0 do
				local msgid = stream:readUint16()
				local msglen = stream:readInt16()
				local msgname = stream:readString()
				local argtype = stream:readInt8()
				local argsize = stream:readUint8()
				KBEngine.INFO_MSG("msgid:"..msgid.." msglen:"..msglen.." argtype:"..argtype.." msgname:"..msgname.." argsize:"..argsize)

				local argstypes={}
				for i=1,argsize do
					argstypes[i] = stream:readUint8()
				end
				local handler=nil
				local isClientMethod = string.find(msgname,"Client_",1,true)==1
				if isClientMethod then
					handler = KBEngine.app[msgname]
					if handler == nil then
						KBEngine.WARNING_MSG("KBEngineApp::onImportClientMessages["..KBEngine.app.currserver .. "]: interface(" .. msgname .. "/" .. msgid .. ") no implement!")
						handler = nil
					else
						KBEngine.INFO_MSG("KBEngineApp::onImportClientMessages: import(" .. msgname .. ") successfully!")
					end
				end

				if #msgname > 0 then					
					KBEngine.messages[msgname] =KBEngine.Message.new(msgid, msgname, msglen, argtype, argstypes, handler)
					if isClientMethod then
						KBEngine.clientmessages[msgid] = KBEngine.messages[msgname]
					else
						KBEngine.messages[KBEngine.app.currserver][msgid] = KBEngine.messages[msgname]
					end
				else
					KBEngine.messages[KBEngine.app.currserver][msgid] = KBEngine.Message.new(msgid, msgname, msglen, argtype, argstypes, handler)
				
				end

				msgcount=msgcount-1
		end
		KBEngine.app:onImportClientMessagesCompleted()

end

function _M:Client_onImportClientEntityDef(stream)
		KBEngine.createDataTypeFromStreams(stream)
		local defmethod=nil
		while not stream:readEOF() do
			local scriptmodule_name = stream:readString()
			local scriptUtype = stream:readUint16()
			local propertysize = stream:readUint16()
			local methodsize = stream:readUint16()
			local base_methodsize = stream:readUint16()
			local cell_methodsize = stream:readUint16()
			
			KBEngine.INFO_MSG("KBEngineApp::Client_onImportClientEntityDef: import(" .. scriptmodule_name .. "), propertys(" .. propertysize .. "), " ..
					"clientMethods(" .. methodsize .. "), baseMethods(" .. base_methodsize .. "), cellMethods(" ..cell_methodsize .. ")!")

			KBEngine.moduledefs[scriptmodule_name] = {}
			local currModuleDefs = KBEngine.moduledefs[scriptmodule_name]
			currModuleDefs["name"] = scriptmodule_name
			currModuleDefs["propertys"] = {}
			currModuleDefs["methods"] = {}
			currModuleDefs["base_methods"] = {}
			currModuleDefs["cell_methods"] = {}
			KBEngine.moduledefs[scriptUtype] = currModuleDefs
			local self_propertys = currModuleDefs["propertys"]
			local self_methods = currModuleDefs["methods"]
			local self_base_methods = currModuleDefs["base_methods"]
			local self_cell_methods= currModuleDefs["cell_methods"]
			local Class = KBEngine[scriptmodule_name]
			while propertysize > 0 do
				local properUtype = stream:readUint16()
				local properFlags = stream:readUint32()
				local aliasID = stream:readInt16()
				local name = stream:readString()
				local defaultValStr = stream:readString()
				local utype = KBEngine.datatypes[stream:readUint16()]
				local setmethod = "null"
				if Class ~=nil then
					setmethod = Class["set_" .. name] or "null"
					if setmethod=="null" then
						KBEngine.ERROR_MSG("========not method============".."set_" .. name)						
					end
				end
				
				local savedata = {properUtype, aliasID, name, defaultValStr, utype, setmethod, properFlags}
				
				self_propertys[name] = savedata
				
				if aliasID >= 0 then					
					self_propertys[aliasID] = savedata
					currModuleDefs["usePropertyDescrAlias"] = true
					
				else
				 	self_propertys[properUtype] = savedata
				 	currModuleDefs["usePropertyDescrAlias"] = false
				end
				
				KBEngine.INFO_MSG("KBEngineApp::Client_onImportClientEntityDef: add(" ..scriptmodule_name .. "), property(" .. name .. "/" .. properUtype .. ").")

				propertysize=propertysize-1
			end
			
			while methodsize > 0 do
				local methodUtype = stream:readUint16()
				local aliasID = stream:readInt16()
				local name = stream:readString()
				local argssize = stream:readUint8()
				local args = {}
				
				while argssize > 0 do
					args[#args+1]=KBEngine.datatypes[stream:readUint16()]					
					argssize=argssize-1
				end
				
				local savedata = {methodUtype, aliasID, name, args}
				self_methods[name] = savedata
				
				if aliasID >= 0 then				
					self_methods[aliasID] = savedata
					currModuleDefs["useMethodDescrAlias"] = true				
				else				
					self_methods[methodUtype] = savedata
					currModuleDefs["useMethodDescrAlias"] = false
				end
				
				KBEngine.INFO_MSG("KBEngineApp::Client_onImportClientEntityDef: add(" .. scriptmodule_name .. "), method(" .. name .. ").")
				methodsize=methodsize-1
			end

			while base_methodsize > 0 do
				
				local methodUtype = stream:readUint16()
				local aliasID = stream:readInt16()
				local name = stream:readString()
				local argssize = stream:readUint8()
				local args = {}
				
				while argssize > 0 do
					args[#args+1]=KBEngine.datatypes[stream:readUint16()]					
					argssize=argssize-1
				end
				
				self_base_methods[name] = {methodUtype, aliasID, name, args}
				KBEngine.INFO_MSG("KBEngineApp::Client_onImportClientEntityDef: add(" .. scriptmodule_name .. "), base_method(" .. name .. ").")
				base_methodsize=base_methodsize-1
			end
			
			while cell_methodsize > 0 do
				local methodUtype = stream:readUint16()
				local aliasID = stream:readInt16()
				local name = stream:readString()
				local argssize = stream:readUint8()
				local args = {}
				while argssize > 0 do
					args[#args+1]=KBEngine.datatypes[stream:readUint16()]
					argssize=argssize-1
				end
				
				self_cell_methods[name] = {methodUtype, aliasID, name, args}
				KBEngine.INFO_MSG("KBEngineApp::Client_onImportClientEntityDef: add(" .. scriptmodule_name .. "), cell_method(" .. name .. ").")
				cell_methodsize=cell_methodsize-1
			end
			defmethod = KBEngine[scriptmodule_name]
			if defmethod == nil then
				KBEngine.INFO_MSG("KBEngineApp::Client_onImportClientEntityDef: module(" .. scriptmodule_name .. ") not found~");
			end

			for name,v in pairs(currModuleDefs.propertys) do
				local infos = currModuleDefs.propertys[name]
				local properUtype = infos[1]
				local aliasID = infos[2]
				local name = infos[3]
				local defaultValStr = infos[4]
				local utype = infos[5]

				if defmethod~=nil then
					defmethod[name] = utype:parseDefaultValStr(defaultValStr)
				end

			end

			for name,v in pairs(currModuleDefs.methods) do
				local infos = currModuleDefs.methods[name]
				local properUtype = infos[1]
				local aliasID = infos[2]
				local name = infos[3]
				local args = infos[4]

				if defmethod ~= nil and defmethod[name] == nil then
					KBEngine.WARNING_MSG(scriptmodule_name .. ":: method(" .. name .. ") no implement!")
				end

			end
		end	
		KBEngine.app:onImportEntityDefCompleted()

end

function _M:Client_onHelloCB(args)
		KBEngine.app.serverVersion = args:readString();
		KBEngine.app.serverScriptVersion = args:readString();
		KBEngine.app.serverProtocolMD5 = args:readString();
		KBEngine.app.serverEntityDefMD5 = args:readString();
		
		local ctype = args:readInt32();
		
		KBEngine.INFO_MSG("KBEngineApp::Client_onHelloCB: verInfo(" .. KBEngine.app.serverVersion .. "), scriptVerInfo(" .. 
			KBEngine.app.serverScriptVersion .. "), serverProtocolMD5(" .. KBEngine.app.serverProtocolMD5 .. "), serverEntityDefMD5(" .. 
			KBEngine.app.serverEntityDefMD5 .. "), ctype(" .. ctype .. ")!");
		
		KBEngine.app.lastTickCBTime = os.time();
end

function _M:Client_onImportServerErrorsDescr(stream)
		local size = stream:readUint16()
		while size > 0 do
			 size =size - 1
			 local e = KBEngine.ServerErr.new()
			  e.id = stream:readUint16()		
			  e.name = stream:readUnicode()
			  e.descr = stream:readUnicode()			  	
			  KBEngine.app.serverErrs[e.id] = e
			  local out=string.format("Client_onImportServerErrorsDescr:id:%d,descr:%s,name:%s",e.id,e.descr,e.name)
			  KBEngine.INFO_MSG(out)				
		end

		

end

function _M:Client_onScriptVersionNotMatch(stream)
		KBEngine.app.serverScriptVersion = stream:readString()
		KBEngine.ERROR_MSG("Client_onScriptVersionNotMatch: verInfo=" .. KBEngine.app.clientScriptVersion .. " not match(server: " .. KBEngine.app.serverScriptVersion .. ")")
		KBEngine.Event.fire("onScriptVersionNotMatch", KBEngine.app.clientScriptVersion, KBEngine.app.serverScriptVersion)
end

function _M:Client_onVersionNotMatch(stream)
		KBEngine.app.serverVersion = stream:readString()
		KBEngine.ERROR_MSG("Client_onVersionNotMatch: verInfo=" ..KBEngine.app.clientVersion .." not match(server: " .. KBEngine.app.serverVersion ..")")
		KBEngine.Event.fire("onVersionNotMatch", KBEngine.app.clientVersion, KBEngine.app.serverVersion)
end

function _M:Client_onControlEntity(eid, isControlled)
		local eid = stream:readInt32()
		local entity = KBEngine.app.entities[eid]
		if entity == nil then
			KBEngine.ERROR_MSG("KBEngineApp::Client_onControlEntity: entity(" .. eid .. ") not found!")
			return
		end
		local isCont = (isControlled ~= 0)
		if isCont then
			--[[
				如果被控制者是玩家自己，那表示玩家自己被其它人控制了
				所以玩家自己不应该进入这个被控制列表
			]]
			if KBEngine.app:player().id ~= entity.id then
				table.insert(KBEngine.app.controlledEntities,entity)
			end
		else
			local newArray = {}
			for i=1,#KBEngine.app.controlledEntities do
				if KBEngine.app.controlledEntities[i] ~= entity.id then
			       	table.insert(newArray,KBEngine.app.controlledEntities[i])
			    end
			end
			KBEngine.app.controlledEntities = newArray

		end
		entity.isControlled = isCont

		entity:onControlled(isCont)
		KBEngine.Event.fire("onControlled", entity, isCont)
end		

return _M
