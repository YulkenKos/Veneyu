-- Vamipro Lite (Cliente-only) - Usable en cualquier servidor (sin ser admin)
-- LocalScript: UI, Spectate, "Golpe" local (efecto), Teleport/Freeze locales

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Config
local STRIKE_COOLDOWN = 1.0
local lastStrike = 0
local DAMAGE_DISPLAY = 25 -- número que mostrará al "golpear" (solo visual)
local SPECTATE_OFFSET = CFrame.new(0, 2.5, -6) -- offset de cámara cuando especteas

-- Utils
local function notify(msg, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Vamipro Lite",
            Text = msg,
            Duration = dur or 2
        })
    end)
end

local function safeFindRoot(p)
    if not p then return nil end
    local ok, root = pcall(function() return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end)
    if ok then return root end
    return nil
end

-- GUI principal
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "VamiproLiteGui"
mainGui.ResetOnSpawn = false
mainGui.Parent = player:WaitForChild("PlayerGui")

-- Botón negro flotante
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleVamipro"
toggleBtn.Size = UDim2.new(0,56,0,56)
toggleBtn.Position = UDim2.new(0,12,0,12)
toggleBtn.Text = "Menu"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.ZIndex = 50
toggleBtn.Parent = mainGui
local tCorner = Instance.new("UICorner", toggleBtn); tCorner.CornerRadius = UDim.new(0,8)

-- Panel admin (cliente)
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,420,0,420)
panel.Position = UDim2.new(0.5,-210,0.5,-210)
panel.BackgroundColor3 = Color3.fromRGB(24,24,24)
panel.Visible = false
panel.Parent = mainGui
local pCorner = Instance.new("UICorner", panel); pCorner.CornerRadius = UDim.new(0,16)

local header = Instance.new("Frame", panel)
header.Size = UDim2.new(1,-20,0,48)
header.Position = UDim2.new(0,10,0,10)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.6,0,1,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.Text = "Vamipro Lite"

local searchBox = Instance.new("TextBox", header)
searchBox.Size = UDim2.new(0.4,-10,1,0)
searchBox.Position = UDim2.new(0.6,8,0,0)
searchBox.PlaceholderText = "Buscar jugadores..."
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
local sCorner = Instance.new("UICorner", searchBox); sCorner.CornerRadius = UDim.new(0,8)

local scroll = Instance.new("ScrollingFrame", panel)
scroll.Name = "PlayerScroll"
scroll.Size = UDim2.new(1,-20,1,-76)
scroll.Position = UDim2.new(0,10,0,56)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Estado spectate
local spectateTarget = nil

