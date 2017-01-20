
require "app.data.slots.dict.dict_machine"
require "app.data.slots.dict.dict_bet"
require "app.data.slots.dict.dict_bonus_paytable"
require "app.data.slots.dict.dict_freespin_paytable"
require "app.data.slots.dict.dict_line"
require "app.data.slots.dict.dict_paytable"
require "app.data.slots.dict.dict_reels"
require "app.data.slots.dict.dict_resource"
-- require "app.data.slots.dict.dict_reward"
require "app.data.slots.dict.dict_symbol"
require "app.data.slots.dict.dict_wild_paytable"
require "app.data.slots.dict.dict_reels"
require "app.data.slots.dict.dict_machine_resource"
-- require "app.data.slots.dict.dict_lobby_resource"
-- require "app.data.slots.dict.dict_scene"
require "app.data.slots.dict.dict_wild_reel"
require "app.data.slots.dict.dict_bonus_config"
require "app.data.slots.dict.dict_bonus_group"
require "app.data.slots.dict.dict_bonus_type"
require "app.data.slots.dict.dict_bonus_value"
-- require "app.data.slots.dict.dict_task"
-- require "app.data.slots.dict.dict_special_task"
-- require "app.data.slots.dict.dict_special_task_off"
-- require "app.data.slots.dict.dict_iap_product_new"
-- require "app.data.slots.dict.dict_product_auth"
-- require "app.data.slots.dict.dict_promotions"
-- require "app.data.slots.dict.dict_timing_reward"
-- require "app.data.slots.dict.dict_notification"
-- require "app.data.slots.dict.dict_props"
require "app.data.slots.dict.dict_line_color"
require "app.data.slots.dict.dict_color"
-- require "app.data.slots.dict.dict_advertisement"
-- require "app.data.slots.dict.dict_gift"
require "app.data.slots.dict.dict_machine_effect"
-- require "app.data.slots.dict.dict_plot"
-- require "app.data.slots.dict.dict_dialog"
-- require "app.data.slots.dict.dict_view_priority"
-- require "app.data.slots.dict.dict_table"
require "app.data.slots.dict.dict_result_pool"
-- require "app.data.slots.dict.dict_facebook_feed"
-- require "app.data.slots.dict.dict_ad_template"
-- require "app.data.slots.dict.dict_product"

DICT_MACHINE=dict_machine
DICT_BET=dict_bet
DICT_REELS=dict_reels
DICT_LINE=dict_line
DICT_SYMBOL=dict_symbol
DICT_PAYTABLE=dict_paytable
DICT_BONUS_PAYTABLE=dict_bonus_paytable
DICT_FREESPIN_PAYTABLE=dict_freespin_paytable
DICT_WILD_PAYTABLE=dict_wild_paytable
DICT_SYM_RES=dict_resource
DICT_MAC_RES=dict_machine_resource
-- DICT_LOBBY_RES=dict_lobby_resource
-- DICT_SCENE=dict_scene
DICT_WILD_REEL=dict_wild_reel
DICT_BONUS_CONFIG=dict_bonus_config
DICT_BONUS_GROUP=dict_bonus_group
DICT_BONUS_TYPE=dict_bonus_type
DICT_BONUS_VALUE=dict_bonus_value
-- DICT_TASK=dict_task
-- DICT_SPECIAL_TASK=dict_special_task
-- DICT_IAP_PRODUCT=dict_iap_product_new
-- DICT_PRODUCT_AUTH=dict_product_auth
-- DICT_PROMOTIONS=dict_promotions
-- DICT_TIMINGRE=dict_timing_reward
DICT_REWARD=dict_reward
-- DICT_NOTIFICATION=dict_notification
DICT_PROPS=dict_props
DICT_LINE_COLOR=dict_line_color
DICT_COLOR=dict_color
-- DICT_ADVERTISEMENT=dict_advertisement
-- DICT_GIFT=dict_gift
DICT_MACHINE_EFF=dict_machine_effect
-- DICT_PLOT=dict_plot
-- DICT_DIALOG=dict_dialog
-- DICT_VIEW_PRIORITY=dict_view_priority
DICT_TABLE=dict_table
DICT_RESULT_POOL=dict_result_pool
-- DICT_FACEBOOK_FEED=dict_facebook_feed
-- DICT_AD_TEMPLATE=dict_ad_template
-- DICT_PRODUCT=dict_product
--DICT 配置

