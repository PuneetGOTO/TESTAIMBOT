--最新aimbotHUB
--[[

	AirHub V2 by Exunys CC0 1.0 Universal (2023)
	https://github.com/Exunys

]]

--// Loaded Check

if AirHubV2Loaded or AirHubV2Loading or AirHub then
	return
end

getgenv().AirHubV2Loading = true

--// Cache

local game = game
local loadstring, typeof, select, next, pcall = loadstring, typeof, select, next, pcall
local tablefind, tablesort = table.find, table.sort
local mathfloor = math.floor
local stringgsub = string.gsub
local wait, delay, spawn = task.wait, task.delay, task.spawn
local osdate = os.date

--// Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// ESP Component
local ESP = {
    Settings = {
        Enabled = false,
        TeamCheck = false,
        AliveCheck = true,
        BoxEnabled = true,
        TracerEnabled = true,
        NameEnabled = true,
        HealthEnabled = true,
        Distance = 2000
    },
    
    Properties = {
        BoxColor = Color3.fromRGB(255, 255, 255),
        TracerColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        HealthColor = Color3.fromRGB(0, 255, 0),
        BoxThickness = 1,
        TracerThickness = 1,
        TextSize = 14
    }
}

--// Aimbot Component
local Aimbot = {
    Settings = {
        Enabled = false,
        TeamCheck = false,
        AliveCheck = true,
        WallCheck = false,
        Sensitivity = 1,
        FieldOfView = 90,
        TargetPart = "Head",
        TriggerKey = Enum.UserInputType.MouseButton2,
        Toggle = false
    },
    
    Properties = {
        FOVColor = Color3.fromRGB(255, 255, 255),
        FOVThickness = 1,
        FOVTransparency = 0.7,
        LockedColor = Color3.fromRGB(255, 150, 150)
    }
}

--// Core Functions
local function GetCharacter(player)
    return player.Character
end

local function IsAlive(player)
    local character = GetCharacter(player)
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

local function IsTeammate(player)
    return player.Team == LocalPlayer.Team
end

local function GetPartPosition(part)
    local position, visible = Camera:WorldToViewportPoint(part.Position)
    return Vector2.new(position.X, position.Y), visible and position.Z > 0
end

--// ESP Functions
local function DrawBox(player)
    if not ESP.Settings.BoxEnabled then return end
    
    local character = GetCharacter(player)
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local position, visible = GetPartPosition(hrp)
    if not visible then return end
    
    local box = Drawing.new("Square")
    box.Visible = true
    box.Color = ESP.Properties.BoxColor
    box.Thickness = ESP.Properties.BoxThickness
    box.Size = Vector2.new(40, 60)
    box.Position = position - box.Size/2
    
    return box
end

local function DrawTracer(player)
    if not ESP.Settings.TracerEnabled then return end
    
    local character = GetCharacter(player)
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local position, visible = GetPartPosition(hrp)
    if not visible then return end
    
    local tracer = Drawing.new("Line")
    tracer.Visible = true
    tracer.Color = ESP.Properties.TracerColor
    tracer.Thickness = ESP.Properties.TracerThickness
    tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
    tracer.To = position
    
    return tracer
end

--// Aimbot Functions
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Aimbot.Settings.TeamCheck and IsTeammate(player) then continue end
        if Aimbot.Settings.AliveCheck and not IsAlive(player) then continue end
        
        local character = GetCharacter(player)
        if not character then continue end
        
        local part = character:FindFirstChild(Aimbot.Settings.TargetPart)
        if not part then continue end
        
        local position, visible = GetPartPosition(part)
        if not visible then continue end
        
        local distance = (UserInputService:GetMouseLocation() - position).Magnitude
        if distance < shortestDistance and distance <= Aimbot.Settings.FieldOfView then
            closestPlayer = player
            shortestDistance = distance
        end
    end
    
    return closestPlayer
end

