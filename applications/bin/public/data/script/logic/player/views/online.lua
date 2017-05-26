--[[
 - PAP Engine ( https://github.com/viticm/plainframework1 )
 - $Id online.lua
 - @link https://github.com/viticm/plainframework1 for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm@126.com/viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm@126.com/viticm.ti@gmail.com>
 - @date 2015/04/30 18:47
 - @uses 在线玩家视图控制器
--]]
module("player_online_view_t", package.seeall)

-- New
function new()
  local player_online_view = {}
  setmetatable(player_online_view, {__index = player_online_view_t})
  player_online_view:init()
  return player_online_view
end

-- Init
function init(self)

end
