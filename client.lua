local repairLocations = {
    {x = -211.55, y = -1324.55, z = 30.89},  -- Los Santos Customs BEENYS
    {x = -1155.44, y = -2007.18, z = 13.18}, -- Los Santos Customs LSIA
    {x = 731.65, y = -1088.7, z = 21.41},    -- Los Santos Customs LA MESA
    {x = -336.4, y = -137.85, z = 38.25},    -- Los Santos Customs Burton
    {x = 1174.97, y = 2640.01, z = 37.0},    -- Los Santos Customs Route 68
    {x = 110.53, y = 6626.91, z = 31.03}     -- Los Santos Customs Paleto Bay
}

local isInCircle = false
local repairTimer = 30
local vehicleRepaired = false

function draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function isPlayerInCircle(coords)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(coords - playerCoords)
    return distance < 5.0
end

function startRepairProcess()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if DoesEntityExist(vehicle) and not vehicleRepaired then
        FreezeEntityPosition(vehicle, true)
        SetVehicleDoorOpen(vehicle, 4, false, false)

        -- Simulate the repair process
        Citizen.Wait(repairTimer * 1000)

        -- Complete repair
        SetVehicleFixed(vehicle)
        SetVehicleDirtLevel(vehicle, 0)
        SetVehicleDoorShut(vehicle, 4, false)
        FreezeEntityPosition(vehicle, false)

        vehicleRepaired = true
        Citizen.SetTimeout(60000, function()
            vehicleRepaired = false
        end)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, location in pairs(repairLocations) do
            DrawMarker(1, location.x, location.y, location.z - 1.0, 0, 0, 0, 0, 0, 0, 3.5, 3.5, 1.0, 255, 0, 0, 150, false, true, 2, false, nil, nil, false)

            if isPlayerInCircle(vector3(location.x, location.y, location.z)) then
                draw3DText(location.x, location.y, location.z + 1.0, "~g~Repair your vehicle~w~ - Press 'E'")
                isInCircle = true
            else
                isInCircle = false
            end

            if isInCircle and IsControlJustReleased(0, 38) and not vehicleRepaired then  -- Key 'E'
                startRepairProcess()
            end
        end
    end
end)