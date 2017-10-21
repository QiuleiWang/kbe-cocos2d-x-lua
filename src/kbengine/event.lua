local EventInfo =class("EventInfo")
function EventInfo:ctor(classinst, callbackfn)
		 self.callbackfn=callbackfn
		 self.classinst=classinst
end

function EventInfo:exeEvent(...)
		self.classinst[self.callbackfn](self.classinst,...)
end
local _M=class("Event")
_M._events={}
function _M.register(evtName, classinst, strCallback)
		 local event=_M._events[evtName]
		 if event==nil then
		 	event={}
		 end
		 event[#event+1]=EventInfo.new(classinst, strCallback)
		 _M._events[evtName]=event
end

function _M.deregister(classinst)
		local newEvents={}
		for evtName,event in pairs(_M._events) do
			newEvents[evtName]={}
			for i,eventObject in ipairs(event) do
				if eventObject.classinst~=classinst then
				   table.insert(newEvents[evtName],eventObject)	
				end
			end
		end
		_M._events=newEvents
end

function _M.fire(evtName,...)
		 local evtlst = _M._events[evtName]
		 if evtlst then
		 	for i,v in ipairs(evtlst) do		 		
		 		v:exeEvent(...)		 		
		 	end
		 end
end

return _M
