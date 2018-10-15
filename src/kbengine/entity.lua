local _M=class("Entity")
function _M:ctor()
		 self.id=0
		 self.className=""
		 self.position=KBEngine.Vector3.new(0,0,0)
		 self.direction = KBEngine.Vector3.new(0, 0, 0)
		 self.velocity = 0
		 self.cell = nil
		 self.base = nil
		 --enterworld之后设置为true
		 self.inWorld = false
		 -- __init__调用之后设置为true
		 self.inited = false
		 --是否被控制
		 self.isControlled = false

		 self.entityLastLocalPos = KBEngine.Vector3.new(0.0, 0.0, 0.0)
		 self.entityLastLocalDir = KBEngine.Vector3.new(0.0, 0.0, 0.0)
		
		--玩家是否在地面上
		self.isOnGround = false

end

function _M:__init__()

end

function _M:callPropertysSetMethods()
		local currModule = KBEngine.moduledefs[self.className]
		for name,v in pairs(currModule.propertys) do
			local propertydata = v
			local properUtype = propertydata[1];
			local name = propertydata[3];
			local setmethod = propertydata[6];
			local flags = propertydata[7];
			local oldval = self[name];
			if setmethod==nil then
				print("not find method:","set_"..name)
			end
			if setmethod ~= nil and setmethod~="null" then
				--base类属性或者进入世界后cell类属性会触发set_*方法
				-- ED_FLAG_BASE_AND_CLIENT、ED_FLAG_BASE
				if flags == 0x00000020 or flags == 0x00000040 then
					if self.inited and (not self.inWorld) then
						setmethod(self,oldval)
					end
				else
					if self.inWorld then
						
						if flags == 0x00000008 or flags == 0x00000010 then
							if self:isPlayer() then
								setmethod(self,oldval)
							end
						else
							setmethod(self,oldval)	
						end
					end		
				end

			end
			
		end
end

function _M:onDestroy()

end

function _M:onControlled(bIsControlled)

end

function _M:isPlayer()
		return self.id == KBEngine.app.entity_id
end

function _M:baseCall(...)

		local arguments={...}
		if #arguments < 1 then
			KBEngine.ERROR_MSG('KBEngine.Entity::baseCall: not fount interfaceName!');  
			return
		end	
		if self.base == nil then
			KBEngine.ERROR_MSG('KBEngine.Entity::baseCall: base is None!');  
			return;			
		end
		local method = KBEngine.moduledefs[self.className].base_methods[arguments[1]];
		if method == nil then
			KBEngine.ERROR_MSG("KBEngine.Entity::baseCall: The server did not find the def_method(" ..self.className .. "." .. arguments[1] .. ")!");
			return;
		end
		
		local methodID = method[1]
		local args1 = method[4]
		dump(arguments)
		if #arguments- 1 ~= #args1 then
			KBEngine.ERROR_MSG("KBEngine.Entity::baseCall: args(" ..#arguments - 1 .. "!= " ..#args1.. ") size is error!");  
			return;
		end
		print("self.base:newCall")
		self.base:newCall();
		self.base.bundle:writeUint16(methodID)
		
		for i=1,#args1 do
			if args1[i]:isSameType(arguments[i + 1]) then
			    args1[i]:addToStream(self.base.bundle, arguments[i + 1])
			else
				KBEngine.ERROR_MSG("KBEngine.Entity::baseCall: arg[" .. i .. "] is error!")   
			end
		end
		
		self.base:sendCall();
		
end

function _M:cellCall(...)
		local arguments={...}
		if #arguments < 1 then
			print(debug.traceback())
			KBEngine.ERROR_MSG('KBEngine.Entity::cellCall: not fount interfaceName!');  
			return
		end
		
		if self.cell == nil then
		
			KBEngine.ERROR_MSG('KBEngine.Entity::cellCall: cell is None!');  
			return;
		end						
		
		
		local method = KBEngine.moduledefs[self.className].cell_methods[arguments[1]];
		
		if method == nil then
			KBEngine.ERROR_MSG("KBEngine.Entity::cellCall: The server did not find the def_method(" .. self.className + "." .. arguments[1] .. ")!");
			return;
		end
		
		local methodID = method[1];
		local args1 = method[4];
		
		if #arguments - 1 ~= #args1 then
		
			KBEngine.ERROR_MSG("KBEngine.Entity::cellCall: args(" .. (#arguments - 1) .. "!= " .. #args .. ") size is error!");  
			return;
		end
		
		self.cell:newCall();
		self.cell.bundle:writeUint16(methodID)

		for i=1,#args1 do
			if args1[i]:isSameType(arguments[i + 1]) then
				args1[i]:addToStream(self.cell.bundle, arguments[i + 1])
			else
				KBEngine.ERROR_MSG("KBEngine.Entity::cellCall: arg[" .. i .. "] is error!");
			end
		end
		self.cell:sendCall()
end

function _M:enterWorld()
		KBEngine.INFO_MSG(self.className ..'::enterWorld: ' .. self.id)
		self.inWorld = true
		self:onEnterWorld()
		KBEngine.Event.fire("onEnterWorld",self)
end

function _M:onEnterWorld()

end

function _M:leaveWorld()
		KBEngine.INFO_MSG(self.className..'::leaveWorld: '..self.id)
		self.inWorld = false
		self:onLeaveWorld()
		KBEngine.Event.fire("onLeaveWorld", self)
end

function _M:onLeaveWorld()

end

function _M:enterSpace()
		KBEngine.INFO_MSG(self.className ..'::enterSpace: ' ..self.id) 
		self:onEnterSpace()
		KBEngine.Event.fire("onEnterSpace", self)
end

function _M:onEnterSpace()

end

function _M:leaveSpace()
		KBEngine.INFO_MSG(self.className ..'::leaveSpace: ' .. self.id) 
		self:onLeaveSpace()
		KBEngine.Event.fire("onLeaveSpace", self)
end

function _M:onLeaveSpace()
		
end

function _M:set_position(old)
		KBEngine.DEBUG_MSG(self.className .."::set_position: (" ..old.x..","..old.y..","..old.z..")")
		if self:isPlayer() then
			KBEngine.app.entityServerPos.x = self.position.x
			KBEngine.app.entityServerPos.y = self.position.y
			KBEngine.app.entityServerPos.z = self.position.z
		end
		KBEngine.Event.fire("set_position", self)
end

function _M:onUpdateVolatileData()
		
end

function _M:set_direction(old)
		KBEngine.DEBUG_MSG(self.className .. "::set_direction: " .. old.x,old.y,old.z)
		KBEngine.Event.fire("set_direction", self)
end


return _M
