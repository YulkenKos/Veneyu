-- UNIVERSAL_TEMPORARY_GAMEPASS_DELTA.lua
-- Pegar en ServerScriptService
-- Edita ADMIN_USER_IDS y GamePassesConfig según tus pases deseados

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

-- === CONFIG ===
local ADMIN_USER_IDS = { 12345678 } -- <- Reemplaza con tu UserId
-- Ejemplo de Game Passes configurables: { key = "speed", name = "Pase Velocidad", id = 1111111, duration = 60, effects = {...} }
local GamePassesConfig = {
    { key="speed", name="Pase Velocidad", id=1111111, duration=60, effects={walkSpeed=60} },
    { key="jump", name="Pase Salto", id=2222222, duration=60, effects={jumpPower=140} },
    { key="oro", name="Pase Oro", id=3333333, duration=120, effects={coins=300} },
}

-- === SERVER STATE ===
local virtualOwned = {}
local activeTimers = {}
local originalValues = {}

-- Helpers
local function isAdmin(userId)
    for _, id in ipairs(ADMIN_USER_IDS) do
        if id == userId then return true end
    end
    return false
end

local function ensureLeaderstats(player)
    local ls = player:FindFirstChild("leaderstats")
    if not ls then
        ls = Instance.new("Folder")
        ls.Name = "leaderstats"
        ls.Parent = player
    end
    if not ls:FindFirstChild("Coins") then
        local c = Instance.new("IntValue")
        c.Name = "Coins"
        c.Value = 0
        c.Parent = ls
    end
end

local function applyEffects(player, pass)
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local uid = player.UserId
    originalValues[uid] = originalValues[uid] or {}
    if humanoid then
        if pass.effects.walkSpeed and not originalValues[uid].walkSpeed then originalValues[uid].walkSpeed = humanoid.WalkSpeed end
        if pass.effects.jumpPower and not originalValues[uid].jumpPower then originalValues[uid].jumpPower = humanoid.JumpPower end
        if pass.effects.walkSpeed then humanoid.WalkSpeed = pass.effects.walkSpeed end
        if pass.effects.jumpPower then humanoid.JumpPower = pass.effects.jumpPower end
    end
    if pass.effects.coins then
        ensureLeaderstats(player)
        player.leaderstats.Coins.Value += pass.effects.coins
        originalValues[uid].coinsAdj = (originalValues[uid].coinsAdj or 0) + pass.effects.coins
    end
end

local function revertEffects(player, pass)
    local uid = player.UserId
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and originalValues[uid] then
            if pass.effects.walkSpeed and originalValues[uid].walkSpeed then humanoid.WalkSpeed = originalValues[uid].walkSpeed end
            if pass.effects.jumpPower and originalValues[uid].jumpPower then humanoid.JumpPower = originalValues[uid].jumpPower end
        end
    end
    if pass.effects.coins and originalValues[uid] and originalValues[uid].coinsAdj then
        ensureLeaderstats(player)
        player.leaderstats.Coins.Value = math.max(0, player.leaderstats.Coins.Value - pass.effects.coins)
        originalValues[uid].coinsAdj -= pass.effects.coins
    end
end

local function scheduleExpiration(player, pass)
    local uid = player.UserId
    activeTimers[uid] = activeTimers[uid] or {}
    if activeTimers[uid][pass.key] and activeTimers[uid][pass.key].Cancel then activeTimers[uid][pass.key]:Cancel() end
    local cancelled = false
    local token = {Cancel=function() cancelled=true end}
    activeTimers[uid][pass.key] = token
    task.spawn(function()
        while not cancelled do
            if os.time() >= virtualOwned[uid][pass.key] then break end
            task.wait(1)
        end
        if not cancelled then
            virtualOwned[uid][pass.key] = nil
            activeTimers[uid][pass.key] = nil
            revertEffects(player, pass)
            if player then
                ReplicatedStorage:WaitForChild("TemporaryPassEvent"):FireClient(player,"Expired",pass.key)
            end
        end
    end)
    return token
end

local function grantVirtualPass(player, pass)
    local uid = player.UserId
    virtualOwned[uid] = virtualOwned[uid] or {}
    virtualOwned[uid][pass.key] = os.time() + pass.duration
    applyEffects(player, pass)
    scheduleExpiration(player, pass)
end

-- RemoteEvent
local event = ReplicatedStorage:FindFirstChild("TemporaryPassEvent") or Instance.new("RemoteEvent")
event.Name = "TemporaryPassEvent"
event.Parent = ReplicatedStorage

