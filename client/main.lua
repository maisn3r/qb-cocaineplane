QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function() 
    while true do
	Citizen.Wait(30 * 60000)
	print('DOSE')
	TriggerServerEvent('qb-cocaineplane:updateTable', false)
    end
end)

local inUse = false
local process 
local coord 
local location = nil
local enroute
local fueling
local dodo
local delivering
local hangar
local jerrycan
local checkPlane
local airplane
local planehash
local driveHangar
local blip
local isProcessing = false

Citizen.CreateThread(function()
    QBCore.Functions.TriggerCallback('qb-cocaineplane:processcoords', function(servercoords)
        process = servercoords
	end)
end)

Citizen.CreateThread(function()
    QBCore.Functions.TriggerCallback('qb-cocaineplane:startcoords', function(servercoords)
        coord = servercoords
	end)
end)

Citizen.CreateThread(function()
	local sleep
	while not coord do
		Citizen.Wait(0)
	end
	while true do
		sleep = 5
		local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.6, 0)
		local pos = GetEntityCoords(ped)
		local player = PlayerPedId()
		local playercoords = GetEntityCoords(player)
		local dist = #(vector3(playercoords.x, playercoords.y, playercoords.z)-vector3(coord.x, coord.y, coord.z))
		if not inUse then
			if dist <= 1 then
				sleep = 5
				DrawText3D(coord.x, coord.y, coord.z, '~b~E~w~ - Rent Plane')
				if IsControlJustPressed(1, 51) then
					QBCore.Functions.TriggerCallback('qb-cocaineplane:pay', function(success)
						if success then
							TriggerServerEvent('qb-cocaineplane:server:PoliceAlertMessage', "Suspicious Situation", pos, true)
							main()
						end
					end)
				end
			else
				sleep = 3000
			end
		elseif dist <= 3 and inUse then
			sleep = 5
			DrawText3D(coord.x, coord.y, coord.z, 'Someone has already requested a plane.')
		else
			sleep = 3000
		end
		Citizen.Wait(sleep)
	end
end)

RegisterNetEvent('qb-cocaineplane:syncTable')
AddEventHandler('qb-cocaineplane:syncTable', function(bool)
    inUse = bool
end)

RegisterNetEvent('qb-cocaineplane:onUse')
AddEventHandler('qb-cocaineplane:onUse', function()
	QBCore.Functions.Notify("You used cocaine.", "success")
	local crackhead = PlayerPedId()
	SetPedArmour(crackhead, 30)
	SetTimecycleModifier("DRUG_gas_huffin")
	Citizen.Wait(Config.cokeTime)
	DoScreenFadeOut(1000)
	Citizen.Wait(1000)
	DoScreenFadeIn(2000)
	QBCore.Functions.Notify("You are feeling normal now.", "success")
	SetPedArmour(crackhead, 0)
	ClearTimecycleModifier()
end)

function main()
	local player = PlayerPedId()
	SetEntityCoords(player, coord.x-0.1,coord.y-0.1,coord.z-1, 0.0,0.0,0.0, false)
	SetEntityHeading(player, Config.doorHeading)
	playAnim("anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 49)
	Citizen.Wait(2000)
	TriggerServerEvent('qb-cocaineplane:updateTable', true)
	rand = math.random(1,#Config.locations)
	location = Config.locations[rand]
	blip1 = AddBlipForCoord(location.fuel.x,location.fuel.y,location.fuel.z)
	enroute = true
	Citizen.CreateThread(function()
		while enroute do
			sleep = 5	
			local player = PlayerPedId()
			playerpos = GetEntityCoords(player)
			local disttocoord = #(vector3(location.fuel.x,location.fuel.y,location.fuel.z)-vector3(playerpos.x,playerpos.y,playerpos.z))
			if disttocoord <= 20 then
				PlaneSpawn()
				enroute = false
			else
				sleep = 1500
			end
			Citizen.Wait(sleep)
		end
	end)
end

RegisterNetEvent('qb-cocaineplane:client:PoliceAlertMessage')
AddEventHandler('qb-cocaineplane:client:PoliceAlertMessage', function(title, coords, blip)
    if blip then
        TriggerEvent('qb-policealerts:client:AddPoliceAlert', {
            timeOut = 5000,
            alertTitle = title,
            details = {
                [1] = {
                    icon = '<i class="fas fa-gem"></i>',
                    detail = "Suspicious Activity",
                },
                [2] = {
                    icon = '<i class="fas fa-video"></i>',
                    detail = "Not Available",
                },
                [3] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = "Cayo Perico Airport",
                },
            },
            callSign = QBCore.Functions.GetPlayerData().metadata["callsign"],
        })
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        Citizen.Wait(100)
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        Citizen.Wait(100)
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        local transG = 100
        local blip = AddBlipForRadius(vector3(4472.75, -4497.2, 4.95), 100.0)
        SetBlipSprite(blip, 9)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, transG)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("DISPATCH: Suspicious Activity")
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 * 4)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

