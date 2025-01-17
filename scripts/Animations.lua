-- + Made by Jimmy Hellp
-- + Thanks to KitCat for help with some of the code!

local path = animations.Cervitaur
local model = models.Cervitaur.Player
local velocity = vec(0, 0, 0)
local kbCrouch = keybinds:newKeybind("Crouch Blocker", keybinds:getVanillaKey("key.sneak"))

-- If you want an animation to stop all other animations in the template, add it to this table. 
-- These aren't exclusive to each other but could be made to be using the allVar, incluVar, and/or excluVar variables when deciding to play the new emote
local allAnims = {
  -- Example animation in table (except like... don't make it a comment):
  -- animations.example.example,
}

-- If you want an animation to stop all exclusive animations in the template (walking, idling, flying, swimming, etc), add it to this table
local excluAnims = {

}

-- If you want an animation to stop all inclusive animations in the template (eating, punching, using a bow or crossbow, etc), add it to this table
local incluAnims = {

}

local hp = 20
local oldhp = 20
local animsTable={
  allVar = false,
  excluVar = false,
  incluVar = false
}
local cFlying = false
local oldcFlying = cFlying
local flying = false
local flyTimer = 0

function events.entity_init()
  hp = player:getHealth() + player:getAbsorptionAmount()
  oldhp = hp
end

function pings.JimmyAnims_cFly(x)
  flying = x
end

local idleTimer = 0
function events.RENDER(delta)
  idleTimer = world.getTime(delta)
end

function events.TICK()
  for key, value in ipairs(allAnims) do
    if value:getPlayState() == "PLAYING" then
      animsTable.allVar = true
      break
    else
      animsTable.allVar = false
    end
  end
  for key, value in ipairs(excluAnims) do
    if value:getPlayState() == "PLAYING" then
      animsTable.excluVar = true
      break
    else
      animsTable.excluVar = false
    end
  end
  for key, value in ipairs(incluAnims) do
    if value:getPlayState() == "PLAYING" then
      animsTable.incluVar = true
      break
    else
      animsTable.incluVar = false
    end
  end
  if host:isHost() then
    cFlying = host:isFlying()
    if cFlying ~= oldcFlying then
      pings.JimmyAnims_cFly(cFlying)
    end
    oldcFlying = cFlying
    
    flyTimer = flyTimer + 1
    if flyTimer % 200 == 0 then
      pings.JimmyAnims_cFly(cFlying)
    end
  end
  
  oldhp = hp
  hp = player:getHealth() + player:getAbsorptionAmount()
  posing = player:getPose()
  local stand = posing == "STANDING"
  local crouch = posing == "CROUCHING" or path.forcecrouch:isPlaying()
  local swim = posing == "SWIMMING"
  local gliding = posing == "FALL_FLYING"
  velocity = player:getVelocity()
  local water = player:isInWater()
  local vehicle = player:getVehicle() ~= nil
  local climbing = player:isClimbing()
  local movingstate = (climbing and velocity:length() > 0) or flying or vehicle or not stand
  local sprint = player:isSprinting()
  local flystate = flying and not vehicle
  local handedness = player:isLeftHanded()
  local rightActive = handedness and "OFF_HAND" or "MAIN_HAND"
  local leftActive = not handedness and "OFF_HAND" or "MAIN_HAND"
  local activeness = player:getActiveHand()
  local using = player:isUsingItem()
  local pv = player:getVelocity():mul(1, 0, 1):normalize()
  local pl = models:partToWorldMatrix():applyDir(0,0,-1):mul(1, 0, 1):normalize()
  local fwd = pv:dot(pl)
  local backwards = fwd < -.8
  local sleeping = posing == "SLEEPING"
  local rightSwing = player:getSwingArm() == rightActive and not sleeping
  local leftSwing = player:getSwingArm() == leftActive and not sleeping
  local rightItem = player:getHeldItem(handedness)
  local leftItem = player:getHeldItem(not handedness)
  local usingR = activeness == rightActive and rightItem:getUseAction()
  local usingL = activeness == leftActive and leftItem:getUseAction()
  
  local crossR = rightItem.tag and rightItem.tag["Charged"] == 1
  local crossL = leftItem.tag and leftItem.tag["Charged"] == 1
  local drinkingR = using and usingR == "DRINK"
  local drinkingL = using and usingL == "DRINK"
  local eatingR = (using and usingR == "EAT") or (drinkingR and not path.drinkingR)
  local eatingL = (using and usingL == "EAT") or (drinkingL and not path.drinkingL)
  local blockingR = using and usingR == "BLOCK"
  local blockingL = using and usingL == "BLOCK"
  local bowingR = using and usingR == "BOW"
  local bowingL = using and usingL == "BOW"
  local spearR = using and usingR == "SPEAR"
  local spearL = using and usingL == "SPEAR"
  local spyglassR = using and usingR == "SPYGLASS"
  local spyglassL = using and usingL == "SPYGLASS"
  local hornR = using and usingR == "TOOT_HORN"
  local hornL = using and usingL == "TOOT_HORN"
  local loadingR = using and usingR == "CROSSBOW"
  local loadingL = using and usingL == "CROSSBOW"
  local flyupstate = flystate and velocity.y > 0
  local flydownstate = flystate and velocity.y < 0
  local flysprintstate = flystate and sprint and velocity.y == 0
  local flywalkbackstate = flystate and backwards and velocity.y == 0
  local flywalkstate = (flystate and velocity:length() > 0 and velocity.y == 0 and not sprint and not backwards) or (flysprintstate and not path.flysprint) or (flywalkbackstate and not path.flywalkback)
  or (flyupstate and not path.flyup) or (flydownstate and not path.flydown)
  local flyidlestate = (flystate and velocity:length() == 0) or (flywalkstate and not path.flywalk)
  local crouchwalkbackstate = crouch and backwards
  local crouchwalkstate = (crouch and velocity:length() > 0  and not backwards) or (crouchwalkbackstate and not path.crouchwalkback)
  local crouchstate =  (crouch and velocity:length() == 0) or (crouchwalkstate and not path.crouchwalk)
  local crawlstillstate = (swim and not water or posing == "CRAWLING") and velocity:length() == 0
  local crawlstate = ((swim and not water or posing == "CRAWLING") and velocity:length() > 0) or (crawlstillstate and not path.crawlstill)
  local swimstate = (swim and water) or (crawlstate and not path.crawl)
  local elytradownstate = gliding and velocity.y < 0
  local elytrastate = (gliding and velocity.y > 0) or (elytradownstate and not path.elytradown)
  local vehiclestate = vehicle
  local sleepstate = sleeping
  local climbstate = climbing and not crouch and velocity:length() > 0
  local tridentstate = posing == "SPIN_ATTACK"
  local fallstate = not movingstate and velocity.y < -.6
  local jumpdownstate = (not movingstate and ((velocity.y < -.0625 and not water) or (velocity.y < 0 and water)) and velocity.y > -.6) or (fallstate and not path.fall)
  local jumpupstate =  (not movingstate and velocity.y > 0.07 and not flying) or (tridentstate and not path.trident) or (jumpdownstate and not path.jumpdown)
  local jumpingstate = jumpdownstate or jumpupstate or fallstate
  local deadstate = hp == 0
  local sprintstate = not movingstate and not jumpingstate and sprint and stand
  local walkbackstate = not movingstate and not jumpingstate and velocity:length() > 0 and not sprint and stand and backwards
  local walkstate = (not movingstate and not jumpingstate and velocity:length() > 0 and not sprint and stand and not backwards) 
  or (walkbackstate and not path.walkback) or (sprintstate and not path.sprint) or (climbstate and not path.climb) or (swimstate and not path.swim) or (elytrastate and not path.elytra)
  or (jumpupstate and not path.jumpup)
  local idlestate = (not movingstate and velocity:length() == 0 and (stand or swim and not water)) or (sleepstate and not path.sleep) or (vehiclestate and not path.vehicle) or (flyidlestate and not path.fly)
  
  if oldhp > hp and hp ~= 0 and oldhp ~= 0 then
    if path.hurt then path.hurt:restart() end
  end
  
  local exclustate = (not animsTable.allVar and not animsTable.excluVar) and not deadstate
  local inclustate = not animsTable.allVar and not animsTable.incluVar
  
  local blockCheck = world.getBlockState(player:getPos() + vec(0, 2, 0)):hasCollision()
  local disableCrouch = gliding
  kbCrouch:onPress(function() return disableCrouch end)
  
  -- Exclusive animations
  path.walk:setPlaying(exclustate and walkstate)
  path.idle:setPlaying(exclustate and idlestate)
  path.crouch:setPlaying(exclustate and crouchstate)
  if path.walkback then path.walkback:setPlaying(exclustate and walkbackstate) end
  if path.sprint then path.sprint:setPlaying(exclustate and sprintstate) end
  if path.crouchwalk then path.crouchwalk:setPlaying(exclustate and crouchwalkstate) end
  if path.crouchwalkback then path.crouchwalkback:setPlaying(exclustate and crouchwalkbackstate) end
  if path.elytra then path.elytra:setPlaying(exclustate and elytrastate) end
  if path.elytradown then path.elytradown:setPlaying(exclustate and elytradownstate) end
  if path.fly then path.fly:setPlaying(exclustate and flyidlestate) end
  if path.flywalk then path.flywalk:setPlaying(exclustate and flywalkstate) end
  if path.flywalkback then path.flywalkback:setPlaying(exclustate and flywalkbackstate) end
  if path.flysprint then path.flysprint:setPlaying(exclustate and flysprintstate) end
  if path.flyup then path.flyup:setPlaying(exclustate and flyupstate) end
  if path.flydown then path.flydown:setPlaying(exclustate and flydownstate) end
  if path.vehicle then path.vehicle:setPlaying(exclustate and vehiclestate) end
  if path.sleep then path.sleep:setPlaying(exclustate and sleepstate) end
  if path.climb then path.climb:setPlaying(exclustate and climbstate) end
  if path.swim then path.swim:setPlaying(exclustate and swimstate) end
  if path.crawl then path.crawl:setPlaying(exclustate and crawlstate) end
  if path.crawlstill then path.crawlstill:setPlaying(exclustate and crawlstillstate) end
  if path.fall then path.fall:setPlaying(exclustate and fallstate) end
  if path.jumpup then path.jumpup:setPlaying(exclustate and jumpupstate) end
  if path.jumpdown then path.jumpdown:setPlaying(exclustate and jumpdownstate) end
  if path.trident then path.trident:setPlaying(exclustate and tridentstate) end
  if path.death then path.death:setPlaying(deadstate) end
  
  -- Inexclusive animations
  if path.eatingR then path.eatingR:setPlaying(inclustate and eatingR) end
  if path.eatingL then path.eatingL:setPlaying(inclustate and eatingL) end
  if path.drinkingR then path.drinkingR:setPlaying(inclustate and drinkingR) end
  if path.drinkingL then path.drinkingL:setPlaying(inclustate and drinkingL) end
  if path.blockingR then path.blockingR:setPlaying(inclustate and blockingR) end
  if path.blockingL then path.blockingL:setPlaying(inclustate and blockingL) end
  if path.bowR then path.bowR:setPlaying(inclustate and bowingR) end
  if path.bowL then path.bowL:setPlaying(inclustate and bowingL) end
  if path.crossbowR then path.crossbowR:setPlaying(inclustate and crossR) end
  if path.crossbowL then path.crossbowL:setPlaying(inclustate and crossL) end
  if path.loadingR then path.loadingR:setPlaying(inclustate and loadingR) end
  if path.loadingL then path.loadingL:setPlaying(inclustate and loadingL) end
  if path.spearR then path.spearR:setPlaying(inclustate and spearR) end
  if path.spearL then path.spearL:setPlaying(inclustate and spearL) end
  if path.spyglassR then path.spyglassR:setPlaying(inclustate and spyglassR) end
  if path.spyglassL then path.spyglassL:setPlaying(inclustate and spyglassL) end
  if path.hornR then path.hornR:setPlaying(inclustate and hornR) end
  if path.hornL then path.hornL:setPlaying(inclustate and hornL) end
  if path.attackR then path.attackR:setPlaying(inclustate and rightSwing) end
  if path.attackL then path.attackL:setPlaying(inclustate and leftSwing) end
  
  -- Lean Animation
  path.lean:setPlaying(sprint and not water)
  path.forcecrouch:setPlaying(blockCheck and not player:isCrouching() and (posing == "STANDING" or posing == "CROUCHING"))
  
  -- Stopping arms while moving if not using or swinging
  if require("Config").armMovement == false then
    local firstPerson = renderer:isFirstPerson() and not client.hasResource("firstperson:icon.png")
    local movementCheck = (((velocity.x ~= 0) or (velocity.z ~= 0)) and (not movingstate or flying) and (not water and not swim) and not vehicle)
    local leftStop = (movementCheck and not leftSwing and not ((crossL or crossR) or (using and usingL ~= "NONE")) and not firstPerson)
    local rightStop = (movementCheck and not rightSwing and not ((crossL or crossR) or (using and usingR ~= "NONE")) and not firstPerson)
    model.LeftArm:setRot(leftStop and vec(-math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, -math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05)) or vec(0,0,0))
    model.RightArm:setRot(rightStop and vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05)) or vec(0,0,0))
    model.LeftArm:setParentType(leftStop and "Body" or "LeftArm")
    model.RightArm:setParentType(rightStop and "Body" or "RightArm")
  end
