--[[
 - PAP Engine ( https://github.com/viticm/plainframework1 )
 - $Id core.lua
 - @link https://github.com/viticm/plainframework1 for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm@126.com/viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm@126.com/viticm.ti@gmail.com>
 - @date 2015/04/30 18:39
 - @uses 中心服务器玩家逻辑
--]]
module("logic_player_t", package.seeall)

require_ex("logic/player/online")

-- 创建一个新的排行榜系统
function new()
  local logic_player = {}
  setmetatable(logic_player, {__index = logic_player_t})
  logic_player:init()
  return logic_player
end

-- 数据初始化
function init(self)
  self.config_ = {
    tablename = "player", -- 数据库表或系统名
    data_default = {}, -- 默认的数据，结果为空也会改为默认数据
  }
  self.status_ = kLogicStatusLoading 
  self.data_ = self.config_.data_default -- 自身的数据，字段需和数据库表对应
  self.event_list_ = {}
  self:init_logics()
end

-- 设置状态
function setstatus(self, status)
  self.status_ = status
end

-- 获得状态
function getstatus(self)
  return self.status_
end

-- 获得逻辑系统ID
function getid(self)
  return kLogicSystemID.player.main
end

-- 子系统初始化
function init_logics(self)
  self.logic_list_ = {} --子系统列表
  self:register(player_online_t.new()) -- 在线玩家
end

-- 注册子系统
function register(self, table)
  self.logic_list_[table:getid()] = table
end

-- 撤销注册子系统
function unregister(self, id)
  self.logic_list_[id] = nil
end

-- 获得一个子系统
function get(self, id)
  return self.logic_list_[id]
end

-- 数据加载，该部分考虑通用模板，默认加载全部数据，如果有条件的，加上条件即可
function dataload(self)
  if kLogicStatusLoading == self.status_ then
    self.status_ = kLogicStatusReady
    return self.status_
  end
  return self.status_
end

-- UI handle
function ui_handle(self, data)
  local systemid = data.id or 0
  local logic = get(systemid)
  if logic then
    logic:controller():request(kLogicRequestUICommand, data)
  end
end

-- 数据库返回数据处理方法
function db_handle(self, data)
  -- 遍历所有子系统
  for _, logic in pairs(self.logic_list_) do
    logic:controller():request(kLogicRequestDB, data)
  end
end

-- 网络数据处理方法
function net_handle(self, data)
  local systemid = net.pread_uint16(data.handle)
  local logic_system = get(systemid)
  if logic_system then 
    logic_system:request(kLogicRequestNet, data)
  end
end

-- 注册事件
function register_event(self, id, func, param)
  if not id or not func then return end
  local event = {func, param}
  if not self.event_list_[id] then
    self.event_list_[id] = {}
  end
  table_insert(self.event_list_[id], event)
end

-- 移除事件
function remove_event(self, id)
  self.event_list_[id] = nil
end

-- 获取事件
function get_event(self, id)
  return self.event_list_[id]
end
