local npcLocation = nil -- To store the chosen spawn location for all players

-- Spawn the NPC on the server
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local locations = {
            vec4(-1150.46, 4940.6, 222.27, 241.69), 
        }

        -- Randomly choose a spawn location
        npcLocation = locations[math.random(#locations)]

        -- Log for debugging
        --print("[Black Market] NPC spawned at: ", npcLocation)

        -- Notify all players to create the NPC at the chosen location
        TriggerClientEvent('blackmarket:syncNPC', -1, npcLocation)
    end
end)

-- Sync the NPC location when a player joins
RegisterNetEvent('blackmarket:requestNPC')
AddEventHandler('blackmarket:requestNPC', function()
    local src = source
    if npcLocation then
        TriggerClientEvent('blackmarket:syncNPC', src, npcLocation)
        --print("[Black Market] Synced NPC location to player ID: ", src)
    else
        print("[Black Market] NPC location is nil. No NPC to sync.")
    end
end)

-- Handle item purchases
RegisterNetEvent('blackmarket:buyItem', function(itemName)
    local player = source
    local items = {
         { name = 'advancedlockpick', label = 'Advanced Lockpick', price = 5000 }, 
         { name = 'armor_vest', label = 'vest', price = 5000 }, 
    --    { name = 'cartelphone', label = 'Cartel Phone', price = 100000 },
        { name = 'decrypter', label = 'Decrypter', price = 2000 },
        { name = 'contracts_tablet', label = 'contract tablet', price = 20000 },
        { name = 'thermite', label = 'Thermite', price = 20000 }
    }

    -- Find the item in the Black Market's inventory
    local selectedItem = nil
    for _, item in ipairs(items) do
        if item.name == itemName then
            selectedItem = item
            break
        end
    end

    if not selectedItem then
        TriggerClientEvent('ox_lib:notify', player, { type = 'error', description = 'Item not found!' })
        return
    end

    -- Check if the player has enough money (black_money)
    local money = exports.ox_inventory:Search(player, 'count', 'black_money')
    if money < selectedItem.price then
        TriggerClientEvent('ox_lib:notify', player, { type = 'error', description = 'Not enough black money!' })
        return
    end

    -- Complete the transaction
    local success = exports.ox_inventory:RemoveItem(player, 'black_money', selectedItem.price)
    if success then
        exports.ox_inventory:AddItem(player, selectedItem.name, 1)
        TriggerClientEvent('ox_lib:notify', player, {
            type = 'success',
            description = ('Purchased %s for $%d'):format(selectedItem.label, selectedItem.price)
        })

    -- Chance to trigger cd_dispatch
    local chance = math.random(1, 100)
    if chance <= 30 then
    TriggerClientEvent('cd_dispatch:client:blackmarket', player) -- Send the event to the specific player
    end

        -- Notify the player that the transaction failed (edge case)
        TriggerClientEvent('ox_lib:notify', player, { type = 'error', description = 'Transaction failed. Try again!' })
    end
end)
