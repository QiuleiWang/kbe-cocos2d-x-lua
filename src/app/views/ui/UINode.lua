local _M=class("UINode",cc.Node)
_M.nextResponse=false --默认不传递

function _M:ctor(size)
    if size then
        self:setContentSize(size)
    end
end

function _M:dealloc()
    	 --释放资源
    	 self:unregisterScriptHandler()
end

function _M:getCenter()
        local csize=self:getContentSize()
        return cc.p(csize.width/2,csize.height/2) 
end

--显示Size
function _M:getShowSize()
         local size=self:getContentSize()
         return cc.size(size.width*self:getScaleX(),size.height*self:getScaleY())
end

--增加click事件
function _M:addClickEvent(callback,swallow)

         self:onTouch(swallow)
         self.clickCallback=callback
end

--获取该节点是否显示，会循环遍历所有的父节点，cocos2dx isVisible 不会检测父节点
function _M:getVisible()
       local node=self
       local m_visible=self:isVisible()
        while(node) do
            local node_visible=node:isVisible()
            if node_visible~= m_visible then
                return node_visible
            end
            node=node:getParent()    
        end
        return m_visible
end


--获取有效事件的节点 可以滚动的父层，一般用于检测点击区域是否在滚动框以外
function _M:getValidNode()
       local node=self
       while(node) do
            local cname=node.__cname
            if "UITableView"==cname or "UIScrollView"==cname or "UIPageView"==cname then
                return node
            end
            node=node:getParent()    
        end        
        return nil
end 



function _M:clickEventProcess(touch,event)
         local startPoint=touch:getStartLocation()
         local endPoint=touch:getLocation()
         local distance=cc.pGetDistance(startPoint,endPoint)
         if distance>15 then return end --可能是滑动操作
         self.clickCallback(self)  
                        
end

--检查是不是点击在node的区域内
function _M:_checkTouchIsNodeArea(touch,event)
    local startPoint=touch:getStartLocation()
    local useBox=self:getValidNode()
    if useBox then
        local touchLocation=useBox:getParent():convertToNodeSpace(startPoint)
        local bBox=useBox:getBoundingBox()
        local bBoxisContain=cc.rectContainsPoint(bBox,touchLocation)
        if not bBoxisContain then return false end
    end
    local touchLocation=self:getParent():convertToNodeSpace(startPoint)
    local bBox=self:getBoundingBox()
    local isContain=cc.rectContainsPoint(bBox,touchLocation)
    return isContain
end


function _M:onTouchBegan(touch,event)
    
    if self.clickCallback then
        
        return self:_checkTouchIsNodeArea(touch,event)
    else
        if self.nextResponse==false then
            --不传递到下一层
            return true
        else       
            return false    
        end
    end

end

function _M:onTouchMoved(touch,event)

end

function _M:onTouchEnded(touch,event)
         if self.clickCallback then
            self:clickEventProcess(touch,event)
         end
end

function _M:onTouchCancelled(touch,event)
    
end

--增加定时调用
function _M:onSchedule(callback,delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local action = cc.RepeatForever:create(sequence)
    self:runAction(action)
    return action
end

--延迟调用某个方法
function _M:scheduleDelay(callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self:runAction(sequence)
    return sequence
end

function _M:setBgColor(color)
    local layer=cc.LayerColor:create(color)
    layer:setContentSize(self:getContentSize())
    self:addChild(layer,-9999)
end

function _M:setZOrder(zorder)
    --gl.POINTS gl.LINEAR
    for k,v in pairs(self:getChildren()) do
        v:setGlobalZOrder(zorder)
    end
    
end


--设置下一层是否接受touch事件
function _M:setNextResponse(enabled)
         self.nextResponse=enabled
         self:onTouch(not self.nextResponse)
end

--增加touch事件
function _M:onTouch(swallowTouches)
    if self.touchListener then 
        if swallowTouches~=nil then
           self.touchListener:setSwallowTouches(swallowTouches) 
        end
        return
    end
    
    local function onBegan(touch,event)
        return self:onTouchBegan(touch,event)
    end
    
    local function onMoved(touch,event)
        self:onTouchMoved(touch,event)
    end
    
    local function onEnded(touch,event)
        self:onTouchEnded(touch,event)
    end
    
    local function onCancelled(touch,event)
        self:onTouchCancelled(touch,event)
    end
    
    local listener=cc.EventListenerTouchOneByOne:create()
    local swallow=swallowTouches or (not self.nextResponse)
    listener:setSwallowTouches(swallow)
    listener:registerScriptHandler(onBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onEnded,cc.Handler.EVENT_TOUCH_ENDED) 
    listener:registerScriptHandler(onCancelled,cc.Handler.EVENT_TOUCH_CANCELLED)
    self.touchListener=listener
    local eventDispatcher=cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
end

return _M