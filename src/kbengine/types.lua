local _M=KBEngine or {}
_M.datatype2id = {}
_M.datatype2id["STRING"] = 1
_M.datatype2id["STD::STRING"] = 1
_M.datatype2id["UINT8"] = 2
_M.datatype2id["BOOL"] = 2
_M.datatype2id["DATATYPE"] = 2
_M.datatype2id["CHAR"] = 2
_M.datatype2id["DETAIL_TYPE"] = 2
_M.datatype2id["ENTITYCALL_TYPE"] = 2
_M.datatype2id["ENTITYCALL_CALL_TYPE"] = 2
_M.datatype2id["UINT16"] = 3
_M.datatype2id["UNSIGNED SHORT"] = 3
_M.datatype2id["SERVER_ERROR_CODE"] = 3
_M.datatype2id["ENTITY_TYPE"] = 3
_M.datatype2id["ENTITY_PROPERTY_UID"] = 3
_M.datatype2id["ENTITY_METHOD_UID"] = 3
_M.datatype2id["ENTITY_SCRIPT_UID"] = 3
_M.datatype2id["DATATYPE_UID"] = 3
_M.datatype2id["UINT32"] = 4
_M.datatype2id["UINT"] = 4
_M.datatype2id["UNSIGNED INT"] = 4
_M.datatype2id["ARRAYSIZE"] = 4
_M.datatype2id["SPACE_ID"] = 4
_M.datatype2id["GAME_TIME"] = 4
_M.datatype2id["TIMER_ID"] = 4
_M.datatype2id["UINT64"] = 5
_M.datatype2id["DBID"] = 5
_M.datatype2id["COMPONENT_ID"] = 5
_M.datatype2id["INT8"] = 6
_M.datatype2id["COMPONENT_ORDER"] = 6
_M.datatype2id["INT16"] = 7
_M.datatype2id["SHORT"] = 7
_M.datatype2id["INT32"] = 8
_M.datatype2id["INT"] = 8
_M.datatype2id["ENTITY_ID"] = 8
_M.datatype2id["CALLBACK_ID"] = 8
_M.datatype2id["COMPONENT_TYPE"] = 8
_M.datatype2id["INT64"] = 9
_M.datatype2id["PYTHON"] = 10
_M.datatype2id["PY_DICT"] = 10
_M.datatype2id["PY_TUPLE"] = 10
_M.datatype2id["PY_LIST"] = 10
_M.datatype2id["ENTITYCALL"] = 10
_M.datatype2id["BLOB"] = 11
_M.datatype2id["UNICODE"] = 12
_M.datatype2id["FLOAT"] = 13
_M.datatype2id["DOUBLE"] = 14
_M.datatype2id["VECTOR2"] = 15
_M.datatype2id["VECTOR3"] = 16
_M.datatype2id["VECTOR4"] = 17
_M.datatype2id["FIXED_DICT"] = 18
_M.datatype2id["ARRAY"] = 19
----------------- 数据类型定义
local Number=class("Number")
function Number:toString()
		local outArray={}
		for k,v in pairs(self) do
			if type(v)~="function" and type(v)~="table" then
				table.insert(outArray,k..":"..v)				
			end
		end
		return string.format("{%s}", table.concat(outArray,','))
end

function Number:bind()

end

function Number:createFromStream(stream)
	local funcName="read"..self.__cname
	return stream[funcName](stream)
end

function Number:addToStream(stream,v)
	local funcName="write"..self.__cname
	if stream[funcName] then
		stream[funcName](stream,v)
	end

end

function Number:parseDefaultValStr(v)
		 return v
end

function Number:isSameType(v)
		return false
end

local KBEBType=class("KBEBType",Number)
KBEBType.type=nil
function KBEBType:createFromStream(stream)
	return stream:readBlob()
end

function KBEBType:addToStream(stream, v)
	return stream:writeBlob(stream,v)
end

local Uint8=class("Uint8",Number)
function Uint8:isSameType(v)
		if type(v) ~= "number" then
			return false
		end
		if v < 0 and v > 0xff then
			return false
		end
		return true
end

local Uint16=class("Uint16",Number)
function Uint16:isSameType(v)
		if type(v) ~= "number" then
			return false
		end
		if v < 0 and v > 0xffff then
			return false
		end
		return true
end

local Uint32=class("Uint32",Number)
function Uint32:isSameType(v)
		if type(v) ~= "number" then
			return false
		end
		if v < 0 and v > 0xffffffff then
			return false
		end
		return true
