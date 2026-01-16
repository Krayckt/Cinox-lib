



local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Cinox.Init(manifest)
    local SG = Instance.new("ScreenGui")
    SG.Name = manifest.Name
    SG.Parent = LocalPlayer.PlayerGui
    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true
    
    local MF = Instance.new("Frame")
    MF.Name = "MainFrame"
    MF.Parent = SG
    MF.Size = UDim2.new(0, 550, 0, 350)
    MF.Position = UDim2.new(0.5, -275, 0.5, -175)
    MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MF.BorderSizePixel = 0
    MF.Active = true
    MF.Draggable = false 
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = MF
    
    local TB = Instance.new("Frame")
    TB.Name = "TitleBar"
    TB.Parent = MF
    TB.Size = UDim2.new(1, 0, 0, 35)
    TB.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TB.BorderSizePixel = 0
    
    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(0, 9)
    TBCorner.Parent = TB

    return SG, MF, TB
end

local Theme = {
    Accent = Color3.fromRGB(0, 170, 255), -- Hauptfarbe 
    Background = Color3.fromRGB(30, 30, 30), -- Hintergrund des Fensters
    Secondary = Color3.fromRGB(25, 25, 25), -- Hintergrund für Buttons/Slider
    Text = Color3.fromRGB(255, 255, 255), -- Schriftfarbe
    Font = Enum.Font.GothamBold, 
    FontSize = 14 -- Standard-Größe für Texte
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

local function OpenPicker(mainFrame, accent, callback)
    if mainFrame:FindFirstChild("CP_Window") then 
        mainFrame.CP_Window:Destroy() 
        return 
    end
    
    local CP = Instance.new("Frame")
    CP.Name = "CP_Window"
    CP.Size = UDim2.new(0, 160, 0, 180)
    CP.Position = UDim2.new(1, 10, 0, 0)
    CP.BackgroundColor3 = Theme.Secondary
    CP.Parent = mainFrame
    AddCorner(CP, 8)
    
    local Wheel = Instance.new("ImageButton")
    Wheel.Name = "ColorWheel"
    Wheel.Size = UDim2.new(0, 130, 0, 130)
    Wheel.Position = UDim2.new(0.5, -65, 0, 10)
    Wheel.Image = "rbxassetid://7393858638"
    Wheel.BackgroundTransparency = 1
    Wheel.Parent = CP
    
    local Pick = Instance.new("Frame")
    Pick.Name = "Picker"
    Pick.Size = UDim2.new(0, 10, 0, 10)
    Pick.BackgroundColor3 = Color3.new(1, 1, 1)
    Pick.Parent = Wheel
    AddCorner(Pick, 10) 
    
    local isDragging = false
    
    local function UpdateColor(input)
        
        local wheelCenter = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
        local inputPos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = inputPos - wheelCenter
        
        local angle = math.atan2(delta.Y, delta.X)
        local distance = math.min(delta.Magnitude, 65) -- Radius begrenzen
        

        Pick.Position = UDim2.new(0.5, math.cos(angle) * distance - 5, 0.5, math.sin(angle) * distance - 5)
        
        local h = ((math.deg(angle) + 180) % 360) / 360
        local s = distance / 65
        callback(Color3.fromHSV(h, s, 1))
    end
    
    Wheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            UpdateColor(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateColor(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(1, -20, 0, 25)
    CloseBtn.Position = UDim2.new(0, 10, 1, -30)
    CloseBtn.Text = "Übernehmen"
    CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    CloseBtn.Parent = CP
    ApplyStyle(CloseBtn)
    AddCorner(CloseBtn, 4)
    CloseBtn.MouseButton1Click:Connect(function() CP:Destroy() end)
end

local function CreateDrag(gui, target)
    local dragging = false
    local dragStart = nil
    local startPos = nil

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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            
            -- Wir ändern die Position über den Offset, um die Skalierung nicht zu zerstören
            target.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function SetSize(target, newSize)
    local tween = TweenService:Create(target, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = newSize})
    tween:Play()
end


local function CreateButton(parent, name, callback)
    local btnFrame = Instance.new("Frame")
    btnFrame.Name = name .. "_Frame"
    btnFrame.Size = UDim2.new(1, -10, 0, 35)
    btnFrame.BackgroundColor3 = Theme.Secondary
    btnFrame.Parent = parent
    AddCorner(btnFrame, 6)
    
    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Parent = btnFrame
    ApplyStyle(btn)
    
    btn.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return btnFrame
end

local function CreateToggle(parent, name, callback)
    local tglFrame = Instance.new("Frame")
    tglFrame.Name = name .. "_Toggle"
    tglFrame.Size = UDim2.new(1, -10, 0, 40)
    tglFrame.BackgroundColor3 = Theme.Secondary
    tglFrame.Parent = parent
    AddCorner(tglFrame, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Text = "  " .. name
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = tglFrame
    ApplyStyle(lbl)
    
    local switch = Instance.new("TextButton")
    switch.Name = "Switch"
    switch.Size = UDim2.new(0, 36, 0, 20)
    switch.Position = UDim2.new(1, -44, 0.5, -10)
    switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    switch.Text = ""
    switch.Parent = tglFrame
    AddCorner(switch, 10)
    
    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = Color3.new(1, 1, 1)
    dot.Parent = switch
    AddCorner(dot, 10)
    
    local state = false
    switch.MouseButton1Click:Connect(function()
        state = not state
    
        local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetColor = state and Theme.Accent or Color3.fromRGB(50, 50, 50)
        
        TweenService:Create(dot, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        
        callback(state)
    end)
    
    return tglFrame
end

local function CreateSlider(parent, name, min, max, callback)
    local sFrame = Instance.new("Frame")
    sFrame.Name = name .. "_Slider"
    sFrame.Size = UDim2.new(1, -10, 0, 50)
    sFrame.BackgroundColor3 = Theme.Secondary
    sFrame.Parent = parent
    AddCorner(sFrame, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Text = "  " .. name
    lbl.Size = UDim2.new(1, -60, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sFrame
    ApplyStyle(lbl)
    
    local valLbl = Instance.new("TextLabel")
    valLbl.Text = tostring(min) .. "  "
    valLbl.Size = UDim2.new(0, 50, 0, 25)
    valLbl.Position = UDim2.new(1, -50, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = sFrame
    ApplyStyle(valLbl)
    
    local bar = Instance.new("TextButton")
    bar.Name = "Bar"
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 32)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bar.Text = ""
    bar.Parent = sFrame
    AddCorner(bar, 3)
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.Parent = bar
    AddCorner(fill, 3)
    
    local active = false
    
    local function UpdateSlider(input)
        local relativePos = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
        local clampedPos = math.clamp(relativePos, 0, 1)
        
        fill.Size = UDim2.new(clampedPos, 0, 1, 0)
        
        local value = math.floor(min + (clampedPos * (max - min)))
        valLbl.Text = tostring(value) .. "  "
        callback(value)
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end)
    
    return sFrame
end

local function AddPlayerInfo(parent)
    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "PlayerInfo"
    infoFrame.Size = UDim2.new(1, -10, 0, 65)
    infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    infoFrame.Parent = parent
    AddCorner(infoFrame, 8)
    
    local pfp = Instance.new("ImageLabel")
    pfp.Name = "UserPFP"
    pfp.Size = UDim2.new(0, 50, 0, 50)
    pfp.Position = UDim2.new(0, 7, 0.5, -25)
    -- Holt das aktuelle Avatar-Bild des Spielers
    pfp.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    pfp.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    pfp.Parent = infoFrame
    AddCorner(pfp, 25)
    
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text = LocalPlayer.DisplayName
    nameLbl.Size = UDim2.new(1, -70, 0, 20)
    nameLbl.Position = UDim2.new(0, 65, 0, 12)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = infoFrame
    ApplyStyle(nameLbl)
    
    local idLbl = Instance.new("TextLabel")
    idLbl.Text = "ID: " .. LocalPlayer.UserId
    idLbl.Size = UDim2.new(1, -70, 0, 20)
    idLbl.Position = UDim2.new(0, 65, 0, 32)
    idLbl.BackgroundTransparency = 1
    idLbl.TextXAlignment = Enum.TextXAlignment.Left
    idLbl.TextTransparency = 0.5 -- Etwas blasser für die ID
    idLbl.Parent = infoFrame
    ApplyStyle(idLbl)
    
    return infoFrame
end

function Cinox.AddWindowControls(mainFrame, titleBar)
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinBtn"
    minBtn.Text = "-"
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -65, 0, 2)
    minBtn.BackgroundTransparency = 1
    minBtn.Parent = titleBar
    ApplyStyle(minBtn)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Parent = titleBar
    ApplyStyle(closeBtn)
    
    local isMinimized = false
    local originalSize = mainFrame.Size
    
    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 550, 0, 35) or originalSize
       
        for _, child in pairs(mainFrame:GetChildren()) do
            if child.Name ~= "TitleBar" and child:IsA("GuiObject") then
                child.Visible = not isMinimized
            end
        end
        
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Parent:Destroy()
    end)
end

return Cinox
