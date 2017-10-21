local _M=class("UIButton",require("views/ui/UINode"))
_M.BT_STATE_NORMAL=1
_M.BT_STATE_SELECT=2
_M.BT_STATE_LIGHT=3

_M.normalImg=nil --默认精灵
_M.selectImg=nil --选中精灵
_M.lightImg=nil  --高亮精灵

_M.normalTitleColor=nil --默认精灵
_M.selectTitleColor=nil --选中精灵
_M.lightITitleColor=nil  --高亮精灵

_M._clickAni=true
_M._scaleByValue=0.95
_M._defScale=1
_M._isAning=false
_M.touchEnabled=true
_M.buttonSound=true

_M.touchBeginCallBack = nil
_M.touchMovedCallBack = nil
_M.touchEndedCallBack = nil

function _M:titleLabel()
        return self.contentNode:getChildByName("titleLabel")
end


function _M:contentSprite()
        return self.contentNode.sprite
end

function _M:getTitle()
    local title_str = ""
    local titleLabel=self:titleLabel()
    if titleLabel then
        title_str = titleLabel:getString()
    end
    return title_str
end

--私有方法，外部不应该调用
function _M:_setTitleColor(color)
        if color==nil then return end
        local titleLabel=self:titleLabel()
        if titleLabel then
           titleLabel:setColor(color)
        end
end

function _M:addView(child_node,zorder)
    zorder = zorder or 0
    if child_node then
        self.contentNode:addChild(child_node,zorder)
    end
end
--设置默认scale
function _M:setDefScale(scale)
         self._defScale=scale
         self.contentNode:setScale(scale)         
end

function _M:setClickAni(ani)
        self._clickAni=ani
end

function _M:setTitle(title,ext)
    local titleLabel=self.contentNode:getChildByName("titleLabel")
    if titleLabel then
       titleLabel:removeFromParent() 
    end
    local ext=ext or {}
    local fontName=ext.font or "Hei.ttf"
    local size=ext.size or 18
    self.normalTitleColor=ext.color or cc.c3b(255,255,255)
    local offset = ext.offset or cc.p(0,0)
    local enableOutline = ext.enableOutline
    if enableOutline == nil then 
        enableOutline = true
    end 
    local titleLabel=display.newLabel(title,size) 
    titleLabel:setColor(self.normalTitleColor)
    titleLabel:setName("titleLabel")    
    titleLabel:setAnchorPoint(0.5,0.5)
    titleLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    if enableOutline == true then
        titleLabel:enableOutline(cc.c4b(0,0, 0, 255),2)
    end
    local titleSize=self.contentNode:getContentSize()
    titleLabel:setPosition(titleSize.width/2+offset.x,titleSize.height/2+offset.y)
    self.contentNode:addChild(titleLabel,10)
    
end

function _M:setScale9Size(size)  --动态设置按钮
    self.contentNode.sprite:setScale9Size(size)
    self:setContentNodeSize(size)
    self.scale9Size=size
end

--单独设置button 点击区域 size
function _M:setSize(size)
        self:setContentSize(size)
        self.contentNode:setPosition(size.width/2,size.height/2)        
end

function _M:setSprites(normalImg,selectImg,lightImg)
         self.normalImg=normalImg
         self.selectImg=selectImg
         self.lightImg=lightImg
end

--设置Title Colrs
function _M:setTitleColors(normalColor,selectColor,lightColor)
         self.normalTitleColor=normalColor
         self.selectTitleColor=selectColor
         self.lightITitleColor=lightColor
end

function _M:setContentNodeSize(size)
        self:setContentSize(size)
        self.contentNode:setContentSize(size)
        self.contentNode:setPosition(size.width/2,size.height/2)
        self.contentNode.sprite:setPosition(self.contentNode:getPosition())                
end

function _M:setContentSprite(img)
         if img==nil then return end
         self.contentNode.sprite:setTexture(img)
         if self.scale9Size then
            self.contentNode.sprite:setScale9Size(self.scale9Size)
         end
         self:setContentNodeSize(self.contentNode.sprite:getShowSize())                  
end

--设置button 状态
function _M:setState(state)
       if state==self.state then return end
       
       if state==_M.BT_STATE_LIGHT then
           self:setContentSprite(self.lightImg)
           self:_setTitleColor(self.lightITitleColor)
           self.state=_M.BT_STATE_LIGHT
       elseif state== _M.BT_STATE_SELECT then
           self:setContentSprite(self.selectImg)
           self:_setTitleColor(self.selectTitleColor)
           self.state=_M.BT_STATE_SELECT
       else    
           self:setContentSprite(self.normalImg)
           self:_setTitleColor(self.normalTitleColor)
           self.state=_M.BT_STATE_NORMAL 
       end

