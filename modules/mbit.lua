--[[
  Made by Fatboychummy
  implementation of bitty bois
]]

local bit = require("modules.bit")
local funcs = {}


local dis = "For application security reasons, this operation is disabled."
local function secureDisable()
  error(dis, 2)
end

-- create a new bit table
function funcs.new(sz)
  -- the returned object
  local tmp = {
    overflowbit = false,
    bits = {}
  }

  -- make sure right types
  if type(sz) == "table" then
    if type(sz["bits"]) == "table" then
      for i = 1, #sz.bits do
        tmp.bits[i] = sz.bits[i]
      end
    else
      error("Bad argument #1: Expected number or bittable, got "
            .. type(sz) .. ".", 2)
    end
  elseif type(sz) == "number" then
    for i = 1, sz do
      tmp.bits[i] = false
    end
  elseif type(sz) ~= "number" then
    error("Bad argument #1: Expected number or bittable, got "
          .. type(sz) .. ".", 2)
  end

  -- ############ Arithmetic functions ############ --

  -- add two bit tables
  function tmp:add(b)
    -- full carry adder implementation, returns the sum and carry bit
    local function add(a, b, c)
      local xor1 = bit.xor(a, b)
      local sum = bit.xor(xor1, c)
      local a1 = bit.band(xor1, c)
      local a2 = bit.band(a, b)
      local carryout = bit.bor(a1, a2)
      return sum, carryout
    end

    -- ripple-carry adder
    local s = false
    local carry = false
    for i = #self.bits, 1, -1 do
      s, carry = add(self.bits[i], b.bits[i], carry)
      self.bits[i] = s
    end

    -- if the carry bit is set at the end of addition, we've overflowed.
    if carry then
      self.overflowbit = true
    end

    return self
  end

  -- negate then add
  function tmp:sub(b)
    local b2 = funcs.new(b):twocomp()
    return self:add(b2)
  end

  -- calculate the two's complement.
  function tmp:twocomp()
    -- invert every bit
    self:bnot()

    -- add one
    local add1 = funcs.new(#self.bits)
    add1:set(1)
    self:add(add1)

    return self
  end

  function tmp:mult(b)
    --TODO: non-temporary implementation
    local a = self:int()
    local b2 = b:int()
    self:set(a * b2)

    return self
  end

  -- return int div AND mod
  function tmp:div(b)
    --TODO: non-temporary implementation
    local a = self:int()
    local b2 = b:int()
    self:set(math.floor(a / b2))

    local tmp = funcs.new(#self.bits)
    tmp:set(a % b2)

    return self, tmp
  end


  -- ############ etc functions ############ --

  --[[
    if a is positive, b is nil:
      cut starting from position a until end
    if a is positive, b is positive:
      cut starting from position a until b
    if a is negative, b is nil:
      cut from start, until (end + a)
    else:
      error
  ]]
  function tmp:cut(a, b)

  end

  -- set a bit in the bit table
  function tmp:set(i)
    if type(i) == "number" then
      -- assume number is int or float
      -- float unsupported atm so assume int
      local flip = false
      if i < 0 then
        flip = true
      end
      i = math.abs(i)

      local k = 1
      for j = #self.bits - 1, 0, -1 do
        local pw = math.pow(2, j)
        if i - pw >= 0 then
          i = i - pw
          self.bits[k] = true
        else
          self.bits[k] = false
        end

        k = k + 1
      end
      if flip then
        self:twocomp()
      end
    else
      -- error
      error("Yeah you did something wrong here", 2)
    end

    return self
  end

  function tmp:size()
    return #self.bits
  end

  -- ############ Logical Functions ############ --

  -- left-shift by c positions
  function tmp:lshift(c)
    c = c or 1

    -- copy bits left c positions
    for i = c, #self.bits do
      self.bits[i - c + 1] = self.bits[i]
    end

    return self
  end

  -- right-shift by c positions
  function tmp:logrshift(c)
    c = c or 1

    -- copy bits right c positions
    for i = 1, #self.bits - c do
      self.bits[i + c] = self.bits[i]
    end

    return self
  end

  function tmp:arithrshift(c)
    c = c or 1

    -- conserve sign bit
    for i = 1, c do
      self.bits[i] = self.bits[1]
    end

    -- copy bits right c positions
    for i = 1, #self.bits - c do
      self.bits[i + c] = self.bits[i]
    end

    return self
  end

  function tmp:bor(b)
    for i = 1, #self.bits do
      self.bits[i] = bit.bor(self.bits[i], b[i])
    end

    return self
  end

  function tmp:band(b)
    for i = 1, #self.bits do
      self.bits[i] = bit.band(self.bits[i], b[i])
    end

    return self
  end

  function tmp:xor(b)
    for i = 1, #self.bits do
      self.bits[i] = bit.xor(self.bits[i], b[i])
    end

    return self
  end

  function tmp:nor(b)
    for i = 1, #self.bits do
      self.bits[i] = bit.nor(self.bits[i], b[i])
    end

    return tm
  end

  function tmp:nand(b)
    for i = 1, #self.bits do
      self.bits[i] = bit.nand(self.bits[i], b[i])
    end

    return self
  end

  function tmp:nxor(b)
    for i = 1, #self.bits do
      self.bits[i] = bit.nxor(self.bits[i], b[i])
    end

    return self
  end

  -- negate every bit
  function tmp:bnot()
    for i = 1, #self.bits do
      self.bits[i] = not self.bits[i]
    end

    return self -- chaincalls
  end

  -- ############ Conversion Functions ############ --

  -- conversion to unsigned integer
  function tmp:uint()
    local sum = 0
    local j = 1

    -- iterate through numbers and add to sum
    for i = #self.bits, 1, -1 do
      if self.bits[i] then
        sum = sum + j
      end
      j = j * 2
    end

    return sum
  end

  -- conversion to signed integer
  function tmp:int()
    local sum = 0
    local j = 1

    if self.bits[1] then
      -- negative
      for i = #self.bits, 2, -1 do
        if not self.bits[i] then
          sum = sum + j
        end
        j = j * 2
      end
      sum = -(sum + 1)
    else
      -- positive
      for i = #self.bits, 2, -1 do
        if self.bits[i] then
          sum = sum + j
        end
        j = j * 2
      end
    end

    return sum
  end

  -- conversion to float value
  function tmp:float()
    error("Float values are unsupported at the moment.", 2)
    -- TODO: PICK float standard
    -- TODO: Figure out how float shit works
    -- TODO: float arithmetic
  end

  -- convert to char
  function tmp:char()
    return string.char(self:uint())
  end

  -- returns a string of bits
  function tmp:bstr()
    local str = ""
    for i = 1, #self.bits do
      str = str .. (self.bits[i] and '1' or '0')
    end
    return str
  end

  -- metatable
  local mta = {
    __type = "bit",
    __metatable = function(ps)
      if ps == 15 then
        return mta
      else
        secureDisable()
      end
    end,
    __newindex = secureDisable,
    __add = tmp.add,
    __sub = tmp.sub
  }

  tmp = setmetatable(tmp, mta)

  return tmp
end

function funcs.read(str, len)
  if type(str) ~= "string" then
    error("Invalid argument #1: expected string, got "
          .. type(str) .. ".", 2)
  end
  if type(len) ~= "nil" and type(len) ~= "number" then
    error("Invalid argument #2: expected number or nil, got "
          .. type(len) .. ".", 2)
  end

  len = len or 4 -- assume reading a byte unless otherwise stated

  local bittybois = {}

  local current = {}
  local i = 0
  for char in str:gmatch(".") do
    if i % len == 0 and i ~= 0 then
      bittybois[#bittybois + 1] = {}
      bittybois[#bittybois].bits = current
      current = {}
    end

    if char ~= "1" and char ~= "0" then
      error("Error in input at character " .. tostring(i + 1)
            .. ": " .. char .. " is not '1' or '0'.", 2)
    end

    local out
    if char == '1' then
      out = true
    else
      out = false
    end

    current[#current + 1] = out
    i = i + 1
  end
  bittybois[#bittybois + 1] = {}
  bittybois[#bittybois].bits = current

  if i % len ~= 0 then
    error("Error in input: Length is not divisible by " .. tostring(len) .. ".",
          2)
  end

  local out = {}
  for i = 1, #bittybois do
    out[i] = funcs.new(bittybois[i])
  end

  return out
end

return funcs