event.OnServerEvent:Connect(function(player, key)
    if not isAdmin(player.UserId) then
        event:FireClient(player,"Denied",key,"NotAdmin")
        return
    end
    for _, pass in ipairs(GamePassesConfig) do
        if pass.key==key then
            grantVirtualPass(player, pass)
            event:FireClient(player,"Granted",key,virtualOwned[player.UserId][key])
            break
        end
    end
end)

-- Aplicar efectos al respawnear
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        local uid = player.UserId
        if virtualOwned[uid] then
            for key, exp in pairs(virtualOwned[uid]) do
                if os.time()<exp then
                    for _, pass in ipairs(GamePassesConfig) do
                        if pass.key==key then applyEffects(player,pass) break end
                    end
                else
                    virtualOwned[uid][key] = nil
                end
            end
        end
    end)
end)

-- Limpiar al salir
Players.PlayerRemoving:Connect(function(player)
    local uid = player.UserId
    if activeTimers[uid] then
        for _, t in pairs(activeTimers[uid]) do
            if t.Cancel then t.Cancel() end
        end
    end
    virtualOwned[uid] = nil
    activeTimers[uid] = nil
    originalValues[uid] = nil
end)

-- === Crear LocalScript en StarterPlayerScripts (GUI + Delta) ===
local starterScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts") or Instance.new("StarterPlayerScripts")
starterScripts.Parent = StarterPlayer

if not starterScripts:FindFirstChild("TemporaryPassClient") then
    local ls = Instance.new("LocalScript")
    ls.Name = "TemporaryPassClient"
    ls.Parent = starterScripts
    local function serializePasses()
        local parts = {"{"}
        for _, pass in ipairs(GamePassesConfig) do
            table.insert(parts,string.format([[
["%s"]={ key="%s", name="%s", duration=%d },
]],pass.key,pass.key,pass.name,pass.duration))
        end
        table.insert(parts,"}")
        return table.concat(parts,"\n")
    end
    ls.Source = [[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local event = ReplicatedStorage:WaitForChild("TemporaryPassEvent")
local PassesInfo = ]]..serializePasses()..[[

local expirations = {}

-- Detect Delta GUI
local DeltaPresent = pcall(function() return player.PlayerGui:WaitForChild("DeltaGui") end)

-- GUI: si Delta está presente, usa su estilo; si no, boton negro flotante
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TemporaryPassGUI"
screenGui.Parent = playerGui

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0,36,0,36)
toggle.Position = UDim2.new(0,10,0,10)
toggle.BackgroundColor3 = Color3.new(0,0,0)
toggle.BorderSizePixel = 0
toggle.Text = "+"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 24
toggle.Parent = screenGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,260,0,220)
panel.Position = UDim2.new(0,10,0,56)
panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-10,0,28)
title.Position = UDim2.new(0,5,0,5)
title.BackgroundTransparency = 1
title.Text = "Menú Game Pass (Admins)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = panel

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1,-10,1,-40)
content.Position = UDim2.new(0,5,0,36)
content.BackgroundTransparency = 1
content.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.Parent = content

for _, info in pairs(PassesInfo) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,50)
    frame.BackgroundTransparency = 1
    frame.Name = info.key
    frame.Parent = content

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.65,-6,1,0)
    btn.Position = UDim2.new(0,0,0,0)
    btn.BackgroundTransparency = 0.15
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.Text = info.name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = frame

    local infoLbl = Instance.new("TextLabel")
    infoLbl.Size = UDim2.new(0.35,-6,1,0)
    infoLbl.Position = UDim2.new(0.65,6,0,0)
    infoLbl.BackgroundTransparency = 1
    infoLbl.TextColor3 = Color3.new(1,1,1)
    infoLbl.Text = "-"
    infoLbl.Font = Enum.Font.SourceSans
    infoLbl.TextSize = 14
    infoLbl.Parent = frame

    btn.MouseButton1Click:Connect(function()
        event:FireServer(info.key)
    end)
end

toggle.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
    toggle.Text = panel.Visible and "x" or "+"
end)

-- Actualizar expiraciones
task.spawn(function()
    while true do
        for _, frame in ipairs(content:GetChildren()) do
            local key = frame.Name
            local lbl = frame:FindFirstChildOfClass("TextLabel")
            if expirations[key] then
                local remain = math.max(0, expirations[key]-os.time())
                lbl.Text = remain>0 and remain.."s" or "Expirado"
            else
                lbl.Text = "-"
            end
        end
        task.wait(1)
    end
end)

event.OnClientEvent:Connect(function(action,key,data)
    if action=="Granted" then
        expirations[key] = data
    elseif action=="Expired" then
        expirations[key] = nil
    end
end)
    ]]
end

print("[TemporaryPass] Script universal cargado. Reemplaza ADMIN_USER_IDS con tu UserId.")
