local DoubleApi = require("app.data.double.DoubleGame")

local DoublePoker = class("DoublePoker", function()
    return display.newNode()
end)

local function scaleFun(target, scaleX,scaleY, time, onComplete)
    transition.scaleTo(target, {scaleX=scaleX,scaleY= scaleY,time= time,onComplete = onComplete})
end

local  POCK = {
    color1 = "spade",
    color2 = "hearts",
    color3 = "club",
    color4 = "diamonds"
}


-----------------------------------------------------------
-- @Construct:
-- args.wincoins
-- args.callback
-----------------------------------------------------------
function DoublePoker:ctor( args )

    local wincoins = args.wincoins

    self.callback = args.callback

    local  node  = CCBReaderLoad("lobby/double/DoublePokerScene.ccbi", self)

    self:addChild(node)
    self.userModel = app:getObject("UserModel")

    if  wincoins then
        wincoins = math.floor(wincoins)
    end
    self.isWin = 0
    self.totalWin = 0 - wincoins
    self.failcoins = 0 - wincoins

    self.openPokers = {}
    self.baseWins = wincoins
    self.wincoins = wincoins
    self.totalcoins = self.userModel:getCoins() - wincoins

    -- self.ChooseCardX,self.ChooseCardY = self.theChooseCard:getPosition()
    -- self.ChoosedCardX,self.ChoosedCardY = self.theChoosedCard:getPosition()
    -- self:init()
    self:registerEvent()

    local topScale = display.width/1136
    self.top:setScale(topScale)

    local bottomScale = display.height/768

    if bottomScale > topScale then
        bottomScale = topScale
    end
    
    self.bottom:setScale(bottomScale)
    
    -- self.centerNode:ignoreAnchorPointForPosition(false)
    local theight = self.topbgSprite:getContentSize().height
    local bheight = self.bottombgSrpite:getContentSize().height
    local centerY = (display.height - theight - bheight)/2
    local keyPosY = bheight + centerY
    self.centerNode:setScale(bottomScale)
    self.centerNode:setPosition(display.width/2, keyPosY)

    -- self.winBtn:setScale(0.7)
    self.winBtn:needsLayout()

    self:setNodeEventEnabled(true)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        end
    end)

    self:Layout()

    self.ChooseCardX,self.ChooseCardY = self.theChooseCard:getPosition()
    self.ChoosedCardX,self.ChoosedCardY = self.theChoosedCard:getPosition()

    self.flipCardsX, self.flipCardsY = self.flipCards:getPosition()

    self:init()

    -- for dataReport
    self.flopCnt = 0

    self:loadSpriteFrame()

end

function DoublePoker:init()
    self.totalcoinsLabel:setString(number.commaSeperate(self.totalcoins))
    self.wincoinsLabel:setString(number.commaSeperate(self.wincoins))
    
    local pokers =  self.userModel:getDoublePoker()
    if pokers ~= nil then
        local x,y = self.flipCardsX, self.flipCardsY
        local count = table.nums( pokers )
        for i = 1, count do

            local index = count - i + 1
            local key = "poker"..tostring(index)
            local poker = pokers[key]
            
            if poker ~= nil then
                local card = self:loadCardImpl(poker.num, poker.color)
                table.insert(self.openPokers, card)
                card:setScale(1)
                card:setPosition(x + (index-1) * (card:getContentSize().width / 3),y)
            end
        end
    end
end

-- -----------------------------------------------------------
-- -- loadSpriteFrame
-- -----------------------------------------------------------
function DoublePoker:loadSpriteFrame()

    local resPath = "slots/hk_double.pvr.ccz"
    local plist = "slots/hk_double.plist"

    display.addSpriteFrames(plist,resPath)
    
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(plist)
    local dict = cc.FileUtils:getInstance():getValueMapFromFile(fullPath)

    local spFrame
    for k,v in pairs(dict.frames) do
        spFrame = display.newSpriteFrame(k)
        spFrame:retain()
    end
end

-- -----------------------------------------------------------
-- -- unLoadSpriteFrame
-- -----------------------------------------------------------
function DoublePoker:unLoadSpriteFrame()

    local resPath = "slots/hk_double.pvr.ccz"
    local plist = string.gsub(resPath, "pvr.ccz", "plist")
    
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(plist)
    local dict = cc.FileUtils:getInstance():getValueMapFromFile(fullPath)

    local spFrame
    for k,v in pairs(dict.frames) do
        spFrame = display.newSpriteFrame(k)
        spFrame:release()
    end
end

function DoublePoker:saveOpenedPoker()
    local count = table.nums(self.openPokers)
    local pokers = {}
    for i = count, 1,-1 do
        local poker = self.openPokers[i]
        if i < 7 and poker ~= nil then
            local skey = "poker"..i
            pokers[skey] = {}
            pokers[skey].num     = poker.num
            pokers[skey].color   = poker.color
        end
    end
    self.userModel:setDoublePoker(pokers)
end

function DoublePoker:onEnter()
    audio.playMusic(RES_AUDIO.wheel_bg)
end

function DoublePoker:onExit()
    self:unLoadSpriteFrame()

    self.userModel = nil
    self.openPokers = nil

end

local function addBtnClikEvent(btn, handle)

    core.displayEX.newButton(btn)
        :onButtonClicked(handle)

end

