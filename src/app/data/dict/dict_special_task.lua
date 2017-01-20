--dict_special_task table
 
dict_special_task = {
    ["10001"] = {task_id = "10001", level = "3", content = "use a booster", type = "use_booster", condition = {level = {3}}, reward_type = "1003", count = "10", view = "BoostTaskView"},
    ["10002"] = {task_id = "10002", level = "3", content = "Rate on us", type = "rate", condition = {level = {4,7,9},coins_below = 200}, reward_type = "1000", count = "5000", view = "RateTaskView"},
    ["10003"] = {task_id = "10003", level = "4", content = "connect facebook", type = "connect_facebook", condition = {level = {5,10,12},coins_below = 500}, reward_type = "1000", count = "5000", view = "FBConnectView"}
}

    