function PlaneSpawn()
if DoesEntityExist(airplane) then
	SetVehicleHasBeenOwnedByPlayer(airplane,false)
	SetEntityAsNoLongerNeeded(airplane)
	DeleteEntity(airplane)
end
    local planehash = GetHashKey("dodo")
    RequestModel(planehash)
    while not HasModelLoaded(planehash) do
        Citizen.Wait(0)
    end
    airplane = CreateVehicle(planehash, location.parking.x, location.parking.y, location.parking.z, location.parking.h, 100, true, false)
    local plt = GetVehicleNumberPlateText(airplane)
	SetVehicleHasBeenOwnedByPlayer(airplane,true)
	exports['LegacyFuel']:SetFuel(airplane, 100)
	local plate = GetVehicleNumberPlateText(airplane)
	TriggerEvent("vehiclekeys:client:SetOwner", plate)
	RemoveBlip(blip1)	
	dodo = false
	delivering = true
	delivery()
    while true do
    	Citizen.Wait(1)
    	 DrawText3D(location.parking.x, location.parking.y, location.parking.z, "Cocaine Plane.")
		 if #(GetEntityCoords(PlayerPedId()) - vector3(location.parking.x, location.parking.y, location.parking.z)) < 8.0 then
    	 	return
    	   end
     end
end

Citizen.CreateThread(function()
	checkPlane = true
	while checkPlane do
		sleep = 100 
		if DoesEntityExist(airplane) then
			if GetVehicleEngineHealth(airplane) < 0 or GetVehicleBodyHealth(airplane) < 0 then
				QBCore.Functions.Notify("Mission Canceled", "error")
				RemoveBlip(blip1)
				RemoveBlip(blip)
				DeleteEntity(pickupSpawn)
				TriggerServerEvent('qb-cocaineplane:updateTable', false)
				checkPlane = false
			end
		else
			sleep = 3000
		end
	   Citizen.Wait(sleep)
	end
end)

function delivery()
	QBCore.Functions.Notify("Get in the plane and pick up the delivery marked on your GPS.")
	local pickup = GetHashKey("prop_drop_armscrate_01")
	blip = AddBlipForCoord(location.delivery.x,location.delivery.y,location.delivery.z)
	RequestModel(pickup)
	while not HasModelLoaded(pickup) do
		Citizen.Wait(0)
	end
	local pickupSpawn = CreateObject(pickup, location.delivery.x,location.delivery.y,location.delivery.z, true, true, true)
	local player = PlayerPedId()
	Citizen.CreateThread(function()
		while delivering do
			sleep = 5	
			local playerpos = GetEntityCoords(player)
			local disttocoord = #(vector3(location.delivery.x,location.delivery.y,location.delivery.z)-vector3(playerpos.x,playerpos.y,playerpos.z))
			local veh = GetVehiclePedIsIn(PlayerPedId(), false)
			if disttocoord <= 10 then
				if veh == airplane then
					RemoveBlip(blip)
					-- SetBlipRoute(blip, false)
					DrawText3D(location.delivery.x,location.delivery.y,location.delivery.z-1, '~b~E~w~ - Pick Up Delivery')
					if IsControlJustPressed(1, 51) then
						if veh == airplane then
							delivering = false
							QBCore.Functions.Progressbar("picking_", "Collecting Delivery", 1000, false, true, {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							}, {}, {}, {}, function() -- Done
							end, function() -- Cancel
								QBCore.Functions.Notify("Canceled", "error")
							end)
							Citizen.Wait(2000)
							QBCore.Functions.Notify("You picked up the package. Now, return to the airfield marked on your GPS for delivery.", "success")
							DeleteEntity(pickupSpawn)
							Citizen.Wait(2000)
							final()
						else
							QBCore.Functions.Notify("You are not in the vehicle which was provided to you.", "error")
							DeleteEntity(airplane)
							DeleteEntity(pickupSpawn)
							RemoveBlip(blip1)
						end
					end
				end
			else
				sleep = 1500
			end
			Citizen.Wait(sleep)
		end
	end)
end

