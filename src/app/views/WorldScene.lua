local _M = class("WorldScene",cc.load("mvc").ViewBase)

function _M:onCreate()
	 self:installEvents()
     self.mapRate=16
     self.entities = {};
     self.mapNode = UINode.new()
     self.mapNode:addTo(self)
end

function _M:onAvatarEnterWorld(rndUUID, eid, avatar)
    --角色进入世界，创建角色精灵
    -- self.player = AvatarSprite.new(self, eid, "res/img/3/clotharmor.png");
    self.player=UIImage.new("login/login_main_head_1_1.png")
    self.player:setPosition(avatar.position.x * self.mapRate,avatar.position.z * self.mapRate)
    self.mapNode:addChild(self.player, 10)
    self.playerLastPos = cc.p(self.player:getPosition())
    self:fixMap()

    -- self.player.attr({
    --         x: avatar.position.x * 16,
    --         y: avatar.position.z * 16,
    --         anchorX: 0.5
    --     });
    -- self.mapNode.addChild(this.player, 10);
    --     self.entities[avatar.id] = this.player;
    --     self.playerLastPos = cc.p(this.player.x, this.player.y);
        
    --     self.fixMap();
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
    -- KBEngine.Event.register("set_position", self, "set_position");
    -- KBEngine.Event.register("set_direction", self, "set_direction");
    -- KBEngine.Event.register("updatePosition", self, "updatePosition");
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
          local  ae = UIImage.new("login/login_main_head_1_2.png");
          ae:setPosition(entity.position.x*self.mapRate,entity.position.z*self.mapRate)
          self.mapNode:addChild(ae, 10);
          self.entities[entity.id] = ae;
      end
end

function _M:createScene(resPath)
   self.tmxmap = UIImage.new(resPath)
   self.tmxmap:setAnchorPoint(0,0)
   self.tmxmap:addTo(self,-1)
end

return _M