end

do
  local bodyCurrent = 0
  local bodyNextTick = 0
  local bodyTarget = 0
  local bodyCurrentPos = 0
  
  local mergeCurrent = 0
  local mergeNextTick = 0
  local mergeTarget = 0
  local mergeCurrentPos = 0
  
  local yawCurrent = 0
  local yawNextTick = 0
  local yawTarget = 0
  local yawCurrentPos = 0
  
  -- Gradual Values
  function events.TICK()
    bodyCurrent = bodyNextTick
    bodyNextTick = math.lerp(bodyNextTick, bodyTarget, 0.5)
    mergeCurrent = mergeNextTick
    mergeNextTick = math.lerp(mergeNextTick, mergeTarget, 0.5)
    yawCurrent = yawNextTick
    yawNextTick = math.lerp(yawNextTick, yawTarget, 1)
  end
  
  local staticYaw = 0
  function events.ENTITY_INIT()
    staticYaw = player:getBodyYaw()
  end
  
  -- Lower Body Rotation + Merge Stretch
  local yawLimit = 45
  function events.RENDER(delta)
    local shouldRot = not (player:getPose() == "SWIMMING") and not player:getVehicle() and not flying and not player:isClimbing() and ((player:getPose() == "STANDING") or (player:getPose() == "CROUCHING"))
    local standing = (player:getPose() == "STANDING" or player:getPose() == "CROUCHING")
    
    local bodyYaw = player:getBodyYaw()
    local yawLimitL = bodyYaw - yawLimit
    local yawLimitR = bodyYaw + yawLimit
    
    if velocity.xz:length() ~= 0 or not standing or (player:isInWater() and not player:isOnGround()) or player:getVehicle() ~= nil then
      staticYaw = bodyYaw
    elseif staticYaw < yawLimitL then
      staticYaw = yawLimitL
    elseif staticYaw > yawLimitR then
      staticYaw = yawLimitR
    end
    
    bodyTarget = shouldRot and math.clamp(velocity.y * 100, -27.5, 27.5) or 0
    mergeTarget = shouldRot and math.clamp(velocity.y * 2 + 1, 0.5, 1.5) or 1
    bodyCurrentPos = math.lerp(bodyCurrent, bodyNextTick, delta)
    mergeCurrentPos = math.lerp(mergeCurrent, mergeNextTick, delta)
    yawTarget = bodyYaw - staticYaw
    yawCurrentPos = math.lerp(yawCurrent, yawNextTick, delta)
    local yawPos = math.map(yawCurrentPos, -45, 45, 2, -2)
    
    model:setPos(-yawPos, 0, -math.abs(yawPos))
    
    model.LowerBody:setPos(yawPos, 0, math.abs(yawPos))
    model.LowerBody:setOffsetRot(bodyCurrentPos, yawCurrentPos, 0)
    
    model.Body.Merge:setScale(1, mergeCurrentPos, math.abs(yawCurrentPos / 45) + 1)
    model.Body.Merge:setOffsetRot(0, yawCurrentPos / 7.5, 0)
  end
