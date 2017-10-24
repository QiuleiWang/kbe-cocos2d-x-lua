local _M = class("WorldScene",cc.load("mvc").ViewBase)
local AvatarSprite=require("views/AvatarSprite")
function _M:onCreate()
	   self:installEvents()
     self.mapRate=16
     self.entities = {};
     self.mapNode = UINode.new()
     self.mapNode:addTo(self)
     -- local function onUpdate(dt)
     --      self:update(dt)
     -- end
     -- self:onUpdate(onUpdate)
     -- local function clickNodeCallback(node,touch)
     --       local endPoint=touch:getLocation()
     --       print(endPoint.x,endPoint.y) 
     -- end
     -- self:addClickEvent(clickNodeCallback)
end

function _M:update(dt)
        if self.tmxmap==nil or self.playerLastPos ==nil then
           return
        end

        -- local player=KBEngine.app:player()
        -- if (player==nil) or (not player.inWorld) then
        --    return
        -- end

        -- local x=self.playerLastPos.x-self.player.x
        -- local y=self.playerLastPos.y-self.player.y
        -- self.playerLastPos.x=self.player.x
        -- self.playerLastPos.y=self.player.y

        -- --local pos=self:convertToNodeSpace(cc.p(x,y))
        -- player.position.x = self.player.x / 16
        -- player.position.y = 0
        -- player.position.z = self.player.y / 16
        -- player.direction.x = 0
        -- player.direction.y = 0   
        -- player.direction.z = self.player:getDirection()
        -- KBEngine.app.isOnGround = 1

end

function _M:onClickUp(pos)
    print("onClickUp at: " .. pos.x .. " " .. pos.y)
    --点击了鼠标，我们需要将角色移动到该位置
    if self.player ~= nil and self.player.state ~= 1 then
       self.player.chaseTarget = nil
       self.player:moveToPosition(self.mapNode:convertToNodeSpace(pos))
    end
end

function _M:onClickTarget(target)
    print("onClickTarget: "..target.res)
    if self.player ~= target then
       --点击了鼠标，我们需要将角色移动到该目标的位置
      if self.player ~= nil and self.player.state ~= 1 then
         self.player:moveToTarget(target)
      end
         
    end
end

function _M:onAvatarEnterWorld(rndUUID, eid, avatar)
    --角色进入世界，创建角色精灵
    self.player=AvatarSprite.new(self,eid,"avatar/clotharmor")
    self.player:setPosition(avatar.position.x * self.mapRate,avatar.position.z * self.mapRate)
    self.mapNode:addChild(self.player, 10)
    self.playerLastPos = cc.p(self.player:getPosition())
    self:fixMap()
end

function _M:installEvents()
    --common
    -- KBEngine.Event.register("onKicked", self, "onKicked");
    -- KBEngine.Event.register("onDisableConnect", self, "onDisableConnect");
    -- KBEngine.Event.register("onConnectStatus", self, "onConnectStatus");
    --in world
    KBEngine.Event.register("addSpaceGeometryMapping",self,"addSpaceGeometryMapping")
    KBEngine.Event.register("onAvatarEnterWorld", self,"onAvatarEnterWorld")
    KBEngine.Event.register("onEnterWorld", self, "onEnterWorld");
    -- KBEngine.Event.register("onLeaveWorld", self, "onLeaveWorld");
    KBEngine.Event.register("set_position", self, "set_position");
    -- KBEngine.Event.register("set_direction", self, "set_direction");
    --KBEngine.Event.register("updatePosition", self, "updatePosition");
    -- KBEngine.Event.register("set_HP", self, "set_HP");
    -- KBEngine.Event.register("set_MP", self, "set_MP");
    -- KBEngine.Event.register("set_HP_Max", self, "set_HP_Max");
    -- KBEngine.Event.register("set_MP_Max", self, "set_MP_Max");
    -- KBEngine.Event.register("set_level", self, "set_level");
    -- KBEngine.Event.register("set_name", self, "set_entityName");
    -- KBEngine.Event.register("set_state", self, "set_state");
    -- KBEngine.Event.register("set_moveSpeed", self, "set_moveSpeed");
    -- KBEngine.Event.register("set_modelScale", self, "set_modelScale");
    -- KBEngine.Event.register("set_modelID", self, "set_modelID");
    -- KBEngine.Event.register("recvDamage", self, "recvDamage");
    -- KBEngine.Event.register("otherAvatarOnJump", self, "otherAvatarOnJump");
    -- KBEngine.Event.register("onAddSkill", self, "onAddSkill");
end

function _M:addSpaceGeometryMapping(resPath)
		--服务器space创建了几何映射（可以理解为添加了场景的具体资源信息，客户端可以使用这个信息来加载对应的场景表现）
		self.mapName = resPath
    --其实可以将resPath与地图tmx文件名设置为一致，那么就可以根据服务器返回的信息来加载场景
    -- resPath由服务端cell/space.py中KBEngine.addSpaceGeometryMapping(self.spaceID, None, resPath)设置
    self:createScene("res/img/3/cocosjs_demo_map1.png");
    self:fixMap()
end

function _M:set_position(entity)
        --强制将位置设置到坐标点
        -- local ae = self.entities[entity.id]
        -- if ae == nil then
        --     return
        -- end    
        -- ae.x = entity.position.x * self.mapRate
        -- ae.y = entity.position.z * self.mapRate
end

function _M:fixMap()
    if self.tmxmap == nil or self.player == nil then
      return
    end
    self.mapNode:setContentSize(self.tmxmap:getContentSize())
     if self:getActionByTag(11)==nil then
        local size=self.mapNode:getContentSize()    
        local rect=cc.rect(0,0,size.width,size.height)
        local folowAction=cc.Follow:create(self.player,rect)
        folowAction:setTag(11)
        self:runAction(folowAction)
    end

end

function _M:onEnterWorld(entity)
    -- NPC/Monster/Gate等实体进入客户端世界，我们需要创建一个精灵来描述整个实体的表现
    if not entity:isPlayer() then
          local  ae = AvatarSprite.new(self,entity.id,"avatar/clotharmor")
          ae:setAnchorPoint(0.5,0)
          ae:setPosition(entity.position.x*self.mapRate,entity.position.z*self.mapRate)
          self.mapNode:addChild(ae, 10)
          self.entities[entity.id] = ae
      end
end

function _M:createScene(resPath)
   self.tmxmap = UIImage.new(resPath)
   self.tmxmap:setAnchorPoint(0,0)
   self.tmxmap:addTo(self,-1)
end

return _M
