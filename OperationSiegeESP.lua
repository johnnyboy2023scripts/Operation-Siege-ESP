-- created by johnny_boy2023 if u find this script good 4 u.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 80)
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

-- Colors
local playerColor = Color3.fromRGB(255, 0, 0)
local gadgetColor = Color3.fromRGB(255, 255, 0)
local camColor = Color3.fromRGB(0, 0, 255)
local espEnabled = false

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

-- Check/Update Players
local function updatePlayerESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team then
            highlightObject(p.Character, "ESP_Highlight", playerColor)
        end
    end
end

-- Check Gadgets
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

-- Check DefaultCam
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

-- Realtime Monitor
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

-- ESP Logic Toggle
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
        -- Remove all highlights
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then unhighlightObject(p.Character, "ESP_Highlight") end
        end
        for _, obj in pairs(Workspace:GetDescendants()) do
            unhighlightObject(obj, "ObjectESP")
            unhighlightObject(obj, "CamHighlight")
        end
    end
end)

-- Optional: Refresh ESP every few seconds just in case
task.spawn(function()
    while true do
        if espEnabled then
            updatePlayerESP()
        end
        task.wait(3)
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