IS_WIN={
    WIN=1,
    FAIL=0
}

MACHINE_TYPE={
    NORMAL="NORMAL",
    DROP="DROP",
    PUSH="PUSH"
}

CALCULATION_RULE={
    NORMAL="NORMAL",
    BOTH_SIDE="BOTH_SIDE"
}

SPIN_TRIGGER={
    Payline="Payline",
    Scatter="Scatter"
}

BONUS_TRIGGER={
    Payline="Payline",
    Scatter="Scatter"
}

ROUND_MODE={
    NORMAL=0,
    FREESPIN=1,
    BONUS=2,
    OVER=9
}

SYMBOL_TYPE={
    Wild="Wild",
    WildReel="WildReel",
    Scatter="Scatter",
    Bonus="Bonus",
    Normal=""
}

ITEM_TYPE={
    NORMAL_MULITIPLE=1000,
    BONUS_MULITIPLE=1001,
    DROP_MULITIPLE=1002,
    GEMS_MULITIPLE=1003,
    STARS_MULITIPLE=1004,
    FREESPIN_MULITIPLE=3001,
    BOOSTER_MULITIPLE2=2001,
    BOOSTER_MULITIPLE5=2002,
    BUYWHEEL_COUNT=600,
    BUYMACHINE_MULITIPLE5=500,
    PIGGYBANK_MULITIPLE=4000,
}

MinCalculateNumber=3

CALCULATE_TYPE={
    NORMAL=1,
    WILD=2,
    NONE=3
}

CALCULATION_SIDE={
    LEFT=1,
    RIGHT=2
}

WILD_REEL_TYPE={
    WildReelA="100",
    WildReelB="101",
    WildReelC="102",
    WildDuplicateA="200",
    WildDuplicateB="201",
    WildHoldA="300",
    WildHoldB="301",
    WildHoldC="302",
    SerialWild="400",
    SerialWildSide="401"
}

DIRECTION={
    TOP="top",
    BOOTOM="bootom"
}

WildConfig={
    ["100"]={wild_reel_type="100",appear="top",change_symbols="2",name="WildReelA"},
    ["101"]={wild_reel_type="101",appear="random",change_symbols="2",name="WildReelB"},
    ["200"]={wild_reel_type="200",name="WildDuplicateA",change_rules={
            ["1"]={reel_idx="1",change_reels={3,4,5}},
            ["2"]={reel_idx="2",change_reels={3,4,5}},
            ["3"]={reel_idx="3",change_reels={2,4,5}},
            ["4"]={reel_idx="4",change_reels={2,3,5}},
            ["5"]={reel_idx="1",change_reels={1,2,3}}
        }
    },
    ["201"]={wild_reel_type="201",name="WildDuplicateB",change_symbols="1"},
    ["300"]={wild_reel_type="300",name="WildHoldA",stay_rounds={2,3,4}},
    ["301"]={wild_reel_type="301",name="WildHoldB"},
    ["302"]={wild_reel_type="302",name="WildHoldC"}
}

CARD_NUM={2,3,4,5,6,7,8,9,10 }

CARD_TYPE={
    Spade=1,
    heart=2,
    club=3,
    diamond=4
}
DOUBLE_TYPE={
    Spade=1,
    heart=2,
    club=3,
    diamond=4,
    red=5,
    black=6
}

BONUS_ID={
    BonusBoxLife3=1,
    BonusBox5Levels=2,
    BonusMatch3=3,
    BonusJourney=4
}

USER_EXPERIENCE={
    ROOKIE_LEVEL_LIMIT=7,
    VIP_LEVEL_LIMIT=1,
    LOW_EXP_LEVEL=1,
    MEDIUM_EXP_LEVEL=2,
    HIGH_EXP_LEVEL=3,
    SUPER_EXP_LEVEL=4,
    EXP_POOL={
              FIRST_LOGIN={11,8,0,0,0,0,0,0,0,0},
              FIRST_DAY_LOGIN={7,0,0,0,0,0,0,0,0,0},
              BUY_COINS={7,8,0,0,0,0,0,0,0,0}
    },
    SWITCH_SIGN={
              USE_BOOSTER_SIGN=0,
              DAY_RESCURE_SIGN=0,
              FAIL_LAST_TIMES=0,
              FIRST_DAY_LOGIN=0,
              BUY_COINS=1,
              FIRST_LOGIN=1
    }
}

