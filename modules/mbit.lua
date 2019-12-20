--[[
  Made by Fatboychummy
  implementation of bitty bois
]]

local bit = require("modules.bit")
local funcs = {}
local mat = {}


local dis = "For application security reasons, this operation is disabled."
local function secureDisable()
  error(dis, 2)
end

-- create a new bit table
function funcs.new(sz)
  -- make sure right types
  if type(sz) == "table" then
    local c = getmetatable(sz)
    if c and c["__type"] == "bit" then
      sz = c.bits
    else
      error("Bad argument #1: Expected number or bittable, got "
            .. type(sz) .. ".", 2)
    end
  elseif type(sz) ~= "number" then
    error("Bad argument #1: Expected number or bittable, got "
          .. type(sz) .. ".", 2)
  end

  -- bit table
  local bits = {}

  -- the returned object
  local tmp = {}

  -- ############ Arithmetic functions ############ --

  -- add two bit tables
  function tmp:add(b)
    local tm = funcs.new(#bits)

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
    for i = #bits, 1, -1 do
      s, carry = add(bits[i], b[i], carry)
      tm:set(i, s)
    end

    -- if the carry bit is set at the end of addition, we've overflowed.
    if carry then
      tm.overflowbit = true
    end

    return tm
  end

  -- negate then add
  function tmp:sub(b)
    local b2 = b:twocomp()
    return self:add(self, b2)
  end

  -- calculate the two's complement.
  function tmp:twocomp()
    local tm = funcs.new(#bits)

    -- invert every bit
    tm = tm:bnot()

    -- add one
    local add1 = funcs.new(#bits):set(#bits, true)
    tm = tm:add(add1)

    return tm
  end

  function tmp:mult(b)

  end

  -- return int div AND mod
  function tmp:div(b)

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
  function tmp:set(i, x)
    bits[i] = x
  end

  function tmp:size()
    return #bits
  end

  -- ############ Logical Functions ############ --

  -- left-shift by c positions
  function tmp:lshift(c)
    c = c or 1
    local tm = funcs.new(#bits)

    -- copy bits left c positions
    for i = c, #bits do
      tm:set(i - c + 1, bits[i])
    end

    return tm
  end

  -- right-shift by c positions
  function tmp:logrshift(c)
    c = c or 1
    local tm = funcs.new(#bits)

    -- copy bits right c positions
    for i = 1, #bits - c do
      tm:set(i + c, bits[i])
    end

    return tm
  end

  function tmp:arithrshift(c)
    c = c or 1
    local tm = funcs.new(#bits)

    -- conserve sign bit
    for i = 1, c do
      tm:set(i, bits[1])
    end

    -- copy bits right c positions
    for i = 1, #bits - c do
      tm:set(i + c, bits[i])
    end

    return tm
  end

  function tmp:bor(b)
    local tm = funcs.new(#bits)

    for i = 1, #bits do
      tm:set(bit.bor(bits[i], b[i]))
    end

    return tm
  end

  function tmp:band(b)
    local tm = funcs.new(#bits)

    for i = 1, #bits do
      tm:set(bit.band(bits[i], b[i]))
    end

    return tm
  end

  function tmp:xor(b)
    local tm = funcs.new(#bits)

    for i = 1, #bits do
      tm:set(bit.xor(bits[i], b[i]))
    end

    return tm
  end

  function tmp:nor(b)
    local tm = funcs.new(#bits)

    for i = 1, #bits do
      tm:set(bit.nor(bits[i], b[i]))
    end

    return tm
  end

  function tmp:nand(b)
    local tm = funcs.new(#bits)

    for i = 1, #bits do
      tm:set(bit.nand(bits[i], b[i]))
    end

    return tm
  end

  function tmp:nxor(b)
    local tm = funcs.new(#bits)

    for i = 1, #bits do
      tm:set(bit.nxor(bits[i], b[i]))
    end

    return tm
  end

  -- negate every bit
  function tmp:bnot()
    local tm = funcs.new(#bits)

    for i = 1, #bits do
      tm:set(i, not bits[i])
    end

    return tm
  end

  -- ############ Conversion Functions ############ --

  -- conversion to unsigned integer
  function tmp:uint()
    local sum = 0
    local j = 1

    -- iterate through numbers and add to sum
    for i = #bits, 1, -1 do
      if bits[i] then
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

    if bits[1] then
      -- negative
      for i = #bits, 2, -1 do
        if not bits[i] then
          sum = sum + j
        end
        j = j * 2
      end
      sum = -(sum + 1)
    else
      -- positive
      for i = #bits, 2, -1 do
        if bits[i] then
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
    for i = 1, #bits do
      str = str .. (bits[i] and '1' or '0')
    end
    return str
  end

  -- ####### Setup ####### --

  if type(sz) == "number" then
    for i = 1, sz do
      bits[i] = false
    end
  else
    for i = 1, #sz do
      bits[i] = sz[i]
    end
  end

  -- metatable
  local mta = {
    __type = "bit",
    __metatable = dis,
    __newindex = secureDisable,
    __add = tmp.add,
    __sub = tmp.sub
  }

  function mta:__index(key)
    return bits[key]
  end

  tmp = setmetatable(tmp, mta)

  return tmp
end

return funcs
