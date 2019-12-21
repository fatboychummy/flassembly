--[[
  Made by Fatboychummy
  single-bit comparison functions
]]

local bit = {}

function bit.bor(a, b)
  return a or b
end
function bit.band(a, b)
  return a and b
end
function bit.xor(a, b)
  return not (a and b) and (a or b)
end
function bit.nor(a, b)
  return not (a or b)
end
function bit.nand(a, b)
  return not (a and b)
end
function bit.nxor(a, b)
  return not bit.xor(a, b)
end

return bit
