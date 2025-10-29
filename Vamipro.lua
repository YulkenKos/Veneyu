-- Las Leyendas Vampíricas 2 (Delta Adaptado - Spectate + Golpear)
-- LocalScript para StarterPlayerScripts

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CONFIGURACIÓN
local ADMINS = { [player.UserId] = true }
local DAMAGE = 25
local STRIKE_COOLDOWN = 2.5
local JAIL_POSITION = Vector3.new(0,50,0)
local FREEZE_ANCHOR = true

-- NOTIFICACIONES
local function notify(msg, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "AdminPanel",
            Text = msg,
            Duration = dur or 2
        })
    end)
end

-- -----------------------------
-- BOTÓN NEGRO PARA ABRIR/CERRAR MENÚ
-- -----------------------------
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,50,0,50)
toggleBtn.Position = UDim2.new(0,10,0,10)
toggleBtn.Text = "Menu"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.ZIndex = 999
toggleBtn.Parent = player:WaitForChild("PlayerGui")

-- -----------------------------
-- CREACIÓN DE UI
-- -----------------------------
local function createUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AdminPanelUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,420,0,420)
    frame.Position = UDim2.new(0.5,-210,0.5,-210)
    frame.BackgroundColor3 = Color3.fromRGB(24,24,24)
    frame.Visible = false
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0,16)

    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1,-20,0,48)
    header.Position = UDim2.new(0,10,0,10)
    header.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(0.6,0,1,0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.new(1,1,1)
    title.Text = "Admin Panel"

    local searchBox = Instance.new("TextBox", header)
    searchBox.Size = UDim2.new(0.4,-10,1,0)
    searchBox.Position = UDim2.new(0.6,8,0,0)
    searchBox.PlaceholderText = "Buscar jugadores..."
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 14
    searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local sCorner = Instance.new("UICorner", searchBox)
    sCorner.CornerRadius = UDim.new(0,8)

    local listFrame = Instance.new("Frame", frame)
    listFrame.Size = UDim2.new(1,-20,1,-76)
    listFrame.Position = UDim2.new(0,10,0,56)
    listFrame.BackgroundTransparency = 1

    local scroll = Instance.new("ScrollingFrame", listFrame)
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 1
    scroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    return {gui=gui, frame=frame, search=searchBox, scroll=scroll, layout=layout}
end

local function createPlayerRow(p)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-12,0,56)
    row.BackgroundColor3 = Color3.fromRGB(30,30,30)
    row.BorderSizePixel = 0
    local rowCorner = Instance.new("UICorner", row); rowCorner.CornerRadius = UDim.new(0,10)

    local avatar = Instance.new("ImageLabel", row)
    avatar.Size = UDim2.new(0,44,0,44)
    avatar.Position = UDim2.new(0,8,0,6)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..p.UserId.."&w=420&h=420"
    local avCorner = Instance.new("UICorner", avatar); avCorner.CornerRadius = UDim.new(0,22)

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(0.45,-16,1,0)
    nameLbl.Position = UDim2.new(0,62,0,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = 16
    nameLbl.TextColor3 = Color3.new(1,1,1)
    nameLbl.Text = p.Name

    local spectBtn = Instance.new("TextButton", row)
    spectBtn.Size = UDim2.new(0.22,-8,0,34)
    spectBtn.Position = UDim2.new(0.6,0,0.18,0)
    spectBtn.Text = "Espectear"
    spectBtn.Font = Enum.Font.GothamSemibold
    spectBtn.TextSize = 14
    spectBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    local sC = Instance.new("UICorner", spectBtn); sC.CornerRadius = UDim.new(0,8)

    local actionBtn = Instance.new("TextButton", row)
    actionBtn.Size = UDim2.new(0.22,-8,0,34)
    actionBtn.Position = UDim2.new(0.84,0,0.18,0)
    actionBtn.Text = "Acción"
    actionBtn.Font = Enum.Font.GothamSemibold
    actionBtn.TextSize = 14
    actionBtn.BackgroundColor3 = Color3.fromRGB(145,70,70)
    local acC = Instance.new("UICorner", actionBtn); acC.CornerRadius = UDim.new(0,8)

    return {row=row, avatar=avatar, name=nameLbl, spect=spectBtn, action=actionBtn}
end

-- Modal para acciones
local function createModal(parent)
    local modal = Instance.new("Frame", parent)
    modal.Size = UDim2.new(0,340,0,160)
    modal.Position = UDim2.new(0.5,-170,0.5,-80)
    modal.BackgroundColor3 = Color3.fromRGB(20,20,20)
    modal.Visible = false
    local corner = Instance.new("UICorner", modal); corner.CornerRadius = UDim.new(0,12)

    local label = Instance.new("TextLabel", modal)
    label.Size = UDim2.new(1,-24,0,60)
    label.Position = UDim2.new(0,12,0,12)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Color3.new(1,1,1)
    label.TextWrapped = true

    local dropdown = Instance.new("TextBox", modal)
    dropdown.Size = UDim2.new(0.96,0,0,30)
    dropdown.Position = UDim2.new(0.02,0,0,70)
    dropdown.PlaceholderText = "Acción: Golpear / Teleport / Freeze"
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 14
    dropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local dc = Instance.new("UICorner", dropdown); dc.CornerRadius = UDim.new(0,6)

    local confirm = Instance.new("TextButton", modal)
    confirm.Size = UDim2.new(0.46,-8,0,36)
    confirm.Position = UDim2.new(0.02,12,1,-48)
    confirm.Text = "Confirmar"
    local cC = Instance.new("UICorner", confirm); cC.CornerRadius = UDim.new(0,8)

    local cancel = Instance.new("TextButton", modal)
    cancel.Size = UDim2.new(0.46,-8,0,36)
    cancel.Position = UDim2.new(0.52,0,1,-48)
    cancel.Text = "Cancelar"
    local ccC = Instance.new("UICorner", cancel); ccC.CornerRadius = UDim.new(0,8)

    return {modal=modal,label=label,dropdown=dropdown,confirm=confirm,cancel=cancel}
end

-- Construir UI
local UI = createUI()
local modal = createModal(UI.gui)

-- VARIABLE GLOBAL SPECTATE
local spectateTarget = nil

-- Función para refrescar lista
local function refreshList(filter)
    local scroll = UI.scroll
    for _,c in ipairs(scroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= player and (not filter or filter == "" or p.Name:lower():match(filter:lower())) then
            local items = createPlayerRow(p)
            items.row.Parent = scroll

            -- Spectate
            items.spect.MouseButton1Click:Connect(function()
                if spectateTarget == p then
                    -- Detener espectate
                    spectateTarget = nil
                    Camera.CameraType = Enum.CameraType.Custom
                    notify("Dejaste de espectear a "..p.Name,2)
                else
                    spectateTarget = p
                    notify("Estás espectando a "..p.Name,2)
                end
            end)

            -- Acción
            items.action.MouseButton1Click:Connect(function()
                modal.label.Text = "Elige acción para "..p.Name
                modal.dropdown.Text = ""
                modal.modal.Visible = true

                local connConfirm
                connConfirm = modal.confirm.MouseButton1Click:Connect(function()
                    local action = modal.dropdown.Text:lower()
                    local targetRoot = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = p.Character and p.Character:FindFirstChild("Humanoid")
                    if action == "golpear" and humanoid then
                        humanoid:TakeDamage(DAMAGE)
                        notify("Golpeaste a "..p.Name,2)
                    elseif action == "teleport" and targetRoot then
                        targetRoot.CFrame = CFrame.new(JAIL_POSITION)
                        notify("Teleportaste a "..p.Name,2)
                    elseif action == "freeze" and targetRoot then
                        targetRoot.Anchored = true
                        notify("Congelaste a "..p.Name,2)
                    else
                        notify("Acción inválida",2)
                    end
                    modal.modal.Visible = false
                    connConfirm:Disconnect()
                end)

                modal.cancel.MouseButton1Click:Connect(function()
                    modal.modal.Visible = false
                    if connConfirm then connConfirm:Disconnect() end
                end)
            end)
        end
    end
end

-- Abrir/cerrar menú
toggleBtn.MouseButton1Click:Connect(function()
    UI.frame.Visible = not UI.frame.Visible
end)

-- Filtrado
UI.search:GetPropertyChangedSignal("Text"):Connect(function()
    refreshList(UI.search.Text)
end)

-- Actualizar lista al entrar/salir jugadores
Players.PlayerAdded:Connect(function() refreshList(UI.search.Text) end)
Players.PlayerRemoving:Connect(function() refreshList(UI.search.Text) end)

-- Inicializar lista
refreshList()

-- -----------------------------
-- UPDATE DE CAMARA (SPECTATE)
-- -----------------------------
RunService.RenderStepped:Connect(function()
    if spectateTarget and spectateTarget.Character and spectateTarget.Character:
