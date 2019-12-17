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

  function tmp:size()
    return #bits
  end

  -- left-shift by c positions
  function tmp:lshift(c)

  end

  -- right-shift by c positions
  function tmp:rshift(c)

  end

  -- add two bit tables
  function tmp:add(b)

  end

  -- negate then add
  function tmp:sub(b)
    local b2 = b:negate()
    return self:add(self, b2)
  end

  -- flip every bit in the bit table
  function tmp:negate()
    local tmp = funcs.new(self)
    for i = 1, #bits do
      tmp:set(i, not bits[i])
    end
    return tmp
  end

  -- set a bit in the bit table
  function tmp:set(i, x)
    bits[i] = x
  end

  function tmp:mult(b)

  end

  -- return int div AND mod
  function tmp:div(b)

  end

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

  if type(sz) == "number" then
    for i = 1, sz do
      bits[i] = 0
    end
  else
    for i = 1, #sz do
      bits[i] = sz[i]
    end
  end

  return tmp
end

return funcs
