--[[
-- @desc 战斗排行榜，处理战斗排行榜
-- @author viticm
-- @date 2015-4-22 16:01:20
--]] 
module("toplist_combat_t", package.seeall)

-- Mvc ...
require_ex("logic/toplist/modules/combat")
require_ex("logic/toplist/views/combat")
require_ex("logic/toplist/controllers/combat")

-- 新建一个战斗排行榜逻辑系统
function new()
  local toplist_combat = {}
  setmetatable(toplist_combat, {__index = toplist_combat_t})
  toplist_combat:init()
  return toplist_combat
end

-- 数据初始化
function init(self)
  self.moudule_ = toplist_combat_module_t.new()
  self.view_ = toplist_combat_view_t.new()
  self.controller_ = toplist_combat_controller_t.new()
  self.controller_:set_core(self) -- Set core.
end

-- 获得系统ID
function getid(self)
  return kLogicSystemID.toplist.combat;
end

-- 获得模块对象
function module(self)
  return self.moudule_
end

-- 获得视图对象
function view(self)
  return self.view_
end

-- 获得控制器对象
function controller(self)
  return self.controller_
end
