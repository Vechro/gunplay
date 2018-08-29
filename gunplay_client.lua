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
local groupHash -- rename this variable, actually holds a specific weapontype's recoil value
local isFiring = false

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
                ShakeGameplayCam("MG_RECOIL_SHAKE", groupHash * 3)
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
-- is replaced by a thread
--[[
function isPlayerFiring() 
    for i = 0, 25 do
        Wait(0)
        if IsPedShooting(PlayerPedId()) then
            return true
        end
    end
    return false
end
]]

-- Sets isFiring to true or false depending on whether the player is firing or not
Citizen.CreateThread(function()
    local playerPed = PlayerPedId()
    while true do
        Wait(0)
        local _, ammo = GetAmmoInClip(playerPed, GetSelectedPedWeapon(playerPed), 0)
        if IsControlPressed(1, 24) and ammo > 0 then
            isFiring = true
        else
            isFiring = false
        end
    end
end)

-- /SECONDARY THREADS/ --

-- If player is no longer firing, calls lowerStep to bring the aim back down
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if not isFiring and step > 0.0 then
            for i = groupHash, 0, -0.1 do
                local l = GetGameplayCamRelativePitch()
                SetGameplayCamRelativePitch(l - groupHash, 0.2)
                Wait(0)
                step = step - 0.1
                print(step)
            end
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