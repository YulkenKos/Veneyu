loadstring([==[
-- Delta-friendly SilasV3 Adaptado

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- CONFIG: IDs de Game Pass (reemplaza con los del juego)
local GAMEPASS_IDS = {12345678, 87654321} 

-- Función para "otorgar" Game Pass
local function grantGamePass(id)
    if not player:FindFirstChild("GamePass_"..id) then
        local tag = Instance.new("BoolValue")
        tag.Name = "GamePass_"..id
        tag.Value = true
        tag.Parent = player
    end
end

-- Crear ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "DeltaSilasV3UI"
screen.Parent = player:WaitForChild("PlayerGui")
screen.ResetOnSpawn = false

-- Botón negro para abrir/cerrar menú
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 40)
toggleBtn.Position = UDim2.new(0, 12, 0, 12)
toggleBtn.Text = "Abrir Menú"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Parent = screen
local tCorner = Instance.new("UICorner", toggleBtn)
tCorner.CornerRadius = UDim.new(0,6)

-- Panel del menú (inicialmente oculto)
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 280, 0, 360)
panel.Position = UDim2.new(0, 12, 0, 60)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = screen
local pCorner = Instance.new("UICorner", panel)
pCorner.CornerRadius = UDim.new(0,12)
panel.Active = true
panel.Draggable = true

-- Título del panel
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, -12, 0, 36)
title.Position = UDim2.new(0,6,0,6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)
title.Text = "SilasV3 Menu"

-- Scroll para botones
local scroll = Instance.new("ScrollingFrame", panel)
scroll.Size = UDim2.new(1, -12, 1, -48)
scroll.Position = UDim2.new(0,6,0,42)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Crear botón por cada Game Pass
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

-- Ajustar tamaño del scroll según contenido
scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)

-- Abrir/Cerrar panel
toggleBtn.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
    toggleBtn.Text = panel.Visible and "Cerrar Menú" or "Abrir Menú"
end)
]==])
