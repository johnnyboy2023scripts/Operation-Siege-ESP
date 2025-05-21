-- created by johnny_boy2023 if u find this script good 4 u. this script is in BETA and will have bugs. if u cant see enemy players just disable and enable the ESP again. 
--UPDATE 20/05/2025 - Added Silent Aim. 
--heres the raw and shortened version
--COPY AND PASTE THIS IN GAME:
--loadstring(game:HttpGet("https://raw.githubusercontent.com/johnnyboy2023scripts/Operation-Siege-ESP/main/OperationSiegeESP.lua"))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Johnny's ESP"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local checkbox = Instance.new("TextButton", frame)
checkbox.Size = UDim2.new(0, 20, 0, 20)
checkbox.Position = UDim2.new(0, 10, 0, 40)
checkbox.Text = "☐"
checkbox.TextColor3 = Color3.new(1, 1, 1)
checkbox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
checkbox.Font = Enum.Font.SourceSans
checkbox.TextSize = 18

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, -40, 0, 20)
label.Position = UDim2.new(0, 40, 0, 40)
label.Text = "ESP"
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.SourceSans
label.TextSize = 16

local silentAimBtn = Instance.new("TextButton", frame)
silentAimBtn.Size = UDim2.new(0, 140, 0, 20)
silentAimBtn.Position = UDim2.new(0, 10, 0, 70)
silentAimBtn.Text = "Silent Aim: Off"
silentAimBtn.TextColor3 = Color3.new(1, 1, 1)
silentAimBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
silentAimBtn.Font = Enum.Font.SourceSans
silentAimBtn.TextSize = 16

-- Colors
local playerColor = Color3.fromRGB(255, 0, 0)
local gadgetColor = Color3.fromRGB(255, 255, 0)
local camColor = Color3.fromRGB(0, 0, 255)
local espEnabled = false
local silentAimEnabled = false

-- FOV
local fovRadius = 100
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = fovRadius
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Thickness = 2
fovCircle.Transparency = 0.5
fovCircle.Filled = false
fovCircle.Visible = false

-- Utility
local function highlightObject(obj, name, color)
    if not obj:FindFirstChild(name) then
        local h = Instance.new("Highlight")
        h.Name = name
        h.FillColor = color
        h.OutlineColor = color
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = obj
        h.Parent = obj
    end
end

local function unhighlightObject(obj, name)
    local h = obj:FindFirstChild(name)
    if h then h:Destroy() end
end

-- ESP Functions
local function updatePlayerESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team then
            highlightObject(p.Character, "ESP_Highlight", playerColor)
        end
    end
end

local keywords = { "gadget", "drone", "camera", "device" }
local function checkAndHighlightGadget(obj)
    for _, word in ipairs(keywords) do
        if obj.Name:lower():find(word) then
            local part = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
            if part and part:IsA("BasePart") then
                highlightObject(part, "ObjectESP", gadgetColor)
            end
            break
        end
    end
end

local function highlightDefaultCams()
    local seWorkspace = Workspace:FindFirstChild("SE_Workspace")
    if not seWorkspace then return end
    local camerasFolder = seWorkspace:FindFirstChild("Cameras")
    if not camerasFolder then return end
    for _, obj in pairs(camerasFolder:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "DefaultCam" then
            highlightObject(obj, "CamHighlight", camColor)
        end
    end
end

-- Toggle ESP
checkbox.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    checkbox.Text = espEnabled and "☑" or "☐"
    if espEnabled then
        updatePlayerESP()
        highlightDefaultCams()
        for _, obj in pairs(Workspace:GetDescendants()) do
            checkAndHighlightGadget(obj)
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then unhighlightObject(p.Character, "ESP_Highlight") end
        end
        for _, obj in pairs(Workspace:GetDescendants()) do
            unhighlightObject(obj, "ObjectESP")
            unhighlightObject(obj, "CamHighlight")
        end
    end
end)

-- Silent Aim Toggle
silentAimBtn.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    fovCircle.Visible = silentAimEnabled
    silentAimBtn.Text = "Silent Aim: " .. (silentAimEnabled and "On" or "Off")
end)

-- Auto ESP refresh
task.spawn(function()
    while true do
        if espEnabled then updatePlayerESP() end
        task.wait(3)
    end
end)

-- FOV circle position
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
end)

-- Closest player to mouse
local function getClosestPlayer()
    local mousePos = UserInputService:GetMouseLocation()
    local closest = nil
    local shortestDist = fovRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = player
                end
            end
        end
    end

    return closest
end

-- Hook mouse ray
local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "FindPartOnRayWithIgnoreList" and silentAimEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local direction = (target.Character.Head.Position - Camera.CFrame.Position).Unit * 500
            local args = {...}
            args[1] = Ray.new(Camera.CFrame.Position, direction)
            return __namecall(self, unpack(args))
        end
    end
    return __namecall(self, ...)
end)

-- Monitor new players and workspace objects
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.3)
        if espEnabled then updatePlayerESP() end
    end)
end)

Workspace.DescendantAdded:Connect(function(obj)
    if not espEnabled then return end
    if obj:IsA("Model") and obj.Name == "DefaultCam" then
        task.wait(0.1)
        highlightObject(obj, "CamHighlight", camColor)
    else
        checkAndHighlightGadget(obj)
    end
end)

-- Hide GUI with Right Ctrl
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    end
end)

