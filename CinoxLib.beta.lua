local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function CheckDevice(req)
    local isMobile = UserInputService.TouchEnabled
    if req == "Mobile" and not isMobile then return false end
    if req == "PC" and isMobile then return false end
    return true
end

local function CreateDrag(gui)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

local function CreateColorPicker(parent, defaultColor, callback)
    if parent:FindFirstChild("CP_Frame") then parent.CP_Frame.Visible = not parent.CP_Frame.Visible return end
    
    local CPFrame = Instance.new("Frame")
    CPFrame.Name = "CP_Frame"; CPFrame.Size = UDim2.new(0, 150, 0, 150); CPFrame.Position = UDim2.new(1, 10, 0, 0)
    CPFrame.BackgroundColor3 = Color3.fromRGB(40,40,40); CPFrame.ZIndex = 10; CPFrame.Parent = parent
    Instance.new("UICorner", CPFrame)
    
    local Wheel = Instance.new("ImageButton")
    Wheel.Size = UDim2.new(0, 130, 0, 130); Wheel.Position = UDim2.new(0, 10, 0, 10); Wheel.Image = "rbxassetid://6020299385"; Wheel.BackgroundTransparency = 1; Wheel.Parent = CPFrame
    
    local Picker = Instance.new("Frame")
    Picker.Size = UDim2.new(0, 10, 0, 10); Picker.Position = UDim2.new(0.5, 0, 0.5, 0); Picker.BackgroundColor3 = Color3.new(1,1,1); Picker.Parent = Wheel
    Instance.new("UICorner", Picker).CornerRadius = UDim.new(1,0)

    local dragging = false
    local function updateColor(input)
        local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize/2)
        local vector = Vector2.new(input.Position.X, input.Position.Y) - center
        local angle = math.atan2(vector.Y, vector.X)
        local radius = math.min(vector.Magnitude, Wheel.AbsoluteSize.X/2)
        
        Picker.Position = UDim2.new(0.5, math.cos(angle) * radius, 0.5, math.sin(angle) * radius)
        
        local hue = (math.pi - angle) / (2 * math.pi)
        local sat = radius / (Wheel.AbsoluteSize.X/2)
        local col = Color3.fromHSV(hue, sat, 1)
        callback(col)
    end
    
    Wheel.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; updateColor(input) end end)
    Wheel.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateColor(input) end end)
end

