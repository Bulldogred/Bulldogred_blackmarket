local npc = nil

-- Create NPC when location is synced from the server
RegisterNetEvent('blackmarket:syncNPC')
AddEventHandler('blackmarket:syncNPC', function(location)
    if npc then
        DeleteEntity(npc) -- Remove any existing NPC to prevent duplicates
    end

    --print("[Black Market] Spawning NPC at location: ", location)

    local model = `g_m_importexport_01` -- Black Market dealer ped model

    -- Load the ped model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    -- Adjust z-coordinate to fix height issue
    npc = CreatePed(4, model, location.x, location.y, location.z - 1.0, location.w, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    -- Sphere marker for interaction
    exports.ox_target:addSphereZone({
        coords = vector3(location.x, location.y, location.z),
        radius = 1.0,
        options = {
            {
                name = 'blackmarket_interact',
                label = 'Black Market',
                icon = 'fas fa-skull-crossbones',
                onSelect = function()
                    openShop()
                end
            }
        }
    })

    --print("[Black Market] NPC spawned and added to ox_target.")
end)

-- Request NPC location when joining the server
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent('blackmarket:requestNPC')
        --print("[Black Market] Requesting NPC location from server.")
    end
end)

-- Function to open the custom Black Market shop
function openShop()
    local items = {
    { name = 'advancedlockpick', label = 'Advanced Lockpick', price = 5000 }, 
    { name = 'armor_vest', label = 'vest', price = 5000 }, 
   --    { name = 'cartelphone', label = 'Cartel Phone', price = 100000 },
    { name = 'decrypter', label = 'Decrypter', price = 2000 },
    { name = 'contracts_tablet', label = 'contract tablet', price = 20000 },
    { name = 'thermite', label = 'Thermite', price = 20000 },
    }

    --print("Sending Black Market items to NUI: ", json.encode(items)) -- Debug
    TriggerEvent('blackmarket:showMenu', items)
end

-- Handle the NUI menu interaction
RegisterNetEvent('blackmarket:showMenu', function(items)
    SendNUIMessage({
        action = 'openBlackMarket',
        items = items
    })
    SetNuiFocus(true, true) -- Enable NUI interaction
end)

-- Close the menu from NUI
RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false) -- Disable NUI interaction
    cb('ok')
end)

-- Handle item purchases
RegisterNUICallback('buyItem', function(data, cb)
    TriggerServerEvent('blackmarket:buyItem', data.itemName) -- Send purchase request to server
    cb('ok')
end)
