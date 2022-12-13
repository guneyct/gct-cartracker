QBCore = exports['qb-core']:GetCoreObject()
local GPSVehicles = {}

RegisterNetEvent("gct-cargps:client:openMenu", function(plate)
    local menu = {{
        header = Config.Language["gps_header"],
        txt = plate or "Bu Cihaz Bir Araca Takılı Değil!",
        isMenuHeader = true
    }, {
        header = Config.Language["gps_put"],
        txt = Config.Language["gps_put_txt"],
        params = {
            event = "gct-cargps:client:putGPS"
        }
    }, {
        header = Config.Language["gps_remove"],
        txt = Config.Language["gps_remove_txt"],
        params = {
            event = "gct-cargps:client:removeGPS"
        }
    }, {
        header = Config.Language["gps_run"],
        txt = Config.Language["gps_run_txt"],
        params = {
            event = "gct-cargps:client:useGPS",
            args = plate
        }
    }, {
        header = "⬅ " .. Config.Language["menu_close"],
        txt = "",
        params = {
            event = "qb-menu:close"
        }
    }}

    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent("gct-cargps:client:putGPS", function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        QBCore.Functions.Notify(Config.Language["gps_put_notify_in_vehicle"], "error", 2500)
    else
        local _vehicle, dist = QBCore.Functions.GetClosestVehicle()
        if DoesEntityExist(_vehicle) and dist <= 3.0 then
            QBCore.Functions.Progressbar("gct_cargps", Config.Language["prog_put_txt"], 4500, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
            }, {
                animDict = "mp_car_bomb",
                anim = "car_bomb_mechanic",
                flags = 16
            }, {}, {}, function() -- Done
                local vehiclePlate = QBCore.Functions.GetPlate(_vehicle)
                GPSVehicles[vehiclePlate] = {
                    plate = vehiclePlate,
                    coords = GetEntityCoords(_vehicle),
                    vehicle = _vehicle
                }
                TriggerServerEvent("gct-cargps:server:putGPS", vehiclePlate)
                QBCore.Functions.Notify(Config.Language["gps_put_notify_success"], "success", 2500)
            end, function() -- Cancel
                ClearPedTasks(PlayerPedId())
                QBCore.Functions.Notify(Config.Language["prog_cancel"], "error", 2500)
            end)
        end
    end
end)

RegisterNetEvent("gct-cargps:client:useGPS", function(plate)
    if plate == nil then
        QBCore.Functions.Notify(Config.Language["gps_run_error"], "error", 2500)
        return
    end
    local active = true
    CreateThread(function()
        for k, v in pairs(GPSVehicles) do
            if active then
                if k == plate then
                    local alpha = 255
                    local zoneblip = AddBlipForRadius(v.coords.x + math.random(Config.MinOffset, Config.MaxOffset),
                        v.coords.y + math.random(Config.MinOffset, Config.MaxOffset),
                        v.coords.z + math.random(Config.MinOffset, Config.MaxOffset), Config.Radius)
                    SetBlipColour(zoneblip, 49)
                    SetBlipAlpha(zoneblip, alpha)
                    while alpha ~= 0 do
                        Wait(3000)
                        alpha = alpha - 25
                        SetBlipAlpha(zoneblip, alpha)
                        if alpha <= 0 then
                            RemoveBlip(zoneblip)
                            active = false
                            return
                        end
                    end
                end
            end
        end
    end)
end)

RegisterNetEvent("gct-cargps:client:removeGPS", function()
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        QBCore.Functions.Notify(Config.Language["gps_put_notify_in_vehicle"], "error", 2500)
    else
        local _vehicle, dist = QBCore.Functions.GetClosestVehicle()
        if DoesEntityExist(_vehicle) and dist <= 3.0 then
            QBCore.Functions.Progressbar("gct_cargps", Config.Language["prog_remove_txt"], 4500, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
            }, {
                animDict = "mp_car_bomb",
                anim = "car_bomb_mechanic",
                flags = 16
            }, {}, {}, function() -- Done
                local vehiclePlate = QBCore.Functions.GetPlate(_vehicle)

                for k, v in pairs(GPSVehicles) do
                    if vehiclePlate == v.plate then
                        GPSVehicles[vehiclePlate] = {}
                        TriggerServerEvent("gct-cargps:server:removeGPS")
                    end
                end
            end, function() -- Cancel
                ClearPedTasks(PlayerPedId())
                QBCore.Functions.Notify(Config.Language["prog_cancel"], "error", 2500)
            end)
        end
    end
end)

CreateThread(function()
    local sleep = 5000
    while true do
        for k, v in pairs(GPSVehicles) do
            v.coords = GetEntityCoords(v.vehicle)
        end

        Wait(sleep)
    end
end)
