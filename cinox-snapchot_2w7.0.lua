
local Cinox = {}
Cinox.__index = Cinox

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


Cinox.Theme = {
    Accent = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    FontSize = 14
}

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function ApplyStyle(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        obj.Font = Cinox.Theme.Font
        obj.TextSize = Cinox.Theme.FontSize
        obj.TextColor3 = Cinox.Theme.Text
    end
end

function Cinox:MakeDraggable(gui, target)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = target.Position
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


function Cinox.Init(manifest)
    local self = setmetatable({}, Cinox)
    
    self.Name = manifest.Name or "Cinox Hub"
    self.ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    self.ScreenGui.Name = self.Name
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true

 
    self.MainFrame = Instance.new("Frame", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 550, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    self.MainFrame.BackgroundColor3 = Cinox.Theme.Background
    AddCorner(self.MainFrame, 9)

   
    self.TitleBar = Instance.new("Frame", self.MainFrame)
    self.TitleBar.Size = UDim2.new(1, 0, 0, 35)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    AddCorner(self.TitleBar, 9)
    self:MakeDraggable(self.TitleBar, self.MainFrame)

    local Title = Instance.new("TextLabel", self.TitleBar)
    Title.Text = "  " .. self.Name
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    ApplyStyle(Title)

Cinox.Settings = {
    CurrentFont = Cinox.Theme.Font,
    CurrentAccent = Cinox.Theme.Accent,
    RainbowMode = false
}


function Cinox:UpdateFont(newFont)
    self.Theme.Font = newFont
    self.Settings.CurrentFont = newFont
    -- Sucht alle Text-Objekte im ScreenGui und aktualisiert sie
    for _, obj in pairs(self.ScreenGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.Font = newFont
        end
    end
end


function Cinox:UpdateAccent(newColor)
    self.Theme.Accent = newColor
    self.Settings.CurrentAccent = newColor
    -- Hier suchen wir spezifische Elemente wie Slider-Fills oder Toggles
    for _, obj in pairs(self.ScreenGui:GetDescendants()) do
        if obj.Name == "Fill" or obj.Name == "Dot" or (obj:IsA("TextButton") and obj.Name == "TabBtn" and obj.TextColor3 ~= self.Theme.Text) then
            if obj:IsA("Frame") or obj:IsA("TextButton") then
                obj.BackgroundColor3 = newColor
            end
        end
    end
end

function Cinox:CreateSettingsIcon(parent)
    local SettingsBtn = Instance.new("ImageButton", parent)
    SettingsBtn.Name = "SettingsIcon"
    SettingsBtn.Size = UDim2.new(0, 25, 0, 25)
    SettingsBtn.Position = UDim2.new(1, -35, 0.5, -12)
    SettingsBtn.BackgroundTransparency = 1
    SettingsBtn.Image = "rbxassetid://6031289116" -- Zahnrad Icon
    SettingsBtn.ImageColor3 = self.Theme.Text
    
    SettingsBtn.MouseButton1Click:Connect(function()
        if self.SettingsTab then
            self:SwitchToTab("Settings") 
        end
    end)
    return SettingsBtn
end

task.spawn(function()
    while task.wait() do
        if Cinox.Settings.RainbowMode then
            local hue = tick() % 5 / 5
            local color = Color3.fromHSV(hue, 1, 1)
        
        end
    end
end)

-- 

function Cinox:SetupInternalStructure()
    -- Erstellung der Tab-Leiste (Links)
    self.TabBar = Instance.new("ScrollingFrame", self.MainFrame)
    self.TabBar.Name = "TabBar"
    self.TabBar.Size = UDim2.new(0, 120, 1, -45)
    self.TabBar.Position = UDim2.new(0, 5, 0, 40)
    self.TabBar.BackgroundTransparency = 1
    self.TabBar.ScrollBarThickness = 0
    
    local TabBarLayout = Instance.new("UIListLayout", self.TabBar)
    TabBarLayout.Padding = UDim.new(0, 5)


    self.Container = Instance.new("Frame", self.MainFrame)
    self.Container.Name = "Container"
    self.Container.Size = UDim2.new(1, -135, 1, -45)
    self.Container.Position = UDim2.new(0, 130, 0, 40)
    self.Container.BackgroundTransparency = 1

    self.Tabs = {}
end

function Cinox:SwitchToTab(tabName)
    for name, data in pairs(self.Tabs) do
        if name == tabName then
            data.Page.Visible = true
            data.Button.TextColor3 = self.Theme.Accent
        else
            data.Page.Visible = false
            data.Button.TextColor3 = self.Theme.Text
        end
    end
end

function Cinox:CreateTab(name)
  
    if not self.TabBar then self:SetupInternalStructure() end


    local TabBtn = Instance.new("TextButton", self.TabBar)
    TabBtn.Name = "TabBtn"
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.Text = name
    TabBtn.BackgroundColor3 = self.Theme.Secondary
    TabBtn.BorderSizePixel = 0
    AddCorner(TabBtn, 4)
    ApplyStyle(TabBtn)


    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Name = name .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.BorderSizePixel = 0
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center


    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
    end)


    self.Tabs[name] = {
        Button = TabBtn,
        Page = Page
    }

    TabBtn.MouseButton1Click:Connect(function()
        self:SwitchToTab(name)
    end)

 
    task.defer(function()
        local count = 0
        for _ in pairs(self.Tabs) do count = count + 1 end
        if count == 1 then self:SwitchToTab(name) end
    end)

    return Page
end


function Cinox:GetPOM(pageInstance)
    local POM = {}
    
    POM.Container = pageInstance
    POM.ParentHub = self

    function POM:AddComponent(config)
        local componentType = config.Type or "Button"
        
        if componentType == "Toggle" then
            return self.ParentHub:CreateToggle(self.Container, config.Name, config.Callback)
        elseif componentType == "Slider" then
            return self.ParentHub:CreateSlider(self.Container, config.Name, config.Min, config.Max, config.Callback)
        elseif componentType == "Button" then
            return self.ParentHub:CreateButton(self.Container, config.Name, config.Callback)
        elseif componentType == "ColorPicker" then
            return self.ParentHub:CreateColorPicker(self.Container, config.Name, config.Default, config.Callback)
        end
    end

    -- Abkürzungen für den Nutzer (Legacy-Support aus deinen vorherigen Wünschen)
    function POM:AddToggle(name, callback)
        return self:AddComponent({Type = "Toggle", Name = name, Callback = callback})
    end

    function POM:AddSlider(name, min, max, callback)
        return self:AddComponent({Type = "Slider", Name = name, Min = min, Max = max, Callback = callback})
    end

    function POM:AddButton(name, callback)
        return self:AddComponent({Type = "Button", Name = name, Callback = callback})
    end
    
    function POM:AddColorPicker(name, default, callback)
        return self:AddComponent({Type = "ColorPicker", Name = name, Default = default, Callback = callback})
    end

    return POM
end

local OldCreateTab = Cinox.CreateTab
function Cinox:CreateTab(name)
    local page = OldCreateTab(self, name)
    return self:GetPOM(page)
end


function Cinox:CreateSlider(parent, name, min, max, callback)
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Name = name .. "_Slider"
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.BackgroundColor3 = self.Theme.Secondary
    AddCorner(SliderFrame, 6)
    
    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Text = "  " .. name
    Label.Size = UDim2.new(1, -60, 0, 25)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    ApplyStyle(Label)
    
    local ValueLabel = Instance.new("TextLabel", SliderFrame)
    ValueLabel.Text = tostring(min) .. "  "
    ValueLabel.Size = UDim2.new(0, 50, 0, 25)
    ValueLabel.Position = UDim2.new(1, -50, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ApplyStyle(ValueLabel)
    
    local SliderBar = Instance.new("TextButton", SliderFrame)
    SliderBar.Name = "SliderBar"
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 32)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.Text = ""
    AddCorner(SliderBar, 3)
    
    local Fill = Instance.new("Frame", SliderBar)
    Fill.Name = "Fill"
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = self.Theme.Accent
    AddCorner(Fill, 3)
    
    local active = false
    
    local function UpdateSlider(input)
        local relativePos = (input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
        local clampedPos = math.clamp(relativePos, 0, 1)
        
        Fill.Size = UDim2.new(clampedPos, 0, 1, 0)
        
        local value = math.floor(min + (clampedPos * (max - min)))
        ValueLabel.Text = tostring(value) .. "  "
        callback(value)
    end
    
    SliderBar.InputBegan:Connect(function(input)
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
    
    return SliderFrame
end


function Cinox:CreateButton(parent, name, callback)
    local ButtonFrame = Instance.new("Frame", parent)
    ButtonFrame.Name = name .. "_ButtonFrame"
    ButtonFrame.Size = UDim2.new(1, -10, 0, 35)
    ButtonFrame.BackgroundColor3 = self.Theme.Secondary
    AddCorner(ButtonFrame, 6)
    
    local Button = Instance.new("TextButton", ButtonFrame)
    Button.Name = "Button"
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = name
    ApplyStyle(Button)
    
  
    Button.MouseEnter:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.Secondary}):Play()
    end)
    
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -15, 0, 32)}):Play()
    end)
    
    Button.MouseButton1Up:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 35)}):Play()
        callback() 
    end)
    
    return ButtonFrame
