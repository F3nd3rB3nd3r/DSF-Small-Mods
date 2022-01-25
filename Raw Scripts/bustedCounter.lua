local copCars = {
  [267] = true,
  [271] = true,
  [280] = true,
  [269] = true,
  [265] = true,
  [302] = true
}
local effectActive = false
local bustedTime = 5
local startTime = nil
local bustedRadius = 25
local maximumBustedSpeed = 5
local promptActive = false
local oneSecRate = 100 / bustedTime
function getawayBustedCounter()
    print("getawayBustedCounter")
    local getawayGameVehicle = localPlayer.primaryFelony.getawayGameVehicle
    if copCars[localPlayer.currentVehicle.gameVehicle.model_id] and
    getawayGameVehicle.speed < maximumBustedSpeed and
    distanceCalculation(getawayGameVehicle,bustedRadius) and not effectActive then
        effectActive = true
        startTime = g_NetworkTime
    end
    if effectActive and startTime then
        if not promptActive then
             --feedbackSystem.menusMaster.masterSetVariable("iPrompt_M_Secondary_Display", 1)
			 feedbackSystem.menusMaster.masterSetVariable("iScore_Feedback_Gauge_State", 1)
             promptActive = true
        end
        --feedbackSystem.menusMaster.masterSetTextVariable("prompt_secondary", string.format("BUSTED IN %.0d",startTime + bustedTime - g_NetworkTime + 1))
		feedbackSystem.menusMaster.masterSetVariable("iScore_Feedback_Gauge", (startTime + bustedTime - startTime) * oneSecRate)
    end
    if effectActive and startTime and g_NetworkTime > startTime + bustedTime then
        bustedCounterCleanUp()
    end
    if not distanceCalculation(getawayGameVehicle,bustedRadius) or getawayGameVehicle.speed > maximumBustedSpeed or not copCars[localPlayer.currentVehicle.gameVehicle.model_id] then
        effectActive = false
        if promptActive then
            --feedbackSystem.menusMaster.masterSetVariable("iPrompt_M_Secondary_Display", 0)
			feedbackSystem.menusMaster.masterSetVariable("iScore_Feedback_Gauge_State", 2)
            promptActive = false
        end
    end
    if getawayGameVehicle.damage > 0.995 or not Chase.IsAChaseActive() then
        bustedCounterCleanUp()
    end
end

function bustedBar(show)

end

function distanceCalculation(getawayGameVehicle,bustedRadius)
	if not Chase.GetZapReturnChaser() then
		return vec.vector():sub(localPlayer.currentVehicle.position, getawayGameVehicle.position):length() < bustedRadius
	else
		return vec.vector():sub(localPlayer.currentVehicle.position, getawayGameVehicle.position):length() < bustedRadius or vec.vector():sub(Chase.GetZapReturnChaser().position, getawayGameVehicle.position):length() < bustedRadius
	end
end

function bustedCounterCleanUp()
    local getawayGameVehicle = localPlayer.primaryFelony.getawayGameVehicle
    --feedbackSystem.menusMaster.masterSetVariable("iPrompt_M_Secondary_Display", 0)
    feedbackSystem.menusMaster.masterSetVariable("iScore_Feedback_Gauge_State", 0)
    felony_chase.wrecked(getawayGameVehicle)
    getawayGameVehicle.damage = 1
    Chase.StopAll()
    effectActive = false
    startTime = nil
    removeUserUpdateFunction("getawayBustedCounter")
end