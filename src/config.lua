
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- display FPS stats on screen
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

-- design resolution
CONFIG_SCREEN_WIDTH  = 1024
CONFIG_SCREEN_HEIGHT = 768

-- auto scale mode
-- CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"

CONFIG_SCREEN_AUTOSCALE_CALLBACK = function(w, h, deviceModel)

    if (w == 1024 and h == 768) or (w == 2048 and h == 1536) then
        -- iPad
        CONFIG_SCREEN_WIDTH = 1024
        CONFIG_SCREEN_HEIGHT = 768

        return w / 1024, h / 768
    end
end