end

function Cinox:CreateToggle(parent, name, callback)
    local ToggleFrame = Instance.new("Frame", parent)
    ToggleFrame.Name = name .. "_ToggleFrame"
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = self.Theme.Secondary
    AddCorner(ToggleFrame, 6)
    
    local Label = Instance.new("TextLabel", ToggleFrame)
    Label.Text = "  " .. name
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    ApplyStyle(Label)
    
    local Switch = Instance.new("TextButton", ToggleFrame)
    Switch.Name = "Switch"
    Switch.Size = UDim2.new(0, 36, 0, 20)
    Switch.Position = UDim2.new(1, -44, 0.5, -10)
    Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Switch.Text = ""
    AddCorner(Switch, 10)
    
    local Dot = Instance.new("Frame", Switch)
    Dot.Name = "Dot"
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 3, 0.5, -7)
    Dot.BackgroundColor3 = Color3.new(1, 1, 1)
    AddCorner(Dot, 10)
    
    local state = false
    
    local function ToggleState(forcedState)
        state = (forcedState ~= nil) and forcedState or not state
        
        local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetColor = state and self.Theme.Accent or Color3.fromRGB(50, 50, 50)
        
        TweenService:Create(Dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
        
        callback(state)
    end
    
    Switch.MouseButton1Click:Connect(function()
        ToggleState()
    end)
    
    return ToggleFrame
end

function Cinox:CreateColorPicker(parent, name, default, callback)
    local CPFrame = Instance.new("Frame", parent)
    CPFrame.Name = name .. "_ColorPickerFrame"
    CPFrame.Size = UDim2.new(1, -10, 0, 40)
    CPFrame.BackgroundColor3 = self.Theme.Secondary
    AddCorner(CPFrame, 6)
    
    local Label = Instance.new("TextLabel", CPFrame)
    Label.Text = "  " .. name
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    ApplyStyle(Label)
    
    local ColorDisplay = Instance.new("TextButton", CPFrame)
    ColorDisplay.Name = "ColorDisplay"
    ColorDisplay.Size = UDim2.new(0, 30, 0, 20)
    ColorDisplay.Position = UDim2.new(1, -40, 0.5, -10)
    ColorDisplay.BackgroundColor3 = default or Color3.fromRGB(255, 255, 255)
    ColorDisplay.Text = ""
    AddCorner(ColorDisplay, 4)
    
    ColorDisplay.MouseButton1Click:Connect(function()
        -- Verhindert doppelte Fenster
        if self.MainFrame:FindFirstChild("CP_Popup") then 
            self.MainFrame.CP_Popup:Destroy() 
            return 
        end
        
        local Popup = Instance.new("Frame", self.MainFrame)
        Popup.Name = "CP_Popup"
        Popup.Size = UDim2.new(0, 160, 0, 180)
        Popup.Position = UDim2.new(1, 10, 0, 0)
        Popup.BackgroundColor3 = self.Theme.Secondary
        AddCorner(Popup, 8)
        
        local Wheel = Instance.new("ImageButton", Popup)
        Wheel.Size = UDim2.new(0, 120, 0, 120)
        Wheel.Position = UDim2.new(0.5, -60, 0, 10)
        Wheel.Image = "rbxassetid://7393858638"
        Wheel.BackgroundTransparency = 1
        
        local Picker = Instance.new("Frame", Wheel)
        Picker.Size = UDim2.new(0, 8, 0, 8)
        Picker.BackgroundColor3 = Color3.new(1, 1, 1)
        AddCorner(Picker, 10)
        
        local dragging = false
        
        local function UpdateColor(input)
            local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
            local delta = Vector2.new(input.Position.X, input.Position.Y) - center
            local angle = math.atan2(delta.Y, delta.X)
            local dist = math.min(delta.Magnitude, 60)
            
            Picker.Position = UDim2.new(0.5, math.cos(angle) * dist - 4, 0.5, math.sin(angle) * dist - 4)
            
            local h = ((math.deg(angle) + 180) % 360) / 360
            local s = dist / 60
            local finalColor = Color3.fromHSV(h, s, 1)
            
            ColorDisplay.BackgroundColor3 = finalColor
            callback(finalColor)
        end
        
        Wheel.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateColor(i)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                UpdateColor(i)
            end
        end)
        
        UserInputService.InputEnded:Connect(function() dragging = false end)
        
        local Confirm = Instance.new("TextButton", Popup)
        Confirm.Size = UDim2.new(1, -20, 0, 25)
        Confirm.Position = UDim2.new(0, 10, 1, -35)
        Confirm.Text = "OK"
        Confirm.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ApplyStyle(Confirm)
        AddCorner(Confirm, 4)
        Confirm.MouseButton1Click:Connect(function() Popup:Destroy() end)
    end)
    
    return CPFrame
