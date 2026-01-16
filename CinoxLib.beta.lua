local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Cinox.Init(manifest)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = manifest.Name
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 580, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    Instance.new("UICorner", MainFrame)

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.ZIndex = 5
    TitleBar.Parent = MainFrame
    Instance.new("UICorner", TitleBar)
    CreateDrag(TitleBar, MainFrame)

    local TitleText = Instance.new("TextLabel")
    TitleText.Text = "  " .. manifest.Name
    TitleText.Size = UDim2.new(1, -70, 1, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.new(1,1,1)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 14
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.ZIndex = 6
    TitleText.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "X"
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.ZIndex = 7
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner", CloseBtn)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 120, 1, -45)
    TabContainer.Position = UDim2.new(0, 5, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.ZIndex = 10
    TabContainer.Parent = MainFrame
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -140, 1, -45)
    PageContainer.Position = UDim2.new(0, 130, 0, 40)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ZIndex = 1
    PageContainer.Parent = MainFrame

    local Lib = {Scripts = {}}
    function Lib:AddScript(n, f) Lib.Scripts[n] = f end

    function Lib:AddTab(conf)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.Text = conf.Name
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabBtn.TextColor3 = Color3.new(1, 1, 1)
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
        Page.Parent = PageContainer
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageContainer:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            Page.Visible = true
        end)

        local TabObj = {}
        function TabObj:AddTool(t)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -5, 0, 35)
            b.Text = "  " .. t.Name
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            b.TextColor3 = Color3.new(1,1,1)
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = Page
            Instance.new("UICorner", b)
            
            if t.Look == "Toggle" then
                b.MouseButton1Click:Connect(function()
                    if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](true) end
                end)
            end
        end
        return TabObj
    end
    return Lib
end

_G.CinoxLib = Cinox
return Cinox
