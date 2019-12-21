--[[
  Original by Fatboychummy.

  Some shitty processor sort of thing which uses opcodes and registers
  Made cuz bored
]]

local mbit = require("modules.mbit")
local regs = {}
for i = 0, 31 do
  regs[i] = mbit.new(32)
end

local ops = {
  [0] = function(srcreg1, srcreg2, destreg, num)

  end
}
