local _M = class("UIImage", function(...)
        return cc.Sprite:create(...)
end)

function _M:ctor()
        self:setBlendFunc(cc.blendFunc(gl.ONE,gl.ONE_MINUS_SRC_ALPHA))
end

function _M:setScale9Size(size,offset)
    local csize=self:getTexture():getContentSize()
    local offset=offset or {}
    local x=offset.x or math.floor(csize.width/2)-1
    local y=offset.y or math.floor(csize.height/2)-1
    self:setCenterRect(cc.rect(x,y,csize.width-2*x,csize.height-2*y))
    self:setContentSize(size)
    self.scale9Size=size
end

function _M:setZOrder(zorder)
		 for i,v in ipairs(self:getChildren()) do
		 	v:setGlobalZOrder(zorder)
		 end
end

--显示Size
function _M:getShowSize()
         local size=self:getContentSize()
         return cc.size(size.width*self:getScaleX(),size.height*self:getScaleY())
end

function _M:setShowSize(size)
         local csize=self:getContentSize()
         local scalex=size.width/csize.width
         local scaley=size.height/csize.height
         local minScale=math.min(scalex,scaley)
         self:setScale(minScale)
end

function _M:getCenter()
    local csize=self:getContentSize()
    return cc.p(csize.width/2,csize.height/2) 
end


return _M