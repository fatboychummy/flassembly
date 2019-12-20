--[[
  Made by Fatboychummy
  single-bit comparison functions
]]

local bit = {}

function bit.or(a, b)
  return a or b
end
function bit.and(a, b)
  return a and b
end
function bit.xor(a, b)
  return not (a and b) and (a or b)
end
function bit.nor(a, b)
  return not bit.or(a, b)
end
function bit.nand(a, b)
  return not bit.and(a, b)
end
function bit.nxor(a, b)
  return not bit.xor(a, b)
end

return bit
