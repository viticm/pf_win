--[[
 - PAP Engine ( https://github.com/viticm/plainframework1 )
 - $Id online.lua
 - @link https://github.com/viticm/plainframework1 for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm@126.com/viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm@126.com/viticm.ti@gmail.com>
 - @date 2015/04/30 18:38
 - @uses 在线玩家逻辑，维护玩家在线信息
--]]
module("player_online_t", package.seeall)

-- Mvc ...
require_ex("logic/player/modules/online")
require_ex("logic/player/views/online")
require_ex("logic/player/controllers/online")

-- 新建一个战斗排行榜逻辑系统
function new()
  local player_online = {}
  setmetatable(player_online, {__index = player_online_t})
  player_online:init()
  return player_online
end

-- 数据初始化
function init(self)
  self.moudule_ = player_online_module_t.new()
  self.view_ = player_online_view_t.new()
  self.controller_ = player_online_controller_t.new()
  self.controller_:set_core(self) -- Set core.
end

-- 获得系统ID
function getid(self)
  return kLogicSystemID.player.online;
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
