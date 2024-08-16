local twitch = require("Config").canTwitch or false
local animation = animations.Cervitaur

local function setTwitch(boolean)
  twitch = boolean
end

local anims = {
  animation.tailTwitch,
  animation.leftEarTwitch,
  animation.rightEarTwitch,
  nil,
  animation.frontLeftLegTwitch,
  animation.frontRightLegTwitch,
  animation.backLeftLegTwitch,
  animation.backRightLegTwitch
}

function pings.randomAnimation(i)
  if i == 4 then
    animation.leftEarTwitch:play()
    animation.rightEarTwitch:play()
  else
    anims[i]:play()
  end
end

if host:isHost() then
  function events.TICK()
    if twitch then
      local rand = math.random(1, math.max(1, require("Config").twitchChance))
      local sleep = player:getPose() == "SLEEPING"
      if rand == 1 then
        local animPick = math.random(1, (sleep and 8 or 4))
        pings.randomAnimation(animPick)
      end
    end
  end
end

pings.setTwitch = setTwitch

setTwitch(twitch)
return action_wheel:newAction()
    :title("Toggle Twitching Animations")
    :item("minecraft:soul_torch")
    :toggleItem("minecraft:torch")
    :onToggle(pings.setTwitch)
    :toggled(twitch)