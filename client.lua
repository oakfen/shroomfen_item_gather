
local promptGroup = "shroomfen_gather"
local currentNearbyPoint = nil

local function initPrompts()
  local gatherKey = Config.gatherKey or "INPUT_ENTER"
  jo.prompt.create(promptGroup, "Gather", gatherKey, false)
  jo.prompt.setVisible(promptGroup, gatherKey, false)
end

local function drawText3D(coords, text)
  local x, y, z = coords.x, coords.y, coords.z + 0.5
  local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)
  if not onScreen then return end
  SetTextScale(0.30, 0.30)
  SetTextFontForCurrentCommand(0)
  SetTextColor(255, 255, 255, 215)
  SetTextCentre(true)
  SetTextDropshadow(1, 0, 0, 0, 255)
  DisplayText(CreateVarString(10, "LITERAL_STRING", text), screenX, screenY)
end

local function getPointCoords(point)
  local c = point.coords
  if type(c) == "table" and not c.x then
    return vector3(c[1], c[2], c[3])
  end
  return c
end

local function getClosestGatherPoint()
  local ped = PlayerPedId()
  local coords = GetEntityCoords(ped)
  local closestPoint = nil
  local closestDist = Config.proximityRange

  for _, point in ipairs(Config.gatherPoints) do
    local pointCoords = getPointCoords(point)
    local dist = #(coords - pointCoords)
    if dist < closestDist then
      closestDist = dist
      closestPoint = point
    end
  end

  return closestPoint
end

local textDrawDistance = Config.textDrawDistance or ((Config.proximityRange or 5) * 1)

CreateThread(function()
  initPrompts()
end)

CreateThread(function()
  if not Config.gatherPoints or #Config.gatherPoints == 0 then
    return
  end
  while true do
    local sleep = 500
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local point = getClosestGatherPoint()
    local gatherKey = Config.gatherKey or "INPUT_ENTER"

    -- Draw 3D text at each gather point within text draw distance
    for _, p in ipairs(Config.gatherPoints) do
      local pCoords = getPointCoords(p)
      local dist = #(coords - pCoords)
      if dist < textDrawDistance then
        sleep = 0
        drawText3D(pCoords, p.label)
      end
    end

    if point then
      sleep = 0
      if currentNearbyPoint ~= point then
        currentNearbyPoint = point
        jo.prompt.editKeyLabel(promptGroup, gatherKey, "[E] " .. point.label)
        jo.prompt.setVisible(promptGroup, gatherKey, true)
      end
      jo.prompt.displayGroup(promptGroup, point.label)

      if jo.prompt.isCompleted(promptGroup, gatherKey) then
        TriggerServerEvent("shroomfen_item_gather:gather", point.id)
        currentNearbyPoint = nil
        jo.prompt.setVisible(promptGroup, gatherKey, false)
        Wait(500)
      end
    else
      if currentNearbyPoint then
        currentNearbyPoint = nil
        jo.prompt.setVisible(promptGroup, gatherKey, false)
      end
    end

    Wait(sleep)
  end
end)

-- Success notification (triggered from server)
RegisterNetEvent("shroomfen_item_gather:notifySuccess")
AddEventHandler("shroomfen_item_gather:notifySuccess", function(itemLabel)
  jo.notif.rightSuccess("You gathered " .. (itemLabel or "the item") .. ".")
end)

-- Error notification (triggered from server)
RegisterNetEvent("shroomfen_item_gather:notifyError")
AddEventHandler("shroomfen_item_gather:notifyError", function(message)
  jo.notif.rightError(message or "You cannot gather here yet.")
end)
