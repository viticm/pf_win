--[[
 - PAP Engine ( https://github.com/viticm/plainframework1 )
 - $Id system.lua
 - @link https://github.com/viticm/plainframework1 for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm@126.com/viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm@126.com/viticm.ti@gmail.com>
 - @date 2015/04/23 11:56
 - @uses 辑系统中心，分派逻辑系统数据，注册逻辑系统
--]]
module("logic_system_t", package.seeall)

local table_insert = table.insert
local table_remove = table.remove

--  创建一个新的逻辑系统中心
function new()
  local logic_system = {}
  setmetatable(logic_system, {__index = logic_system_t})
  logic_system:init()
  return logic_system
end

--  初始化
function init(self)
  self.logic_list_ = {} -- 逻辑系统
  self.event_list_ = {} -- 事件列表
  self.query_list_ = {} -- 数据查询列表
  self.status_ = kLogicStatusLoading
  self.name_ = "unknown"
end

--  根据逻辑系统ID和对应的logic注册
function register(self, logic)
  self.logic_list_[logic:getid()] = logic
end

--  撤销注册
function unregister(self, id)
  if self.logic_list_[id] then
    self.logic_list_[id] = nil
  end
end

--  获得逻辑系统
function get(self, id)
  return self.logic_list_[id]
end

-- 获得系统状态
function getstatus(self)
  return self.status_
end

-- 设置系统状态
function setstatus(self, status)
  self.status_ = status
end

--  系统心跳，一般做定时器和加载数据用
function heartbeat(self)

  local result = true -- 返回，一般给C++用，有的心跳如果错误将是致命的

  -- 数据加载
  if kLogicStatusLoading == self.status_ then
    local ready = true
    for _, logic in pairs(self.logic_list_) do
        local code = logic:dataload()
        if kLogicStatusLoadError == code or 
           kLogicStatusLoadTimeOut == code then
           result = false
           ready = false
          break
        end
        if kLogicStatusLoading == code then
          ready = false
        end
    end
    if ready then self.status_ = kLogicStatusReady end
    if kLogicStatusReady == self.status_ then -- 第一次数据加载成功
      -- Event list.
      local event_list = self.event_list_[kLogicEventID.ready]
      if event_list then
        for _, event in ipairs(event_list) do
          local func = event[1]
          local param = event[2]
          func(param)
        end
      end
      log.fast_debug("-- %s -- logic system first ready!!!", self.name_)
    end
  end

  -- 定时器或其他
  if kLogicStatusReady == self.status_ then
    for _, logic in pairs(self.logic_list_) do
      if logic.save then
        logic:save()
      end
    end
  end

  -- 查询监听
  for index, query in ipairs(self.query_list_) do
    local logic = self:get(query.id)
    local result, data = cache.get(query.name)
    if kCacheSuccess == result then
      if query.subid ~= -1 then
        local _data = {data, query.name}
        logic:get(query.subid):controller():recv_dbdata(_data);
      else
        logic:db_handle(data)
      end
    end
    
    -- 监听移除
    local timecost = os.time() - query.time
    if result ~= kCacheWaiting or timecost >= 10 then
      table_remove(self.query_list_, index)
    end
  end
  return result
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

-- 注册查询监听
function register_query(self, id, subid, name)
  if not id or not subid or not name then return end
  local query = {}
  query.id = id
  query.subid = subid
  query.name = name
  query.time = os.time()
  table_insert(self.query_list_, query)
end

-- 设置名称
function setname(self, name)
  self.name_ = name
end
