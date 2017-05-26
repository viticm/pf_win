--[[
 - PLAIN FRAMEWORK ( https://github.com/viticm/plainframework )
 - $Id dcache.lua
 - @link https://github.com/viticm/plainframework for the canonical source repository
 - @copyright Copyright (c) 2014- viticm( viticm.ti@gmail.com )
 - @license
 - @user viticm<viticm.ti@gmail.com>
 - @date 2017/05/05 20:26
 - @uses For test dcache.
 -       2017-05-25 dcache_tests 1000000 
					on AMD Athlon(tm) II X2 215 Processor(centos 7)
                    used 179 seconds, lua print(1-1000000) used 113 seconds.
					
					--> Windows has some capability problem, will fix in next version.
					dcache_tests 10000
					on Intel(R) Core(TM) i7-4790K CPU @ 4.00GHz(windows) use 69 seconds
--]]

local test_times = 10000

-- Test for dcache set.
function dcache_settest()
  for i = 1, test_times do
    local r, cache = dcache.get("t_user", i)
    if kCacheInvalid == r then
      dcache.set("t_user", i, "select * from t_user")
      dcache.setstatus("t_user", i, kQuerySelect)
    end
  end
end

-- Test for dcache query.
function dcache_querytest()
  for i = 1, test_times do
    local r, cache = dcache.get("t_user", i)
    if kCacheSuccess == r then
      --print(cache)
      dcache.query("t_user", i)
    end
  end
end

-- Test for get tables.
function dcache_tables()
  for i = 1, test_times do
    local r, cache = dcache.gettable("t_user", i)
    if kCacheSuccess == r then
      print("-----------------------------------------", i)
      print(dump(cache))
    end
  end
end

-- Test for forget.
function dcache_forget()
  for i = 1, test_times do
    local r, cache = dcache.forget("t_user", i)
    if kCacheSuccess == r then
      --print(dump(cache))
    end
  end
end


-- All dcache test.
function dcache_tests()
  local start_time = os.time()
  print("set test ......")
  dcache_settest()
  print("tables ......")
  dcache_tables()
  print("query test ......")
  dcache_querytest()
  print("forget ......")
  dcache_forget()
  log.fast_debug("dcache_tests time: %d", os.time() - start_time)
end
