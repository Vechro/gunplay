local recoilGroups = {
    [416676503] = 0.1, -- GROUP_PISTOL
    [-957766203] = 0.2, -- GROUP_SMG
    [970310034] = 0.3, -- GROUP_RIFLE
    [1159398588] = 0.4, -- GROUP_MG
    [860033945] = 0.4, -- GROUP_SHOTGUN
    [-1212426201] = 0.4, -- GROUP_SNIPER
    [-1569042529] = 0.3, -- GROUP_HEAVY
    [690389602] = 0.05 -- GROUP_UNDEFINED
}

local step = 0
local tempPitch = 0.0
local groupHash -- rename this variable, actually holds a specific weapontype's recoil value

-- /PRIMARY THREAD/ --

-- Handles screen shake and recoil vertical pull upward and the counter (step) that's later necessary for bringing the pull back down
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        if IsPedArmed(playerPed, 4) then -- disable pistol-whips
            DisableControlAction(1, 140, true) -- move to other thread, might not work when second condition is active
        end
        if IsPedShooting(playerPed) and not IsPedDoingDriveby(playerPed) then
            local weapon = GetSelectedPedWeapon(playerPed)
            groupHash = recoilGroups[GetWeapontypeGroup(weapon)]
            if groupHash and groupHash ~= 0 then
                ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", groupHash / 10)
                for i = 0, groupHash, 0.1 do
                    Wait(0)
                    local p = GetGameplayCamRelativePitch()
                    SetGameplayCamRelativePitch(p + 0.1, 0.2)
                    step = step + 0.1
                    print(step)
                end
            end
        end
    end
end)

-- /FUNCTIONS/ --

-- IsPedShooting alone only checks if the ped is firing that very same frame, I need a longer timeframe than that to check, that's where this function comes into play
function isPlayerFiring() 
    for i = 0, 10 do
        Wait(0)
        if IsPedShooting(PlayerPedId()) then
            return true
        end
    end
    return false
end

-- Brings down the aim when firing stops, probably doesn't need to be a separate function
function lowerStep()
    if step > 0.0 then
        for i = groupHash, 0, -0.1 do
            local l = GetGameplayCamRelativePitch()
            SetGameplayCamRelativePitch(l - (0.4 * 4), 0.2)
            step = step - 0.1
        end
    end
end

-- /SECONDARY THREADS/ --

-- If player is no longer firing, calls lowerStep to bring the aim back down
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if not isPlayerFiring() then
            lowerStep()
        end
    end
end)


-- Disables crosshair for all weapons expect sniper rifles, y'know, for added realism, disabled while testing
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local weapon = GetSelectedPedWeapon(PlayerPedId())
        if GetWeapontypeGroup(weapon) ~= -1212426201 then -- GROUP_SNIPER
            --HideHudComponentThisFrame(14)
        end
    end
end)



--[[
function hasPlayerNotFiredRecently()
    local counter = 0
    for i = 0, 25 do
        Wait(0)
        if IsPedShooting(PlayerPedId()) then
            counter = counter + 1
        end
    end
    if counter == 0 then
        return true
    else
        return false
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if not isPlayerFiring() then
            step = 0
            SetGameplayCamRelativePitch(tempPitch, 0.01)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        SetGameplayCamRelativePitch(tempPitch, 0.2)
        if hasPlayerNotFiredRecently() then
            tempPitch = GetGameplayCamRelativePitch()
        end
    end
end)
]]