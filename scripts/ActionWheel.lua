--The script that connects various actions accross many scripts into pages.

local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

mainPage:setAction( -1, require("scripts.Saddle"))
mainPage:setAction( -1, require("scripts.Twitching"))

--Enable/Disable Armor page
mainPage:setAction( -1, require("scripts.Armor"))