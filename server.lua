local cooldowns = {} -- [source][pointId] = timestamp when they can gather again

local function getPointById(id)
  for _, point in ipairs(Config.gatherPoints) do
    if point.id == id then
      return point
    end
  end
  return nil
end

local function isOnCooldown(source, pointId)
  if not cooldowns[source] then
    return false
  end
  local nextAllowed = cooldowns[source][pointId]
  if not nextAllowed then
    return false
  end
  return os.time() < nextAllowed
end

local function setCooldown(source, pointId)
  if not cooldowns[source] then
    cooldowns[source] = {}
  end
  cooldowns[source][pointId] = os.time() + Config.cooldownSeconds
end

RegisterNetEvent("shroomfen_item_gather:gather")
AddEventHandler("shroomfen_item_gather:gather", function(pointId)
  local source = source
  if not source or source == 0 then return end

  local point = getPointById(pointId)
  if not point then
    TriggerClientEvent("shroomfen_item_gather:notifyError", source, "Invalid gather location.")
    return
  end

  if isOnCooldown(source, pointId) then
    local nextTime = cooldowns[source][pointId]
    local remaining = nextTime - os.time()
    local hours = math.floor(remaining / 3600)
    local mins = math.floor((remaining % 3600) / 60)
    TriggerClientEvent("shroomfen_item_gather:notifyError", source,
      ("You must wait %d hours and %d minutes before gathering here again."):format(hours, mins))
    return
  end

  -- Add item via VORP inventory
  exports.vorp_inventory:addItem(source, point.item, point.amount or 1, {}, function(success)
    if success then
      setCooldown(source, pointId)
      TriggerClientEvent("shroomfen_item_gather:notifySuccess", source, point.label:gsub("^Gather ", ""))
    else
      TriggerClientEvent("shroomfen_item_gather:notifyError", source, "Your inventory is full.")
    end
  end)
end)

AddEventHandler("playerDropped", function()
  local source = source
  if cooldowns[source] then
    cooldowns[source] = nil
  end
end)
