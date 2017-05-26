--[[
-- @desc 战斗排行榜，模块，主要负责数据
-- @author viticm
-- @date 2015-4-22 16:01:20
--]] 
module("toplist_combat_module_t", package.seeall)

-- New
function new()
  local toplist_combat_module = {}
  setmetatable(toplist_combat_module, {__index = toplist_combat_module_t})
  toplist_combat_module:init()
  return toplist_combat_module
end

-- Init
function init(self)

end
