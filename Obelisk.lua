--[[  Obelisk Extension (separate loadstring)
     - Adds a new "Obelisk" tab to your Obsidian UI
     - Button fires the Dragon Obelisk upgrade RPC you provided
     - Requires your main script to expose getgenv().MY_SCRIPT with:
         MY_SCRIPT.ToServer  (ReplicatedStorage.Events.To_Server)
         MY_SCRIPT.Register(function(Window, MiscTab) ... end)  -- optional but preferred
         (optional) MY_SCRIPT.Window or getgenv().OBSIDIAN_WINDOW as a fallback
--]]

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
    -- Create the new tab
    local ObeliskTab = Window:AddTab('Obelisk', 'landmark') -- icon can be any lucide name you like
    local G = ObeliskTab:AddLeftGroupbox('Dragon Obelisk', 'zap')

    -- One-click button: Dragon Obelisk upgrade
    G:AddButton({
        Text = 'Activate Dragon Obelisk',
        Func = function()
            local args = {
                { Upgrading_Name = "Obelisk", Action = "_Upgrades", Upgrade_Name = "Dragon_Obelisk" }
            }
            Script.ToServer:FireServer(unpack(args))
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
