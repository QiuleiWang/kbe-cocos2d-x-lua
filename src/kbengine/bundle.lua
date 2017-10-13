local _M=class("Bundle")
function _M:ctor()
	self.memorystreams={}
	self.stream =KBEngine.MemoryStream.new()
	self.numMessage = 0
	self.messageLengthBuffer =nil
	self.messageLength = 0
	self.message =nil
end

function _M:newMessage(message)
		self:fini(false)
		self.message = message
		self.numMessage =self.numMessage+1
		if self.message.length == -1 then
			self.messageLengthBuffer =KBEngine.MemoryStream.new()		
		end
		self:writeUint16(message.id)
		if self.messageLengthBuffer then
			self:writeUint16(0)
			self.messageLengthBuffer[0] = 0
			self.messageLengthBuffer[1] = 0
			self.messageLength = 0
		end

end

function _M:writeMsgLength(v)
		if self.messageLengthBuffer then
			self.messageLengthBuffer:writeUint16(v) 
			self.stream.buffer[3]=self.messageLengthBuffer.buffer[1]
			self.stream.buffer[4]=self.messageLengthBuffer.buffer[2]
		end

end

function _M:fini(issend)
		if self.numMessage > 0 then
			self:writeMsgLength(self.messageLength)
			if self.stream then
				self.memorystreams[#self.memorystreams+1]=self.stream
			end
		end

		if issend then
			self.messageLengthBuffer = nil
			self.numMessage = 0
			self.message = nil
		end
end	


function _M:send(network)
		self:fini(true)
		local network=network or KBEngine.app		
		for i=1,#self.memorystreams do
			local stream = self.memorystreams[i]	
			local buff=stream:getbuffer()			
			network:send(buff)
		end
		self.memorystreams={}
		self.stream =KBEngine.MemoryStream.new(KBEngine.PACKET_MAX_SIZE_TCP)
end

 -- ---------------------------------------------------------------------------------
function _M:checkStream(v)
		if v > self.stream:space() then
			self.memorystreams[#self.memorystreams+1]=self.stream
			self.stream = KBEngine.MemoryStream.new()
		end
		self.messageLength= self.messageLength+v
end		
	
---------------------------------------------------------------------------------
function _M:writeInt8(v)
		self:checkStream(1)
		self.stream:writeInt8(v)
end

function _M:writeInt16(v)
		self:checkStream(2)
		self.stream:writeInt16(v)
end
		
function _M:writeInt32(v)
		self:checkStream(4)
		self.stream:writeInt32(v)
end

function _M:writeInt64(v)
		self:checkStream(8);
		self.stream:writeInt64(v)
end
	
function _M:writeUint8(v)
		self:checkStream(1)
		self.stream:writeUint8(v)
end

function _M:writeUint16(v)
		self:checkStream(2)
		self.stream:writeUint16(v)
end
		
function _M:writeUint32(v)
		self:checkStream(4)
		self.stream:writeUint32(v)
end

function _M:writeUint64(v)
		self:checkStream(8)
		self.stream:writeUint64(v)
end
	
function _M:writeFloat(v)
		self:checkStream(4)
		self.stream:writeFloat(v)
end
function _M:writeDouble(v)

		self:checkStream(8);
		self.stream:writeDouble(v);
end
	
function _M:writeString(v)
		if #v<1 then return end
		self:checkStream(#v+1)
		self.stream:writeString(v);
end
	
function _M:writeBlob(v)
		self:checkStream(#v + 4)
		self.stream:writeBlob(v);
end	

return _M
