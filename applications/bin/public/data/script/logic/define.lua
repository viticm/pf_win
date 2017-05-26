--[[
 - PAP Engine ( https://github.com/viticm/plainframework1 )
 - $Id define.lua
 - @link https://github.com/viticm/plainframework1 for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm@126.com/viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm@126.com/viticm.ti@gmail.com>
 - @date 2015/04/23 11:47
 - @uses 逻辑系统全局定义，状态、接收数据类型由C++定义
--]]

-- * 逻辑系统定义开始 * --

kLogicSystemID = {

  player = {
    main = 1,
    online = 1,
  }, -- 玩家系统

  toplist = {
    main = 10, -- 系统ID
    combat = 1, -- 子 战斗系统
  }, -- 排行榜系统

} -- ID定义

kLogicEventID = {

  ready = 1, -- 系统准备完毕事件

} -- 逻辑事件ID定义

-- * 逻辑系统定义结束 * --