end


Cinox.Registry = {} 
function Cinox:RegisterElement(id, elementData)
    if id then
        self.Registry[id] = elementData
    end
end


function Cinox:GetValue(id)
    if self.Registry[id] then
        return self.Registry[id].Value
    end
    return nil
end

function Cinox:CreateColorPickerWithID(parent, name, id, default, callback)

    self:RegisterElement(id, {
        Type = "ColorPicker",
        Value = default or Color3.fromRGB(255, 255, 255)
    })

    return self:CreateColorPicker(parent, name, default, function(color)
      
        if self.Registry[id] then
            self.Registry[id].Value = color
        end
        
        callback(color, id)
    end)
end

function Cinox:OnEvent(id, action)
 
    spawn(function()
        local lastValue = self:GetValue(id)
        while task.wait(0.1) do
            local currentLines = self:GetValue(id)
            if currentLines ~= lastValue then
                action(currentLines)
                lastValue = currentLines
            end
        end
    end)
end

function Cinox:GetPOM(pageInstance)
    local POM = {}
    POM.Container = pageInstance
    POM.ParentHub = self


    function POM:Add(config)
   
        local componentType = config.Type or "Button"
        local element = nil

        if componentType == "Toggle" or componentType == "Onetime" then
            element = self.ParentHub:CreateToggle(self.Container, config.Name, config.Callback)
        elseif componentType == "Slider" then
            element = self.ParentHub:CreateSlider(self.Container, config.Name, config.Min or 0, config.Max or 100, config.Callback)
        elseif componentType == "Button" then
            element = self.ParentHub:CreateButton(self.Container, config.Name, config.Callback)
        elseif componentType == "ColorPicker" then
            element = self.ParentHub:CreateColorPickerWithID(self.Container, config.Name, config.ID, config.Default, config.Callback)
        end

        if config.ID and element then
            self.ParentHub:RegisterElement(config.ID, {Instance = element, Value = config.Default})
        end
        
        return element
    end

    function POM:AddToggle(n, c) return self:Add({Type = "Toggle", Name = n, Callback = c}) end
    function POM:AddSlider(n, mi, ma, c) return self:Add({Type = "Slider", Name = n, Min = mi, Max = ma, Callback = c}) end
    function POM:AddButton(n, c) return self:Add({Type = "Button", Name = n, Callback = c}) end

    return POM
