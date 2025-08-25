--[[  Obelisk Extension (separate loadstring)
     - Adds a new "Obelisk" tab to your Obsidian UI
     - Left: Dragon Obelisk upgrade button
     - Right: Redeem All Rewards toggle (IDs 1 → 9)
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
    local ObeliskTab = Window:AddTab('Obelisk/Adds', 'landmark')

    -- LEFT: Dragon Obelisk
    local G_Left = ObeliskTab:AddLeftGroupbox('Dragon Obelisk', 'zap')
    G_Left:AddButton({
        Text = 'Activate Dragon Obelisk',
        Func = function()
            local args = {
                { Upgrading_Name = "Obelisk", Action = "_Upgrades", Upgrade_Name = "Dragon_Obelisk" }
            }
            Script.ToServer:FireServer(unpack(args))
        end,
    })

    -- RIGHT: Rewards (Redeem All Rewards)
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

-- Preferred: register via main script’s hook (gives us the Window handle)
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
