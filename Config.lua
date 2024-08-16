local Config = {
  -- Should the model get textures from the player's skin?
  usesPlayerSkin = true,
  -- Should the model use Slim proportions, or Regular proportions?
  isSlim = true,
  -- Should the avatar have antlers?
  antlers = true,
  -- Should you be wearing a saddle by default?
  hasSaddle = false,
  -- Should your arms have movement while moving? (except when swimming or crawling)
  armMovement = false,
  -- Should "Twitching" animations play? 
  -- Chance is 1 out of "twitchChance" every tick, 1 = 100%, 100 = 1%, 125 = 0.8% (recommended)
  -- When Chance is met, 1 of 4 possible twitch animations will play (1 of 8 when sleeping)
  canTwitch = true,
  twitchChance = 125,
  -- Should your Camera match your head's position? (Recommend First Person Mod)
  matchCamera = false,
}
return Config