Citizen.CreateThread(function()
	checkPlane = true
	while checkPlane do
		sleep = 100 
		if DoesEntityExist(airplane) then
			if GetVehicleEngineHealth(veh) < 0 or GetVehicleBodyHealth(airplane) < 0 then
				QBCore.Functions.Notify("Mission Canceled", "error")
				RemoveBlip(blip)
				RemoveBlip(blip1)
				TriggerServerEvent('qb-cocaineplane:updateTable', false)
				checkPlane = false
			end
		else
			sleep = 3000
		end
		Citizen.Wait(sleep)
	end
end)

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(true)
	AddTextComponentString(text)
	SetDrawOrigin(x,y,z, 0)
	DrawText(0.0, 0.0)
	local factor = (string.len(text)) / 370
	DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
	ClearDrawOrigin()
end
function final()
	QBCore.Functions.Notify("Deliver the plane back to a hangar.", "success")
	blip = AddBlipForCoord(location.hangar.x,location.hangar.y,location.hangar.z)
	hangar = true
	local player = PlayerPedId()
	Citizen.CreateThread(function()
		while hangar do
			sleep = 5	
			local playerpos = GetEntityCoords(player)
			local disttocoord = #(vector3(location.hangar.x,location.hangar.y,location.hangar.z)-vector3(playerpos.x,playerpos.y,playerpos.z))
			local veh = GetVehiclePedIsIn(PlayerPedId(),false)
			if disttocoord <= 10 then
				if veh == airplane then
					RemoveBlip(blip)
					DrawText3D(location.hangar.x,location.hangar.y,location.hangar.z-1, '~b~E~w~ - Park Plane')
					if IsControlJustPressed(1, 51) then
						if veh == airplane then
							hangar = false
							FreezeEntityPosition(airplane, true)

							QBCore.Functions.Progressbar("parking", "Parking Plane", 1500, false, true, {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							}, {}, {}, {}, function() -- Done
								DeleteEntity(airplane)
							end, function() -- Cancel
								DeleteEntity(airplane)
							end)

							Citizen.Wait(2000)
							TriggerServerEvent('qb-cocaineplane:GiveItem')
							DeleteEntity(airplane)
							SetVehicleDoorsLocked(airplane, 2)
							Citizen.Wait(1000)	
							cooldown()
							TriggerServerEvent('qb-cocaineplane:updateTable', false)
							end
						else
							QBCore.Functions.Notify("This is not the vehicle which was provided to you.", "error")
							DeleteEntity(airplane)
						end 
					end
				end
			else
				sleep = 1500
			end
			Citizen.Wait(sleep)
		end
	end)
end

Citizen.CreateThread(function()
	local sleep
	while not process do
		Citizen.Wait(0)
	end
	while true do
		sleep = 5
		local player = PlayerPedId()
		local playercoords = GetEntityCoords(player)
		local dist = #(vector3(playercoords.x,playercoords.y,playercoords.z)-vector3(process.x,process.y,process.z))
		if dist <= 1 and not isProcessing then
			sleep = 5
			DrawText3D(process.x, process.y, process.z, '~b~E~w~ - Process Coke')
			if IsControlJustPressed(1, 51) then		
				isProcessing = true
				QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
					if result then
						LocalPlayer.state:set("inv_busy", true, true)
						processing()
					else
						QBCore.Functions.Notify("You need coke brick to process.", "error")
						isProcessing = false
						
					end
				end, 'coke_brick')
			end
		else
			sleep = 1500
		end
		Citizen.Wait(sleep)
	end
end)

function processing()
	local player = PlayerPedId()
	SetEntityCoords(player, process.x,process.y,process.z-1, 0.0, 0.0, 0.0, false)
	SetEntityHeading(player, 160.84)
	FreezeEntityPosition(player, true)
	playAnim("anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 30000)

	QBCore.Functions.Progressbar("coke-", "Breaking Coke", 30000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done
		FreezeEntityPosition(player, false)
		LocalPlayer.state:set("inv_busy", false, true)
		TriggerServerEvent('qb-cocaineplane:processed')
		isProcessing = false
	end, function() -- Cancel
		isProcessing = false
		ClearPedTasksImmediately(player)
		FreezeEntityPosition(player, false)
	end)

end

function cooldown()
    Citizen.Wait(20000)
    TriggerServerEvent('qb-cocaineplane:updateTable', false)
end

function playAnimPed(animDict, animName, duration, buyer, x,y,z)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do 
      Citizen.Wait(0) 
    end
    TaskPlayAnim(pilot, animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
    RemoveAnimDict(animDict)
end

function playAnim(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do 
      Citizen.Wait(0) 
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
    RemoveAnimDict(animDict)
end