RESULT_POOL={
    TotalBet2_5=6,
    TotalBet5_10=7,
    TotalBet10_20=8,
    FreeSpin=11,
    TotalBet1_2=5,
    LevelControl9_10=6
}

RESULT_POOL_WEIGHT={
    WEIGHT_51_SPECIAL={
          LIST={
            ["300"]=4,
            ["550"]=5,
            ["800"]=6,
            ["900"]=7,
            ["950"]=8,
            ["1000"]=9
          },
          USE_WIGHT=200,
          ALL_WIGHT=1000
    },
    WEIGHT_31_SPECIAL={
          LIST={
            ["300"]=4,
            ["550"]=5,
            ["800"]=6,
            ["900"]=7,
            ["950"]=8,
            ["1000"]=9
          },
          USE_WIGHT=333,
          ALL_WIGHT=1000
    },
    WEIGHT_31={
          LIST={
            ["550"]=1,
            ["750"]=2,
            ["900"]=3,
            ["950"]=4,
            ["980"]=5,
            ["1000"]=6
          },
          USE_WIGHT=333,
          ALL_WIGHT=1000
    },
    WEIGHT_54={
          LIST={
            ["600"]=1,
            ["800"]=2,
            ["900"]=3,
            ["980"]=4,
            ["990"]=5,
            ["1000"]=6
          },
          USE_WIGHT=800,
          ALL_WIGHT=1000
    },
    WEIGHT_51_NORMAL={
        LIST={
            ["350"]=4,
            ["620"]=5,
            ["910"]=6,
            ["960"]=7,
            ["990"]=8,
            ["1000"]=9
        },
        USE_WIGHT=200,
        ALL_WIGHT=1000
    }
}

RESULT_POOL_LEVEL={
    UNIQUE_LEVEL={
        {minLevel=1,maxLevel=5,weight=RESULT_POOL_WEIGHT.WEIGHT_31_SPECIAL}
        --[[ 
        {minLevel=5,maxLevel=6,weight=RESULT_POOL_WEIGHT.WEIGHT_51_SPECIAL},
        {minLevel=7,maxLevel=7.5,weight=RESULT_POOL_WEIGHT.WEIGHT_51_NORMAL},
        {minLevel=8.5,maxLevel=9.5,weight=RESULT_POOL_WEIGHT.WEIGHT_31},
        {minLevel=9.5,maxLevel=10,weight=RESULT_POOL_WEIGHT.WEIGHT_51_NORMAL},
        {minLevel=10,maxLevel=10.5,weight=RESULT_POOL_WEIGHT.WEIGHT_51_NORMAL},
        {minLevel=12.5,maxLevel=13,weight=RESULT_POOL_WEIGHT.WEIGHT_31},
        {minLevel=13,maxLevel=13.5,weight=RESULT_POOL_WEIGHT.WEIGHT_51_NORMAL},
        {minLevel=14,maxLevel=14.5,weight=RESULT_POOL_WEIGHT.WEIGHT_31},
        {minLevel=14.5,maxLevel=15,weight=RESULT_POOL_WEIGHT.WEIGHT_51_NORMAL}
        --]]
    },
    REPEAT_BEGIN_LEVEL=999,
    REPEAT_LEVEL={
        {minLevel=0,maxLevel=0.5,weight=RESULT_POOL_WEIGHT.WEIGHT_51_NORMAL},
        {minLevel=2.5,maxLevel=3,weight=RESULT_POOL_WEIGHT.WEIGHT_54},
        {minLevel=3,maxLevel=3.5,weight=RESULT_POOL_WEIGHT.WEIGHT_51_NORMAL},
        {minLevel=4,maxLevel=4.5,weight=RESULT_POOL_WEIGHT.WEIGHT_31}
    }
}

MOVE_DIRECTION={
    DOWN=-1,
    UP=1,
    NONE=0
}