end

function Cinox:AddTab(config)

    local tabName = type(config) == "table" and config.Name or config
    local pom = self:CreateTab(tabName)
    
    if type(config) == "table" and config.Elements then
        for _, elementConfig in pairs(config.Elements) do
            pom:Add(elementConfig)
        end
    end
    
    return pom
end

function Cinox:CreateKeybind(parent, name, default, callback)
    local KeyFrame = Instance.new("Frame", parent)
    KeyFrame.Name = name .. "_Keybind"
    KeyFrame.Size = UDim2.new(1, -10, 0, 40)
    KeyFrame.BackgroundColor3 = self.Theme.Secondary
    AddCorner(KeyFrame, 6)
    
    local Label = Instance.new("TextLabel", KeyFrame)
    Label.Text = "  " .. name
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    ApplyStyle(Label)
    
    local BindButton = Instance.new("TextButton", KeyFrame)
    BindButton.Size = UDim2.new(0, 70, 0, 25)
    BindButton.Position = UDim2.new(1, -75, 0.5, -12)
    BindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BindButton.Text = default.Name
    ApplyStyle(BindButton)
    AddCorner(BindButton, 4)
    
    local currentBind = default
    local listening = false
    
    BindButton.MouseButton1Click:Connect(function()
        listening = true
        BindButton.Text = "..."
        BindButton.TextColor3 = self.Theme.Accent
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            currentBind = input.KeyCode
            BindButton.Text = currentBind.Name
            BindButton.TextColor3 = self.Theme.Text
        elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentBind then
            callback(currentBind)
        end
    end)
