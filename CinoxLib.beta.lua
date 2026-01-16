local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function CheckDevice(req)
    local isMobile = UserInputService.TouchEnabled
    if req == "Mobile" and not isMobile then return false end
    if req == "PC" and isMobile then return false end
    return true
end

local function CreateDrag(gui, target)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
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
    
    local isMobile = UserInputService.TouchEnabled
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = isMobile and UDim2.new(0, 450, 0, 280) or UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
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
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.Parent = MainFrame
    Instance.new("UICorner", TitleBar)
    CreateDrag(TitleBar, MainFrame)

    local TitleText = Instance.new("TextLabel")
    TitleText.Text = "  " .. manifest.Name
    TitleText.Size = UDim2.new(0.5, 0, 1, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.new(1,1,1)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = isMobile and 14 or 18
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local Buttons = Instance.new("Frame")
    Buttons.Size = UDim2.new(0, 80, 1, 0); Buttons.Position = UDim2.new(1, -85, 0, 0)
    Buttons.BackgroundTransparency = 1; Buttons.Parent = TitleBar
    
    local isMin = false
    local fullSize = MainFrame.Size
    
    local function mkBtn(txt, col, pos, cb)
        local b = Instance.new("TextButton")
        b.Text = txt; b.BackgroundColor3 = col; b.Size = UDim2.new(0, 25, 0, 25); b.Position = pos
        b.TextColor3 = Color3.new(1,1,1); b.Parent = Buttons; Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(cb)
    end
    
    mkBtn("X", Color3.fromRGB(200,50,50), UDim2.new(1,-30,0,5), function() ScreenGui:Destroy() end)
    mkBtn("-", Color3.fromRGB(60,60,60), UDim2.new(1,-60,0,5), function()
        isMin = not isMin
        local targetSize = isMin and UDim2.new(0, 200, 0, 35) or fullSize
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    end)

    local UserInfo = Instance.new("TextLabel")
    if manifest.USER_INFO then
        UserInfo.Text = LocalPlayer.Name .. " | " .. LocalPlayer.UserId
        UserInfo.Size = UDim2.new(1, -10, 0, 20); UserInfo.Position = UDim2.new(0, 5, 1, -25)
        UserInfo.BackgroundTransparency = 1; UserInfo.TextColor3 = Color3.new(1,1,1)
        UserInfo.TextXAlignment = Enum.TextXAlignment.Left; UserInfo.Parent = MainFrame
    end

    MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
        if MainFrame.Size.Y.Offset < 40 then
            UserInfo.Visible = false
        else
            UserInfo.Visible = manifest.USER_INFO or false
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode[manifest.ToggelKeybind or "RightShift"] then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 110, 1, -80); TabContainer.Position = UDim2.new(0, 5, 0, 45)
    TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = MainFrame
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "Pages"
    PageContainer.Size = UDim2.new(1, -130, 1, -80); PageContainer.Position = UDim2.new(0, 120, 0, 45)
    PageContainer.BackgroundTransparency = 1; PageContainer.Parent = MainFrame

    local Lib = {Scripts = {}, POMs = {}}

    function Lib:AddScript(name, func)
        Lib.Scripts[name] = func
    end

    function Lib:AddTab(config)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 30); TabBtn.Text = config.Name; TabBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        TabBtn.TextColor3 = config.Name_Color == "Rainbow" and Color3.new(1,1,1) or config.Name_Color or Color3.new(1,1,1)
        TabBtn.TextSize = 12; TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn)
        
        local Page = Instance.new("ScrollingFrame")
        Page.Name = config.Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.Parent = PageContainer
        Page.ScrollBarThickness = 2
        
        local layoutType = string.split(manifest.LAYOUT, "+")[1]
        if layoutType == "TABEL" then
            local grid = Instance.new("UIGridLayout", Page); grid.CellSize = isMobile and UDim2.new(0, 90, 0, 80) or UDim2.new(0, 130, 0, 100)
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
            POMFrame.Name = name; POMFrame.Size = UDim2.new(1, 0, 0, 0); POMFrame.AutomaticSize = Enum.AutomaticSize.Y
            POMFrame.BackgroundColor3 = Color3.fromRGB(30,30,30); POMFrame.Parent = Page
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
            if tool["Do.POM"] and tool.PartOfMenu and Lib.POMs[tool.PartOfMenu] then Parent = Lib.POMs[tool.PartOfMenu] end
            local Btn = Instance.new("TextButton")
            Btn.Size = (Parent == Page and layoutType == "TABEL") and (isMobile and UDim2.new(0, 90, 0, 80) or UDim2.new(0, 130, 0, 100)) or UDim2.new(1, 0, 0, 30)
            Btn.Text = tool.Name; Btn.BackgroundColor3 = Color3.fromRGB(50,50,50); Btn.TextColor3 = Color3.new(1,1,1); Btn.TextSize = 10; Btn.Parent = Parent
            Instance.new("UICorner", Btn)
            Btn.MouseButton1Click:Connect(function()
                if tool.Look == "Button" then
                    local on = not (Btn.BackgroundColor3 == Color3.fromRGB(60, 180, 60))
                    Btn.BackgroundColor3 = on and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(50,50,50)
                    if Lib.Scripts[tool.Name] then Lib.Scripts[tool.Name](on) end
                else
                    if Lib.Scripts[tool.Name] then Lib.Scripts[tool.Name]() end
                end
            end)
        end
        return TabObj
    end
    return Lib
end
return Cinox
