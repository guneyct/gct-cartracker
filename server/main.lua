QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem(Config.GPSItem, function(playerId)
    local xPlayer = QBCore.Functions.GetPlayer(playerId)
    if xPlayer.Functions.GetItemByName(Config.GPSItem).info.plate == nil then
        TriggerClientEvent("gct-cargps:client:openMenu", playerId)
    else
        TriggerClientEvent("gct-cargps:client:openMenu", playerId, xPlayer.Functions.GetItemByName(Config.GPSItem).info.plate)
    end
end)

RegisterNetEvent("gct-cargps:server:putGPS", function(_plate)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    xPlayer.Functions.RemoveItem(Config.GPSItem, 1)
    local info = {
        plate = _plate
    }
    xPlayer.Functions.AddItem(Config.GPSItem, 1, false, info)
end)

RegisterNetEvent("gct-cargps:server:removeGPS", function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    xPlayer.Functions.RemoveItem(Config.GPSItem, 1)

    xPlayer.Functions.AddItem(Config.GPSItem, 1, false)
end)