end


function Cinox:SetMinimizeKey(keyCode)
    self.Settings.MinimizeKey = keyCode
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.Settings.MinimizeKey then
            self:ToggleMinimize() 
        end
    end)
end


function Cinox:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    local targetSize = self.IsMinimized and UDim2.new(0, 550, 0, 35) or self.OriginalSize
    
    for _, child in pairs(self.MainFrame:GetChildren()) do
        if child ~= self.TitleBar and child:IsA("GuiObject") then
            child.Visible = not self.IsMinimized
        end
    end
    TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
end

function Cinox:EnableResizing()
   
    if not UserInputService.KeyboardEnabled then return end

    local ResizeHandle = Instance.new("ImageButton", self.MainFrame)
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
    ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Image = "rbxassetid://6034503522" -- Resize Icon
    ResizeHandle.ImageColor3 = self.Theme.Text
    ResizeHandle.ZIndex = 10

    local resizing = false
    local startPos, startSize

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startPos = input.Position
            startSize = self.MainFrame.Size
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            local newWidth = math.clamp(startSize.X.Offset + delta.X, 300, 800)
            local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 200, 600)
            
            self.MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            self.OriginalSize = self.MainFrame.Size -- Update für Minimize
            
          
            if self.Container then
                self.Container.Size = UDim2.new(1, -135, 1, -45)
            end
            if self.TabBar then
                self.TabBar.Size = UDim2.new(0, 120, 1, -45)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
end

  return Cinox
