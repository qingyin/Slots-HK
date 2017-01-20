--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local c = cc
local Scene = c.Scene

function Scene:setAutoCleanupEnabled()
    self:addNodeEventListener(c.NODE_EVENT, function(event)
        if event.name == "exit" then
            if self.autoCleanupImages_ then
                for imageName, v in pairs(self.autoCleanupImages_) do
                    display.removeSpriteFrameByImageName(imageName)
                end
                self.autoCleanupImages_ = nil
            end
        end
    end)
end

function Scene:markAutoCleanupImage(imageName)
    if not self.autoCleanupImages_ then self.autoCleanupImages_ = {} end
    self.autoCleanupImages_[imageName] = true
    return self
end


function Scene:Layout(animation)

    local newX = 0
    local newY = 0
    local anchorPT = 0
    local size = nil
    local igoreAnchor = nil
    local borderWidth = 0

    -- top node (1 / 8)
    if self.top == nil then
        --print("there is no top node")
    else
        size = self.top:getContentSize()
        igoreAnchor = self.top:isIgnoreAnchorPointForPosition()
        anchorPT = self.top:getAnchorPoint()

        if igoreAnchor then
            anchorPT.x = 0
            anchorPT.y = 0
        end

        newX = display.cx - size.width * (0.5 - anchorPT.x)
        newY = display.top - size.height * (1-anchorPT.y) - borderWidth

        self.top:setPosition(newX, newY)
    end

    -- top left node (2 / 8)
    if self.top_left == nil then
        -- print("there is no top left node")
    else
        size = self.top_left:getContentSize()
        igoreAnchor = self.top_left:isIgnoreAnchorPointForPosition()
        anchorPT = self.top_left:getAnchorPoint()

        if igoreAnchor then
            anchorPT.x = 0
            anchorPT.y = 0
        end

        newX = display.left + size.width * anchorPT.x + borderWidth
        newY = display.top - size.height * (1-anchorPT.y) - borderWidth

        self.top_left:setPosition(newX, newY)

    end

    -- top right node (3 / 8)
    if self.top_right == nil then
        -- print("there is no top right node")
    else

        size = self.top_right:getContentSize()
        igoreAnchor = self.top_right:isIgnoreAnchorPointForPosition()
        anchorPT = self.top_right:getAnchorPoint()

        if igoreAnchor then
            anchorPT.x = 0
            anchorPT.y = 0
        end

        newX = display.right - size.width * (1-anchorPT.x) - borderWidth
        newY = display.top - size.height * (1-anchorPT.y) - borderWidth

        self.top_right:setPosition(newX, newY)
    end


    -- bottom node (4 / 8)
    if self.bottom == nil then
        --print("there is no bottom node")
    else
        size = self.bottom:getContentSize()
        igoreAnchor = self.bottom:isIgnoreAnchorPointForPosition()
        anchorPT = self.bottom:getAnchorPoint()

        if igoreAnchor then
            anchorPT.x = 0
            anchorPT.y = 0
        end

        newX = display.cx - size.width * (0.5 - anchorPT.x)
        newY = display.bottom + size.height * anchorPT.y + borderWidth

        self.bottom:setPosition(newX, newY)
    end

    -- bottom left node (5 / 8)
    if self.bottom_left == nil then
        --print("there is no bottom left node")
    else
        size = self.bottom_left:getContentSize()
        igoreAnchor = self.bottom_left:isIgnoreAnchorPointForPosition()
        anchorPT = self.bottom_left:getAnchorPoint()

        if igoreAnchor then
            anchorPT.x = 0
            anchorPT.y = 0
        end

        newX = display.left + size.width * anchorPT.x + borderWidth
        newY = display.bottom + size.height * anchorPT.y + borderWidth

        self.bottom_left:setPosition(newX, newY)

    end

    -- bottom right node (6 / 8)
    if self.bottom_right == nil then
        -- print("there is no bottom right node")
    else
        size = self.bottom_right:getContentSize()
        igoreAnchor = self.bottom_right:isIgnoreAnchorPointForPosition()
        anchorPT = self.bottom_right:getAnchorPoint()

        if igoreAnchor then
            anchorPT.x = 0
            anchorPT.y = 0
        end

        newX = display.right - size.width * (1-anchorPT.x) - borderWidth
        newY = display.bottom + size.height * (anchorPT.y) + borderWidth

        self.bottom_right:setPosition(newX, newY)
    end

    -- left node (7 / 8)
    if self.left == nil then
        -- print("there is no left node")
    else
        size = self.left:getContentSize()
        igoreAnchor = self.left:isIgnoreAnchorPointForPosition()
        anchorPT = self.left:getAnchorPoint()

        if igoreAnchor then
            anchorPT.x = 0
            anchorPT.y = 0
        end

        newX = display.left + size.width * anchorPT.x + borderWidth
        newY = display.cy - size.height * (0.5 - anchorPT.y)

        self.left:setPosition(newX, newY)
    end

    -- right node (8 / 8)
    if self.right == nil then
        --print("there is no right node")
    else
        size = self.right:getContentSize()
        igoreAnchor = self.right:isIgnoreAnchorPointForPosition()
        anchorPT = self.right:getAnchorPoint()

        if igoreAnchor then
            anchorPT.x = 0
            anchorPT.y = 0
        end

        newX = display.right - size.width * (1-anchorPT.x) - borderWidth
        newY = display.cy - size.height * (0.5 - anchorPT.y)

        self.right:setPosition(newX, newY)
    end

    if animation then

        local posX, posY

        if self.right ~= nil then

            posX, posY = self.right:getPosition()

            self.right:setPositionX(posX+100)

            transition.moveTo(self.right, {x=posX, y=posY, time=0.3, delay = 1.0,
                onComplete=function()
                end})

        end

        if self.left ~= nil then

            posX, posY = self.left:getPosition()

            self.left:setPositionX(posX-100)

            transition.moveTo(self.left, {x=posX, y=posY, time=0.3, delay = 1.0,
                onComplete=function()
                end})

        end


        if self.top ~= nil then

            posX, posY = self.top:getPosition()

            self.top:setPositionY(posY+150)

            transition.moveTo(self.top, {x=posX, y=posY, time=0.3, delay = 1.0,
                onComplete=function()
                end})

        end

        if self.top_left ~= nil then

            posX, posY = self.top_left:getPosition()

            self.top_left:setPositionY(posY+150)

            transition.moveTo(self.top_left, {x=posX, y=posY, time=0.3, delay = 1.0,
                onComplete=function()
                end})

        end

        if self.top_right ~= nil then

            posX, posY = self.top_right:getPosition()

            self.top_right:setPositionY(posY+150)

            transition.moveTo(self.top_right, {x=posX, y=posY, time=0.3, delay = 1.0,
                onComplete=function()
                end})

        end

        if self.bottom ~= nil then

            posX, posY = self.bottom:getPosition()

            self.bottom:setPositionY(posY-150)

            transition.moveTo(self.bottom, {x=posX, y=posY, time=0.3, delay = 1.0,
                onComplete=function()
                end})

        end

        if self.bottom_left ~= nil then

            posX, posY = self.bottom_left:getPosition()

            self.bottom_left:setPositionY(posY-150)

            transition.moveTo(self.bottom_left, {x=posX, y=posY, time=0.3, delay = 1.0,
                onComplete=function()
                end})

        end

        if self.bottom_right ~= nil then

            posX, posY = self.bottom_right:getPosition()

            self.bottom_right:setPositionY(posY-150)

            transition.moveTo(self.bottom_right, {x=posX, y=posY, time=0.3, delay = 1.0,
                onComplete=function()
                end})

        end

    end


end