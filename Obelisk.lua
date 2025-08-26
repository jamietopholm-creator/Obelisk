--[[  Obelisk Extension (separate loadstring)
     - Adds a new "Obelisk" tab to your Obsidian UI
     - LEFT:
         • Dragon Obelisk button
         • Auto Upgrade (dropdown + toggle + speed + "once now")
     - RIGHT:
         • Redeem All Rewards toggle (IDs 1 → 9)
     - Requires your main script to expose getgenv().MY_SCRIPT with:
         MY_SCRIPT.ToServer  (ReplicatedStorage.Events.To_Server)
         MY_SCRIPT.Register(function(Window) ... end)
         (optional) MY_SCRIPT.Window as a fallback
]]

-- Wait briefly for the main script to expose MY_SCRIPT
local t0, TIMEOUT = os.clock(), 5
repeat task.wait(0.05) until getgenv().MY_SCRIPT or (os.clock() - t0) > TIMEOUT

local Script = getgenv().MY_SCRIPT
if not Script then
    return warn("[Obelisk] Main script (MY_SCRIPT) not found. Load the main script first.")
end
if not Script.ToServer then
    return warn("[Obelisk] MY_SCRIPT.ToServer missing. Expose ReplicatedStorage.Events.To_Server in main.")
end

local function attach(Window)
    -- Create the tab
    local ObeliskTab = Window:AddTab('Obelisk', 'landmark')

    -- ============== LEFT SIDE ==============
    local G_Left = ObeliskTab:AddLeftGroupbox('Dragon Obelisk', 'zap')

    -- One-click button: Dragon Obelisk upgrade
    G_Left:AddButton({
        Text = 'Activate Dragon Obelisk',
        Func = function()
            local args = {
                { Upgrading_Name = "Obelisk", Action = "_Upgrades", Upgrade_Name = "Dragon_Obelisk" }
            }
            Script.ToServer:FireServer(unpack(args))
        end,
    })

     -- One-click button: Pirate Obelisk upgrade (same style as Dragon button)
G_Left:AddButton({
    Text = 'Activate Pirate Obelisk',
    Func = function()
        local args = {
            {
                Upgrading_Name = "Obelisk",
                Action = "_Upgrades",
                Upgrade_Name = "Pirate_Obelisk",
            },
        }
        Script.ToServer:FireServer(unpack(args))
    end,
})


     -- One-click button: Soul Obelisk upgrade (same style as Dragon/Pirate)
G_Left:AddButton({
    Text = 'Activate Soul Obelisk',
    Func = function()
        local args = {
            {
                Upgrading_Name = "Obelisk",
                Action = "_Upgrades",
                Upgrade_Name = "Soul_Obelisk",
            },
        }
        Script.ToServer:FireServer(unpack(args))
    end,
})


     -- One-click button: Sorcerer Obelisk upgrade (same style as others)
G_Left:AddButton({
    Text = 'Activate Sorcerer Obelisk',
    Func = function()
        local args = {
            {
                Upgrading_Name = "Obelisk",
                Action = "_Upgrades",
                Upgrade_Name = "Sorcerer_Obelisk",
            },
        }
        Script.ToServer:FireServer(unpack(args))
    end,
})

     -- One-click button: Slayer Obelisk upgrade (same style as others)
G_Left:AddButton({
    Text = 'Activate Slayer Obelisk',
    Func = function()
        local args = {
            {
                Upgrading_Name = "Obelisk",
                Action = "_Upgrades",
                Upgrade_Name = "Slayer_Obelisk",
            },
        }
        Script.ToServer:FireServer(unpack(args))
    end,
})


     -- One-click button: Solo Obelisk upgrade (same style as others)
G_Left:AddButton({
    Text = 'Activate Solo Obelisk',
    Func = function()
        local args = {
            {
                Upgrading_Name = "Obelisk",
                Action = "_Upgrades",
                Upgrade_Name = "Solo_Obelisk",
            },
        }
        Script.ToServer:FireServer(unpack(args))
    end,
})


     -- One-click button: Clover Obelisk upgrade