end

local Uint64=class("Uint64",Number)
function Uint64:ctor(low,hi)
	self.low=low
	self.hi=hi
end

function Uint64:toString()
		local result = ""
		local low = string.format("%08x",self.low)
		local high = string.format("%08x",self.hi)
		result =result..high..low
		return result
end

function Uint64:isSameType(v)
		
		return v.__cname=="Uint64"
end

local Int8=class("Int8",Number)
function Int8:isSameType(v)
		if type(v) ~= "number" then
			return false
		end
		if v < -0x80 and v > 0x7f then
			return false
		end
		return true
end

local Int16=class("Int16",Number)
function Int16:isSameType(v)
		if type(v) ~= "number" then
			return false
		end
		if v < -0x8000 and v > 0x7fff then
			return false
		end
		return true
end

local Int32=class("Int32",Number)
function Int32:isSameType(v)
		if type(v) ~= "number" then
			return false
		end
		if v < -0x80000000 and v > 0x7fffffff then
			return false
		end
		return true
end

local Int64=class("Int64",Number)
function Int64:ctor(low,hi)
	if low~=nil and hi~=nil then
		self.low=low
		self.hi=hi
		self.sign=1
		if hi>=2147483648 then
			self.sign=-1
			if self.low>0 then
			   self.low=bit.band((4294967296-self.low),0xffffffff)
			   self.hi = 4294967295 - self.hi
			else
			   self.low=bit.band((4294967296-self.low),0xffffffff)
			   self.hi = 4294967296 - self.hi   	
			end
		end
	end
end

function Int64:toString()
		local result = ""
		if self.sign < 0 then
			result = result.."-"
		end
		local low = string.format("%08x",self.low)
		local high = string.format("%08x",self.hi)
		result =result..high..low
		return result
end

function Int64:isSameType(v)
		return v.__cname=="Int64"
end

local Float=class("Float",Number)
function Float:isSameType(v)
		return type(v) == "number"
end

local Double=class("Double",Number)
function Double:isSameType(v)
		return type(v) == "number"
end

local String=class("String",Number)
function String:isSameType(v)
		return type(v) == "string"
end

local Vector2 =class("Vector2",KBEBType)
function Vector2:ctor(x,y,z)
		 self.x=x
		 self.y=y		
end

function Vector2:distance(pos,KBEBType)
	local x=pos.x-self.x
	local y=pos.y-self.y
	return math.sqrt(x*x+y*y)
end

function Vector2:createFromStream(stream)
	return stream:readVector2()
end

local 	Vector3 =class("Vector3",KBEBType)
function Vector3:ctor(x,y,z)
		 self.x=x
		 self.y=y
		 self.z=z
end

function Vector3:createFromStream(stream)
	return stream:readVector3()
end

function Vector3:distance(pos)
	local x=pos.x-self.x
	local y=pos.y-self.y
	local z=pos.z-self.z
	return math.sqrt(x*x+y*y+z*z)
end

local 	Vector4 =class("Vector4",KBEBType)
function Vector4:ctor(x,y,z,w)
		 self.x=x
		 self.y=y
		 self.z=z
		 self.w=w
end
function Vector4:distance(pos)
	local x=pos.x-self.x
	local y=pos.y-self.y
	local z=pos.z-self.z
	local w=pos.w-self.w
	return math.sqrt(x*x+y*y+z*z+w*w)
end
local PYTHON=class("Python",KBEBType)
local ARRAY=class("Array",KBEBType)
function ARRAY:bind()
		if type(self.type) == "number" then
			self.type = KBEngine.datatypes[self.type]
		end
end

