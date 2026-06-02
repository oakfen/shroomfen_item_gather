Config = {}

-- Distance in meters to interact (press E)
Config.proximityRange = 2

-- Distance in meters to show 3D text at gather points (optional, default: proximityRange * 2)
Config.textDrawDistance = 3

-- Cooldown per gather point in seconds (4 hours = 14400)
Config.cooldownSeconds = 14400

Config.gatherKey = "INPUT_ENTER"

Config.gatherPoints = {
  {
    id = "test_one",
    coords = vector3(-158.29791259765625, 1731.5836181640625, 170.04010009765625),  -- or {x, y, z}
    item = "test_item",
    label = "Gather Test Item",
    amount = 1,  -- optional, default 1
  },
}
