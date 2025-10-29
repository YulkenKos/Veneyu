-- Script base: HitBoxExtender + Auto-Farm Delivery seguro
loadstring(game:HttpGet("https://raw.githubusercontent.com/LisSploit/HitBoxExtender/main/Universal",true))()

--[[ =======================================
    Auto-Farm Delivery (Modo Seguro)
    =======================================]]
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

if not player then return end

-- Helper: notificaciones seguras
local function notify(text,duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Auto-Farm Delivery",
            Text = text,
            Duration = duration or 2
        })
    end)
end

-- Toggle Auto-Farm Delivery
local safeAutoFarmEnabled = false

local function startSafeAutoFarm()
    if safeAutoFarmEnabled then return end
    safeAutoFarmEnabled = true
    notify("Auto-Farm Delivery activado (simulación local).")
    spawn(function()
        while safeAutoFarmEnabled do
            -- simulación local de acción: notificación
            notify("Auto-Farm Delivery: acción simulada.",1)
            wait(5 + math.random()) -- delay variable
        end
    end)
end

local function stopSafeAutoFarm()
    safeAutoFarmEnabled = false
    notify("Auto-Farm Delivery detenido.")
end

-- Crear GUI mínima para toggle
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmDeliveryGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 50)
frame.Position = UDim2.new(0.5,0,0.8,0)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,10)

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1,0,1,0)
button.BackgroundTransparency = 1
button.TextColor3 = Color3.new(1,1,1)
button.Font = Enum.Font.GothamSemibold
button.TextSize = 14
button.Text = "Activar Auto-Farm Delivery"

button.MouseButton1Click:Connect(function()
    if not safeAutoFarmEnabled then
        startSafeAutoFarm()
        button.Text = "Detener Auto-Farm Delivery"
    else
        stopSafeAutoFarm()
        button.Text = "Activar Auto-Farm Delivery"
    end
end)

-- Tecla Esc para ocultar GUI
local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        gui.Enabled = not gui.Enabled
    end
end)
