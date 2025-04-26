local XOR = {}
local callback = bit32.bxor

function XOR:DoIt(Chars: string, Key: number): string
	local t = {}
	for i = 1, #Chars do
		local Char = string.byte(string.sub(Chars, i, i))
		t[i] = string.char(callback(Char, Key))
	end
	return table.concat(t)
end

return XOR
