local model = models.Cervitaur.Player
local animPos = 0
local lastCorrectTrueHeadPos = vec(0, 0)
function events.RENDER(delta)
  animPos = model:getAnimPos() / 16
  nameplate.ENTITY:pos(player:getPose() ~= "FALL_FLYING" and vec(0, animPos.y + 0.25, 0) or vec(0, 0, 0))
end

if require("Config").matchCamera == true then
  local function fix(a, i) return a==a and a or lastCorrectTrueHeadPos[i] end
  local scale = 1
  
  local camCurrent = 0
  local camNextTick = 0
  local camTarget = 0
  local camCurrentPos = 0
  function events.TICK()
    camCurrent = camNextTick
    camNextTick = math.lerp(camNextTick, camTarget, 0.25)
  end
  
  function events.RENDER(delta)
    local nbt = player:getNbt()
    scale = (nbt["pehkui:scale_data_types"] and nbt["pehkui:scale_data_types"]["pehkui:base"] and nbt["pehkui:scale_data_types"]["pehkui:base"]["scale"]) and player:getNbt()["pehkui:scale_data_types"]["pehkui:base"]["scale"] or 1
    
    local pose = player:getPose()
    local swim = pose == "SWIMMING"
    local crawl = pose == "CRAWLING"
    local elytra = pose == "FALL_FLYING"
    local dir = math.map(player:getLookDir().y, -1, 1, 0, 1 )
    local standing = (pose == "STANDING") or (pose == "CROUCHING")
    local playerPos = player:getPos()
    local trueHeadPos = model.Head:partToWorldMatrix():apply().xz:applyFunc(fix)
    lastCorrectTrueHeadPos:set(trueHeadPos)
    
    camTarget = ((swim or crawl) and playerPos.x_z or vec(trueHeadPos.x, 0, trueHeadPos.y)) - playerPos.x_z
    camCurrentPos = math.lerp(camCurrent, camNextTick, delta) + vec(0, animPos.y + 0.4 * (elytra and 2 or swim and dir or crawl and 0 or 1), 0)
    
    renderer:offsetCameraPivot(camCurrentPos)
    
    model.Head:setVisible(not(renderer:isFirstPerson() and pose == "SLEEPING"))
    renderer:offsetCameraRot(pose == "SLEEPING" and renderer:isFirstPerson() and vec(0, 0, 70) or vec(0, 0, 0))
  end
end