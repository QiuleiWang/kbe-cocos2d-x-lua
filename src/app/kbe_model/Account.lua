local _M=class("Account",KBEngine.GameObject)
function _M:__init__()
		 _M.super.__init__(self)
		 KBEngine.Event.fire("onLoginSuccessfully", KBEngine.app.entity_uuid, self.id, self);
		 self.avatars = {}
		 self:baseCall("reqAvatarList")
end

function _M:onCreateAvatarResult(retcode, info)
		if retcode == 0 then
			self.avatars[info.dbid] = info;
			table.insert(self.avatars.values,info)
			print("KBEAccount::onCreateAvatarResult: name=" .. info.name);
		end

		print("KBEAccount::onCreateAvatarResult: avatarsize=" .. #self.avatars.values .. ", error=" .. KBEngine.app:serverErr(retcode));
		KBEngine.Event.fire("onCreateAvatarResult", retcode, info, self.avatars)
end

function _M:onRemoveAvatar(found)
	KBEngine.Event.fire("onRemoveAvatar", found)
end

function _M:onReqAvatarList(infos)
		self.avatars = infos;
		KBEngine.Event.fire("onReqAvatarList", self.avatars)
end

function _M:reqCreateAvatar(roleType, name)
		self:baseCall("reqCreateAvatar", roleType, name)
end

function _M:selectAvatarGame(dbid)
		self:baseCall("selectAvatarGame", dbid)
end

return _M
