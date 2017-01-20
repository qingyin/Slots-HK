
local Bit = class("Bit")

local BIT_LEN = 32
local bitData = {}

--------------------------------------
-- Construct
--------------------------------------
function Bit:ctor( intValue )
	-- print("intValue:" , intValue)
	self.bitArray  = {}
    self.intValue = intValue
    self:init()
end

--------------------------------------
-- Init
--------------------------------------
function Bit:init()
	for i=1,BIT_LEN do
		bitData[i] = 2^(BIT_LEN - i)
		-- print("bitData[i]:",bitData[i])
	end
	self:upBitArray()
end

--------------------------------------
-- rshift
--------------------------------------
function Bit:rshift( n )
	local bitArray = clone(self.bitArray)
	
	for i=BIT_LEN, n+1, -1 do
		self.bitArray[i] = bitArray[i - n]
	end

	for i=1 , n do
		self.bitArray[i] = 0
	end

	self:upIntValue()
end

--------------------------------------
-- lshift
--------------------------------------
function Bit:lshift( n )
	local bitArray = clone(self.bitArray)

	for i=1, BIT_LEN - n+1 do
		self.bitArray[i] = bitArray[i+n]
	end

	for i=BIT_LEN - n , BIT_LEN do
		self.bitArray[i] = 0
	end

	self:upIntValue()
end

--------------------------------------
-- setPosValue
--------------------------------------
function Bit:setPosValue( pos, value )

	if pos > BIT_LEN or pos < 1 or
		(value ~= 1 and value ~= 0) then
		print('setPosValue error:', 'pos:', 
			pos, 'value:', value)
		return
	end

	self.bitArray[pos] = value
	self:upIntValue()

end

--------------------------------------
-- getPosValue
--------------------------------------
function Bit:getPosValue( pos )
	return self.bitArray[pos]
end

--------------------------------------
-- getIntValue
--------------------------------------
function Bit:getIntValue()
	return self.intValue
end

--------------------------------------
-- upBitArray
--------------------------------------
function Bit:upBitArray()
	local num = self.intValue

	for i=1,BIT_LEN do

		-- print("num:",num, "bitData[i]:", bitData[i] )

		if num >= bitData[i] then
			self.bitArray[i] = 1
			num = num - bitData[i]
		else
			self.bitArray[i] = 0
		end
	end

end

--------------------------------------
-- upIntValue
--------------------------------------
function Bit:upIntValue()
	self.intValue = 0
    for i=1,BIT_LEN do
        if self.bitArray[i] ==1 then
        	self.intValue = 
        	self.intValue+2^(BIT_LEN-i)
        end
    end
end

return Bit