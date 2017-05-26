--[[
-- @desc 战斗排行榜，视图管理器
-- @author viticm
-- @date 2015-4-22 16:01:20
--]] 
module("toplist_combat_view_t", package.seeall)

-- New
function new()
  local toplist_combat_view = {}
  setmetatable(toplist_combat_view, {__index = toplist_combat_view_t})
  toplist_combat_view:init()
  return toplist_combat_view
end

-- Init
function init(self)

end
