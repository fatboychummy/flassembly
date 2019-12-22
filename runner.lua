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

local OPREGS = {
  ZERO = 0,
  ERRCODE = 1,
  EXTRA = 5
}

local ops = {
  [0] = function(srcreg1, srcreg2, destreg, shift, proc)
    local src1 = srcreg1:uint()
    local src2 = srcreg2:uint()
    local dest = destreg:uint()
    local sh = shift:int()
    local procInt = proc:uint()

    if procInt == 0 then
      -- addition operation
      local out = mbit.new(regs[srcreg1]):add(regs[srcreg2])

      regs[destreg]:set(out:uint())
    elseif procInt == 1 then
      -- subtraction operation
      local out = mbit.new(regs[srcreg1]):sub(regs[srcreg2])

      regs[destreg]:set(out:uint())
    elseif procInt == 2 then
      -- multiplication operation
      local out = mbit.new(regs[srcreg1]):mult(regs[srcreg2])

      regs[destreg]:set(out:uint())
    elseif procInt == 3 then
      -- division operation
      local out, mod = mbit.new(regs[srcreg1]):div(regs[srcreg2])

      regs[destreg]:set(out:uint())
      regs[OPREGS.EXTRA]:set(mod:uint())
    elseif procInt == 4 then
      -- leftshift operation

    elseif procInt == 5 then
      -- rightshift (logical) operation

    elseif procInt == 6 then
      -- rightshift (arithmetic) operation

    end
  end
}
