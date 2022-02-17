local minerblips = {
    {["CaveName"] = "Gold Mine", x = 2753.078125, y = 1325.9373779297, z = 68.901306152344, ["HasRares"] = true},
}


local spawnedRocks = 0
local Rocks = {}
local InArea = false
local entity
local HasRareGems = false


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        local ped = Ped()
        local pos = GetEntityCoords(ped)
        for k,v in pairs(minerblips) do
            if GetDistanceZTrue(pos,v) < 20.0 then
                InArea = true
                SpawnRocks()
                HasRareGems = v.HasRares
            end
        end
    end
end)

----check distance for both caves, if both false dont run thread & delete objects (Saves performance???), prolly a better way todo this but fuck it
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        local ped = Ped()
        local pos = GetEntityCoords(ped)
        if InArea then
            local Rock = {x = 2753.078125, y = 1325.9373779297, z = 68.901306152344}
            if GetDistanceZTrue(pos,Rock) > 55.0 then
                InArea = false
                for k, v in pairs(Rocks) do
                    DeleteObject(v)
                end
                spawnedRocks = 0
            end
        end
    end
end)


---check distance from spawned rock 
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if InArea then
            local ped = Ped()
            local pos = GetEntityCoords(ped)
            local nearbyObject, nearbyID
            for i=1, #Rocks, 1 do
                local EntCoords = GetEntityCoords(Rocks[i])
                if GetDistanceZTrue(pos,EntCoords) < 2 then
                    nearbyObject, nearbyID = Rocks[i], i
                    if nearbyObject then
                        DrawText3D(EntCoords.x, EntCoords.y, EntCoords.z, 'Press [E] To Mine Rock')
                        if whenKeyJustPressed("E") then
                            local W = math.random(1350)
                            MineAndAttach()
                            local testplayer = exports["syn_minigame"]:taskBar(4000,7)
                            local testplayer2
                            local testplayer3
                            local testplayer4
                            Wait(500)
                            if testplayer == 100 then
                                testplayer2 = exports["syn_minigame"]:taskBar(3500,7)
                            end
                            Wait(500)
                            if testplayer2 == 100 then
                                testplayer3 = exports["syn_minigame"]:taskBar(3200,7)
                            end
                            Wait(500)
                            if testplayer3 == 100 then
                                testplayer4 = exports["syn_minigame"]:taskBar(2900,7)
                            end
                            if testplayer4 == 100 then       
                            FreezeEntityPosition(ped,true)
                            Wait(W)
                            FreezeEntityPosition(ped,false)
                            DeleteObject(entity)
                            ClearPedTasks(ped)
                            SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
                            DeleteObject(nearbyObject)
                            table.remove(Rocks, nearbyID)
                            spawnedRocks = spawnedRocks - 1
                            TriggerServerEvent("Mushy_MinerJob:start", HasRareGems)
                            end
                        end
                    end
                end
            end
        end
    end
end)

function SpawnRocks()
    while spawnedRocks < 5 do
        local RockCoords = GenerateRockCoords()
        print(RockCoords)
        local obj = CreateObject(GetHashKey('mp004_p_rockpilegoal01x'), RockCoords.x, RockCoords.y,RockCoords.z, false, false, false)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
        table.insert(Rocks, obj)
        spawnedRocks = spawnedRocks + 1
	end
end

function GenerateRockCoords()
    while true do
        Citizen.Wait(1)

        local RockCoordX, RockCoordY

        math.randomseed(GetGameTimer())
        local modX = math.random(-6, 3)

        Citizen.Wait(100)

        math.randomseed(GetGameTimer())
        local modY = math.random(-6, 3)
        for k, v in pairs(minerblips) do
            if GetDistance(GetEntityCoords(Ped()),v) < 20.0 then
                RockCoordX = v.x + modX
                RockCoordY = v.y + modY
            end
        end

        local coordZ = GetCoordZ(RockCoordX, RockCoordY)
        local coord = vector3(RockCoordX, RockCoordY, coordZ)
        -- if ValidateRockCoord(coord) then
            return coord
       -- end
    end
end


function ValidateRockCoord(rockCoord)
	if spawnedRocks > 0 then
        local validate = true
        local outsideinterior = Citizen.InvokeNative(0xF291396B517E25B2,rockCoord.x, rockCoord.y, rockCoord.z) --ISENTITYOUTSIDE

		for k, v in pairs(Rocks) do
            if GetDistance(rockCoord,GetEntityCoords(v)) < 1 then
				validate = false
            end
            if outsideinterior then
                validate = false
            end
        end

        for k,v in pairs(minerblips) do
            if GetDistance(rockCoord,v) > 25 then
                if not k then 
                    validate = false
                end
            end
        end

		return validate
	else
		return true
	end
end

function GetCoordZ(x, y)

    for height = 1, 1000 do
		local foundGround, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, height+0.0)

		if foundGround then
            return groundZ
		end
	end
end

function MineAndAttach()
    if not IsPedMale(Ped()) then
        local waiting = 0
        local dict = "amb_work@world_human_pickaxe@wall@male_d@base"   
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 5000 then
            elseif not testplayer then
                break
            end      
        end

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_R_HAND")
        --local modelHash = GetHashKey("P_PICKAXE01X")
        LoadModel(modelHash)
        entity = CreateObject(modelHash, coords.x, coords.y,coords.z, true, false, false)
        SetEntityVisible(entity, true)
        SetEntityAlpha(entity, 255, false)
        Citizen.InvokeNative(0x283978A15512B2FE, entity, true)
        SetModelAsNoLongerNeeded(modelHash)
        AttachEntityToEntity(entity,ped, boneIndex, -0.030, -0.300, -0.010, 0.0, 100.0, 68.0, false, false, false, true, 2, true)  ---6th rotates axe point
        TaskPlayAnim(ped, dict, "base", 1.0, 8.0, -1, 1, 0, false, false, false)
    else
        TaskStartScenarioInPlace(Ped(), GetHashKey('WORLD_HUMAN_PICKAXE_WALL'), 14000, true, false, false, false)
    end
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(Rocks) do
			DeleteObject(v)
		end
	end
end)

Citizen.CreateThread(function()
   local blip = N_0x554d9d53f696d002(1664425300,2784.9870605469, 1339.4422607422, 70.300170898438)
    SetBlipSprite(blip, -758970771, 1)
         Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Gold Mine") 
 end)