G_Left:AddButton({
    Text = 'Activate Clover Obelisk',
    Func = function()
        local args = {
            {
                Upgrading_Name = "Obelisk",
                Action = "_Upgrades",
                Upgrade_Name = "Clover_Obelisk",
            },
        }
        Script.ToServer:FireServer(unpack(args))
    end,
})


     -- One-click button: Leaf Obelisk (add this to the Obelisk tab's left group `G_Left`)
G_Left:AddButton({
    Text = 'Activate Leaf Obelisk',
    Func = function()
        local args = {
            {
                Upgrading_Name = "Obelisk",
                Action = "_Upgrades",
                Upgrade_Name = "Leaf_Obelisk",
            },
        }
        Script.ToServer:FireServer(unpack(args))
    end,
})

     
     
    -- ---- Auto Upgrade section ----
    local Upgrade_Group = ObeliskTab:AddLeftGroupbox('Auto Upgrade', 'trending-up')

    local AutoUpgOn = false
    local AutoUpgDelay = 0.25

    -- UI label -> server Upgrading_Name map
    local UpgradeMap = {
        ["Damage"]    = "Damage",
        ["Star Luck"] = "Star_Luck",
        ["Coins"]     = "Coins",
        ["Energy"]    = "Energy",
    }
    local SelectedUpgLabel = "Damage"     -- default selection
    local SelectedUpgName  = UpgradeMap[SelectedUpgLabel]

    local function sendUpgradeOnce(upgName)
        if not upgName or upgName == "" then return end
        local args = {
            {
                Upgrading_Name = upgName,
                Action = "_Upgrades",
                Upgrade_Name = "Upgrades",
            }
        }
        Script.ToServer:FireServer(unpack(args))
    end

    local function startAutoUpgrade()
        task.spawn(function()
            while AutoUpgOn do
                sendUpgradeOnce(SelectedUpgName)
                task.wait(AutoUpgDelay)
            end
        end)
    end

    Upgrade_Group:AddDropdown('Ob_AutoUpgChoice', {
        Text = 'Upgrade',
        Values = { 'Damage', 'Star Luck', 'Coins', 'Energy' },
        Callback = function(label)
            SelectedUpgLabel = label
            SelectedUpgName  = UpgradeMap[label]
            print("[Obelisk] Auto Upgrade selected:", label, "→", SelectedUpgName)
        end,
    })

    Upgrade_Group:AddToggle('Ob_AutoUpgToggle', {
        Text = 'Auto Upgrade (selected)',
        Default = false,
        Callback = function(on)
            AutoUpgOn = on
            if on then startAutoUpgrade() end
        end,
    })

    Upgrade_Group:AddSlider('Ob_AutoUpgDelay', {
        Text = 'Upgrade Speed (s)',
        Default = AutoUpgDelay,
        Min = 0.01, Max = 2.00, Rounding = 2,
        Callback = function(v) AutoUpgDelay = v end,
    })

    Upgrade_Group:AddButton({
        Text = 'Upgrade Once Now',
        Func = function()
            sendUpgradeOnce(SelectedUpgName)
        end,
    })

    -- ============== RIGHT SIDE ==============
    local G_Right = ObeliskTab:AddRightGroupbox('Rewards', 'gift')

    local RedeemOn = false
    local RedeemDelay = 2.0 -- seconds between full cycles

    G_Right:AddToggle("Obelisk_RedeemAll", {
        Text = "Redeem All Rewards",
        Default = false,
        Callback = function(on)
            RedeemOn = on
            if on then
                task.spawn(function()
                    while RedeemOn do
                        for id = 1, 9 do
                            local args = {
                                { Action = "_Hourly_Rewards", Id = id }
                            }
                            Script.ToServer:FireServer(unpack(args))
                            task.wait(0.2) -- small gap between IDs
                        end
                        task.wait(RedeemDelay) -- wait before repeating the cycle
                    end
                end)
            end
        end,
    })
end

-- Preferred: register via main script’s hook
if type(Script.Register) == "function" then
    Script.Register(function(Window)
        attach(Window)
    end)
else
    -- Fallback: try to use a window handle exposed by the main script/globals
    local Win = Script.Window or getgenv().OBSIDIAN_WINDOW
    if Win then
        attach(Win)
    else
        warn("[Obelisk] No Register function or Window handle available; expose one of them in the main script.")
    end
end
