local defaultSaddle = require("Config").hasSaddle or false

local function setSaddle(boolean)
  
  models.Cervitaur.Player.LowerBody.Saddle:setVisible(boolean)
  
  if player:isLoaded() then
    sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 0.5)
  end
end

pings.setSaddle = setSaddle

setSaddle(defaultSaddle)
return action_wheel:newAction()
    :title("Toggle Saddle")
    :item("minecraft:barrier")
    :toggleItem("minecraft:saddle")
    :onToggle(pings.setSaddle)
    :toggled(defaultSaddle)