--[[
 - PAP Engine ( https://github.com/viticm/plainframework1 )
 - $Id online.lua
 - @link https://github.com/viticm/plainframework1 for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm@126.com/viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm@126.com/viticm.ti@gmail.com>
 - @date 2015/04/30 18:46
 - @uses 在线玩家逻辑模块
--]]
module("player_online_module_t", package.seeall)

require_ex("class/player")

-- New
function new()
  local player_online_module = {}
  setmetatable(player_online_module, {__index = player_online_module_t})
  player_online_module:init()
  return player_online_module
end

-- Init
function init(self)
  self.account_list_ = {}
  self.guid_list_ = {}
  self.query_list_ = {} -- 正在查询的列表，存储的是当前的查询参数
end

-- Add player to list.
function add(self, account, guid, key, data)
  local player = player_t.new()
  player:setaccount(account)
  player:setguid(guid)
  player:setkey(key);
  self.account_list_[account] = player
  self.guid_list_[guid] = player
end

-- Get player by account.
function get_byaccount(self, account)
  return self.account_list_[account]
end

-- Get player by guid.
function get_byguid(self, guid)
  return self.guid_list_[guid]
end

-- Remove player.
function remove(self, account)
  local guid = self:get_byaccount(account):getaccount()
  self.account_list_[account] = nil
  self.guid_list_[guid] = nil
end

-- Load data form db.
function loaddb(self, guid, param)
    local tablename = "t_role"
    local column = {"account", "name", "guid", "serverid"}
    local key = tostring(guid)
    local condition = string.format("account = %d", guid)
    local result = cache.select(tablename, column, condition, key)
    local name = string.format("%s\t%s", tablename, key)
    self:addquery(name, param)
    return result
end

-- 增加查询参数
function addquery(self, id, param)
  if not id then return end
  self.query_list_[id] = param
end

-- 获取查询参数
function getquery(self, guid)
  return self.query_list_[guid]
end

-- 移除查询参数
function removequery(self, guid)
  if not guid then return end
  self.guid_list_[guid] = nil
end
