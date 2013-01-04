--[[

pathmap - Path finding using group oriented programming.
BSD license.
by Sven Nilsen, 2012
http://www.cutoutpro.com

Version: 0.000 in angular degrees version notation
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html

For an NxN map, using group bitstreams increases memory with 4N^2.
The raw data requires one map per pixel, which increases memory N^4.

In raw data, a complete solved 1000x1000 map requires 1 trillion pixels, which doesn't fit inside memory.
A map with 1000x1000 resolution requires only 4 million groups.

Each groups doesn't take a lot of memory since neighbor pixels tend to clump together.
If a row of pixels all belong to the same group, it takes only two numbers to represent that row.

This solver uses pixels with maximum 4 directions.
A group is generated for each direction per pixel that tells "shortest path direction" to other pixels.

Using group oriented programming with group bitstreams makes it possible to store
much larger maps in memory, which makes it suitable for advanced game AI. 

--]]

--[[
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of the FreeBSD Project.
--]]


require "groups"
local pathmap = {}

-- A map consists of a list of lists of numbers.
-- map[y][x]
-- Each intersection is given by a combination of directions.
-- 0 - right
-- 1 - down
-- 4 - left
-- 8 - up

-- Returns a group associated with a location and direction in the solution.
-- solution - A list of groups.
-- x - The x coordinate of the current location.
-- y - The y coordinate of the current location.
-- stride - The maximum number of columns.
-- direction:
--   0 - right
--   1 - down
--   2 - left
--   3 - up
-- off - The index offset for x and y coordinates, 0 for 0 based.
function pathmap.groupInSolution(solution, x, y, stride, direction, off)
  assert(x, "Missing argument 'x'")
  assert(y, "Missing argument 'y'")
  assert(stride, "Missing argument 'stride'")
  assert(off, "Missing argument 'off'")
  
  local coord = (x-off) + (y-off) * stride
  return solution[coord * 4 + 1 + direction]
end

-- Finds the directions of a value.
function pathmap.getDirections(val)
  local up = val % 16 >= 8
  local left = val % 8 >= 4
  local down = val % 4 >= 2
  local right = val % 2 >= 1
  return right, down, left, up
end

function pathmap.getCoord(rows, x, y)
  assert(rows, "Missing argument 'rows'")
  assert(x, "Missing argument 'x'")
  assert(y, "Missing argument 'y'")
  
  if not rows[y] then return 0 end
  
  local val = rows[y][x]
  if not val then return 0 end
  
  return val
end

function pathmap.setCoord(rows, x, y, val)
  assert(rows, "Missing argument 'ros'")
  assert(x, "Missing argument 'x'")
  assert(y, "Missing argument 'y'")
  assert(val, "Missing argument 'va'")
  
  if not rows[y] then
    if val == 0 then return end
    
    rows[y] = {}
  end
  
  rows[y][x] = val
end

-- This method is used when solving shortest directions.
function visit(rows, buf, stack, x, y, rect, direction)
  if x < rect.x or y < rect.y or x > rect.w or y > rect.h then return end
  
  local bufVal = pathmap.getCoord(buf, x, y)
  local val = pathmap.getCoord(rows, x, y)
  
  -- Use a trick to emulate bitwise AND operation.
  local isBuf = bufVal > 0 -- bufVal % (2 * direction) >= direction
  local isVal = val % (2 * direction) >= direction
  
  if isVal and not isBuf then
    -- print(x .. ", " .. y .. ": " .. (bufVal + direction))
    pathmap.setCoord(buf, x, y, bufVal + direction)
    stack[#stack+1] = {x, y}
  end
end

-- Create a new map that got directions to shortest path toward a target.
function pathmap.solveCoord(rows, x, y, rect)
  assert(rows, "Missing argument 'rows'")
  assert(x, "Missing argument 'x'")
  assert(y, "Missing argument 'y'")
  assert(rect, "Missing argument 'rect'")
  
  -- Use a flood filling algorithm.
  local buf = {}
  pathmap.setCoord(buf, x, y, 0)
  
  local stack = {{x, y}}
  
  while #stack > 0 do
    local nxt = 1
    local tx, ty = stack[nxt][1], stack[nxt][2]
    table.remove(stack, nxt)
    
    local rightX, rightY = tx + 1, ty
    local downX, downY = tx, ty + 1
    local leftX, leftY = tx - 1, ty
    local upX, upY = tx, ty - 1
    
    if rightX ~= x or rightY ~= y then visit(rows, buf, stack, rightX, rightY, rect, 4) end
    if downX ~= x or downY ~= y then visit(rows, buf, stack, downX, downY, rect, 8) end
    if leftX ~= x or leftY ~= y then visit(rows, buf, stack, leftX, leftY, rect, 1) end
    if upX ~= x or upY ~= y then visit(rows, buf, stack, upX, upY, rect, 2) end
  end
  
  return buf
end

function addToGroups(bufRows, gr, stride, tx, ty)
  local addr = (tx - 1) + (ty - 1) * stride
  local itemGroup = groups_Item(addr)
  for i, _ in pairs(bufRows) do
    local r = bufRows[i]
    if r then
      for j, _ in pairs(r) do
        local x, y = j, i
        local coord = (x-1) + (y-1) * stride
        local right, down, left, up = pathmap.getDirections(r[j])
        
        if right then
          local g = gr[coord * 4 + 1]
          if not g then g = groups_Empty() end
          
          g = g + itemGroup
          gr[coord * 4 + 1] = g
        end
        if down then
          local g = gr[coord * 4 + 2]
          if not g then g = groups_Empty() end
          
          g = g + itemGroup
          gr[coord * 4 + 2] = g
        end
        if left then
          local g = gr[coord * 4 + 3]
          if not g then g = groups_Empty() end
          
          g = g + itemGroup
          gr[coord * 4 + 3] = g
        end
        if up then
          local g = gr[coord * 4 + 4]
          if not g then g = groups_Empty() end
          
          g = g + itemGroup
          gr[coord * 4 + 4] = g
        end
      end
    end
  end
end

-- Returns a list of groups, 4 for each pixel.
-- The 4 groups tells what targets can be reached per direction.
-- The order of the groups is right, down, left, up.
-- A group uses a the with of rectangle as stride.
function pathmap.solve(rows, rect)
  local gr = {}
  for i, r in pairs(rows) do
    if type(r) == "table" then
      local n = #r
      for j = 1, n do
        local x, y = j, i
        local buf = pathmap.solveCoord(rows, x, y, rect)
        addToGroups(buf, gr, rect.w, x, y)
      end
    end
  end
  
  return gr
end

-- Draw the map.
function pathmap.draw(rows, units)
  assert(rows, "Missing argument 'rows'")
  assert(units, "Missing argument 'units'")
  
  love.graphics.setColor(255, 255, 255, 255)
  local halfUnits = units * 0.5
  for i, _ in pairs(rows) do
    local r = rows[i]
    if r then
      for j, _ in pairs(r) do
        local val = r[j]
        
        if val then
          local x, y = (j - 0.5) * units, (i - 0.5) * units
          local right, down, left, up = pathmap.getDirections(val)
          
          love.graphics.rectangle("line", x - halfUnits, y - halfUnits, units, units)
          
          if right then
            love.graphics.line(x, y, x + halfUnits, y)
          end
          if down then
            love.graphics.line(x, y, x, y + halfUnits)
          end
          if left then
            love.graphics.line(x - halfUnits, y, x, y)
          end
          if up then
            love.graphics.line(x, y - halfUnits, x, y)
          end
        end
      end
    end
  end
end

return pathmap
