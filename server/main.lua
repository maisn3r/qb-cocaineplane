local QBCore = exports['qb-core']:GetCoreObject()

---------------------------------
----/* Processing Location *\----
---------------------------------
local hiddenprocess = vector3(1116.91, -1239.52, 16.42) -- Change this to whatever location you want. This is server side to prevent people from dumping the coords 

---------------------------------
-----/* Starting Location *\-----
---------------------------------
local hiddenstart = vector3(4520.27, -4515.47, 4.48) -- Change this to whatever location you want. This is server side to prevent people from dumping the coords

RegisterNetEvent('qb-cocaineplane:updateTable')
AddEventHandler('qb-cocaineplane:updateTable', function(bool)
    TriggerClientEvent('qb-cocaineplane:syncTable', -1, bool)
end)

QBCore.Functions.CreateCallback('qb-cocaineplane:processcoords', function(source, cb)
    cb(hiddenprocess)
end)

QBCore.Functions.CreateCallback('qb-cocaineplane:startcoords', function(source, cb)
    cb(hiddenstart)
end)

---------------------------------
--------/* Rent Money *\---------
---------------------------------
QBCore.Functions.CreateCallback('qb-cocaineplane:pay', function(source, cb)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local price = Config.price
	local check = Player.PlayerData.money.cash

	if check >= price then
		Player.Functions.RemoveMoney('cash', price)
		cb(true)
    else
		TriggerClientEvent("QBCore:Notify", src, "You dont have enough money to start.", "error", 10000)
    	cb(false)
    end
end)

---------------------------------
-------/* Police Alert *\--------
---------------------------------
RegisterServerEvent('qb-cocaineplane:server:PoliceAlertMessage')
AddEventHandler('qb-cocaineplane:server:PoliceAlertMessage', function(title, coords, blip)
    local src = source
    local alertData = {
        title = title,
        coords = {vector3(1406.49, 4784.83, 40.97)}, 
        description = "Suspicious Activity at Grapeseed<br>No Cameras Available",
    }

    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                if blip then
                        TriggerClientEvent("arp-phone:client:addPoliceAlert", v, alertData)
                        TriggerClientEvent("qb-cocaineplane:client:PoliceAlertMessage", v, title, coords, blip)
                end
            end
        end
    end
end)

---------------------------------
-----/* Processing Event *\------
---------------------------------
RegisterServerEvent("qb-cocaineplane:processed")
AddEventHandler("qb-cocaineplane:processed", function(x,y,z)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local pick = Config.randBrick
	  
	Player.Functions.RemoveItem('coke_brick', Config.takeBrick, k)
	Player.Functions.AddItem('cokebaggy', pick)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['cokebaggy'], "add")
end)

---------------------------------
-------/* Giving Event *\--------
---------------------------------
RegisterServerEvent("qb-cocaineplane:GiveItem")
AddEventHandler("qb-cocaineplane:GiveItem", function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local price = Config.price

	Player.Functions.AddMoney('cash', price)
	Player.Functions.AddItem('coke_brick', 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['coke_brick'], "add")
end)

---------------------------------
-------/* Cocaine Item *\--------
---------------------------------
QBCore.Functions.CreateUseableItem("cokebaggy", function(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent('qb-cocaineplane:onUse', source)
	end
end)

