--[[
-- @desc 排行榜逻辑核心，负责全局排行榜所有系统
-- @author viticm
-- @date 2015-4-22 16:01:20
--]] 
module("logic_toplist_t", package.seeall)

require_ex("logic/toplist/combat")

-- @desc 创建一个新的排行榜系统
function new()
  local logic_toplist = {}
  setmetatable(logic_toplist, {__index = logic_toplist_t})
  logic_toplist:init()
  return logic_toplist
end

-- @desc 数据初始化
function init(self)
  self.config_ = {
    tablename = "toplist", -- 数据库表名，如果是客户端，此值可以表示系统名
    tablename_prefix = "t_", -- 数据库表名前缀
    dbload = true, -- 是否需要加载数据库数据，需要自身有相应的方法支持
    dbinit = false, -- 在数据库查询结果为空的时候是否需要初始化数据，需要相应方法支持
    data_default = {}, -- 默认的数据，结果为空也会改为默认数据
    waittime = 10, -- 查询等待时间
  }
  self.load_starttime_ = nil -- 数据开始加载时间
  self.status_ = kLogicStatusLoading 
  self.data_ = self.config_.data_default -- 自身的数据，字段需和数据库表对应
  self.dataupdate_ = false -- 数据是否已更新，更新了后自动保存
  self:init_logics()
  self.event_list_ = {}
end

-- 设置状态
function setstatus(self, status)
  self.status_ = status
end

-- 获得状态
function getstatus(self)
  return self.status_
end

-- @desc 获得逻辑系统ID
function getid(self)
  return kLogicSystemID.toplist.main
end

-- @desc 子系统初始化
function init_logics(self)
  self.logic_list_ = {} --子系统列表
  self:register(toplist_combat_t.new()) -- 战斗排行榜
end

-- @desc 注册子系统
function register(self, table)
  self.logic_list_[table:getid()] = table
end

-- @desc 撤销注册子系统
function unregister(self, id)
  self.logic_list_[id] = nil
end

-- 获得一个子系统
function get(self, id)
  return self.logic_list_[id]
end

-- 数据加载，该部分考虑通用模板，默认加载全部数据，如果有条件的，加上条件即可
function dataload(self)
  if self.status_ ~= kLogicStatusLoading then
    return self.status_
  end
  local tablename = self.config_.tablename
  local tablename_prefix = self.config_.tablename_prefix or ""
  local real_tablename = tablename_prefix..tablename -- Fix to db table.
  local result = kCacheSuccess

  -- Data check.
  result, self.data_ = cache.get(real_tablename)
  if kCacheError == result then
    self.status_ = kLogicStatusLoadError
    log.fast_error("logic system %s data load have error 3", tablename)
    return self.status_
  end
  if kCacheSuccess == result then
    log.fast_debug("logic system %s data load success", tablename)
    self.status_ = kLogicStatusReady
    log.fast_debug("name: %s, combat: %d", self.data_.name, self.data_.combat)
    if not self.data_ then
      self.data_ = self.config_.data_default
    end
    return self.status_
  end

  if not self.load_starttime_ then 
    log.fast_debug("logic system %s data load start", tablename)
    self.load_starttime_ = os.time()
    if self.config_.dbload then
      result, self.data_ = cache.get(real_tablename)
      if kCacheInvalid == result then
        result = cache.put(real_tablename)
      end
      if kCacheError == result then
        log.fast_error("logic system %s data load have error 1", tablename)
        self.status_ = kLogicStatusLoadError
        return self.status_
      end
      result = cache.select(real_tablename)
      if kCacheError == result then
        log.fast_error("logic system %s data load have error 2", tablename)
        self.status_ = kLogicStatusLoadError
        return self.status_
      end
    end
  end
  
  local waittime = self.config_.waittime or 10
  local cur_time = os.time()
  local difftime = cur_time - self.load_starttime_
  if difftime > waittime then
    log.fast_error("logic system %s data load time out", tablename)
    self.status_ = kLogicStatusLoadTimeOut
  end
  return self.status_
end

-- 数据保存方法，定时调用，如果没有此方法，将不进行任何操作
function save(self)
  if not self.dataupdate_ then return end -- Not alive.
  local tablename = self.config_.tablename
  local tablename_prefix = self.config_.tablename_prefix
  local real_tablename = tablename_prefix..tablename
  if self.dataupdate_ then
    log.fast_debug("logic system %s data save start", tablename)
    cache.save(real_tablename, self.data_)
  end
  local result = cache.get(real_tablename)
  if kCacheSuccess == result then 
    log.fast_debug("logic system %s data save end", tablename)
    self.dataupdate_ = false 
  end
  if kCacheError == result then
    log.fast_debug("logic system %s data save error 1", tablename)
    self.dataupdate_ = false 
  end
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
