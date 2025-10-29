loadstring([==[
-- Game Pass Menu Delta - Funciona en cualquier servidor
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

-- CONFIG: IDs de los Game Pass que quieres activar
local GAMEPASS_IDS = {12345678, 87654321} -- reemplaza con tus Game Pass

-- Función para "otorgar" Game Pass temporalmente
local function grantGamePass(id)
    local tag = player:FindFirstChild("GamePass_"..id)
    if not tag then
        tag = Instance.new("BoolValue")
        tag.Name = "GamePass_"..id
        tag.Value = true
        tag.Parent = player
    end
end

-- Función para remover todos
local function removeGamePasses()
    for _, id in ipairs(GAMEPASS_IDS) do
        local tag = player:FindFirstChild("GamePass_"..id)
        if tag then tag:Destroy() end
    end
end

-- Crear GUI
local screen = Instance.new("ScreenGui")
screen.Name = "GamePassMenuUI"
screen.Parent = player:WaitForChild("PlayerGui")
screen.ResetOnSpawn = false

-- Panel movible
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 280, 0, 360)
panel.Position = UDim2.new(0, 12, 0, 12)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
local pCorner = Instance.new("UICorner", panel)
pCorner.CornerRadius = UDim.new(0,12)
panel.Active = true
panel.Draggable = true -- Hacerlo movible

-- Título
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, -12, 0, 36)
title.Position = UDim2.new(0,6,0,6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.Text = "Game Pass Menu"

-- Scroll para botones
local scroll = Instance.new("ScrollingFrame", panel)
scroll.Size = UDim2.new(1, -12, 1, -48)
scroll.Position = UDim2.new(0,6,0,42)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Crear botones para cada Game Pass
for _, id in ipairs(GAMEPASS_IDS) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -12, 0, 36)
    btn.Text = "Activar Game Pass "..id
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        grantGamePass(id)
        btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        btn.Text = "Game Pass "..id.." activado"
    end)
end

-- Ajustar tamaño del Scroll según contenido
scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
]==])