function ARRAY:createFromStream(stream)
		local size = stream:readUint32()
		local datas = {}
		while size>0 do
			local value=self.type:createFromStream(stream)
			datas[#datas+1]=value
			size=size-1
		end
		return datas
end

function ARRAY:addToStream(stream,v)
		 stream:writeUint32(#v)
		 for i=1,#v do
		 	 self.type:addToStream(stream, v[i])
		 end
end

function ARRAY:isSameType(v)
	for i=1,#v do
		 if not self.type:isSameType(v[i]) then
		 	return false
		 end
	end
	return true
end

local FIXED_DICT=class("FIXED_DICT",KBEBType)
function FIXED_DICT:ctor()
		 self.dicttype = {}
		 self.implementedBy = nil
end

function FIXED_DICT:bind()
		for k,v in pairs(self.dicttype) do
			if type(v)=="number" then
				self.dicttype[k]=KBEngine.datatypes[v]
			end
		end
end

function FIXED_DICT:createFromStream(stream)
		local datas = {}
		local typearray=self.datatypeArray or {}
		for i=1,#typearray do
			local key=typearray[i]
			datas[key]=self.dicttype[key]:createFromStream(stream)
		end

		return datas;
end

function FIXED_DICT:addToStream(stream,v)
		for k,value in pairs(self.dicttype) do
			value:addToStream(stream, v[k])
		end
end

function FIXED_DICT:isSameType(v)
		for k,value in pairs(self.dicttype) do
			if not value:isSameType(v[k]) then
				return false
			end
		end
		return true
end

local BLOB=class("BLOB",KBEBType)
local ENTITYCALL=class("ENTITYCALL",KBEBType)
local UNICODE=class("Unicode",KBEBType)
function UNICODE:createFromStream(stream)
	return stream:readUnicode()
end

function UNICODE:addToStream(stream,v)
		 stream:writeUnicode(v)
end

function UNICODE:isSameType(v)
	return type(v)=="string"
end


_M.Vector3=Vector3
_M.Uint64=Uint64
_M.Int64=Int64
_M.ARRAY=ARRAY
_M.FIXED_DICT=FIXED_DICT
			
---datatypes----- 数据类型定义完成--------------
_M.datatypes=_M.datatypes or {}
_M.datatypes["UINT8"]=Uint8.new()
_M.datatypes["UINT16"]=Uint16.new()
_M.datatypes["UINT32"]=Uint32.new()
_M.datatypes["UINT64"]=Uint64.new()
_M.datatypes["INT8"]=Int8.new()
_M.datatypes["INT16"]=Int16.new()
_M.datatypes["INT32"]=Int32.new()
_M.datatypes["INT64"]=Int64.new()
_M.datatypes["FLOAT"]=Float.new()
_M.datatypes["DOUBLE"]=Double.new()
_M.datatypes["STRING"]=String.new()
_M.datatypes["PYTHON"]=PYTHON.new()
_M.datatypes["VECTOR2"]=Vector2.new()
_M.datatypes["VECTOR3"]=Vector3.new()
_M.datatypes["VECTOR4"]=Vector4.new()
_M.datatypes["BLOB"]=BLOB.new()
_M.datatypes["UNICODE"]=UNICODE.new()
_M.datatypes["FIXED_DICT"]=FIXED_DICT.new()
_M.datatypes["ARRAY"]=ARRAY.new()

function _M.createDataTypeFromStream(stream)
		local utype = stream:readUint16()
		local name = stream:readString()
		local valname = stream:readString()
		local length=""
		if #valname == 0 then
			length = "Null_"..utype
		end
		KBEngine.INFO_MSG("KBEngineApp::Client_onImportClientEntityDef: importAlias(" ..name .. ":" .. valname .. ")!")

		if name == "FIXED_DICT" then
			local datatype = KBEngine.FIXED_DICT.new();
			datatype.datatypeArray={} --用来解析的时候排序
			local keysize = stream:readUint8()
			datatype.implementedBy = stream:readString()	
			while(keysize > 0) do
				local keyname = stream:readString()
				local keyutype = stream:readUint16()
				datatype.datatypeArray[#datatype.datatypeArray+1]=keyname
				datatype.dicttype[keyname] = keyutype
				keysize=keysize-1
			end
			KBEngine.datatypes[valname] = datatype
		elseif name == "ARRAY" then
			local uitemtype = stream:readUint16()
			local datatype = KBEngine.ARRAY.new()
			datatype.type = uitemtype
			KBEngine.datatypes[valname] = datatype
		else
			KBEngine.datatypes[valname] = KBEngine.datatypes[name]
		end
		KBEngine.datatypes[utype] = KBEngine.datatypes[valname]
		--将用户自定义的类型补充到映射表中
		_M.datatype2id[valname] = utype
end

function _M.createDataTypeFromStreams(stream)
		local aliassize = stream:readUint16()
		KBEngine.INFO_MSG("KBEngineApp::createDataTypeFromStreams: importAlias(size=" ..aliassize ..")!")
		while(aliassize > 0) do
			_M.createDataTypeFromStream(stream)
			aliassize=aliassize-1
		end

		for k,v in pairs(KBEngine.datatypes) do
			if KBEngine.datatypes[k] ~=nil then
				v:bind()
			end
		end
end

return _M
