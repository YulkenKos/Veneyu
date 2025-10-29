-- Spectate Power Trigger (LocalScript - Delta)
-- Menú pequeño, spectate 3ra persona, al click sobre el objetivo se dispara un RemoteEvent (si existe).
-- NO agrega ataques locales. El ataque real debe implementarlo el servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ===== CONFIG =====
local PANEL_SIZE = UDim2.new(0, 260, 0, 320) -- tamaño compacto
local ATTACK_REMOTE_NAME = "RE_AttackRequest" -- nombre del RemoteEvent que el servidor debe usar (si existe)
local CLICK_COOLDOWN = 0.6 -- segundos entre clicks que intentan enviar ataque
local notifyDuration = 2

-- ===== HELPERS =====
local function notify(text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "Spectate", Text = text, Duration = dur or notifyDuration})
    end)
end

local function safeFindRoot(p)
    if not p then return nil end
    return p.Character and (p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildWhichIsA("BasePart"))
end

-- ===== GUI =====
local screen = Instance.new("ScreenGui")
screen.Name = "SpectatePowerUI"
screen.Parent = player:WaitForChild("PlayerGui")
screen.ResetOnSpawn = false

-- botón negro flotante (pequeño)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleSpect"
toggleBtn.Size = UDim2.new(0,44,0,44)
toggleBtn.Position = UDim2.new(0,12,0,12)
toggleBtn.AnchorPoint = Vector2.new(0,0)
toggleBtn.Text = "S"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Parent = screen
local tCorner = Instance.new("UICorner", toggleBtn); tCorner.CornerRadius = UDim.new(0,8)

-- panel compacto
local panel = Instance.new("Frame")
panel.Name = "CompactPanel"
panel.Size = PANEL_SIZE
panel.Position = UDim2.new(0.5, -PANEL_SIZE.X.Offset/2, 0.5, -PANEL_SIZE.Y.Offset/2)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = screen
local pCorner = Instance.new("UICorner", panel); pCorner.CornerRadius = UDim.new(0,10)

local header = Instance.new("TextLabel", panel)
header.Size = UDim2.new(1, -12, 0, 34)
header.Position = UDim2.new(0, 6, 0, 6)
header.BackgroundTransparency = 1
header.Font = Enum.Font.GothamBold
header.TextSize = 16
header.TextColor3 = Color3.new(1,1,1)
header.Text = "Spectate - Selecciona un jugador"

local listFrame = Instance.new("ScrollingFrame", panel)
listFrame.Size = UDim2.new(1, -12, 1, -52)
listFrame.Position = UDim2.new(0,6,0,42)
listFrame.BackgroundTransparency = 1
listFrame.ScrollBarThickness = 6
local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ===== LOGICA =====
local spectateTarget = nil
local lastClick = 0

local function setSpectateTarget(p)
    if p == spectateTarget then
        -- toggle off
        spectateTarget = nil
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = player.Character and (player.Character:FindFirstChildOfClass("Humanoid") or player.Character:FindFirstChild("HumanoidRootPart"))
        notify("Dejaste de spectear", 1.2)
        return
    end

    if not p or not p.Character then
        notify("Jugador no disponible", 1.2)
        return
    end

    local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        spectateTarget = p
        -- poner en 3ra persona siguiendo al humanoid
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = humanoid
        notify("Espectando a "..p.Name.." (click sobre él = intento de activar poder)", 2.5)
    else
        notify("No se encontró Humanoid para "..p.Name, 1.6)
    end
end

-- construir fila pequeña por jugador
local function makeRow(p)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -12, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(28,28,28)
    row.Parent = listFrame
    local rCorner = Instance.new("UICorner", row); rCorner.CornerRadius = UDim.new(0,6)

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(0.6, -8, 1, 0)
    nameLbl.Position = UDim2.new(0,8,0,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = 14
    nameLbl.TextColor3 = Color3.new(1,1,1)
    nameLbl.Text = p.Name

    local spectBtn = Instance.new("TextButton", row)
    spectBtn.Size = UDim2.new(0.34, -12, 0, 28)
    spectBtn.Position = UDim2.new(0.62, 0, 0.12, 0)
    spectBtn.Text = "Espectear"
    spectBtn.Font = Enum.Font.GothamSemibold
    spectBtn.TextSize = 13
    spectBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    local sC = Instance.new("UICorner", spectBtn); sC.CornerRadius = UDim.new(0,6)

    spectBtn.MouseButton1Click:Connect(function()
        setSpectateTarget(p)
    end)

    return row
end

local function refreshList()
    for _,c in ipairs(listFrame:GetChildren()) do
        if c:IsA("Frame") then pcall(function() c:Destroy() end) end
    end
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= player then
            makeRow(pl)
        end
    end
    -- ajustar CanvasSize
    local _, sizeY = pcall(function()
        listFrame.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 8)
    end)
end

-- toggle panel
toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then refreshList() end
end)

-- actualizar lista al entrar/salir
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
refreshList()

-- ===== Detectar click sobre el personaje que estás specteando =====
-- usamos el mouse para raycast al hacer click; si el click golpea una parte dentro
-- del Character del spectateTarget, intentamos disparar el RemoteEvent (si existe).
local mouse = player:GetMouse()

mouse.Button1Down:Connect(function()
    if not spectateTarget then return end
    if not spectateTarget.Character then return end

    local now = tick()
    if now - lastClick < CLICK_COOLDOWN then return end
    lastClick = now

    local target = mouse.Target -- la parte que el mouse tocó
    if not target then return end

    -- verificar si la parte pertenece al character objetivo
    if target:IsDescendantOf(spectateTarget.Character) then
        -- intentar obtener RemoteEvent
        local rem = ReplicatedStorage:FindFirstChild(ATTACK_REMOTE_NAME)
        if rem and rem:IsA("RemoteEvent") then
            -- enviamos el UserId del target. El servidor decide cómo interpretarlo.
            pcall(function()
                rem:FireServer(spectateTarget.UserId)
            end)
            notify("Intento de activar poder enviado al servidor.", 1.6)
        else
            -- No existe remote; no añadimos ataques locales por tu instrucción
            notify("No hay RemoteEvent '"..ATTACK_REMOTE_NAME.."'. El servidor gestiona el ataque.", 1.8)
        end
    end
end)

-- ===== Mantener camera si el humanoid desaparece =====
RunService.RenderStepped:Connect(function()
    if spectateTarget then
        if not spectateTarget.Character or not spectateTarget.Character:FindFirstChildOfClass("Humanoid") then
            -- si perdió character, dejar de spectear
            spectateTarget = nil
            camera.CameraType = Enum.CameraType.Custom
            notify("Jugador desconectado / sin character. Spectate detenido.", 1.6)
        end
    end
end)

-- limpiar cámara si el script se destruye o el jugador muere
player.AncestryChanged:Connect(function(_, parent)
    if not parent then
        camera.CameraType = Enum.CameraType.Custom
    end
end)

-- fin del script
