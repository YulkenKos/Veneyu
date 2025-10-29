-- OpreHubGUI (Refactorizado y más seguro)
-- Autor: Adaptado para el usuario (OpresorDev)
-- Nota de seguridad: NUNCA añadas llamadas a Remotes/InvokeServer o loadstring aquí
-- si quieres evitar riesgos de expulsión. Testea siempre en un servidor privado.

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then return end -- seguridad: salir si no hay LocalPlayer

-- Root GUI --
local gui = Instance.new("ScreenGui")
gui.Name = "OpreHubGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Helper: crea frames/text/buttons con parámetros claros
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

-- Interfaz principal --
local root = createFrame(gui, {
    Size = UDim2.new(0, 420, 0, 260),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    UICorner = UDim.new(0, 18)
})

-- Cabecera
local header = Instance.new("Frame", root)
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, -20, 0, 48)
header.Position = UDim2.new(0, 10, 0, 10)

local title = createLabel(header, "️ OpreHub", {
    Size = UDim2.new(0.6, 0, 1, 0),
    TextSize = 20,
    Font = Enum.Font.GothamBold
})
title.Position = UDim2.new(0, 0, 0, 0)

local welcome = createLabel(header, "Welcome,\n" .. player.Name, {
    Size = UDim2.new(0.4, -10, 1, 0),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Right
})
welcome.Position = UDim2.new(0.6, 0, 0, 0)

-- Avatar
local avatar = Instance.new("ImageLabel", header)
avatar.Size = UDim2.new(0, 36, 0, 36)
avatar.Position = UDim2.new(1, -36, 0.5, -18)
avatar.AnchorPoint = Vector2.new(1, 0.5)
avatar.BackgroundColor3 = Color3.fromRGB(200,200,200)
avatar.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1,0)

-- Cargar thumbnail (con pcall por seguridad)
task.spawn(function()
    local success, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if success and thumb then avatar.Image = thumb end
end)

-- Contenedor de opciones
local menu = Instance.new("Frame", root)
menu.Size = UDim2.new(1, -20, 1, -68)
menu.Position = UDim2.new(0, 10, 0, 56)
menu.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout", menu)
listLayout.Padding = UDim.new(0, 8)
listLayout.FillDirection = Enum.FillDirection.Vertical

-- Sub-frames (información/creditos)
local function makeSubFrame(titleText, bodyText)
    local f = createFrame(gui, {
        Size = UDim2.new(0, 420, 0, 260),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        UICorner = UDim.new(0, 18)
    })
    f.Visible = false

    local H = createLabel(f, titleText, {Size = UDim2.new(1, -20, 0, 36), TextSize = 20, Font = Enum.Font.GothamBold})
    H.Position = UDim2.new(0, 10, 0, 10)

    local B = createLabel(f, bodyText, {Size = UDim2.new(1, -20, 1, -80), Position = UDim2.new(0, 10, 0, 50), TextSize = 15})
    B.TextWrapped = true
    B.TextYAlignment = Enum.TextYAlignment.Top

    local back = createButton(f, "<- Volver", {Size = UDim2.new(0, 120, 0, 34), Position = UDim2.new(0, 10, 1, -44), UICorner = UDim.new(0, 10)})
    back.MouseButton1Click:Connect(function()
        f:Destroy()
        root.Visible = true
    end)

    return f
end

-- Notifications helper (safe pcall, no spam)
local function notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "OpreHub",
            Text = text,
            Duration = duration or 2
        })
    end)
end

-- ITEMS del menu (seguro)
local menuItems = {
    {name = "Auto-Farm Delivery", action = "autofarm_delivery"},
    {name = "Auto-Farm Farmanada (Próximamente)", action = "coming_soon"},
    {name = "Información", action = "info"},
    {name = "Créditos", action = "credits"}
}

-- Aquí guardamos subframes si es necesario
local infoFrame, creditFrame

-- Safe "auto-farm" demo: NO interactúa con el servidor. Solo muestra lo que haría.
-- Si quieres añadir automations reales, hazlo POR TU CUENTA y sabiendo el riesgo.
local safeAutoFarmEnabled = false
local autofarmToggleButton

local function startSafeAutoFarm()
    if safeAutoFarmEnabled then return end
    safeAutoFarmEnabled = true
    notify("Auto-Farm (modo seguro) activado. No interactuará con el servidor.")
    -- Ejemplo de acción segura: mostrar texto cada cierto tiempo localmente
    spawn(function()
        while safeAutoFarmEnabled do
            -- acción segura: simular actualización en UI, sin tocar remotes
            notify("Auto-Farm: acción local simulada", 1)
            wait(6 + math.random()) -- delays human-like
        end
    end)
end

local function stopSafeAutoFarm()
    safeAutoFarmEnabled = false
    notify("Auto-Farm detenido")
end

-- Crear botones del menú
for _, item in ipairs(menuItems) do
    local row = Instance.new("Frame", menu)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1

    local btn = createButton(row, "️ " .. item.name, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(40,40,40),
        UICorner = UDim.new(0, 8)
    })
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.MouseEnter:Connect(function() btn.TextColor3 = Color3.fromRGB(200,200,200) end)
    btn.MouseLeave:Connect(function() btn.TextColor3 = Color3.new(1,1,1) end)

    btn.MouseButton1Click:Connect(function()
        if item.action == "autofarm_delivery" then
            -- mostramos un toggle seguro (NO hace remotes)
            if not autofarmToggleButton then
                root.Visible = false
                local f = makeSubFrame("Auto-Farm Delivery (Modo Seguro)",
                    "Este modo simula tareas localmente y NO interactúa con el servidor. " ..
                    "Automatizaciones que toquen remotes o invoquen servidores pueden resultar en expulsión.")
                f.Visible = true

                local toggle = createButton(f, "Activar Auto-Farm (seguro)", {Position = UDim2.new(0.05,0,0.6,0), Size = UDim2.new(0.9,0,0,36), UICorner = UDim.new(0,10)})
                toggle.MouseButton1Click:Connect(function()
                    if not safeAutoFarmEnabled then
                        startSafeAutoFarm()
                        toggle.Text = "Detener Auto-Farm (seguro)"
                    else
                        stopSafeAutoFarm()
                        toggle.Text = "Activar Auto-Farm (seguro)"
                    end
                end)

                local info = createLabel(f, "Recuerda: para reducir riesgo de baneo, prueba siempre en servidores privados y evita remotes.", {Position = UDim2.new(0.05,0,0.68,0), Size = UDim2.new(0.9,0,0.15,0), TextSize = 14})
                autofarmToggleButton = toggle
            else
                notify("Ya hay una ventana de Auto-Farm abierta")
            end

        elseif item.action == "coming_soon" then
            notify("Funcionalidad próximamente...", 2)

        elseif item.action == "info" then
            root.Visible = false
            infoFrame = makeSubFrame("Información", "Este script es únicamente una interfaz local (cliente). No me hago responsable por el uso que se haga de automatizaciones que interactúen con servidores. Usa con precaución.")
            infoFrame.Visible = true

        elseif item.action == "credits" then
            root.Visible = false
            creditFrame = makeSubFrame("Créditos", "Desarrollado por OpreHub (OpresorDev). Adaptado para un modo más seguro.")
            creditFrame.Visible = true
        end
    end)
end

-- Tecla para cerrar la GUI (Esc)
local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        root.Visible = not root.Visible
    end
end)

-- Mensaje final
notify("OpreHub listo (modo seguro). Revisa la pestaña 'Auto-Farm' para acciones locales.")

-- FIN DEL SCRIPT