end

-- Fixing spyglass jank
function events.RENDER(delta)
  local rot = vanilla_model.HEAD:getOriginRot()
  rot.x = math.clamp(rot.x, -90, 30)
  model.Spyglass:setRot(rot)
end

-- Animation Speeds
function events.RENDER(delta)
  path.walk:speed(math.clamp(velocity:length() * 5.5, 0, 2))
  path.walkback:speed(math.clamp(velocity:length() * 5.5, 0, 2))
  path.crouchwalk:speed(math.clamp(velocity:length() * 5.5, 0, 2))
  path.crouchwalkback:speed(math.clamp(velocity:length() * 5.5, 0, 2))
  path.sprint:speed(math.clamp(velocity:length() * 6, 0, 2))
  path.swim:speed(math.clamp(velocity:length() * 3, 0, 1.5))
end

-- Animation Blend Control
function events.RENDER(delta)
  path.walk:blend(math.clamp(velocity.xz:length() * 5, 0, 1))
  path.walkback:blend(math.clamp(velocity.xz:length() * 5, 0, 1))
  path.sprint:blend(math.clamp(velocity.xz:length() * 4, 0, 1))
  path.lean:blend(math.clamp(velocity.xz:length() * 4, 0, 1))
end

-- Breathing Control
do
  local speed = 0
  local lastSpeed = 0
  function events.TICK()
    lastSpeed = speed
    speed = speed + (velocity:length() * ((flying or posing == "FALL_FLYING") and 1 or 15) + 1) * 0.05
  end
  
  function events.RENDER(delta)
    local scale = math.sin(math.lerp(lastSpeed, speed, delta)) * 0.0125 + 1.0125
    local apply = vec(scale, scale, 1)
    model.LowerBody.LowerBodyCubesFront.Main:setScale(apply)
    model.LowerBody.LowerBodyCubesFront.Front:setScale(apply.xyx)
    model.LowerBody.LowerBodyLayer.Main:setScale(apply)
    model.LowerBody.LowerBodyLayer.Front:setScale(apply.xyx)
  end
