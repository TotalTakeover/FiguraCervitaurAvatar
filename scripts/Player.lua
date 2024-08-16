--Configures the ModelParts that mimic vanilla parts.

--Change this if you change the bbmodel's name
local model = models.Cervitaur
--Minor optimization. Saves like 20 instructions lol
local modelRoot = model.Player

local vanillaSkinParts = {
  modelRoot.Head.Head,
  modelRoot.Head.Hat_Layer,

  modelRoot.Body.Body,
  modelRoot.Body.BodyLayer,
  modelRoot.Body.Merge.Body,
  modelRoot.Body.Merge.Layer,

  modelRoot.RightArm.RightSteve,
  modelRoot.RightArm.RightSlim,

  modelRoot.LeftArm.LeftSteve,
  modelRoot.LeftArm.LeftSlim,
}
for _, part in pairs(vanillaSkinParts) do
  part:setPrimaryTexture(require("Config").usesPlayerSkin and "SKIN" or nil)
end

modelRoot.Body.Cape:setPrimaryTexture(require("Config").usesPlayerSkin and "CAPE" or nil)

--Sets the modelType of the avatar.
local slim = require("Config").isSlim or false
modelRoot.LeftArm.LeftSteve:setVisible(not slim and nil)
modelRoot.RightArm.RightSteve:setVisible(not slim and nil)

modelRoot.LeftArm.LeftSlim:setVisible(slim and nil)
modelRoot.RightArm.RightSlim:setVisible(slim and nil)

--Show/hide skin layers depending on Skin Customization settings
---@type table<PlayerAPI.skinLayer|string,ModelPart[]>
local layerParts = {
  HAT = {
    modelRoot.Head.Hat_Layer,
  },
  JACKET = {
    modelRoot.Body.BodyLayer,
    modelRoot.Body.Merge.Layer,
    modelRoot.LowerBody.LowerBodyLayer
  },
  RIGHT_SLEEVE = {
    modelRoot.RightArm.RightSteve.RightArmLayerSteve,
    modelRoot.RightArm.RightSlim.RightArmLayerSlim,
  },
  LEFT_SLEEVE = {
    modelRoot.LeftArm.LeftSteve.LeftArmLayerSteve,
    modelRoot.LeftArm.LeftSlim.LeftArmLayerSlim,
  },
  RIGHT_PANTS_LEG = {
    modelRoot.LowerBody.FrontRightLeg.Layer,
    modelRoot.LowerBody.FrontRightLeg.FrontRightLowerLeg.Layer,
    modelRoot.LowerBody.BackRightLeg.Layer,
    modelRoot.LowerBody.BackRightLeg.BackRightLowerLeg.Layer
  },
  LEFT_PANTS_LEG = {
    modelRoot.LowerBody.FrontLeftLeg.Layer,
    modelRoot.LowerBody.FrontLeftLeg.FrontLeftLowerLeg.Layer,
    modelRoot.LowerBody.BackLeftLeg.Layer,
    modelRoot.LowerBody.BackLeftLeg.BackLeftLowerLeg.Layer
  },
  CAPE = {
    modelRoot.Body.Cape,
  },
}
function events.TICK()
  for playerPart, parts in pairs(layerParts) do
    local enabled = true
    enabled = player:isSkinLayerVisible(playerPart)
    enabled = enabled and nil
    for _, part in ipairs(parts) do
      part:setVisible(enabled)
    end
  end
  modelRoot.LowerBody:setVisible(player:getGamemode() ~= "SPECTATOR")
end

if not require("Config").antlers then
  log("Yep")
  modelRoot.Head.Antlers:setVisible(false)
  modelRoot.Head.Helmet:setUVPixels(32, 0)
end