local function AimAt(player)
    if not player then return end
    
    local character = GetCharacter(player)
    if not character then return end
    
    local part = character:FindFirstChild(Aimbot.Settings.TargetPart)
    if not part then return end
    
    local position = Camera:WorldToViewportPoint(part.Position)
    local mousePos = UserInputService:GetMouseLocation()
    local aimDelta = Vector2.new(
        (position.X - mousePos.X) * Aimbot.Settings.Sensitivity,
        (position.Y - mousePos.Y) * Aimbot.Settings.Sensitivity
    )
    
    mousemoverel(aimDelta.X, aimDelta.Y)
end

--// Initialize Functions
local function InitializeESP()
    RunService.RenderStepped:Connect(function()
        if not ESP.Settings.Enabled then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if ESP.Settings.TeamCheck and IsTeammate(player) then continue end
            if ESP.Settings.AliveCheck and not IsAlive(player) then continue end
            
            DrawBox(player)
            DrawTracer(player)
        end
    end)
end

local function InitializeAimbot()
    local isAiming = false
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Aimbot.Settings.TriggerKey then
            isAiming = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Aimbot.Settings.TriggerKey then
            isAiming = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not Aimbot.Settings.Enabled or not isAiming then return end
        
        local target = GetClosestPlayer()
        if target then
            AimAt(target)
        end
    end)
end

--// Load Modern UI Library
local library = loadstring(game:HttpGet("ModernUI.lua"))()

--// Create Window
local window = library:CreateWindow({
    title = "AirHub V2",
    width = 600,
    height = 400
})

--// Create Tabs
local mainTab = window:AddTab("Main")
local aimbotTab = window:AddTab("Aimbot")
local espTab = window:AddTab("ESP")
local settingsTab = window:AddTab("Settings")

--// Main Tab
local mainSection = mainTab:AddSection({
    name = "Information",
    position = UDim2.new(0, 0, 0, 0),
    size = UDim2.new(1, 0, 0, 100)
})

mainSection:AddButton({
    name = "Enable All",
    callback = function()
        ESP.Settings.Enabled = true
        Aimbot.Settings.Enabled = true
    end
})

--// Aimbot Tab
local aimbotSection = aimbotTab:AddSection({
    name = "Aimbot Settings",
    position = UDim2.new(0, 0, 0, 0),
    size = UDim2.new(0.5, -5, 0, 200)
})

aimbotSection:AddToggle({
    name = "Enabled",
    default = false,
    callback = function(value)
        Aimbot.Settings.Enabled = value
    end
})

aimbotSection:AddToggle({
    name = "Team Check",
    default = false,
    callback = function(value)
        Aimbot.Settings.TeamCheck = value
    end
})

aimbotSection:AddSlider({
    name = "Sensitivity",
    min = 0,
    max = 10,
    default = 1,
    callback = function(value)
        Aimbot.Settings.Sensitivity = value
    end
})

--// ESP Tab
local espSection = espTab:AddSection({
    name = "ESP Settings",
    position = UDim2.new(0, 0, 0, 0),
    size = UDim2.new(0.5, -5, 0, 200)
})

espSection:AddToggle({
    name = "Enabled",
    default = false,
    callback = function(value)
        ESP.Settings.Enabled = value
    end
})

espSection:AddToggle({
    name = "Box ESP",
    default = true,
    callback = function(value)
        ESP.Settings.BoxEnabled = value
    end
})

espSection:AddToggle({
    name = "Tracer ESP",
    default = true,
    callback = function(value)
        ESP.Settings.TracerEnabled = value
    end
})

--// Settings Tab
local settingsSection = settingsTab:AddSection({
    name = "Configuration",
    position = UDim2.new(0, 0, 0, 0),
    size = UDim2.new(1, 0, 0, 100)
})

settingsSection:AddButton({
    name = "Save Configuration",
    callback = function()
        -- Save settings
    end
})

--// Initialize
InitializeESP()
InitializeAimbot()
getgenv().AirHubV2Loaded = true
getgenv().AirHubV2Loading = nil