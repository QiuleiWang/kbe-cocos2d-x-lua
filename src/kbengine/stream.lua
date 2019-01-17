local _M=class("MemoryStream")
_M.ENDIAN_LITTLE = "ENDIAN_LITTLE"
_M.ENDIAN_BIG = "ENDIAN_BIG"
_M.PackFloatXType=class("PackFloatXType")
function _M.PackFloatXType:ctor()		
		self._unionData ={}
		self.fv =_M.new(self._unionData) 
		self.uv =_M.new(self._unionData)
		self.iv =_M.new(self._unionData)				
end

function _M:clearReadBuff()
		 local tempBuff={}
		 for i=self.rpos,#self.buffer do
		 	 tempBuff[#tempBuff+1]=self.buffer[i]
		 end
		 self.buffer=tempBuff
		 self.rpos=1
		 self.wpos=#self.buffer+1
end

function _M:ctor(buff)
		self.rpos = 1
		self.wpos = 1
		self.maxLength=KBEngine.PACKET_MAX_SIZE_TCP
		self._endian=_M.ENDIAN_LITTLE		
		self.buffer={}
		if buff and type(buff)~="number" then
			if type(buff)=="table" then
				self.buffer=buff
			else		
				self:writeBuf(buff)	
			end
		end
end

function _M:getLength()
	return #self.buffer
end

function _M:_getLC(__fmt)
	__fmt = __fmt or ""
	if self._endian == _M.ENDIAN_LITTLE then
		return "<"..__fmt
	elseif self._endian == _M.ENDIAN_BIG then
		return ">"..__fmt
	end
	return "="..__fmt
end

function _M:getBytes(offset,length)
	offset = offset or 1
	length = length or self:getLength()
	local buffer={}
	for i=offset,offset+length-1 do
		buffer[#buffer+1]=self.buffer[i]
	end
	return buffer
end

function _M:writeBytes(rawByte)
	if self.wpos > #self.buffer+1 then
		for i=#self.buffer+1,self.wpos-1 do
			self.buffer[i] = string.char(0)
		end
	end
	self.buffer[self.wpos] = string.sub(rawByte, 1,1)
	self.wpos = self.wpos + 1
end

function _M:readByteArray(len)
	local bytes = self:getBytes(self.rpos,len)
	return bytes
end


function _M:readBuf(len)
	local byteArray = self:readByteArray(len)
	local bytes=table.concat(byteArray, "",1,#byteArray)
	self.rpos = self.rpos + len
	return bytes
end

function _M:writeBuf(buf)
	for i=1,#buf do
		self:writeBytes(string.sub(buf,i,i))
	end
end

function _M:readInt8()
	local __, __v = string.unpack(self:readBuf(1), self:_getLC("c"))
	return __v
end

function _M:readInt16()
	local v=self:readUint16()
	if v>=32768 then
	   v=v-65536	
	end
	return v
end

function _M:readInt32()
	local v=self:readUint32()
	if v>=2147483648 then
	   v=v-4294967296	
	end
	return v
end

function _M:readInt64()
	local low=self:readUint32()
	local high=self:readUint32()
	return KBEngine.INT64.new(low,high)
end

function _M:readUint8()
	local __, __v = string.unpack(self:readBuf(1), self:_getLC("b"))
	return __v
end

function _M:readUint8Array(v)
		local uint8array={}
		for i=1,v do
			uint8array[#uint8array+1]=self:readUint8()
		end
		return uint8array
end

function _M:readUintNumber(num)
	local int8Array=self:readUint8Array(num)
	local value=0
	for i=1,#int8Array do
		local a=bit.band(int8Array[i],0xff)
		local lnum=(i-1)*8
		a=bit.lshift(a,lnum)
		value=value+a
	end
	return value
end

function _M:readUint16()
	return self:readUintNumber(2)
end

function _M:readUint32()
	return self:readUintNumber(4)
end

function _M:readUint64()
	return self:readUintNumber(8)
end

function _M:readFloat()
	local __, __v = string.unpack(self:readBuf(4), self:_getLC("f"))
	return __v
end

function _M:readDouble()
	local __, __v = string.unpack(self:readBuf(8), self:_getLC("d"))
	return __v
end

function _M:readString()
	local str=""
	local begin=self.rpos
	for i=begin,#self.buffer do
		local buf=self.buffer[i]
		self.rpos=self.rpos+1
		if string.byte(buf)~=0 then
		 	str=str..buf
		else
			break   
		end
	end
	return str
	
end

function _M:readBlob()
		local size = self:readUint32()
		local buff=self:readBuf(size)
		return buff
end

function _M:readUnicode()
		local size = self:readUint32()
		local buff=self:readBuf(size)
		local __, __v = string.unpack(buff, self:_getLC("A"..size))
		return __v
end

function _M:print()
		local out=""
		for i=self.rpos,#self.buffer do
			out=out..self.buffer[i] --string.byte(self.buffer[i])
		end
		print(out)
end

function _M:writeUnicode(v)
		local size = #v
		self:writeUint32(size)
		local pack = string.pack(self:_getLC("A"),v)
		self:writeBuf(pack)
end

function _M:readStream()
		local len=self.wpos-self.rpos
		local buf = self:readBuf(len)
		return KBEngine.MemoryStream.new(buf)
end

function _M:getStream(len)
		local len=len
		local buf = self:readBuf(len)
		return KBEngine.MemoryStream.new(buf)
end

function _M:readPackXZ()
		local xPackData =_M.PackFloatXType.new()
		local zPackData =_M.PackFloatXType.new()

		xPackData.fv:writeFloat(0.0)
		zPackData.fv:writeFloat(0.0)
		
		xPackData.uv:writeUint32(0x40000000)
		zPackData.uv:writeUint32(0x40000000)
		local v1 = self:readUint8()
		local v2 = self:readUint8()
		local v3 = self:readUint8()
		
		local data = 0
		data=bit.bor(data,bit.blshift(v1,16))
		data=bit.bor(data,bit.blshift(v2,8))
		data=bit.bor(data,v3)

		
		local t1=bit.blshift(bit.band(data,0x7ff000),3)
		local uv=xPackData.uv:readUint32()
		xPackData.uv.wpos=1			
		xPackData.uv:writeUint32(bit.bor(uv,t1))

		local t1=bit.blshift(bit.band(data,0x0007ff),15)		
		local uv=zPackData.uv:readUint32()
		zPackData.uv.wpos=1
		zPackData.uv:writeUint32(bit.bor(uv,t1))

		local fv=xPackData.fv:readFloat()
		xPackData.fv.wpos=1		
		xPackData.fv:writeFloat(fv-2.0)

		local fv=zPackData.fv:readFloat()
		zPackData.fv.wpos=1		
		zPackData.fv:writeFloat(fv-2.0)
		
		local t1=bit.blshift(bit.band(data,0x800000),8)
		xPackData.uv.rpos=1
		local uv=xPackData.uv:readUint32()
		xPackData.uv.wpos=1
		xPackData.uv:writeUint32(bit.bor(uv,t1))

		local t1=bit.blshift(bit.band(data,0x000800),20)
		zPackData.uv.rpos=1
		local uv=zPackData.uv:readUint32()
		zPackData.uv.wpos=1
		zPackData.uv:writeUint32(bit.bor(uv,t1))
		xPackData.fv.rpos=1
		zPackData.fv.rpos=1
		local data={}
		data[1]=xPackData.fv:readFloat()
		data[2]=zPackData.fv:readFloat()
		return data
		
end

function _M:readPackY()
		return self:readUint16()
end

function _M:writeInt8(v)
		 self:writeBytes(string.pack(self:_getLC("c"), v))
end

function _M:writeInt16(v)
		for i=1,2 do
			self:writeInt8(bit.band(bit.brshift(v,(i-1)*8),0xff))
		end			
end

function _M:writeInt32(v)
		for i=1,4 do
			self:writeInt8(bit.band(bit.brshift(v,(i-1)*8),0xff))
		end	
end

function _M:writeInt64(v)
		for i=1,8 do
			self:writeInt8(bit.band(bit.brshift(v,(i-1)*8),0xff))
		end	
end

function _M:writeUint8(v)
		 if type(v)=="boolean" then
		 	if v==true then
		 	   v=1		
		 	else
		 	   v=0
		 	end
		 end
		 self:writeBuf(string.pack(self:_getLC("b"), v))
end

function _M:writeUint16(v)
		for i=1,2 do
			self:writeUint8(bit.band(bit.brshift(v,(i-1)*8),0xff))
		end	
end

function _M:writeUint32(v)
		for i=1,4 do
			self:writeUint8(bit.band(bit.brshift(v,(i-1)*8),0xff))
		end	
end

function _M:writeUint64(v)
		for i=1,8 do
			self:writeUint8(bit.band(bit.brshift(v,(i-1)*8),0xff))
		end	
end

function _M:writeFloat(v)
		local __s = string.pack(self:_getLC("f"),v)
		self:writeBuf(__s)
end

function _M:writeDouble(v)
		local __s = string.pack(self:_getLC("d"),v)
		self:writeBuf(__s)
end

function _M:writeBlob(v)
		local size = #v
		self:writeUint32(size)
		if type(v)=="string" then
			for i=1,size do
				self:writeUint8(string.byte(v,i))
			end
		else
			for i=1,size do
				self:writeUint8(v[i])
			end
		end

end

function _M:writeString(v)
		if #v<1 then return end
		self:writeBuf(v)
		self:writeInt8(0)
end

function _M:readSkip(v)
		self.rpos = self.rpos+v
end

--剩余空间
function _M:space()
		return self.maxLength - self.wpos
end

function _M:length()
		return #self.buffer-self.rpos
end


function _M:readEOF()
	return #self.buffer - self.rpos <= 0
end

function _M:done()
	self.rpos = self.wpos
end

function _M:readVector2()
		local x=self:readInt32()
		local y=self:readInt32()
		return KBEngine.Vector2.new(x,y)
end	

function _M:readVector3()
	if KBEngine.CLIENT_NO_FLOAT==1 then
		local x=self:readInt32()
		local y=self:readInt32()
		local z=self:readInt32()
		return KBEngine.Vector3.new(x,y,z)
	else
		local x=self:readFloat()
		local y=self:readFloat()
		local z=self:readFloat()
		return KBEngine.Vector3.new(x,y,z)
	end
		
end

function _M:getPack(offset,length,save)
	offset = offset or 1
	length = length or #self.buffer
	local temp = {}
	--local out=""
	for i=offset,length do
		temp[#temp+1] = string.byte(self.buffer[i])
		--out=string.format("%s-%0x",out,string.byte(self.buffer[i]))
	end
	local fmt = self:_getLC("b"..#temp)
	local pack = string.pack(fmt, unpack(temp))
	return pack
end

function _M:getbuffer(bengin,length,sava)
	return self:getPack(bengin,length,sava)	
end

return _M
