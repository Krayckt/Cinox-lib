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
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj.Font = Theme.Font
        obj.TextSize = Theme.FontSize
        obj.TextColor3 = Theme.Text
        obj.LineHeight = 1.1
    end
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function CreateDrag(gui, target)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType :== Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Cinox.Init(manifest)
    local SG = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    SG.Name = manifest.Name
    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true

    local MF = Instance.new("Frame", SG)
    MF.Name = "MainFrame"
    MF.Size = UDim2.new(0, 550, 0, 350)
    MF.Position = UDim2.new(0.5, -275, 0.5, -175)
    MF.BackgroundColor3 = Theme.Background
    MF.BorderSizePixel = 0
    MF.Active = true
    AddCorner(MF, 9)

    local TB = Instance.new("Frame", MF)
    TB.Name = "TitleBar"
    TB.Size = UDim2.new(1, 0, 0, 35)
    TB.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    AddCorner(TB, 9)
    CreateDrag(TB, MF)

    -- Tab-System Container
    local TabBar = Instance.new("ScrollingFrame", MF)
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, 120, 1, -45)
    TabBar.Position = UDim2.new(0, 5, 0, 40)
    TabBar.BackgroundTransparency = 1
    TabBar.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabBar)
    TabList.Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame", MF)
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -135, 1, -45)
    Container.Position = UDim2.new(0, 130, 0, 40)
    Container.BackgroundTransparency = 1

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
    Page.ScrollBarThickness = 2
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 8)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Container:GetChildren()) do p.Visible = false end
        Page.Visible = true
    end)

    local TabMethods = {}

    function TabMethods:AddToggle(text, callback)
        local tFrame = Instance.new("Frame", Page)
        tFrame.Size = UDim2.new(1, -10, 0, 40)
        tFrame.BackgroundColor3 = Theme.Secondary
        AddCorner(tFrame)
        
        local lbl = Instance.new("TextLabel", tFrame)
        lbl.Text = "  " .. text
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = "Left"
        ApplyStyle(lbl)

        local btn = Instance.new("TextButton", tFrame)
        btn.Size = UDim2.new(0, 35, 0, 20)
        btn.Position = UDim2.new(1, -45, 0.5, -10)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = ""
        AddCorner(btn, 10)

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 50)
            callback(state)
        end)
    end

    function TabMethods:AddSlider(text, min, max, callback)
        local sFrame = Instance.new("Frame", Page)
        sFrame.Size = UDim2.new(1, -10, 0, 50)
        sFrame.BackgroundColor3 = Theme.Secondary
        AddCorner(sFrame)

        local lbl = Instance.new("TextLabel", sFrame)
        lbl.Text = "  " .. text
        lbl.Size = UDim2.new(1, 0, 0, 25)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = "Left"
        ApplyStyle(lbl)

        local bar = Instance.new("TextButton", sFrame)
        bar.Size = UDim2.new(1, -20, 0, 6)
        bar.Position = UDim2.new(0, 10, 0, 35)
        bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        bar.Text = ""
        AddCorner(bar, 3)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        AddCorner(fill, 3)

        local active = false
        local function update(input)
            local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            callback(math.floor(min + (p * (max - min))))
        end

        bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true update(i) end end)
        UserInputService.InputChanged:Connect(function(i) if active then update(i) end end)
        UserInputService.InputEnded:Connect(function() active = false end)
    end

    return TabMethods
end

function Cinox:AddPlayerInfo(parent)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -10, 0, 60)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    AddCorner(f, 8)

    local img = Instance.new("ImageLabel", f)
    img.Size = UDim2.new(0, 50, 0, 50)
    img.Position = UDim2.new(0, 5, 0.5, -25)
    img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    AddCorner(img, 25)

    local t = Instance.new("TextLabel", f)
    t.Text = "  " .. LocalPlayer.DisplayName .. "\n  ID: " .. LocalPlayer.UserId
    t.Size = UDim2.new(1, -60, 1, 0)
    t.Position = UDim2.new(0, 60, 0, 0)
    t.BackgroundTransparency = 1
    t.TextXAlignment = "Left"
    ApplyStyle(t)
end

function Cinox.AddWindowControls(mainFrame, titleBar)
    local minBtn = Instance.new("TextButton", titleBar)
    minBtn.Text = "-"
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -65, 0, 2)
    minBtn.BackgroundTransparency = 1
    ApplyStyle(minBtn)

    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    ApplyStyle(closeBtn)

    local isMinimized = false
    local originalSize = mainFrame.Size

    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 550, 0, 35) or originalSize
        for _, child in pairs(mainFrame:GetChildren()) do
            if child.Name ~= "TitleBar" then child.Visible = not isMinimized end
        end
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    end)

    closeBtn.MouseButton1Click:Connect(function() mainFrame.Parent:Destroy() end)
end

return Cinox
