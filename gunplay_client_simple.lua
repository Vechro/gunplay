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

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        if IsPedArmed(playerPed, 4) then -- disable pistol-whips
            DisableControlAction(1, 140, true) -- move to other thread, might not work when second condition is active
        end
        if IsPedShooting(playerPed) and not IsPedDoingDriveby(playerPed) then
            local weapon = GetSelectedPedWeapon(playerPed)
            local groupHash = recoilGroups[GetWeapontypeGroup(weapon)]
            if groupHash and groupHash ~= 0 then
                ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", groupHash / 10)
                for i = 0, groupHash, 0.1 do
                    Wait(0)
                    local p = GetGameplayCamRelativePitch()
                    SetGameplayCamRelativePitch(p + 0.1, 0.2)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local weapon = GetSelectedPedWeapon(PlayerPedId())
        if GetWeapontypeGroup(weapon) ~= -1212426201 then -- GROUP_SNIPER
            HideHudComponentThisFrame(14)
        end
    end
end)
