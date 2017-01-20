local DoubleApi = require("app.data.double.DoubleGame")

local DoublePoker = class("DoublePoker", function()
    local layer = display.newLayer()
    layer:setNodeEventEnabled(true)
    return layer
end)

local function scaleFun(target, scaleX,scaleY, time, onComplete)
    transition.scaleTo(target, {scaleX=scaleX,scaleY= scaleY,time= time,onComplete = onComplete})
end

local  POCK = {
    card_1         = "_a_slots_d.png",
    card_2         = "_2_slots_d.png",
    card_3         = "_3_slots_d.png",
    card_4         = "_4_slots_d.png",
    card_5         = "_5_slots_d.png",
    card_6         = "_6_slots_d.png",
    card_7         = "_7_slots_d.png",
    card_8         = "_8_slots_d.png",
    card_9         = "_9_slots_d.png",
    card_10         = "_10_slots_d.png",
    card_11         = "_j_slots_d.png",
    card_12         = "_k_slots_d.png",
    card_13         = "_q_slots_d.png",
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

    local  node  = CCBReaderLoad("slots/double/DoublePokerScene.ccbi", self)
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

    self.ChooseCardX,self.ChooseCardY = self.theChooseCard:getPosition()
    self.ChoosedCardX,self.ChoosedCardY = self.theChoosedCard:getPosition()
    self:init()
    self:registerEvent()
    self:Layout()

end

function DoublePoker:init()
    self.totalcoinsLabel:setString(self.totalcoins)
    self.wincoinsLabel:setString(self.wincoins)
    
    local pokers =  self.userModel:getDoublePoker()
    if pokers ~= nil then
        local x,y = 600,125
        local count = table.nums( pokers )
        for i = count, 1,-1 do
            local poker = pokers["poker"..i]
            if poker ~= nil then
                local card = self:loadCardImpl(poker.num, poker.color)
                table.insert(self.openPokers, card)
                card:setScale(0.7)
                card:setPosition(x + (i-1) * (card:getContentSize().width / 3),y)
            end
        end
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
    self.userModel:getDoublePoker(pokers)
end

function DoublePoker:onEnter()

end

function DoublePoker:onExit()

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
        self.totalcoinsLabel:setString(self.totalcoins)
        self.wincoinsLabel:setString(self.wincoins)
    end
    addBtnClikEvent(self.halfBtn,onHalfBtnTogle)
end

function DoublePoker:setEnbaleButton(enable)
    self.redBtn:setTouchEnabled(enable)
    self.blackBtn:setTouchEnabled(enable)
    self.spadeBtn:setTouchEnabled(enable)
    self.diomandBtn:setTouchEnabled(enable)
    self.clubBtn:setTouchEnabled(enable)
    self.heartBtn:setTouchEnabled(enable)
    self.winBtn:setTouchEnabled(enable)
    self.halfBtn:setTouchEnabled(enable)
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
    image = '#'..POCK["color"..color]..POCK["card_"..num]
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
                    self.theChooseCard:setScaleX(0.7)
                    self.theChooseCard:setScaleY(0.7)
                    self.theChooseCard:setPosition(self.ChooseCardX,self.ChooseCardY)
                    self.theChoosedCard:setPosition(self.ChoosedCardX,self.ChoosedCardY)
                    self.theChooseCard:setOpacity(0)
                    transition.fadeIn(self.theChooseCard, {time  =  0.2})
                end
            })

            transition.scaleTo(self.theChooseCard, {scale=1,time=0.5})
            transition.moveTo(front, {
                x = 600, y = 125,time = 0.5,
                onComplete = function()
                    table.insert(self.openPokers, front)
                    self:setEnbaleButton(true)
                    self:saveOpenedPoker()

                    if self.isWin == 1 then
                        self.wincoins = math.floor(self.wincoins * self.multiple)
                        self.totalWin = math.floor(self.failcoins + self.wincoins)
                        self.wincoinsLabel:setString(tostring(self.wincoins))
                    else
                        self.wincoins = 0
                        self.userModel:setCoins(self.totalcoins + self.wincoins)

                        self.callback(self.failcoins)
                        self:removeFromParent()
                        
                    end
                end
            })

            transition.scaleTo(front, {scale = 0.7,time= 0.5 })
            local count = table.nums(self.openPokers)
            for i = 1, count do
                local poker = self.openPokers[i]
                transition.moveTo(poker, {y = 125, time = 0.3,
                    x = poker:getPositionX() + poker:getContentSize().width / 3
                })
            end
        end)
    end)
end

return DoublePoker
