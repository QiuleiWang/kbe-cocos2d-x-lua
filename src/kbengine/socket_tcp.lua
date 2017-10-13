local SOCKET_TICK_TIME = 0.1 			-- check socket data interval
local SOCKET_RECONNECT_TIME = 5			-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3	-- socket failure timeout
local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"
local timer = require("kbengine.timer")
local socket = require("socket")

local _M = class("SocketTCP")
_M.EVENT_DATA = "SOCKET_TCP_DATA"
_M.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
_M.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
_M.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
_M.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"
_M._VERSION = socket._VERSION

function _M.getTime()
	return socket.gettime()
end

function _M:ctor(host,port,reConnectFailure)
	--绑定事件组件
	cc.bind(self,"event")
    self.host = host
    self.port = port
	self.tickScheduler = nil			-- timer for data
	self.reconnectScheduler = nil		-- timer for reconnect
	self.connectTimeTickScheduler = nil	-- timer for connect timeout
	self.tcp = nil
	self.isRetryConnect = reConnectFailure
	self.isConnected = false
end

--设置心跳时间
function _M:setTickTime(time)
	SOCKET_TICK_TIME = time
	return self
end

function _M:setReconnTime(time)
	SOCKET_RECONNECT_TIME = time
	return self
end

function _M:setConnFailTime(time)
	SOCKET_CONNECT_FAIL_TIMEOUT = time
	return self
end

function _M:connect(host,port,reConnectFailure)
	if host then self.host = host end
	if port then self.port = port end
	if reConnectFailure ~= nil then self.isRetryConnect = reConnectFailure end
	self.tcp = socket.tcp()
	self.tcp:settimeout(0)

	if not self:_checkConnect() then
		local _connectTimeTick = function ()
			if self.isConnected then return end
			self.waitConnect = self.waitConnect or 0
			self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
			if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
				self.waitConnect = nil
				self:close()
				self:_connectFailure()
			end
			self:_checkConnect()
		end
		self.connectTimeTickScheduler = timer.onTimer(_connectTimeTick, SOCKET_TICK_TIME)
	end
end

function _M:send(data)
	self.tcp:send(data)
end

function _M:close( ... )
	self.tcp:close()
	if self.connectTimeTickScheduler then timer.unTimer(self.connectTimeTickScheduler) end
	if self.tickScheduler then timer.unTimer(self.tickScheduler) end
	self:dispatchEvent({name=_M.EVENT_CLOSE})
end

-- disconnect on user's own initiative.
function _M:disconnect()
	self:_disconnect()
	self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

--------------------
-- private
--------------------

--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function _M:_checkConnect()
	local succ = self:_connect()
	if succ then
		self:_onConnected()
	end
	return succ
end

function _M:_connect()
	local succ, status = self.tcp:connect(self.host, self.port)
	return succ == 1 or status == STATUS_ALREADY_CONNECTED
end

function _M:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
	self:dispatchEvent({name=_M.EVENT_CLOSED})
end

function _M:_onDisconnect()
	self.isConnected = false
	self:dispatchEvent({name=_M.EVENT_CLOSED})
	self:_reconnect();
end

-- connecte success, cancel the connection timerout timer
function _M:_onConnected()
	self.isConnected = true
	self:dispatchEvent({name=_M.EVENT_CONNECTED})
	if self.connectTimeTickScheduler then timer.unTimer(self.connectTimeTickScheduler) end

	local _tick = function()
		while true do
			-- if use "*l" pattern, some buffer will be discarded, why?
			local body, status, partial = self.tcp:receive("*a")	-- read the package body
    	    if status == STATUS_CLOSED or status == STATUS_NOT_CONNECTED then
		    	self:close()
		    	if self.isConnected then
		    		self:_onDisconnect()
		    	else
		    		self:_connectFailure()
		    	end
		   		return
	    	end
		    if 	(body and string.len(body) == 0) or
				(partial and string.len(partial) == 0)
			then return end
			if body and partial then body = body .. partial end
			self:dispatchEvent({name=_M.EVENT_DATA, data=(partial or body), partial=partial, body=body})
		end
	end

	-- start to read TCP data
	self.tickScheduler = timer.onTimer(_tick, SOCKET_TICK_TIME)
end

function _M:_connectFailure(status)
	self:dispatchEvent({name=_M.EVENT_CONNECT_FAILURE})
	self:_reconnect()
end

-- if connection is initiative, do not reconnect
function _M:_reconnect(immediately)
	if not self.isRetryConnect then return end
	if immediately then self:connect() return end
	if self.reconnectScheduler then timer.unTimer(self.reconnectScheduler) end
	local _doReConnect = function ()
		self:connect()
	end
	self.reconnectScheduler = timer.delayTimer(_doReConnect, SOCKET_RECONNECT_TIME)
end

return _M
