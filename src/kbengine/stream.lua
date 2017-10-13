local _M=class("MemoryStream")
_M.ENDIAN_LITTLE = "ENDIAN_LITTLE"
_M.ENDIAN_BIG = "ENDIAN_BIG"
_M.PackFloatXType=class("PackFloatXType")
function _M.PackFloatXType:ctor()		
		self._unionData = {{},{},{},{}}
		self.fv =self._unionData[1] 
		self.uv =self._unionData[2] 
		self.iv =self._unionData[3]
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
	local bytes = self:getBytes(self.rpos, self.rpos + len - 1)
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

function _M:readStream()
		local len=self:getLength()
		local buf = self:readBuf(len - self.rpos)
		return KBEngine.MemoryStream.new(buf)
end



function _M:readPackXZ()
		local xPackData =_M.PackFloatXType.new()
		local zPackData =_M.PackFloatXType.new()
		xPackData.fv[1]=0.0
		zPackData.fv[1]=0.0
		
		xPackData.uv[1]=0x40000000
		zPackData.uv[1]=0x40000000

		local v1 = self:readUint8()
		local v2 = self:readUint8()
		local v3 = self:readUint8()
		local data = 0
		data=bit.bitor(data,bit.blshift(v1,16))
		data=bit.bitor(data,bit.blshift(v2,8))
		data=bit.bitor(data,v3)

		local t1=bit.blshift(bit.band(data,0x7ff000),3)
		xPackData.uv[1]=bit.bitor(data,t1)
		local t1=bit.blshift(bit.band(data,0x7ff000),15)
		zPackData.uv[1]=bit.bitor(data,t1)

		xPackData.fv[1] = xPackData.fv[1]-2.0
		zPackData.fv[1] = zPackData.fv[1]-2.0

		local t1=bit.blshift(bit.band(data,0x800000),8)
		xPackData.uv[1]=bit.bitor(data,t1)
		local t1=bit.blshift(bit.band(data,0x000800),20)
		zPackData.uv[1]=bit.bitor(data,t1)
		local data={}
		data[1]=xPackData.fv[1]
		data[2]=zPackData.fv[1]
		return data
		
end

function _M:readPackY()
		return self:readUint16()
end

function _M:writeInt8(v)
		 self:writeBytes(string.pack("<c", v))
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
		 self:writeBuf(string.pack(">b", v))
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
		local __s = string.pack(">f",v)
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

function _M:getPack(offset,length,save)
	offset = offset or 1
	length = length or #self.buffer
	local temp = {}
	local out=""
	for i=offset,length do
		temp[#temp+1] = string.byte(self.buffer[i])
		out=string.format("%s-%0x",out,string.byte(self.buffer[i]))
	end
	--print(out)
	local fmt = self:_getLC("b"..#temp)
	local pack = string.pack(fmt, unpack(temp))
	return pack
end

function _M:getbuffer(bengin,length,sava)
	return self:getPack(bengin,length,sava)	
end

return _M
