local _M=class("GameObject",KBEngine.Entity)
function _M:__init__()
		 _M.super.__init__(self)	 
end

function _M:set_HP(old)
	KBEngine.Event.fire("function _M:set_HP", self, self.HP)
end
function _M:set_MP(old)
	KBEngine.Event.fire("function _M:set_MP", self, self.MP)
end

function _M:set_HP_Max(old)
	KBEngine.Event.fire("function _M:set_HP_Max", self, self.HP_Max)
end

function _M:set_MP_Max(old)
	KBEngine.Event.fire("function _M:set_MP_Max", self, self.MP_Max)
end

function _M:set_level(old)
	KBEngine.Event.fire("function _M:set_level", self, self.level)
end

function _M:set_name(old)
	KBEngine.Event.fire("function _M:set_name", self, self.name)
end

function _M:set_state(old)
	KBEngine.Event.fire("function _M:set_state", self, self.state)
end

function _M:set_subState(old)

end

function _M:set_utype(old)

end

function _M:set_uid(old)

end

function _M:set_spaceUType(old)

end

function _M:set_moveSpeed(old)
	KBEngine.Event.fire("function _M:set_moveSpeed", self, self.moveSpeed)
end

function _M:set_modelScale(old)
	KBEngine.Event.fire("function _M:set_modelScale", self, self.modelScale)
end

function _M:set_modelID(old)
	KBEngine.Event.fire("function _M:set_modelID", self, self.modelID)
end

function _M:set_forbids(old)

end

function _M:recvDamage(attackerID, skillID, damageType, damage)
	local entity = KBEngine.app:findEntity(attackerID)
	KBEngine.Event.fire("recvDamage", self, entity, skillID, damageType, damage)
end

return _M





