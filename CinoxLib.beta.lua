local UGS = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function createColorPicker(parent, callback)
    if parent:FindFirstChild("UGS_Picker") then parent.UGS_Picker:Destroy() return end
    local PickerFrame = Instance.new("Frame")
    PickerFrame.Name = "UGS_Picker"; PickerFrame.Size = UDim2.new(0, 140, 0, 140)
    PickerFrame.Position = UDim2.new(1, 10, 0, 0); PickerFrame.BackgroundTransparency = 1; PickerFrame.ZIndex = 10; PickerFrame.Parent = parent
    local Ring = Instance.new("ImageLabel")
    Ring.Size = UDim2.new(1, 0, 1, 0); Ring.Image = "rbxassetid://6020299385"; Ring.BackgroundTransparency = 1; Ring.Parent = PickerFrame
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 2, 0, 60); Indicator.AnchorPoint = Vector2.new(0.5, 1); Indicator.Position = UDim2.new(0.5, 0, 0.5, 0); Indicator.Parent = PickerFrame
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 10, 0, 10); Dot.Position = UDim2.new(0.5, -5, 0, -5); Dot.Parent = Indicator; Instance.new("UICorner", Dot)
    local isPicking = false
    local function update()
        local mousePos = UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
        local center = Ring.AbsolutePosition + (Ring.AbsoluteSize / 2)
        local delta = mousePos - center
        local angle = math.atan2(delta.Y, delta.X)
        local color = Color3.fromHSV((math.pi - angle) / (2 * math.pi), 1, 1)
        Dot.BackgroundColor3 = color; callback(color)
    end
    Ring.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isPicking = true update() end end)
    UserInputService.InputChanged:Connect(function(i) if isPicking and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isPicking = false end end)
end

function UGS.Init(manifest)
    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = manifest.Name; ScreenGui.ResetOnSpawn = false; ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 350); MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175); MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame); Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(60, 60, 60)
    local TitleBar = Instance.new("Frame"); TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35); TitleBar.Parent = MainFrame
    Instance.new("UICorner", TitleBar)
    local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, -20, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = manifest.Name; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = TitleBar
    local TabHolder = Instance.new("Frame"); TabHolder.Size = UDim2.new(1, -20, 0, 30); TabHolder.Position = UDim2.new(0, 10, 0, 45); TabHolder.BackgroundTransparency = 1; TabHolder.Parent = MainFrame
    Instance.new("UIListLayout", TabHolder).FillDirection = Enum.FillDirection.Horizontal; TabHolder.UIListLayout.Padding = UDim.new(0, 5)
    local Pages = Instance.new("Frame"); Pages.Size = UDim2.new(1, -20, 1, -95); Pages.Position = UDim2.new(0, 10, 0, 85); Pages.BackgroundTransparency = 1; Pages.Parent = MainFrame
    local Lib = {}
    function Lib:AddTab(name)
        local Page = Instance.new("ScrollingFrame"); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 2; Page.Parent = Pages
        local GL = Instance.new("UIGridLayout", Page); GL.CellSize = UDim2.new(0, 150, 0, 40); GL.Padding = UDim2.new(0, 10, 0, 10)
        local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(0, 100, 1, 0); TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); TabBtn.Text = name; TabBtn.TextColor3 = Color3.new(1,1,1); TabBtn.Font = Enum.Font.Gotham; TabBtn.Parent = TabHolder; Instance.new("UICorner", TabBtn)
        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in pairs(TabHolder:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end end
            Page.Visible = true; TabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end)
        if #Pages:GetChildren() == 1 then Page.Visible = true; TabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end
        local Tab = {}
        function Tab:AddFunc(text, colorMode)
            local b = Instance.new("TextButton"); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 12; b.Parent = Page
            Instance.new("UICorner", b); local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(80, 80, 80); s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            b.MouseButton1Click:Connect(function() if colorMode then createColorPicker(b, function(c) b.BackgroundColor3 = c end) else print(text) end end)
        end
        return Tab
    end
    return Lib
end
return UGS