end

require("lib.GSAnimBlend")

-- GS Blending Setup
local blendAnims = {
	{ anim = path.idle,           ticks = {4,4}   },
	{ anim = path.walk,           ticks = {8,8}   },
	{ anim = path.walkback,       ticks = {8,8}   },
	{ anim = path.sprint,         ticks = {4,4}   },
	{ anim = path.lean,           ticks = {4,4}   },
	{ anim = path.crouch,         ticks = {4,4}   },
	{ anim = path.crouchwalk,     ticks = {4,4}   },
	{ anim = path.crouchwalkback, ticks = {4,4}   },
	{ anim = path.jumpup,         ticks = {6,6}   },
	{ anim = path.jumpdown,       ticks = {6,6}   },
	{ anim = path.elytra,         ticks = {4,4}   },
	{ anim = path.vehicle,        ticks = {10,10} },
	{ anim = path.sleep,          ticks = {10,10} },
	{ anim = path.climb,          ticks = {8,8}   },
	{ anim = path.swim,           ticks = {10,10} },
	{ anim = path.crawl,          ticks = {4,4}   },
	{ anim = path.crawlstill,     ticks = {4,4}   },
	{ anim = path.trident,        ticks = {8,8}   },
	{ anim = path.fly,            ticks = {10,10} }
}

-- Apply GS Blending
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(table.unpack(blend.ticks)):blendCurve("easeOutQuad")
end

-- If you're choosing to edit this script, don't put anything beneath the return line

return animsTable