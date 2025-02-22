--最新aimbotHUB
--[[
    AirHub V2 - Modern UI with Integrated ESP and Aimbot
    By Exunys & PuneetGOTO
]]

--// Loaded Check

if AirHubV2Loaded or AirHubV2Loading or AirHub then
    return
end

getgenv().AirHubV2Loading = true

--// Load Dependencies
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/PuneetGOTO/TESTAIMBOT/master/--ESP库.lua"))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/PuneetGOTO/TESTAIMBOT/master/--aimbot文件.lua"))()

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

--// Initialize Functions
local function InitializeESP()
    RunService.RenderStepped:Connect(function()
        if not ESP.Settings.Enabled then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if ESP.Settings.TeamCheck and IsTeammate(player) then continue end
            if ESP.Settings.AliveCheck and not IsAlive(player) then continue end
            
            ESP.DrawBox(player)
            ESP.DrawTracer(player)
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
        
        local target = Aimbot.GetClosestPlayer()
        if target then
            Aimbot.AimAt(target)
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