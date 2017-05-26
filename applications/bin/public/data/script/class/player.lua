--[[
 - PAP Engine ( https://github.com/viticm/plainframework1 )
 - $Id player.lua
 - @link https://github.com/viticm/plainframework1 for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm@126.com/viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm@126.com/viticm.ti@gmail.com>
 - @date 2015/04/30 18:20
 - @uses player class
 -       cn: 中心服务器玩家基础信息
--]]
module("player_t", package.seeall)

-- 新建
function new()
  local player = {}
  setmetatable(player, {__index = player_t})
  player:init()
  return player
end

-- 初始化
function init(self)
  self.key_ = nil
  self.data_ = {} -- 数据库查询的数据
end

-- 获得账号名
function getaccount(self)
  return self.data_.account
end

-- 设置安全key
function setkey(self, key)
  self.key_ = key
end

-- 获得安全key
function getkey(self)
  return self.key_
end

-- 获得guid
function getguid(self)
  return self.data_.guid
end

-- 获得服务器ID
function get_serverid(self)
  return self.data_.serverid
end
