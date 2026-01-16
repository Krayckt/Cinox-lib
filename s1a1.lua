local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Theme = {
    Accent = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    FontSize = 14
}

local function ApplyStyle(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        obj.Font = Theme.Font
        obj.TextSize = Theme.FontSize
        obj.TextColor3 = Theme.Text
    end
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
end

-- Interne Color Picker Logik
local function OpenPickerUI(mainFrame, callback)
    if mainFrame:FindFirstChild("CP_Window") then mainFrame.CP_Window:Destroy() end
    local CP = Instance.new("Frame", mainFrame)
    CP.Name = "CP_Window"
    CP.Size = UDim2.new(0, 160, 0, 185)
    CP.Position = UDim2.new(1, 10, 0, 0)
    CP.BackgroundColor3 = Theme.Secondary
    AddCorner(CP, 8)
    
    local Wheel = Instance.new("ImageButton", CP)
    Wheel.Size = UDim2.new(0, 120, 0, 120)
    Wheel.Position = UDim2.new(0.5, -60, 0, 10)
    Wheel.Image = "rbxassetid://7393858638"
    Wheel.BackgroundTransparency = 1
    
    local Pick = Instance.new("Frame", Wheel)
    Pick.Size = UDim2.new(0, 8, 0, 8)
    Pick.BackgroundColor3 = Color3.new(1, 1, 1)
    AddCorner(Pick, 10)
    
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
    UserInputService.InputChanged:Connect(function(i) if isDragging then update(i) end end)
    UserInputService.InputEnded:Connect(function() isDragging = false end)
    
    local B = Instance.new("TextButton", CP)
    B.Size = UDim2.new(1, -20, 0, 25)
    B.Position = UDim2.new(0, 10, 1, -30)
    B.Text = "Fertig"
    B.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ApplyStyle(B)
    AddCorner(B, 4)
    B.MouseButton1Click:Connect(function() CP:Destroy() end)
end

function Cinox.Init(manifest)
    local SG = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    SG.Name = manifest.Name
    SG.ResetOnSpawn = false
    
    local MF = Instance.new("Frame", SG)
    MF.Size = UDim2.new(0, 550, 0, 350)
    MF.Position = UDim2.new(0.5, -275, 0.5, -175)
    MF.BackgroundColor3 = Theme.Background
    AddCorner(MF, 9)

    local TB = Instance.new("Frame", MF)
    TB.Name = "TitleBar"
    TB.Size = UDim2.new(1, 0, 0, 35)
    TB.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    AddCorner(TB, 9)

    local Container = Instance.new("Frame", MF)
    Container.Size = UDim2.new(1, -135, 1, -45)
    Container.Position = UDim2.new(0, 130, 0, 40)
    Container.BackgroundTransparency = 1

    local TabBar = Instance.new("ScrollingFrame", MF)
    TabBar.Size = UDim2.new(0, 120, 1, -45)
    TabBar.Position = UDim2.new(0, 5, 0, 40)
    TabBar.BackgroundTransparency = 1
    TabBar.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabBar).Padding = UDim.new(0, 5)

    Cinox.MainFrame = MF
    Cinox.Container = Container
    Cinox.TabBar = TabBar
    return Cinox
end

function Cinox:CreateTab(name)
    local TabBtn = Instance.new("TextButton", self.TabBar)
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.Text = name
    TabBtn.BackgroundColor3 = Theme.Secondary
    ApplyStyle(TabBtn)
    AddCorner(TabBtn, 4)

    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 8)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Container:GetChildren()) do p.Visible = false end
        Page.Visible = true
    end)

    local TabMethods = {}

    function TabMethods:AddColorPicker(text, default, callback)
        local f = Instance.new("Frame", Page)
        f.Size = UDim2.new(1, -10, 0, 40)
        f.BackgroundColor3 = Theme.Secondary
        AddCorner(f)
        
        local l = Instance.new("TextLabel", f)
        l.Text = "  " .. text
        l.Size = UDim2.new(1, -50, 1, 0)
        l.BackgroundTransparency = 1
        l.TextXAlignment = "Left"
        ApplyStyle(l)

        local box = Instance.new("TextButton", f)
        box.Size = UDim2.new(0, 30, 0, 20)
        box.Position = UDim2.new(1, -40, 0.5, -10)
        box.BackgroundColor3 = default
        box.Text = ""
        AddCorner(box, 4)

        box.MouseButton1Click:Connect(function()
            OpenPickerUI(Cinox.MainFrame, function(color)
                box.BackgroundColor3 = color
                callback(color)
            end)
        end)
    end

    function TabMethods:AddToggle(n, c)
        local f = Instance.new("Frame", Page)
        f.Size = UDim2.new(1,-10,0,40)
        f.BackgroundColor3 = Theme.Secondary
        AddCorner(f)
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0,35,0,20)
        b.Position = UDim2.new(1,-45,0.5,-10)
        b.Text = ""
        b.BackgroundColor3 = Color3.fromRGB(50,50,50)
        AddCorner(b,10)
        local s = false
        b.MouseButton1Click:Connect(function() s = not s; b.BackgroundColor3 = s and Theme.Accent or Color3.fromRGB(50,50,50); c(s) end)
    end

    return TabMethods
end

return Cinox