-- Efecto visual al golpear (solo local): muestra un Billboard con -X y un sonido
local function showHitEffect(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Billboard con texto de daño
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = root
    billboard.Size = UDim2.new(0,100,0,40)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
    label.TextColor3 = Color3.new(1,0.2,0.2)
    label.Text = "-"..tostring(DAMAGE_DISPLAY)
    label.TextStrokeTransparency = 0.6

    billboard.Parent = mainGui

    -- pequeño sonido (opcional si existe)
    local sound = Instance.new("Sound", root)
    sound.SoundId = "" -- deja vacío (opcional). Si quieres un sonido, pon URL de asset.
    sound.Volume = 1
    -- sound:Play() -- si configuras SoundId puedes reproducirlo

    -- Animación simple: subir y desaparecer
    spawn(function()
        local t = 0
        while t < 0.9 do
            t = t + 0.1
            billboard.StudsOffset = billboard.StudsOffset + Vector3.new(0,0.1,0)
            wait(0.03)
        end
        pcall(function() billboard:Destroy() end)
        pcall(function() sound:Destroy() end)
    end)
end

-- Crear fila para jugador en la lista
local function makePlayerRow(p)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-12,0,56)
    row.BackgroundColor3 = Color3.fromRGB(30,30,30)
    row.BorderSizePixel = 0
    local rc = Instance.new("UICorner", row); rc.CornerRadius = UDim.new(0,10)

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(0.6,0,1,0)
    nameLbl.Position = UDim2.new(0,10,0,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = 16
    nameLbl.TextColor3 = Color3.new(1,1,1)
    nameLbl.Text = p.Name

    local spectBtn = Instance.new("TextButton", row)
    spectBtn.Size = UDim2.new(0.2, -8, 0, 34)
    spectBtn.Position = UDim2.new(0.62, 0, 0.18, 0)
    spectBtn.Text = "Espectear"
    spectBtn.Font = Enum.Font.GothamSemibold
    spectBtn.TextSize = 14
    spectBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    local sC = Instance.new("UICorner", spectBtn); sC.CornerRadius = UDim.new(0,8)

    local actionBtn = Instance.new("TextButton", row)
    actionBtn.Size = UDim2.new(0.18, -8, 0, 34)
    actionBtn.Position = UDim2.new(0.84, 0, 0.18, 0)
    actionBtn.Text = "Acción"
    actionBtn.Font = Enum.Font.GothamSemibold
    actionBtn.TextSize = 14
    actionBtn.BackgroundColor3 = Color3.fromRGB(145,70,70)
    local aC = Instance.new("UICorner", actionBtn); aC.CornerRadius = UDim.new(0,8)

    -- Click espectear toggle
    spectBtn.MouseButton1Click:Connect(function()
        if spectateTarget == p then
            spectateTarget = nil
            Camera.CameraType = Enum.CameraType.Custom
            notify("Dejaste de espectear a "..p.Name, 2)
        else
            spectateTarget = p
            Camera.CameraType = Enum.CameraType.Scriptable
            notify("Espectando "..p.Name.." (presiona E para 'golpear' visual)", 2)
        end
    end)

    -- Click acción: show small options (golpear local / teleport local / freeze local)
    actionBtn.MouseButton1Click:Connect(function()
        -- menu rápido: simple prompt con tres botones simples (creamos un pequeño frame)
        local quick = Instance.new("Frame")
        quick.Size = UDim2.new(0,220,0,96)
        quick.Position = UDim2.new(0.5,-110,0.5,-48)
        quick.BackgroundColor3 = Color3.fromRGB(18,18,18)
        quick.Parent = mainGui
        local qc = Instance.new("UICorner", quick); qc.CornerRadius = UDim.new(0,8)

        local info = Instance.new("TextLabel", quick)
        info.Size = UDim2.new(1,-12,0,32)
        info.Position = UDim2.new(0,6,0,6)
        info.BackgroundTransparency = 1
        info.Font = Enum.Font.Gotham
        info.TextSize = 14
        info.TextColor3 = Color3.new(1,1,1)
        info.Text = "Acciones locales para "..p.Name

        local bHit = Instance.new("TextButton", quick)
        bHit.Size = UDim2.new(0.9,0,0,24)
        bHit.Position = UDim2.new(0.05,0,0.35,0)
        bHit.Text = "Golpear (visual)"
        bHit.Font = Enum.Font.Gotham
        bHit.TextSize = 14
        bHit.BackgroundColor3 = Color3.fromRGB(160,60,60)
        local bhc = Instance.new("UICorner", bHit); bhc.CornerRadius = UDim.new(0,6)

        local bTP = Instance.new("TextButton", quick)
        bTP.Size = UDim2.new(0.44,0,0,24)
        bTP.Position = UDim2.new(0.05,0,0.65,0)
        bTP.Text = "Teleport (local)"
        bTP.Font = Enum.Font.Gotham
        bTP.TextSize = 14
        bTP.BackgroundColor3 = Color3.fromRGB(80,80,160)
        local btc = Instance.new("UICorner", bTP); btc.CornerRadius = UDim.new(0,6)

        local bF = Instance.new("TextButton", quick)
        bF.Size = UDim2.new(0.44,0,0,24)
        bF.Position = UDim2.new(0.51,0,0.65,0)
        bF.Text = "Freeze (local)"
        bF.Font = Enum.Font.Gotham
        bF.TextSize = 14
        bF.BackgroundColor3 = Color3.fromRGB(80,160,80)
        local bfc = Instance.new("UICorner", bF); bfc.CornerRadius = UDim.new(0,6)

        local function cleanupQuick()
            pcall(function() quick:Destroy() end)
        end

        bHit.MouseButton1Click:Connect(function()
            showHitEffect(p)
            cleanupQuick()
        end)
        bTP.MouseButton1Click:Connect(function()
            local root = safeFindRoot(p)
            if root then
                -- Teleport local: mueve la parte en tu cliente para verla allí, no es server-side
                pcall(function()
                    root.CFrame = root.CFrame * CFrame.new(0, 0, 0) -- no cambia, pero si quieres puedes mover localmente:
                    -- Ejemplo local: desplazamos la parte solo en el cliente (esto solo cambia para ti)
                    root.CFrame = Camera.CFrame * CFrame.new(0, 0, -8)
                end)
                notify("Teleport local aplicado a "..p.Name, 2)
            else
                notify("No se encontró HumanoidRootPart",2)
            end
            cleanupQuick()
        end)
        bF.MouseButton1Click:Connect(function()
            local root = safeFindRoot(p)
            if root then
                pcall(function()
                    root.Anchored = true -- solo anclado en tu cliente
                end)
                notify("Freeze local aplicado a "..p.Name, 2)
            else
                notify("No se encontró HumanoidRootPart",2)
            end
            cleanupQuick()
        end)

        -- cerrar al hacer clic afuera o después de 6s
        spawn(function()
            wait(6)
            cleanupQuick()
        end)
    end)

    return row
end

-- Refrescar lista
local function refreshList(filter)
    for _,c in ipairs(scroll:GetChildren()) do
        if c:IsA("Frame") then pcall(function() c:Destroy() end) end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= player and (not filter or filter == "" or p.Name:lower():match(filter:lower())) then
            local r = makePlayerRow(p)
            r.Parent = scroll
        end
    end
    -- ajustar CanvasSize (usa layout)
    pcall(function()
        scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end)
end

-- Toggle panel
toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then refreshList(searchBox.Text) end
end)

-- Filtrado en vivo
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    refreshList(searchBox.Text)
end)

-- Actualizar cuando jugadores entran/salen
Players.PlayerAdded:Connect(function() refreshList(searchBox.Text) end)
Players.PlayerRemoving:Connect(function() refreshList(searchBox.Text) end)

refreshList()

-- Update camara para spectate
RunService.RenderStepped:Connect(function()
    if spectateTarget and spectateTarget.Character then
        local root = safeFindRoot(spectateTarget)
        if root then
            local targetCFrame = root.CFrame
            -- colocamos la cámara atrás/arriba del target
            Camera.CFrame = targetCFrame * SPECTATE_OFFSET
        else
            spectateTarget = nil
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
end)

-- Golpear con E (solo efecto local)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.E then
        if spectateTarget and spectateTarget.Character then
            local now = tick()
            if now - lastStrike < STRIKE_COOLDOWN then
                notify("En cooldown...", 1)
                return
            end
            lastStrike = now
            -- efecto visual
            showHitEffect(spectateTarget)
        end
    end
end)

-- Limpieza si el script se reinicia
player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        pcall(function() mainGui:Destroy() end)
    end
end)

-- Nota: TODO cliente. Estos efectos son solo locales en TU cliente y NO afectan el servidor ni la salud real de otros jugadores.
