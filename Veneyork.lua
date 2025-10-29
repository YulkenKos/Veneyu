-- OpreHubGUI (Ultra-Safe)
-- Autor: Adaptado para el usuario (OpresorDev)
-- Nota: Solo contiene Auto-Farm Delivery seguro (local)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
if not player then return end

-- Root GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OpreHubGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Helper functions
local function createFrame(parent, props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(25,25,25)
    f.Size = props.Size or UDim2.new(0, 300, 0, 200)
    f.Position = props.Position or UDim2.new(0.5, 0, 0.5, 0)
    f.AnchorPoint = props.AnchorPoint or Vector2.new(0.5,0.5)
    f.Parent = parent
    if props.UICorner then
        local corner = Instance.new("UICorner", f)
        corner.CornerRadius = props.UICorner
    end
    return f
end

local function createLabel(parent, text, props)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text or ""
    lbl.Size = props.Size or UDim2.new(1, -10, 0, 30)
    lbl.Position = props.Position or UDim2.new(0, 5, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = props.Font or Enum.Font.Gotham
    lbl.TextSize = props.TextSize or 16
    lbl.TextColor3 = props.TextColor3 or Color3.new(1,1,1)
    lbl.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createButton(parent, text, props)
    local btn = Instance.new("TextButton")
    btn.Text = text or "Button"
    btn.Size = props.Size or UDim2.new(1, 0, 0, 28)
    btn.Position = props.Position or UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(40,40,40)
    btn.Font = props.Font or Enum.Font.GothamSemibold
    btn.TextSize = props.TextSize or 16
    btn.TextColor3 = props.TextColor3 or Color3.new(1,1,1)
    btn.AutoButtonColor = true
    btn.Parent = parent
    if props.UICorner then
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = props.UICorner
    end
    return btn
end

-- Main frame
local root = createFrame(gui, {
    Size = UDim2.new(0, 420, 0, 200),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    UICorner = UDim.new(0, 18)
})

-- Header
local title = createLabel(root, "OpreHub - Auto Delivery", {Size = UDim2.new(1, -20, 0, 36), TextSize = 20, Font = Enum.Font.GothamBold})
title.Position = UDim2.new(0,10,0,10)

-- Menu container
local menu = Instance.new("Frame", root)
menu.Size = UDim2.new(1, -20, 1, -60)
menu.Position = UDim2.new(0, 10, 0, 50)
menu.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout", menu)
listLayout.Padding = UDim.new(0, 8)
listLayout.FillDirection = Enum.FillDirection.Vertical

-- Safe Auto-Farm Delivery
local safeAutoFarmEnabled = false
local function notify(text,duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title="OpreHub", Text=text, Duration=duration or 2})
    end)
end

local function startSafeAutoFarm()
    if safeAutoFarmEnabled then return end
    safeAutoFarmEnabled = true
    notify("Auto-Farm Delivery activado (local).")
    spawn(function()
        while safeAutoFarmEnabled do
            notify("Auto-Farm Delivery: simulación local.", 1)
            wait(5 + math.random()) -- delay aleatorio
        end
    end)
end

local function stopSafeAutoFarm()
    safeAutoFarmEnabled = false
    notify("Auto-Farm Delivery detenido.")
end

-- Button
local btn = createButton(menu, "Toggle Auto-Farm Delivery", {Size=UDim2.new(1,0,0,36), UICorner=UDim.new(0,10)})
btn.MouseButton1Click:Connect(function()
    if not safeAutoFarmEnabled then
        startSafeAutoFarm()
        btn.Text = "Detener Auto-Farm Delivery"
    else
        stopSafeAutoFarm()
        btn.Text = "Activar Auto-Farm Delivery"
    end
end)

-- Esc para cerrar GUI
local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        root.Visible = not root.Visible
    end
end)

notify("OpreHub listo (solo Auto-Farm Delivery seguro).")
