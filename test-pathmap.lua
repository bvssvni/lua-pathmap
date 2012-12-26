local pathmap = require "pathmap"
local test = {}

function test1()
  local map = {
    {1, 1+4, 4},  
  }
  local rect = {x = 1, y = 1, w = 3, h = 1}
  local buf = pathmap.solveCoord(map, 2, 1, rect)
  
  local val = pathmap.getCoord(buf, 1, 1)
  local right, down, left, up = pathmap.getDirections(val)
  assert(right)
  
  val = pathmap.getCoord(buf, 3, 1)
  right, down, left, up = pathmap.getDirections(val)
  assert(left)
end

function test2()
  local map = {
    {2},
    {2+8}, 
    {8},  
  }
  local rect = {x = 1, y = 1, w = 1, h = 3}
  local buf = pathmap.solveCoord(map, 1, 2, rect)
  
  local val = pathmap.getCoord(buf, 1, 1)
  local right, down, left, up = pathmap.getDirections(val)
  assert(down)
  
  val = pathmap.getCoord(buf, 1, 3)
  right, down, left, up = pathmap.getDirections(val)
  assert(up)
end

function test3()
  local map = {
    {0, 2, 0},
    {1, 15, 4},
    {0, 8, 0},
  }
  local rect = {x = 1, y = 1, w = 3, h = 3}
  local buf = pathmap.solveCoord(map, 2, 2, rect)
  assert(pathmap.getCoord(buf, 1, 1) == 0)
  assert(pathmap.getCoord(buf, 2, 1) == 2)
  assert(pathmap.getCoord(buf, 3, 1) == 0)
  assert(pathmap.getCoord(buf, 1, 2) == 1)
  assert(pathmap.getCoord(buf, 2, 2) == 0)
  assert(pathmap.getCoord(buf, 3, 2) == 4)
  assert(pathmap.getCoord(buf, 1, 3) == 0)
  assert(pathmap.getCoord(buf, 2, 3) == 8)
  assert(pathmap.getCoord(buf, 3, 3) == 0)
end

function test4()
  local map = {
    {3, 5, 6},
    {10, 0, 10},
    {9, 5, 13},
  }
  local rect = {x = 1, y = 1, w = 3, h = 3}
  local buf = pathmap.solveCoord(map, 1, 1, rect)
  assert(pathmap.getCoord(buf, 1, 1) == 0)
  assert(pathmap.getCoord(buf, 2, 1) == 4)
  assert(pathmap.getCoord(buf, 3, 1) == 4)
  assert(pathmap.getCoord(buf, 1, 2) == 8)
  assert(pathmap.getCoord(buf, 2, 2) == 0)
  assert(pathmap.getCoord(buf, 3, 2) == 8)
  assert(pathmap.getCoord(buf, 1, 3) == 8)
  assert(pathmap.getCoord(buf, 2, 3) == 4)
  assert(pathmap.getCoord(buf, 3, 3) == 8)
end

function test5()
  local map = {
    {3, 5, 5, 6},
    {10, 0, 0, 10},
    {10, 0, 0, 10},
    {9, 5, 5, 12},
  }
  local rect = {x = 1, y = 1, w = 4, h = 4}
  local buf = pathmap.solveCoord(map, 1, 1, rect)
  assert(pathmap.getCoord(buf, 1, 1) == 0)
  assert(pathmap.getCoord(buf, 2, 1) == 4)
  assert(pathmap.getCoord(buf, 3, 1) == 4)
  assert(pathmap.getCoord(buf, 4, 1) == 4)
  assert(pathmap.getCoord(buf, 1, 2) == 8)
  assert(pathmap.getCoord(buf, 2, 2) == 0)
  assert(pathmap.getCoord(buf, 3, 2) == 0)
  assert(pathmap.getCoord(buf, 4, 2) == 8)
  assert(pathmap.getCoord(buf, 1, 3) == 8)
  assert(pathmap.getCoord(buf, 2, 3) == 0)
  assert(pathmap.getCoord(buf, 3, 3) == 0)
  assert(pathmap.getCoord(buf, 4, 3) == 8)
  assert(pathmap.getCoord(buf, 1, 4) == 8)
  assert(pathmap.getCoord(buf, 2, 4) == 4)
  assert(pathmap.getCoord(buf, 3, 4) == 4)
  assert(pathmap.getCoord(buf, 4, 4) == 8)
end

function test_solve_1()
  local map = {
    {0, 2, 0},
    {1, 15, 4},
    {0, 8, 0},
  }
  local rect = {x = 1, y = 1, w = 3, h = 3}
  local gr = pathmap.solve(map, rect)
  
  --[[
  for i, _ in pairs(gr) do
    local g = gr[i]
    print(i .. ": " .. table.concat(g, ", "))
  end
  --]]
  
end

function test.run()
  test1()
  test2()
  test3()
  test4()
  test5()
  test_solve_1()
end

return test

