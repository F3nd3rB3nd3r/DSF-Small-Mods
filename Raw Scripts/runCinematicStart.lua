function runCinematicStart()
local vehicle = localPlayer.currentVehicle.gameVehicle
  local cameras = nil
  
  if bigVehicles[vehicle.model_id] then
	cameras = bigVehicleCameras
  else
	cameras = carCameras
  end
  
  local randomStart = framework.random(1,#cameras)
  local attachCamera = cameras[randomStart][1]

  if not attachCamera.lookAt then
	attachCamera[1].lookAt = vehicle
  end

  if not attachCamera.lookFrom then
	attachCamera[1].lookFrom = vehicle
  end

  vehicle.visualLodHint = "" 
  CameraSystem.SetClippingPlanesForKidnappedBootShot(true) 
  CameraSystem.AddScene(attachCamera)  
  
  local startTime = g_NetworkTime
  addUserUpdateFunction("camSetup", function() 
	if(g_NetworkTime > startTime + 1) then 
		local attachCamera2 = cameras[randomStart][2]
		if not attachCamera2.lookAt then
			attachCamera2[1].lookAt = vehicle
		end

		if not attachCamera2.lookFrom then
			attachCamera2[1].lookFrom = vehicle
		end
		vehicle.visualLodHint = ""  
		CameraSystem.SetClippingPlanesForKidnappedBootShot(true)   
		CameraSystem.AddScene(attachCamera2) 
		removeUserUpdateFunction("camSetup") 
    end  
	end  
  , 1) 
end