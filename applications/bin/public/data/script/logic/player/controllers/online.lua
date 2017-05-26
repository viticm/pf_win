--[[
 - PAP Engine ( https://github.com/viticm/plainframework1 )
 - $Id online.lua
 - @link https://github.com/viticm/plainframework1 for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm@126.com/viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm@126.com/viticm.ti@gmail.com>
 - @date 2015/04/30 18:46
 - @uses 在线玩家逻辑控制器
--]]
module("player_online_controller_t", package.seeall)

-- New
function new()
  local player_online_controller = {}
  setmetatable(player_online_controller, 
               {__index = player_online_controller_t})
  player_online_controller:init()
  return player_online_controller
end

-- Init
function init(self)
  self.core_ = nil
end

-- Set core.
function set_core(self, core)
  self.core_ = core
end

-- Get core
function get_core(self)
  return self.core_
end

-- Event. 0 UI command 1 Database 2 Network
function request(self, type, data)
  if kLogicRequestUICommand == type then
    self:recv_uicommand(data);
  elseif kLogicRequestDB == type then
    self:recv_dbdata(data);
  elseif kLogicRequestNet == type then
    self:recv_netdata(data);
  end
end

-- UI command.
function recv_uicommand(self, data)

end

-- Database data.
function recv_dbdata(self, data)
  -- 只有进入游戏时才会接收到数据库过来的数据，唯一逻辑
  -- 每个子逻辑系统最好是只发出一种逻辑数据库查询，否则自己加上查询参数判断
  local dbdata = data[1]
  local queryname = data[2]
  if not queryname then
    log.slow_error("logic player (online:recv_dbdata) the query name is nil")
    return
  end
  local queryparam = self:get_core():module():getquery(queryname)
  if not queryparam then
    log.slow_error("logic player (online:recv_dbdata) the query is nil")
    return
  end
  local key = queryparam[1]
  local account = queryparam[2]
  local guid = queryparam[3]
  local connectionid = queryparam[4]
  local _connectionid = queryparam[5]
  if not dbdata or 
     0 == table.getsize(dbdata) or
     account ~= data.account or
     guid ~= data.guid then -- 数据库数据异常
     net.send_roleenter(connectionid, 
                        account, 
                        guid, 
                        _connectionid, 
                        nil, 
                        kRoleEnterResultLoadDBError)
  else
    self:get_core():module():add(account, guid, key, dbdata)
    net.send_roleenter(connectionid, 
                       account, 
                       guid, 
                       _connectionid, 
                       dbdata.serverid, 
                       kRoleEnterResultSuccess)
  end
  -- 删除缓存参数，释放内存
  self:get_core():module():removequery(queryname)
end

-- Network data.
function recv_netdata(self, data)
  local type = net.pread_uint8(data.handle);
  if 1 == type then
    self:role_enter(data)
  elseif 2 == type then
    self:role_kick(data)
  end
end

-- 进入游戏逻辑
function role_enter(self, data)
  local account = net.pread_string(data.handle);
  local guid = net.pread_int64(data.handle)
  local connectionid = net.pread_uint16(data.handle)
  local key = net.pread_uint32(data.handle)
  local result = kRoleEnterResultSuccess
  local info = self:get_core():module():get_byguid(guid)
  if info then
    self:broadcast_offline(guid) -- 将在线角色直接踢下线，可以使用全局脚本查询
    net.send_roleenter(data.connectionid, 
                       account, 
                       guid, 
                       connectionid, 
                       info:get_serverid(),
                       result)
  else
    -- 进入数据库查询
    local queryparam = {key, account, guid, data.connectionid, connectionid}
    if self:get_core():module():loaddb(guid, queryparam) ~= kCacheSuccess then
      result = kRoleEnterResultLoadDBError
      net.send_roleenter(
        data.connectionid, account, guid, connectionid, nil, result)
    end
  end
end

-- 踢出玩家逻辑
function role_kick(self, data)
  local account = net.pread_string(data.handle);
  local guid = net.pread_int64(data.handle)
  self:get_core():module():remove(account) -- 从在线列表移除
  self:broadcast_offline(guid)
end

-- 通知下线
function broadcast_offline(self, guid)
  local npack = net.alloc(1, 999) -- 消息通知包
  net.pwrite_int64(guid)
  net.pwrite_int32(1) -- 通知玩家下线
  net.broadcast_server(npack)
end

-- 检查角色是否通过
function role_check(self, guid, key)
  local player = self:get_core():module():get_byguid(guid)
  if not player then return false end
  local result = player:getkey() == key
  return result
end

-- More self functions.
-- ....
