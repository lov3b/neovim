--- A small seedable random number generator (xorshift32).
---
--- math.random is global state that plugins reseed with os.time() (snacks,
--- LuaSnip), which made every start within the same second show the same
--- fortune. A generator of our own is passed to whatever needs randomness,
--- seeded from the OS in the app and from a constant in tests.
local M = {}

---@alias fun.Rand fun(m: integer, n?: integer): integer rand(n) is in [1, n], rand(m, n) in [m, n]

local bit = require("bit")

--- Creates a generator. The same seed gives the same sequence.
---@param seed integer any 32-bit integer; 0 is remapped, as xorshift would stay at 0
---@return fun.Rand
function M.new(seed)
	local state = bit.tobit(seed)
	if state == 0 then
		state = bit.tobit(0x9E3779B9)
	end
	return function(m, n)
		if not n then
			m, n = 1, m
		end
		assert(n >= m, "rand: empty range")
		state = bit.bxor(state, bit.lshift(state, 13))
		state = bit.bxor(state, bit.rshift(state, 17))
		state = bit.bxor(state, bit.lshift(state, 5))
		return m + (state % 2 ^ 32) % (n - m + 1)
	end
end

--- A seed from the operating system (getrandom via libuv).
---@return integer
function M.os_seed()
	local b1, b2, b3, b4 = vim.uv.random(4):byte(1, 4)
	return bit.tobit(((b1 * 256 + b2) * 256 + b3) * 256 + b4)
end

return M
