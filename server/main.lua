local API = exports.vorp_inventory:vorp_inventoryApi()
local Loot = {
    {item = 'clay', amountToGive = math.random(1, 2)},
    {item = 'coal', amountToGive = math.random(1, 2)},
    {item = 'copper', amountToGive = math.random(1, 2)},
    {item = 'iron', amountToGive = math.random(1, 2)},
    {item = 'nitrite', amountToGive = math.random(1, 2)},
    {item = 'rock', amountToGive = math.random(1, 2)},
    {item = 'salt', amountToGive = math.random(1, 2)},
    {item = 'goldnugget', amountToGive = math.random(1, 2)}
}

RegisterServerEvent('Mushy_MinerJob:start')
AddEventHandler(
    'Mushy_MinerJob:start',
    function(HR)
        local _source = source
        local FinalLoot,LabelLoot = LootToGive(_source, HR)
        TriggerEvent(
            'vorp:getCharacter',
            _source,
            function(user)
                if HR then
                    for k, v in pairs(Loot) do
                        if v.item == FinalLoot then
                            API.addItem(_source, FinalLoot, v.amountToGive)
                            LootsToGiveR = {}
                            break
                        end
                    end
                    ---    TriggerClientEvent("redemrp_notification:start", _source, "You got "..FinalLoot, 4)
                    --TriggerClientEvent('Notify', _source, 'Success', 'Got x1 <b>' .. Loot,5000)
                else
                    for k, v in pairs(Loot) do
                        if v.item == FinalLoot then
                            API.addItem(_source, FinalLoot, v.amountToGive)
                            LootsToGive = {}
                            break
                        end
                    end
                    TriggerClientEvent('Notify', _source, 'Success', 'Got x1 <b>' .. LabelLoot,5000)
                end
                TriggerEvent('vorp:addXp', _source, 10) -- some exp here if you want, fuck knows
            end
        )
    end
)

function LootToGive(source, HasRares) -- kek
    local LootsToGive = {}
    if HasRares then
        for k, v in pairs(Loot) do
            table.insert(LootsToGive, v.item)
        end
    else
        for k, v in pairs(Loot) do
            table.insert(LootsToGive, v.item)
        end
    end

    if LootsToGive[1] ~= nil then
        local value = math.random(1, #LootsToGive)
        local picked = LootsToGive[value]
        return picked
     elseif LootsToGive[1] ~= nil then
        local value = math.random(1, #LootsToGive)
        local picked = LootsToGive[value]
        local itemLabel = nil
        
        if picked == "clay" then itemLabel = "clay" 
        elseif picked == "coal" then itemLabel = "coal"
        elseif picked == "copper" then itemLabel = "copper"
        elseif picked == "iron" then itemLabel = "iron"
        elseif picked == "nitrite" then itemLabel = "nitrite"
        elseif picked == "rock" then itemLabel = "rock"
        elseif picked == "salt" then itemLabel = "salt"
        elseif picked == "goldnugget" then itemLabel = "goldnugget"
        end
        return picked, itemLabel
    end
end