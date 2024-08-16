--Script that handles registering parts to the ArmorAPI and it's modules

--Change this if you change the model's name
local model = models.Cervitaur
--Minor optimization. saves like 20 instructions
local modelRoot = model.Player

--Register parts that act as armor
local kattArmor = require("lib.KattArmor")
kattArmor.Armor.Helmet:addParts(modelRoot.Head.Helmet.Helmet)
kattArmor.Armor.Chestplate:addParts(
  modelRoot.Body.Chestplate,
  modelRoot.Body.Merge.Chestplate,
  modelRoot.RightArm.RightChestplate,
  modelRoot.LeftArm.LeftChestplate
)
kattArmor.Armor.Leggings:setLayer(1):addParts(
  modelRoot.Body.Merge.Leggings,
  modelRoot.Body.LeggingsBelt.Leggings,
  modelRoot.LowerBody.LowerBodyLeggings,
  modelRoot.LowerBody.FrontLeftLeg.FrontLeftLeggings.Leggings,
  modelRoot.LowerBody.FrontRightLeg.FrontRightLeggings.Leggings,
  modelRoot.LowerBody.BackLeftLeg.BackLeftLeggings.Leggings,
  modelRoot.LowerBody.BackRightLeg.BackRightLeggings.Leggings
)
kattArmor.Armor.Boots:addParts(
  modelRoot.LowerBody.FrontLeftLeg.FrontLeftLowerLeg.FrontLeftBoots.Boots,
  modelRoot.LowerBody.FrontRightLeg.FrontRightLowerLeg.FrontRightBoots.Boots,
  modelRoot.LowerBody.BackLeftLeg.BackLeftLowerLeg.BackLeftBoots.Boots,
  modelRoot.LowerBody.BackRightLeg.BackRightLowerLeg.BackRightBoots.Boots
)

kattArmor.Materials.leather
    :setTexture(textures["textures.armor.leather"])
    :addParts(kattArmor.Armor.Helmet,
      modelRoot.Head.Helmet.HelmetLeather
    )
    :addParts(kattArmor.Armor.Leggings,
      modelRoot.Body.LeggingsBelt.LeggingsLeather,
      modelRoot.LowerBody.LowerBodyLeggingsLeather,
      modelRoot.LowerBody.FrontLeftLeg.FrontLeftLeggings.LeggingsLeather,
      modelRoot.LowerBody.FrontRightLeg.FrontRightLeggings.LeggingsLeather,
      modelRoot.LowerBody.BackLeftLeg.BackLeftLeggings.LeggingsLeather,
      modelRoot.LowerBody.BackRightLeg.BackRightLeggings.LeggingsLeather
    )
    :addParts(kattArmor.Armor.Boots,
      modelRoot.LowerBody.FrontLeftLeg.FrontLeftLowerLeg.FrontLeftBoots.BootsLeather,
      modelRoot.LowerBody.FrontRightLeg.FrontRightLowerLeg.FrontRightBoots.BootsLeather,
      modelRoot.LowerBody.BackLeftLeg.BackLeftLowerLeg.BackLeftBoots.BootsLeather,
      modelRoot.LowerBody.BackRightLeg.BackRightLowerLeg.BackRightBoots.BootsLeather
    )
kattArmor.Materials.chainmail:setTexture(textures["textures.armor.chainmail"])
kattArmor.Materials.iron:setTexture(textures["textures.armor.iron"])
kattArmor.Materials.golden:setTexture(textures["textures.armor.golden"])
kattArmor.Materials.diamond:setTexture(textures["textures.armor.diamond"])
kattArmor.Materials.netherite:setTexture(textures["textures.armor.netherite"])
kattArmor.Materials.turtle:setTexture(textures["textures.armor.turtle"])

local armorPage = action_wheel:newPage()

local armorActions = {}
pings["Katt$setArmorVisible"] = function(part, bool)
  if part ~= "All" then
    kattArmor.Armor[part]:setMaterial(not bool or nil)
    return
  end
  for partID, action in pairs(armorActions) do
    action:toggled(bool)
    kattArmor.Armor[partID]:setMaterial(not bool or nil)
  end
end
for partID, _ in pairs(kattArmor.Armor) do
  armorActions[partID] = armorPage:newAction()
      :toggled(true)
      :title("Toggle " .. partID)
      :item("minecraft:chainmail_" .. partID:lower())
      :toggleItem("minecraft:diamond_" .. partID:lower())
      :onToggle(function(state)
        pings["Katt$setArmorVisible"](partID, state)
      end)
end

local prevPage

armorPage:newAction()
    :title("Go Back")
    :item("minecraft:barrier")
    :onLeftClick(function()
      action_wheel:setPage(prevPage)
    end)

return action_wheel:newAction()
    :title("Toggle Armor"):toggled(true)
    :item("minecraft:chainmail_chestplate")
    :toggleItem("minecraft:netherite_chestplate")
    :onToggle(function(toggle)
      pings["Katt$setArmorVisible"]("All", toggle)
    end)
    :onRightClick(function()
      prevPage = action_wheel:getCurrentPage()
      action_wheel:setPage(armorPage)
    end)
