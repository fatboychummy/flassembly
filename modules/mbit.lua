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

  -- metatable
  local mta = {
    __type = "bit",
    __metatable = dis,
    __newindex = secureDisable
  }

  -- the returned object
  local tmp = setmetatable(
    {
      overflowbit = false,
    }, mta)

  function mta:__index(key)
    return bits[key]
  end

  -- ############ Arithmetic functions ############ --

  -- add two bit tables
  function tmp:add(b)
    local tm = funcs.new(#bits)

    -- full carry adder implementation, returns the sum and carry bit
    local function add(a, b, c)
      local xor1 = bit32.bxor(a, b)
      local sum = bit32.bxor(xor1, c)
      local a1 = bit32.band(xor1, c)
      local a2 = bit32.band(a, b)
      local carryout = bit32.bor(a1, a2)
      return sum, carryout
    end

    -- ripple-carry adder
    local s = 0
    local carry = 0
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
    local b2 = b:negate()
    return self:add(self, b2)
  end

  -- flip every bit in the bit table
  function tmp:negate()
    local tm = funcs.new(self)
    for i = 1, #bits do
      tm:set(i, not bits[i])
    end
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

  function tmp:or(b)

  end

  function tmp:and(b)

  end

  function tmp:xor(b)

  end

  function tmp:nor(b)

  end

  function tmp:nand(b)

  end

  function tmp:nxor(b)

  end

  -- ############ Conversion Functions ############ --

  function tmp:int()
    local sum = 0
    local j = 1
    for i = #bits, 1, -1 do
      sum = sum + bits[i] * j
      j = j * 2
    end
    return sum
  end

  function tmp:float()
    -- TODO
  end

  function tmp:char()
    return string.char(self:int())
  end

  -- returns a string of bits
  function tmp:bstr()
    local str = ""
    for i = 1, #bits do
      str = str .. tostring(bits[i])
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

  return tmp
end

return funcs
