local _M=class("Message")
function _M:ctor(id, name, length, argstype, args, handler)
		 self.id=id
		 self.name=name
		 self.length=length
		 self.argstype=argstype
		 --绑定执行
		local args=args or {}
		for i=1,#args do
			args[i]=KBEngine.bindReader(args[i])
		end
		self.args=args
		self.handler=handler
end

function _M:createFromStream(msgstream)
		if #self.args <= 0 then
			return msgstream
		end		
		local  result = {}
		for i=1,#self.args do
			dump(self.args[i])
			result[i] = self.args[i]:createFromStream(msgstream)
		end
		return result
end

function _M:handleMessage(msgstream)
		if self.handler ==nil then
			KBEngine.ERROR_MSG("KBEngine.Message::handleMessage: interface("..self.name.."/" ..self.id..") no implement!")  
			return;
		end
		print("handleMessage")
		if #self.args <= 0 then
			if self.argstype < 0 then
				self.handler(KBEngine.app,msgstream)
			else
				self.handler(KBEngine.app)
			end
		else
			local parmter=self:createFromStream(msgstream)
			self.handler(KBEngine.app,unpack(parmter));
		end
end

return _M
