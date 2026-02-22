Karakterin boşlukta sıkışmasının sebebi, yer altına (VerticalOffset = -3.5) indiğinde Roblox'un fizik motorunun seni haritanın dışına düşüyor sanıp karakteri dondurması veya noclip tam devreye girmeden bir parçaya takılmandır.

Bunu çözmek için koda "BodyVelocity" (Yerçekimi Sabitleyici) ekledim. Bu sayede karakterin yerin altında "yüzüyormuş" gibi sabit duracak ve aşağı sonsuza kadar düşmeyecek ya da takılmayacak.

Sıkışma Sorunu Giderilmiş Güncel Kod
İki
-- MM2 ULTIMATE FARM (STUCK FIX + UNDERGROUND)
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- UI LIBRARY
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("MM2 FIXED FARM", "DarkTheme")
local MainTab = Window:NewTab("Main Menu")
local Section = MainTab:NewSection("Auto Farm Settings")

_G.AutoFarm = false
_G.Noclip = false
local FarmSpeed = 15 
local VerticalOffset = -4.0 -- Slightly deeper to avoid floor collisions

-- STUCK PREVENTION (Anti-Fall & Anti-Physics)
local function CreateAntiFall()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if not root:FindFirstChild("FarmVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FarmVelocity"
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Parent = root
        end
    end
end

local function RemoveAntiFall()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FarmVelocity")
        if bv then bv:Destroy() end
    end
end

-- NOCLIP LOGIC
RunService.Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- GET NEAREST COIN
local function GetNearestCoin()
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end
    local Coins = workspace:FindFirstChild("CoinContainer", true)
    local Closest, MaxDist = nil, math.huge
    if Coins then
        for _, v in pairs(Coins:GetChildren()) do
            if v:IsA("BasePart") then
                local Dist = (Root.Position - v.Position).Magnitude
                if Dist < MaxDist then MaxDist = Dist Closest = v end
            end
        end
    end
    return Closest
end

-- TWEEN MOVEMENT
local function MoveTo(targetCFrame)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local part = character.HumanoidRootPart
        local offsetCFrame = targetCFrame * CFrame.new(0, VerticalOffset, 0)
        local distance = (part.Position - offsetCFrame.p).Magnitude
        local info = TweenInfo.new(distance / FarmSpeed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(part, info, {CFrame = offsetCFrame})
        tween:Play()
        return tween
    end
end

-- UI TOGGLE
Section:NewToggle("Enable Auto-Farm", "Stuck Fix + Underground", function(state)
    _G.AutoFarm = state
    _G.Noclip = state
    
    if state then
        CreateAntiFall()
    else
        RemoveAntiFall()
    end
    
    task.spawn(function()
        while _G.AutoFarm do
            task.wait(0.2)
            local nearest = GetNearestCoin()
            if nearest and _G.AutoFarm then
                local move = MoveTo(nearest.CFrame)
                if move then 
                    move.Completed:Wait() 
                    task.wait(0.1) 
                end
            else 
                task.wait(1) 
            end
        end
    end)
end)

Section:NewSlider("Farm Speed", "Max 25", 25, 5, function(s) FarmSpeed = s end)

local Section2 = MainTab:NewSection("Utility")
Section2:NewButton("Enable Anti-AFK", "Prevents idle kick", function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

print("Script updated: Stuck prevention active.")
