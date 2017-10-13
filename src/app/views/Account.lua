local _M=class("Account",KBEngine.Entity)
function _M:__init__()
		 _M.super.__init__(self)
		 print("======onLoginSuccessfully=========")
		 KBEngine.Event.fire("onLoginSuccessfully", KBEngine.app.entity_uuid, self.id, self);
		 self.avatars = {}
		 self:baseCall("reqAvatarList")
end

function _M:onCreateAvatarResult(retcode, info)
		if retcode == 0 then
			self.avatars[info.dbid] = info;
			self.avatars.values.push(info);
			print("KBEAccount::onCreateAvatarResult: name=" .. info.name);
		end
		print("KBEAccount::onCreateAvatarResult: avatarsize=" .. #self.avatars.values .. ", error=" .. KBEngine.app.serverErr(retcode));
		KBEngine.Event.fire("onCreateAvatarResult", retcode, info, self.avatars)
end

function _M:onReqAvatarList(infos)
		self.avatars = infos;
		print("KBEAccount::onReqAvatarList: avatarsize=" ..#self.avatars)
		for i=1,#self.avatars.values do
			local avator=self.avatars.values[i]
			print("KBEAccount::onReqAvatarList: name" .. i .. "=" .. avator.name)
		end
		KBEngine.Event.fire("onReqAvatarList", self.avatars)
end


function _M:reqCreateAvatar(roleType, name)
		self:baseCall("reqCreateAvatar", roleType, name)
end

return _M





