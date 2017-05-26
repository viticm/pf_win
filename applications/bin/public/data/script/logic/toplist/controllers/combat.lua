--[[
-- @desc 战斗排行榜，控制器，调度视图和模块
-- @author viticm
-- @date 2015-4-22 16:01:20
--]] 
module("toplist_combat_controller_t", package.seeall)

-- New
function new()
  local toplist_combat_controller = {}
  setmetatable(toplist_combat_controller, 
               {__index = toplist_combat_controller_t})
  toplist_combat_controller:init()
  return toplist_combat_controller
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

end

-- Network data.
function recv_netdata(self, data)

end

-- More self functions.
-- ....
