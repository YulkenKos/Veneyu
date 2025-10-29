loadstring([==[
-- Game Pass Temporales - Compatible Delta y cualquier servidor
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- CONFIGURA AQUÍ TUS GAMEPASS IDs
local GAMEPASS_IDS = {12345678, 87654321} -- reemplaza con tus Game Pass reales

-- Funciones para activar/desactivar
local function grantGamePasses()
    for _, id in ipairs(GAMEPASS_IDS) do
        local tag = Instance.new("BoolValue")
        tag.Name = "GamePass_"..id
        tag.Value = true
        tag.Parent = player
    end
end

local function removeGamePasses()
    for _, id in ipairs(GAMEPASS_IDS) do
        local tag = player:FindFirstChild("GamePass_"..id)
        if tag then tag:Destroy() end
    end
end

-- GUI
local screen = Instance.new("ScreenGui")
screen.Name = "GamePassToggleUI"
screen.Parent = player:WaitForChild("PlayerGui")
screen.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 140, 0, 44)
toggleBtn.Position = UDim2.new(0, 12, 0, 12)
toggleBtn.Text = "Activar Game Pass"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Parent = screen
local tCorner = Instance.new("UICorner", toggleBtn)
tCorner.CornerRadius = UDim.new(0,8)

local active = false
toggleBtn.MouseButton1Click:Connect(function()
    if not active then
        grantGamePasses()
        toggleBtn.Text = "Desactivar Game Pass"
        active = true
    else
        removeGamePasses()
        toggleBtn.Text = "Activar Game Pass"
        active = false
    end
end)
]==])
