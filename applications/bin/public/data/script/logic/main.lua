--[[
 - PAP Engine ( https://github.com/viticm/plainframework1 )
 - $Id main.lua
 - @link https://github.com/viticm/plainframework1 for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm@126.com/viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm@126.com/viticm.ti@gmail.com>
 - @date 2015/04/23 11:47
 - @uses 逻辑系统全局方法定义
--]]

require_ex("logic/player/core")
require_ex("logic/toplist/core")

-- 处理DB数据
function logic_system_handle_db()
end

-- 处理网络数据
function logic_system_handle_net()

end

-- 注册全局逻辑系统
function register_global_logic_systems()
  g_logic_system = logic_system_t.new()
  g_logic_system:setname("global")
  g_logic_system:register(logic_toplist_t.new()) -- 排行榜系统
  g_logic_system:register(logic_player_t.new()) -- 玩家系统
end

-- 服务器发送过来的角色检查
function server_rolecheck(guid, key)
  local player = g_logic_system:get(kLogicSystemID.player.main)
  local online = player:get(kLogicSystemID.player.online)
  local result = online:controller():role_check(guid, key)
  return result
end