end

function _M:onTouchBegan(touch,event)
    if self._isAning or self.touchEnabled==false then 
        return not self.nextResponse
    end
    if self.touchBeginCallBack then
        self.touchBeginCallBack(touch,event)
    end
    self.last_state=self.state    
    return _M.super.onTouchBegan(self,touch,event)
end    
function _M:onTouchMoved(touch,event)
    if self.touchMovedCallBack then
        self.touchMovedCallBack(touch,event)
    end
end
function _M:onTouchEnded(touch,event)                   
        self.contentNode:setScale(self._defScale)                           
        local state=self.last_state or self.state
        self:setState(state)
        if self.touchEndedCallBack then
            self.touchEndedCallBack(touch,event)
        end
        _M.super.onTouchEnded(self,touch,event)
        
end

function _M:onTouchCancelled(touch,event)                  
         self._isAning=false
         self.contentNode:setScale(self._defScale)
         local state=self.last_state or self.state
         self:setState(state)
         _M.super.onTouchCancelled(self,touch,event)
end

--检查是不是点击在node的区域内
function _M:_checkTouchIsNodeArea(touch,event)
        local isContain=_M.super._checkTouchIsNodeArea(self,touch,event)
        if isContain then
            if self._clickAni then
                --有动画的处理方式
                self.contentNode:setScale(self._defScale)
                self.contentNode:runAction(cc.ScaleBy:create(0.1,self._scaleByValue))
            else
                --没有动画图片切换的方式                
                self:setState(_M.BT_STATE_SELECT)
            end   
        end
        return isContain    
end

--触发单击事件
function _M:click()
    if self._clickAni then
        self._isAning=true
        self.contentNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,self._defScale),cc.CallFunc:create(function()   
                if self.__cname then
                    self._isAning=false
                    self.contentNode:setScale(self._defScale)
                    if self.callback then
                        self.callback(self)
                    end
                end                
        end)))
    else
        if self.callback then
            self.callback(self)
        end
    end

end

function _M.newButtonWithBg(defaultbg,selectedbg,callback,ext)
    local button=_M.new(cc.size(0,0),callback,ext)
    button:setSprites(defaultbg,selectedbg,defaultbg)
    button:setState(_M.BT_STATE_NORMAL)
    button:setAnchorPoint(0.5,0.5)    
    return button
end

function _M.newButton(bgimage,callback,ext)
    local button=_M.new(cc.size(0,0),callback,ext)
    button:setSprites(bgimage,bgimage,bgimage)
    button:setState(_M.BT_STATE_NORMAL)
    button:setAnchorPoint(0.5,0.5)
    return button
end    

function _M:ctor(size,callback,extParmter,stillCallback)
        _M.super.ctor(self,size)
        extParmter = extParmter or {}
        self._isAning=false
        self.touchEnabled=true
        local csize=self:getContentSize()
        self.contentNode=UINode.new()
        self.contentNode:setContentSize(self:getContentSize())                                
        self.contentNode:setAnchorPoint(0.5,0.5)
        self.contentNode:setPosition(csize.width/2,csize.height/2)
        local contentSprite=UIImage.new()
        contentSprite:setPosition(csize.width/2,csize.height/2)
        self.contentNode:addChild(contentSprite,-1)
        self.contentNode.sprite=contentSprite

        self.touchBeginCallBack = extParmter.touchBeginCallBack
        self.touchMovedCallBack = extParmter.touchMovedCallBack
        self.touchEndedCallBack = extParmter.touchEndedCallBack

        self:addChild(self.contentNode)
        self.callback=callback
        local function clickCallback()
             self:click()
        end
        self:addClickEvent(clickCallback)

    local function onEnterOrExit(tag)
        if tag == "enter" then
            local node=self:getValidNode()
            if node then
               --滚动的视图设置touch事件可传递 
               self:setNextResponse(true) 
            end
        elseif tag == "exit" then
            self._isAning=false
            self.contentNode:setScale(self._defScale)
        end
    end
    self:registerScriptHandler(onEnterOrExit)

end

function _M:setTouchEnabled(enabled)
        self.touchEnabled=enabled
end

function _M:setButtonSouond(enabled)
    self.buttonSound=enabled
end


return _M