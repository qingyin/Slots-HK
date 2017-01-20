
local Symbol = class("Symbol")
local SYMB = Symbol
--------------------------------------
-- Construct 
--------------------------------------
function SYMB:ctor( symId, x, y )

	self.id = symId
	self.resId = DICT_SYMBOL[tostring(symId)].res_id

    self.image = DICT_SYM_RES[self.resId].res_name
    self.ccbName = DICT_SYM_RES[self.resId].ccb

	local ccbFile = self.ccbName

	self.nodeLayer = display.newLayer()
    self.rootNode = CCBuilderReaderLoad(ccbFile, self)
    self.nodeLayer:addChild(self.rootNode)

    self:setPosition(x, y)

    if self.image ~= "" then
    	local spFrame = display.newSpriteFrame(self.image)
		if spFrame then
    		self:setDisplayFrame(spFrame)
		end
    end
    
    self:setHoldLabel('')

    self.inUse = false

end

--------------------------------------
-- attachTo 
--------------------------------------
function SYMB:attachTo( target, zOrder )

	if zOrder then
		target:addChild(self.nodeLayer, zOrder)
	else
		target:addChild(self.nodeLayer)
	end
	self.inUse = true
	
end

--------------------------------------
-- attachTo 
--------------------------------------
function SYMB:attachToNewNode( target, zOrder )

	local pos = self:getWorldPosition()
	local pos_ = target:convertToNodeSpace(pos)

	self:removeFromParent(false)
	self:setPosition(pos_.x, pos_.y)

	if zOrder then
		target:addChild(self.nodeLayer, zOrder)
	else
		target:addChild(self.nodeLayer)
	end
	
	self.inUse = true
	
end

--------------------------------------
-- moveTo 
--------------------------------------
function SYMB:moveTo( args )
	transition.moveTo(
		self.nodeLayer, 
		{
			y = args.y ,
			x = args.x , 
			time = args.time ,
			onComplete  = args.onComplete
		})
end

--------------------------------------
-- fadeOut 
--------------------------------------
function SYMB:fadeOut( args )
	transition.fadeOut(
		self.nodeLayer, 
		{
			time = args.time ,
			onComplete  = args.onComplete
		})
end

--------------------------------------
-- getWildReplaceSymbol 
--------------------------------------
function SYMB:getWildReplaceSymbol()

    local id = DICT_SYM_RES[
        DICT_WILD_REEL[tostring(self.id)].replace_id]

    return SYMB.new( id, 0, 0 )

end


--------------------------------------
-- setDisplayFrame 
--------------------------------------
function SYMB:setDisplayFrame( displayFrame )

	self.spNode:setSpriteFrame(displayFrame)

end

--------------------------------------
-- runAnimationByName 
--------------------------------------
function SYMB:runAnimationByName( name )

	-- if true then return end

	local animationMgr = self.rootNode.animationManager
    animationMgr:runAnimationsForSequenceNamed(name)

    -- if animationMgr:getRootNode():getTag() == 10011 then
    --     return false
    -- end

    return true

end

--------------------------------------
-- runWinAnimation 
--------------------------------------
function SYMB:runWinAnimation( name )

	local acName = name
	local animationMgr = self.rootNode.animationManager

	local flag = animationMgr:getSequenceId('win')

	if flag ~= -1 then
		acName = 'win'
	end

	self:runAnimationByName(acName)

end


--------------------------------------
-- runAction 
--------------------------------------
function SYMB:runAction( ccSequence )
	self.nodeLayer:runAction( ccSequence )
end

--------------------------------------
-- stopAllActions 
--------------------------------------
function SYMB:stopAllActions()

	self.spNode:stopAllActions()
	self.rootNode:stopAllActions()
	
end

--------------------------------------
-- setScale 
--------------------------------------
function SYMB:setScale( value )
	self.nodeLayer:setScale(value)
end

--------------------------------------
-- getWorldPosition 
--------------------------------------
function SYMB:getWorldPosition()
	return self.nodeLayer:getParent():
		convertToWorldSpace(cc.p(self:getPosition()))
end

--------------------------------------
-- getPositionX 
--------------------------------------
function SYMB:getPositionX()
	return self.nodeLayer:getPositionX()
end

--------------------------------------
-- getPositionY 
--------------------------------------
function SYMB:getPositionY()
	return self.nodeLayer:getPositionY()
end

--------------------------------------
-- getPosition 
--------------------------------------
function SYMB:getPosition()
	return self:getPositionX(), self:getPositionY()
end

--------------------------------------
-- setPositionX 
--------------------------------------
function SYMB:setPositionX( x )
	self.nodeLayer:setPositionX(x)
end

--------------------------------------
-- setPositionY 
--------------------------------------
function SYMB:setPositionY( y )
	self.nodeLayer:setPositionY(y)
end

--------------------------------------
-- setPosition 
--------------------------------------
function SYMB:setPosition( x, y )
	self:setPositionX(x)
	self:setPositionY(y)
end

--------------------------------------
-- setVisible 
--------------------------------------
function SYMB:setVisible( vbool )
	self.nodeLayer:setVisible(vbool)
end

--------------------------------------
-- removeFromParent 
--------------------------------------
function SYMB:removeFromParent( vbool )

	if vbool == nil then
		vbool = false
	end

    self.nodeLayer:retain()
    self.nodeLayer:removeFromParent(vbool)
    self.inUse = false

end

--------------------------------------
-- setHoldLabel 
--------------------------------------
function SYMB:setHoldLabel( str )
	local label = self.holdCountLabel
	local wildnumBg = self.wildnumBg

	if self.holdCountLabel then

		if str == '' then
			wildnumBg:setVisible(false)
		else
			label:setString(str)
			wildnumBg:setVisible(true)
		end

	end
end

--------------------------------------
-- release 
--------------------------------------
function SYMB:release()
	self.nodeLayer:removeFromParent()
	self = nil
end

--------------------------------------
-- setReelIndex 
--------------------------------------
function SYMB:setReelIndex( index )
	self.reelIndex = index
end


--------------------------------------
-- getReelIndex 
--------------------------------------
function SYMB:getReelIndex()
	return self.reelIndex
end

--------------------------------------
-- getReelIndex 
--------------------------------------
function SYMB:setGlobalZOrder(var)
    self:setAllChildrensZorder(self.rootNode, var)
end

--------------------------------------
-- setAllChildrensZorder 
--------------------------------------
function SYMB:setAllChildrensZorder(target, var)
	target:setGlobalZOrder(var)
    local childrens = target:getChildren()
    for i=1, table.getn(childrens) do
        if childrens[i]:getChildrenCount() > 0 then
            self:setAllChildrensZorder(childrens[i], var)
        else
        	childrens[i]:setGlobalZOrder(var)
        end
    end
end


return Symbol