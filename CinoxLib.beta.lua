local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- TEIL 1: MANIFEST & CORE FUNKTIONEN
-- ==========================================
function Cinox.Init(manifest)
    local SG = Instance.new("ScreenGui")
    SG.Name = manifest.Name
    SG.Parent = LocalPlayer.PlayerGui
    SG.ResetOnSpawn = false
    
    local MF = Instance.new("Frame")
    MF.Name = "MainFrame"
    MF.Size = UDim2.new(0, 550, 0, 350)
    MF.Position = UDim2.new(0.5, -275, 0.5, -175)
    MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MF.BorderSizePixel = 0
    MF.Parent = SG
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MF
    
    local TB = Instance.new("Frame")
    TB.Name = "TitleBar"
    TB.Size = UDim2.new(1, 0, 0, 35)
    TB.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TB.Parent = MF
    Instance.new("UICorner", TB)

    return SG, MF, TB
end

-- ==========================================
-- TEIL 2: CUSTOMIZING (FONTS & FARBEN)
-- ==========================================
local Theme = {
    Accent = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    FontSize = 14
}

local function ApplyStyle(obj)
    obj.Font = Theme.Font
    obj.TextSize = Theme.FontSize
    obj.TextColor3 = Theme.Text
end

-- ==========================================
-- TEIL 3: COLOR PICKER (MOBILE OPTIMIERT)
-- ==========================================
local function OpenPicker(mainFrame, callback)
    if mainFrame:FindFirstChild("CP_Window") then mainFrame.CP_Window:Destroy() end
    
    local CP = Instance.new("Frame", mainFrame)
    CP.Name = "CP_Window"
    CP.Size = UDim2.new(0, 160, 0, 180)
    CP.Position = UDim2.new(1, 10, 0, 0)
    CP.BackgroundColor3 = Theme.Secondary
    Instance.new("UICorner", CP)
    
    local Wheel = Instance.new("ImageButton", CP)
    Wheel.Size = UDim2.new(0, 120, 0, 120)
    Wheel.Position = UDim2.new(0.5, -60, 0, 10)
    Wheel.Image = "rbxassetid://7393858638"
    Wheel.BackgroundTransparency = 1
    
    local Pick = Instance.new("Frame", Wheel)
    Pick.Size = UDim2.new(0, 8, 0, 8)
    Pick.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Pick).CornerRadius = UDim.new(1, 0)
    
    local isDragging = false
    local function update(input)
        local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
        local delta = Vector2.new(input.Position.X, input.Position.Y) - center
        local angle = math.atan2(delta.Y, delta.X)
        local dist = math.min(delta.Magnitude, 60)
        Pick.Position = UDim2.new(0.5, math.cos(angle) * dist - 4, 0.5, math.sin(angle) * dist - 4)
        callback(Color3.fromHSV(((math.deg(angle) + 180) % 360) / 360, dist / 60, 1))
    end
    
    Wheel.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDragging = true update(i) end end)
    UserInputService.InputChanged:Connect(function(i) if isDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
    UserInputService.InputEnded:Connect(function() isDragging = false end)
end

-- ==========================================
-- TEIL 4: DRAG & GRÖSSENÄNDERUNG (PC & MOBILE)
-- ==========================================
local function MakeDraggable(gui, target)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

-- ==========================================
-- TEIL 5: TOGGLES & INTERAKTION
-- ==========================================
local function CreateToggle(parent, name, callback)
    local b = Instance.new("Frame", parent)
    b.Size = UDim2.new(1, -10, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", b)
    
    local lbl = Instance.new("TextLabel", b)
    lbl.Text = name
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.TextXAlignment = "Left"
    lbl.BackgroundTransparency = 1
    ApplyStyle(lbl)
    
    local btn = Instance.new("TextButton", b)
    btn.Size = UDim2.new(0, 35, 0, 20)
    btn.Position = UDim2.new(1, -45, 0.5, -10)
    btn.Text = ""
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

-- ==========================================
-- TEIL 6: SLIDER
-- ==========================================
local function CreateSlider(parent, name, min, max, callback)
    local sFrame = Instance.new("Frame", parent)
    sFrame.Size = UDim2.new(1, -10, 0, 50)
    sFrame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", sFrame)
    lbl.Text = name
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    ApplyStyle(lbl)

    local bar = Instance.new("TextButton", sFrame)
    bar.Size = UDim2.new(0.9, 0, 0, 6)
    bar.Position = UDim2.new(0.05, 0, 0.7, 0)
    bar.BackgroundColor3 = Theme.Secondary
    bar.Text = ""
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        callback(math.floor(min + (rel * (max - min))))
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then update(i) end end)
end

-- ==========================================
-- TEIL 7: MIN/MAX & SPIELERINFO
-- ==========================================
local function AddPlayerInfo(parent)
    local info = Instance.new("Frame", parent)
    info.Size = UDim2.new(1, -10, 0, 60)
    info.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", info)
    
    local img = Instance.new("ImageLabel", info)
    img.Size = UDim2.new(0, 50, 0, 50)
    img.Position = UDim2.new(0, 5, 0.5, -25)
    img.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
    Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
    
    local txt = Instance.new("TextLabel", info)
    txt.Text = LocalPlayer.DisplayName .. "\nID: " .. LocalPlayer.UserId
    txt.Position = UDim2.new(0, 60, 0, 0)
    txt.Size = UDim2.new(1, -70, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextXAlignment = "Left"
    ApplyStyle(txt)
end

function Cinox.AddMinMax(mainFrame, titleBar)
    local minBtn = Instance.new("TextButton", titleBar)
    minBtn.Text = "-"
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -70, 0, 2)
    ApplyStyle(minBtn)

    local isMin = false
    local fullSize = mainFrame.Size
    minBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        mainFrame:TweenSize(isMin and UDim2.new(0, 550, 0, 35) or fullSize, "Out", "Quad", 0.3, true)
    end)
end

-- Hier kannst du die Funktionen jetzt in deinem Hauptscript abrufen!
return Cinox
