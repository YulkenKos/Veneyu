loadstring([==[
-- Menu Game Pass Temporal - Delta/Universal
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- CONFIG: Agrega aquí los IDs de tus Game Pass si quieres un filtro, sino se listan todos
local GAMEPASS_IDS = {12345678, 87654321} -- reemplaza con tus IDs reales

-- Función para “otorgar” el Game Pass temporalmente
local function grantGamePass(id)
    local tag = player:FindFirstChild("GamePass_"..id)
    if not tag then
        tag = Instance.new("BoolValue")
        tag.Name = "GamePass_"..id
        tag.Value = true
        tag.Parent = player
    end
end

-- GUI
local screen = Instance.new("ScreenGui")
screen.Name = "GamePassMenuUI"
screen.Parent = player:WaitForChild("PlayerGui")
screen.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 300, 0, 400)
panel.Position = UDim2.new(0.5, -150, 0.5, -200)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Parent = screen
local pCorner = Instance.new("UICorner", panel); pCorner.CornerRadius = UDim.new(0,12)

-- Hacer panel movible
local dragging = false
local dragInput, dragStart, startPos
panel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
panel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Titulo
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, -12, 0, 40)
title.Position = UDim2.new(0,6,0,6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.Text = "Game Pass Menu"

-- Scroll frame para los Game Pass
local scroll = Instance.new("ScrollingFrame", panel)
scroll.Size = UDim2.new(1, -12, 1, -52)
scroll.Position = UDim2.new(0,6,0,46)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Crear botones por Game Pass
for _, id in ipairs(GAMEPASS_IDS) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -12, 0, 36)
    btn.Text = "Obtener Game Pass "..id
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        grantGamePass(id)
        btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        btn.Text = "Game Pass "..id.." activado"
    end)
end

scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
]==])
