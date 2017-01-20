local Card = class("CardSprite", function()
    return display.newNode()
end)

local function scaleFun(target, scaleX,scaleY, time, onComplete)
    transition.scaleTo(target, {scaleX=scaleX,scaleY= scaleY,time= time,onComplete = onComplete})
end

function Card:ctor(front,back)
    local resName = "#"..front
    local sp = display.newSprite(resName)
    self:addChild(sp)
    self.front = sp

    if back ~= nil then
        resName = "#"..back
        sp = display.newSprite(resName)
        self:addChild(sp)
        self.back = sp
    end
    self:setNodeEventEnabled(true)
end

function Card:flip(callback)
    self.front:setScaleX(0)
    scaleFun(self.back, 0,1, 0.2, function()
        scaleFun( self.front, 1,1, 0.2,function()
            self.back:setVisible(false)
            if callback ~= nil then
                callback()
            end

        end)
    end)
end


function Card:onExit()
    self.front = nil
    self.back = nil
    self:removeAllNodeEventListeners()
end

return Card
