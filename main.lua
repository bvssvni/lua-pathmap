require "groups"

local pathmap = require "pathmap"
local test = require "test-pathmap"

test.run()

-- Set up map.
local map = {
  {3, 5, 5, 6, 1, 6},
  {11, 5, 6, 10, 0, 10},
  {10, 1, 12, 10, 0, 10},
  {9, 15, 5, 13, 5, 12},
  {3, 12},
}

local units = 30
local rect = {x = 1, y = 1, w = 6, h = 5}
local direction = 0
local bufMap
local gr = pathmap.solve(map, rect) -- Generate groups from the map.
local g
local nx, ny

function love.keypressed(key)
  if key == "right" then
    direction = 0
  end
  if key == "down" then
    direction = 1
  end
  if key == "left" then
    direction = 2
  end
  if key == "up" then
    direction = 3
  end
end

function love.update()
  local x, y = love.mouse.getX(), love.mouse.getY()
  if x >= 0 and y >= 0 and x < rect.w * units and y < rect.h * units then
    nx, ny =  math.floor(x/units) + 1, math.floor(y/units) + 1
    bufMap = pathmap.solveCoord(map, nx, ny, rect)
    
    local stride = rect.w
    local coord = (nx-1) + (ny-1) * stride
    g = gr[coord * 4 + 1 + direction]
  else
    nx, ny = nil, nil
    g = nil
  end
end

function drawArrow()
  love.graphics.setColor(255, 255, 255, 255)
  local tx, ty = 50, 200
  local angle = direction * math.pi * 2 / 4
  love.graphics.translate(tx, ty)
  love.graphics.rotate(angle)
  love.graphics.line(0, 0, 40, 0)
  love.graphics.line(40, 0, 30, -10)
  love.graphics.line(40, 0, 30, 10)
  love.graphics.rotate(-angle)
  love.graphics.translate(-tx, -ty)
  
  love.graphics.print("Use keyboard arrows to see which pixels are reachable", 200, 200)
  love.graphics.print("Select pixel to upper left with mouse", 200, 220)
  love.graphics.print("The map to the right tells shortest directions to selected pixel", 200, 240)
  love.graphics.print("Groups are generated as the alternative representation", 200, 260)
end

function love.draw()
  pathmap.draw(map, units)
  
  local tx, ty = 200, 0
  love.graphics.translate(tx, ty)
  if bufMap then
    pathmap.draw(bufMap, units)
  end
  love.graphics.translate(-tx, -ty)
  
  if g then
    local stride = rect.w
    love.graphics.setColor(255, 255, 255, 100)
    for i in group(g, 0) do
      local x, y = i % stride + 1, math.floor(i / stride) + 1
      love.graphics.rectangle("fill", (x - 1) * units, (y - 1) * units, units, units)
    end
  end
  
  if nx and ny then
    love.graphics.setColor(0, 255, 0, 100)
    love.graphics.rectangle("fill", (nx-1) * units, (ny-1) * units, units, units)
  end
  
  drawArrow()
end