function Cinox.Init(manifest)
    if manifest.OFP_Active then
        local allowed = false
        for _, id in pairs(string.split(manifest.OFP_List or "", ",")) do
            if tonumber(id) == LocalPlayer.UserId or id == LocalPlayer.Name then allowed = true end
        end
        if not allowed then return end
    end
    
    if manifest.For_Device and not CheckDevice(manifest.For_Device) then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = manifest.Name
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame)
    
    local bgColor = Color3.fromRGB(35, 35, 35)
    if manifest.Background_Mode == "L" then bgColor = Color3.fromRGB(240, 240, 240)
    elseif manifest.Background_Mode == "C" and manifest["C/A-B_Color"] then 
        bgColor = Color3.fromHex(manifest["C/A-B_Color"]) or manifest["C/A-B_Color"]
    end
    MainFrame.BackgroundColor3 = bgColor

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.Parent = MainFrame
    Instance.new("UICorner", TitleBar)
    CreateDrag(TitleBar)

    local TitleText = Instance.new("TextLabel")
    TitleText.Text = "  " .. manifest.Name
    TitleText.Size = UDim2.new(0.5, 0, 1, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.new(1,1,1)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local Buttons = Instance.new("Frame")
    Buttons.Size = UDim2.new(0, 80, 1, 0); Buttons.Position = UDim2.new(1, -85, 0, 0)
    Buttons.BackgroundTransparency = 1; Buttons.Parent = TitleBar
    
    local function mkBtn(txt, col, pos, cb)
        local b = Instance.new("TextButton")
        b.Text = txt; b.BackgroundColor3 = col; b.Size = UDim2.new(0, 30, 0, 30); b.Position = pos
        b.TextColor3 = Color3.new(1,1,1); b.Parent = Buttons; Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        b.MouseButton1Click:Connect(cb)
    end
    
    mkBtn("X", Color3.fromRGB(200,50,50), UDim2.new(1,-30,0,5), function() ScreenGui:Destroy() end)
    local isMin = false
    local fullSize = MainFrame.Size
    mkBtn("-", Color3.fromRGB(60,60,60), UDim2.new(1,-65,0,5), function()
        isMin = not isMin
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = isMin and UDim2.new(0, 600, 0, 40) or fullSize}):Play()
    end)

    if manifest.USER_INFO then
        local Info = Instance.new("TextLabel")
        Info.Text = LocalPlayer.Name .. " | ID: " .. LocalPlayer.UserId
        Info.Size = UDim2.new(1, -10, 0, 20); Info.Position = UDim2.new(0, 5, 1, -25)
        Info.BackgroundTransparency = 1; Info.TextColor3 = Color3.new(1,1,1); Info.TextXAlignment = Enum.TextXAlignment.Left
        Info.Parent = MainFrame
        
        if string.find(manifest.LAYOUT, "+C") then
            local SwitchBtn = Instance.new("TextButton")
            SwitchBtn.Size = UDim2.new(0, 80, 0, 20); SwitchBtn.Position = UDim2.new(1, -85, 1, -25)
            SwitchBtn.Text = "Switch Layout"; SwitchBtn.BackgroundColor3 = Color3.fromRGB(50,50,50); SwitchBtn.TextColor3 = Color3.new(1,1,1)
            SwitchBtn.Parent = MainFrame; Instance.new("UICorner", SwitchBtn)
            SwitchBtn.MouseButton1Click:Connect(function()
               for _, page in pairs(MainFrame.Pages:GetChildren()) do
                   if page:IsA("ScrollingFrame") then
                       if page:FindFirstChild("UIGridLayout") then
                           page.UIGridLayout:Destroy()
                           Instance.new("UIListLayout", page).Padding = UDim.new(0, 5)
                       elseif page:FindFirstChild("UIListLayout") then
                           page.UIListLayout:Destroy()
                           Instance.new("UIGridLayout", page).CellSize = UDim2.new(0, 130, 0, 130)
                           page.UIGridLayout.Padding = UDim2.new(0,10,0,10)
                       end
                   end
               end
            end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode[manifest.ToggelKeybind or "RightShift"] then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 140, 1, -50); TabContainer.Position = UDim2.new(0, 5, 0, 45)
    TabContainer.BackgroundTransparency = 1; TabContainer.Parent = MainFrame
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "Pages"
    PageContainer.Size = UDim2.new(1, -160, 1, -80); PageContainer.Position = UDim2.new(0, 150, 0, 45)
    PageContainer.BackgroundTransparency = 1; PageContainer.Parent = MainFrame

    local Lib = {Scripts = {}, POMs = {}}

    function Lib:AddScript(name, func)
        Lib.Scripts[name] = func
    end

    function Lib:AddTab(config)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = config.Name; TabBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        TabBtn.TextColor3 = config.Name_Color == "Rainbow" and Color3.new(1,1,1) or config.Name_Color or Color3.new(1,1,1)
        TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn)
        
        if config.Borderlines then
            local stroke = Instance.new("UIStroke", TabBtn)
            stroke.Color = config.BL_Color == "Rainbow" and Color3.new(1,0,0) or config.BL_Color
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end

        local Page = Instance.new("ScrollingFrame")
        Page.Name = config.Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.Parent = PageContainer
        Page.LayoutOrder = config.NUMBER or 0
        
        local layoutType = string.split(manifest.LAYOUT, "+")[1]
        if layoutType == "TABEL" then
            local grid = Instance.new("UIGridLayout", Page); grid.CellSize = UDim2.new(0, 130, 0, 100); grid.Padding = UDim2.new(0,10,0,10)
        else
            Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
            Page.Visible = true
        end)

        local TabObj = {}
        
        function TabObj:AddPOM(name)
            local POMFrame = Instance.new("Frame")
            POMFrame.Name = name
            POMFrame.Size = UDim2.new(1, 0, 0, 0)
            POMFrame.AutomaticSize = Enum.AutomaticSize.Y
            POMFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            POMFrame.Parent = Page
            Instance.new("UICorner", POMFrame)
            
            local Label = Instance.new("TextLabel")
            Label.Text = name; Label.Size = UDim2.new(1,0,0,20); Label.BackgroundTransparency=1; Label.TextColor3=Color3.new(1,1,1); Label.Parent=POMFrame
            
            local Content = Instance.new("Frame")
            Content.Name = "Content"; Content.Size = UDim2.new(1, -10, 0, 0); Content.Position = UDim2.new(0,5,0,25); Content.AutomaticSize = Enum.AutomaticSize.Y
            Content.BackgroundTransparency = 1; Content.Parent = POMFrame
            Instance.new("UIListLayout", Content).Padding = UDim.new(0,2)
            
            Lib.POMs[name] = Content
        end

        function TabObj:AddTool(tool)
            local Parent = Page
            if tool["Do.POM"] and tool.PartOfMenu and Lib.POMs[tool.PartOfMenu] then
                Parent = Lib.POMs[tool.PartOfMenu]
            end

            local Btn = Instance.new("TextButton")
            Btn.Size = (Parent == Page and layoutType == "TABEL") and UDim2.new(0, 130, 0, 100) or UDim2.new(1, 0, 0, 35)
            Btn.Text = tool.Name
            Btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Parent = Parent
            Instance.new("UICorner", Btn)

            if tool.Look == "ColorPick" then
                local Indicator = Instance.new("Frame")
                Indicator.Size = UDim2.new(0, 20, 0, 20); Indicator.Position = UDim2.new(1, -25, 0.5, -10)
                Indicator.Parent = Btn
                Btn.MouseButton1Click:Connect(function()
                    CreateColorPicker(Btn, Color3.new(1,1,1), function(col)
                        Indicator.BackgroundColor3 = col
                        if Lib.Scripts[tool.Name] then Lib.Scripts[tool.Name](col) end
                    end)
                end)
            elseif tool.Look == "Button" then
                local on = false
                Btn.MouseButton1Click:Connect(function()
                    on = not on
                    Btn.BackgroundColor3 = on and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(50,50,50)
                    if Lib.Scripts[tool.Name] then Lib.Scripts[tool.Name](on) end
                end)
            else 
                Btn.MouseButton1Click:Connect(function()
                    if Lib.Scripts[tool.Name] then Lib.Scripts[tool.Name]() end
                end)
            end
        end
        return TabObj
    end
    return Lib
end
return Cinox
