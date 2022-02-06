local suspiciousVehicles = {}
local copModelIDs = {
  [302] = true,
  [271] = true,
  [280] = true,
  [269] = true,
  [265] = true,
  [267] = true
}
local function ClosestSuspiciousVehicleFromPlayer()
  local playerVehicle = SuspiciousVehicleManager.GetVehicleBeingWatched()
  local closestSuspiciousVehicle
  local closestSuspiciousVehicleDistance = 5000
  for i = 1, #suspiciousVehicles do
    local currentDistance = vec.vector():sub(playerVehicle.position, suspiciousVehicles[i].position):length()
    if currentDistance < closestSuspiciousVehicleDistance then
      closestSuspiciousVehicleDistance = currentDistance
      closestSuspiciousVehicle = suspiciousVehicles[i]
    end
  end
  return closestSuspiciousVehicleDistance, closestSuspiciousVehicle
end

local startTime = 0
local delayActive = false
local getawayCar = nil
local distanceFromGetaway = 5000
local userUpdateActive = false
local function DelayToStartChase()
  if g_NetworkTime > startTime + 3 then
    startFelony(getawayCar,SuspiciousVehicleManager.GetVehicleBeingWatched())
    userUpdateActive = false
    removeUserUpdateFunction("TriggerChaseWithoutHit")
    removeUserUpdateFunction("3secDelayThenStart")
  end
end

local function TriggerChaseWithoutHit()
  if localPlayer.inZap or not copModelIDs[localPlayer.currentVehicle.model_id] or Chase.IsAChaseActive() then
    removeUserUpdateFunction("TriggerChaseWithoutHit")
    removeUserUpdateFunction("3secDelayThenStart")
  end
  distanceFromGetaway, getawayCar = ClosestSuspiciousVehicleFromPlayer()
  if distanceFromGetaway < 15 and not delayActive then
    startTime = g_NetworkTime
    delayActive = true
    addUserUpdateFunction("3secDelayThenStart",DelayToStartChase,10)
  elseif distanceFromGetaway > 15 and delayActive then
    delayActive = false
    removeUserUpdateFunction("3secDelayThenStart")
  end
end

function suspiciousVehicleAdded(suspiciousGameVehicle)
  collision_system.RegisterCollisionCallback(suspiciousGameVehicle, collisionCallback)
  table.insert(suspiciousVehicles,suspiciousGameVehicle)
  if #suspiciousVehicles > 0 and not userUpdateActive then
    addUserUpdateFunction("TriggerChaseWithoutHit",TriggerChaseWithoutHit,10)
  end
end
function suspiciousVehicleRemoved(suspiciousGameVehicle)
  collision_system.UnRegisterCollisionCallback(suspiciousGameVehicle, collisionCallback)
  for i = 1, #suspiciousVehicles do
    if suspiciousVehicles[i] == suspiciousGameVehicle then
      table.remove(suspiciousVehicles,i)
      break
    end
  end
  table.remove(suspiciousVehicles,suspiciousGameVehicle)
  if #suspiciousVehicles == 0 and userUpdateActive then
    removeUserUpdateFunction("TriggerChaseWithoutHit")
    userUpdateActive = false
  end
end