function DoublePoker:registerEvent()
    local function onRedBtnTogle()
        self:flipPoker(DOUBLE_TYPE.red)
    end
    addBtnClikEvent(self.redBtn,onRedBtnTogle)

    local function onBlackBtnTogle()
        self:flipPoker(DOUBLE_TYPE.black)
    end
    addBtnClikEvent(self.blackBtn,onBlackBtnTogle)

    local function onSpadeBtnTogle()
        self:flipPoker(DOUBLE_TYPE.Spade)
    end
    addBtnClikEvent(self.spadeBtn,onSpadeBtnTogle)
    
    local function onDiomandBtnTogle()
        self:flipPoker(DOUBLE_TYPE.diamond)
    end
    addBtnClikEvent(self.diomandBtn,onDiomandBtnTogle)
    
    local function onClubBtnTogle()
        self:flipPoker(DOUBLE_TYPE.club)
    end
    addBtnClikEvent(self.clubBtn,onClubBtnTogle)
    
    local function onHeartBtnTogle()
        self:flipPoker(DOUBLE_TYPE.heart)
    end
    addBtnClikEvent(self.heartBtn,onHeartBtnTogle)

    local function onWinBtnTogle()

        app:getObject("ReportModel"):doubleGame(self.baseWins, self.flopCnt, self.wincoins)
        self.userModel:setCoins(self.totalcoins + self.wincoins)
        self.callback(self.wincoins)
        self:removeFromParent()

    end

    addBtnClikEvent(self.winBtn,onWinBtnTogle)


    local function onHalfBtnTogle()
        local halfcoin = math.floor( self.wincoins / 2 )
        self.totalWin = self.totalWin + halfcoin
        self.totalcoins = self.totalcoins + halfcoin
        self.wincoins = self.wincoins - halfcoin
        self.totalcoinsLabel:setString(number.commaSeperate(self.totalcoins))
        self.wincoinsLabel:setString(number.commaSeperate(self.wincoins))
    end
    addBtnClikEvent(self.halfBtn,onHalfBtnTogle)
end

function DoublePoker:setEnbaleButton(enable)
    self.redBtn:setButtonEnabled(enable)
    self.blackBtn:setButtonEnabled(enable)
    self.spadeBtn:setButtonEnabled(enable)
    self.diomandBtn:setButtonEnabled(enable)
    self.clubBtn:setButtonEnabled(enable)
    self.heartBtn:setButtonEnabled(enable)
    self.winBtn:setButtonEnabled(enable)
    self.halfBtn:setButtonEnabled(enable)
end

function DoublePoker:flipPoker(type)
    self:setEnbaleButton(false)
    local result = DoubleApi.getDoubleResult(type)
    self.isWin = result.isWin
    self.multiple = result:getMultiple()

    local spfront = self:loadCardImpl(result.cardNum, result.cardType)
    spfront:setScaleX(0)
    self:flipCard(self.theChoosedCard, spfront, 0.2)
end

function DoublePoker:loadCardImpl(num, color)
    local image,spfront = "",nil

    image = '#'..POCK["color"..color]..'.png'
    spfront = display.newSprite(image, self.ChoosedCardX, self.ChoosedCardY)

    spfront.num     = num
    spfront.color   = color
    self.centerNode:addChild(spfront)
    return spfront
end

function DoublePoker:flipCard(back, front, fliptime)
    scaleFun(back, 0,1, fliptime, function()
        scaleFun(front, 1,1, fliptime, function()
            local px, py = front:getPosition()
            transition.moveTo(self.theChooseCard, {
                x = px, y = py, time = 0.5,
                onComplete = function()
                    self.theChoosedCard = self.theChooseCard
                    self.theChooseCard = back
                    self.theChooseCard:setScaleX(0.74)
                    self.theChooseCard:setScaleY(0.74)
                    self.theChooseCard:setPosition(self.ChooseCardX,self.ChooseCardY)
                    self.theChoosedCard:setPosition(self.ChoosedCardX,self.ChoosedCardY)
                    self.theChooseCard:setOpacity(0)
                    transition.fadeIn(self.theChooseCard, {time  =  0.2})
                end
            })

            transition.scaleTo(self.theChooseCard, {scale=1,time=0.5})
            transition.moveTo(front, {
                x = self.flipCardsX, y = self.flipCardsY,time = 0.5,
                onComplete = function()
                    table.insert(self.openPokers, front)
                    self:setEnbaleButton(true)
                    self:saveOpenedPoker()

                    if self.isWin == 1 then

                        audio.playSound(RES_AUDIO.double_win)

                        self.wincoins = math.floor(self.wincoins * self.multiple)
                        self.totalWin = math.floor(self.failcoins + self.wincoins)
                        self.wincoinsLabel:setString(tostring(self.wincoins))
                    else
                        self.wincoins = 0
                        self.userModel:setCoins(self.totalcoins + self.wincoins)
                        --SCNM.backToLastScene(self.failcoins)
                        -- scn.ScnMgr.replaceScene("PokerScene")

                        self.callback(self.failcoins)
                        self:removeFromParent()
                        
                        print("--todo--")
                    end
                end
            })

            transition.scaleTo(front, {scale = 1,time= 0.5 })
            local count = table.nums(self.openPokers)
            for i = 1, count do
                local poker = self.openPokers[i]
                transition.moveTo(poker, {y = self.flipCardsY, time = 0.3,
                    x = poker:getPositionX() + poker:getContentSize().width / 3
                })
            end
        end)
    end)
end


return DoublePoker
