local UGS = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-------------------------------------------------------------------
-- COLOR PICKER LOGIK
-------------------------------------------------------------------
local function createColorPicker(parent, callback)
    if parent:FindFirstChild("UGS_Picker") then parent.UGS_Picker:Destroy() return end

    local PickerFrame = Instance.new("Frame")
    PickerFrame.Name = "UGS_Picker"
    PickerFrame.Size = UDim2.new(0, 150, 0, 150)
    PickerFrame.Position = UDim2.new(1, 15, 0, 0)
    PickerFrame.BackgroundTransparency = 1
    PickerFrame.Parent = parent

    local Ring = Instance.new("ImageLabel")
    Ring.Size = UDim2.new(1, 0, 1, 0)
    Ring.Image = "rbxassetid://6020299385" 
    Ring.BackgroundTransparency = 1
    Ring.Parent = PickerFrame

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 2, 0, 65)
    Indicator.AnchorPoint = Vector2.new(0.5, 1)
    Indicator.Position = UDim2.new(0.5, 0, 0.5, 0)
    Indicator.BackgroundColor3 = Color3.new(1, 1, 1)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = PickerFrame

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 10, 0, 10)
    Dot.Position = UDim2.new(0.5, -5, 0, -5)
    Dot.Parent = Indicator
    Instance.new("UICorner").Parent = Dot

    local isPicking = false
    local function update()
        local mousePos = UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
        local center = Ring.AbsolutePosition + (Ring.AbsoluteSize / 2)
        local delta = mousePos - center
        local angle = math.atan2(delta.Y, delta.X)
        Indicator.Rotation = math.deg(angle) + 90
        local hue = (math.pi - angle) / (2 * math.pi)
        local color = Color3.fromHSV(hue, 1, 1)
        Dot.BackgroundColor3 = color
        callback(color)
    end

    Ring.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isPicking = true update() end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isPicking and input.UserInputType == Enum.UserInputType.MouseMovement then update() end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isPicking = false end
    end)
end

-------------------------------------------------------------------
-- HAUPT INITIALISIERUNG
-------------------------------------------------------------------
function UGS.Init(manifest)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = manifest.Name
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner").Parent = MainFrame

    -- Dragging Logik
    local dragging, dragInput, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    -- Titelleiste (Auch der Bereich zum Ziehen)
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainFrame

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then updateDrag(input) end
    end)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -90, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.Text = manifest.Name
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = TitleBar

    -- BUTTONS (Schließen & Minimieren)
    local BtnContainer = Instance.new("Frame")
    BtnContainer.Size = UDim2.new(0, 70, 0, 30)
    BtnContainer.Position = UDim2.new(1, -75, 0, 5)
    BtnContainer.BackgroundTransparency = 1
    BtnContainer.Parent = TitleBar

    local function createTopBtn(text, color, pos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = BtnContainer
        Instance.new("UICorner").Parent = btn
        return btn
    end

    local CloseBtn = createTopBtn("X", Color3.fromRGB(180, 50, 50), UDim2.new(0, 40, 0, 0))
    local MiniBtn = createTopBtn("-", Color3.fromRGB(60, 60, 60), UDim2.new(0, 0, 0, 0))

    -- Logik Buttons
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local minimized = false
    local oldSize = MainFrame.Size
    MiniBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MiniBtn.Text = minimized and "+" or "-"
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = minimized and UDim2.new(0, 400, 0, 40) or oldSize}):Play()
    end)

    -- Container für Tools
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -60)
    Container.Position = UDim2.new(0, 10, 0, 45)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2
    Container.Parent = MainFrame
    Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)

    local Lib = {}
    function Lib:AddTool(config)
        local ToolBtn = Instance.new("TextButton")
        ToolBtn.Size = UDim2.new(1, 0, 0, 35)
        ToolBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ToolBtn.Text = "  " .. config.Name
        ToolBtn.TextColor3 = Color3.new(1, 1, 1)
        ToolBtn.TextXAlignment = Enum.TextXAlignment.Left
        ToolBtn.Font = Enum.Font.Gotham
        ToolBtn.Parent = Container
        Instance.new("UICorner").Parent = ToolBtn

        ToolBtn.MouseButton1Click:Connect(function()
            if config.Look == "ColorPick" then
                createColorPicker(ToolBtn, function(color)
                    print("Selected Color:", color)
                end)
            end
        end)
    end

    return Lib
end

return UGS
