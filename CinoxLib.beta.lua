local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Utility: Dragging
local function CreateDrag(gui, target)
    local dragging, dragStart, startPos
    gui.Active = true
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = target.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Utility: ColorPicker
local function CreateColorPicker(callback, isMobile, mainFrame)
    if mainFrame:FindFirstChild("CP_Frame") then mainFrame.CP_Frame:Destroy() return end
    local CP = Instance.new("Frame"); CP.Name = "CP_Frame"; CP.Size = UDim2.new(0, 170, 0, 185); CP.Position = UDim2.new(1, 10, 0, 50); CP.BackgroundColor3 = Color3.fromRGB(25, 25, 25); CP.Parent = mainFrame; CP.ZIndex = 2000; Instance.new("UICorner", CP)
    local Wheel = Instance.new("ImageButton"); Wheel.Size = UDim2.new(0, 130, 0, 130); Wheel.Position = UDim2.new(0.5, -65, 0, 10); Wheel.Image = "rbxassetid://7393858638"; Wheel.BackgroundTransparency = 1; Wheel.Parent = CP; Wheel.ZIndex = 2001
    local Picker = Instance.new("Frame"); Picker.Size = UDim2.new(0, 10, 0, 10); Picker.BackgroundColor3 = Color3.new(1,1,1); Picker.Parent = Wheel; Picker.ZIndex = 2002; Instance.new("UICorner", Picker).CornerRadius = UDim.new(1,0)
    
    local drag = false
    local function update(input)
        local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
        local vec = Vector2.new(input.Position.X, input.Position.Y) - center
        local angle = math.atan2(vec.Y, vec.X); local radius = math.min(vec.Magnitude, 65)
        Picker.Position = UDim2.new(0.5, math.cos(angle) * radius - 5, 0.5, math.sin(angle) * radius - 5)
        callback(Color3.fromHSV((math.pi - angle) / (2 * math.pi), radius / 65, 1))
    end
    Wheel.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true update(i) end end)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
    UserInputService.InputEnded:Connect(function() drag = false end)
    local Close = Instance.new("TextButton"); Close.Size = UDim2.new(1, -20, 0, 25); Close.Position = UDim2.new(0, 10, 1, -30); Close.Text = "OK"; Close.Parent = CP; Close.MouseButton1Click:Connect(function() CP:Destroy() end)
end

function Cinox.Init(manifest)
    local SG = Instance.new("ScreenGui"); SG.Name = manifest.Name; SG.Parent = LocalPlayer.PlayerGui; SG.ResetOnSpawn = false
    local isMobile = UserInputService.TouchEnabled
    local MF = Instance.new("Frame"); MF.Size = UDim2.new(0, 550, 0, 350); MF.Position = UDim2.new(0.5, -275, 0.5, -175); MF.BackgroundColor3 = Color3.fromRGB(35, 35, 35); MF.Parent = SG; Instance.new("UICorner", MF)
    
    local TB = Instance.new("Frame"); TB.Size = UDim2.new(1, 0, 0, 35); TB.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TB.Parent = MF; CreateDrag(TB, MF); Instance.new("UICorner", TB)
    local CloseBtn = Instance.new("TextButton"); CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.Parent = TB; CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

    local TabContainer = Instance.new("ScrollingFrame"); TabContainer.Size = UDim2.new(0, 110, 1, -50); TabContainer.Position = UDim2.new(0, 5, 0, 45); TabContainer.BackgroundTransparency = 1; TabContainer.Parent = MF; Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)
    local PageContainer = Instance.new("Frame"); PageContainer.Size = UDim2.new(1, -130, 1, -50); PageContainer.Position = UDim2.new(0, 120, 0, 45); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = MF

    local Lib = {Scripts = {}}
    function Lib:AddScript(n, f) Lib.Scripts[n] = f end

    function Lib:AddTab(conf)
        local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(1, 0, 0, 30); TabBtn.Text = conf.Name; TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn)
        local Page = Instance.new("ScrollingFrame"); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.Parent = PageContainer; Page.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)
        TabBtn.MouseButton1Click:Connect(function() for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end Page.Visible = true end)

        local TabObj = {POMs = {}}
        function TabObj:AddTool(t)
            local target = Page
            -- POM System
            if t["Do.POM"] then
                if not TabObj.POMs[t.PartOfMenu] then
                    local pomF = Instance.new("Frame"); pomF.Size = UDim2.new(1, 0, 0, 30); pomF.BackgroundColor3 = Color3.fromRGB(25, 25, 25); pomF.Parent = Page; pomF.ClipsDescendants = true; Instance.new("UICorner", pomF)
                    local pomL = Instance.new("TextButton"); pomL.Size = UDim2.new(1, 0, 0, 30); pomL.Text = "[+] " .. t.PartOfMenu; pomL.BackgroundTransparency = 1; pomL.TextColor3 = Color3.new(1,1,1); pomL.Parent = pomF
                    local pomC = Instance.new("Frame"); pomC.Size = UDim2.new(1, 0, 0, 0); pomC.Position = UDim2.new(0, 0, 0, 30); pomC.BackgroundTransparency = 1; pomC.Parent = pomF
                    local ui = Instance.new("UIListLayout", pomC); ui.Padding = UDim.new(0, 2)
                    ui:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() pomC.Size = UDim2.new(1, 0, 0, ui.AbsoluteContentSize.Y) end)
                    local open = false
                    pomL.MouseButton1Click:Connect(function() open = not open; pomF:TweenSize(open and UDim2.new(1, 0, 0, pomC.Size.Y.Offset + 35) or UDim2.new(1, 0, 0, 30), "Out", "Quad", 0.3, true) end)
                    TabObj.POMs[t.PartOfMenu] = pomC
                end
                target = TabObj.POMs[t.PartOfMenu]
            end

            local b = Instance.new("Frame"); b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(50, 50, 50); b.Parent = target; Instance.new("UICorner", b)
            local lbl = Instance.new("TextLabel"); lbl.Text = "  " .. t.Name; lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.new(1,1,1); lbl.TextXAlignment = "Left"; lbl.Parent = b

            if t.Look == "ColorPick" then
                local ind = Instance.new("TextButton"); ind.Size = UDim2.new(0, 20, 0, 20); ind.Position = UDim2.new(1, -30, 0.5, -10); ind.Text = ""; ind.Parent = b; Instance.new("UICorner", ind)
                ind.MouseButton1Click:Connect(function() CreateColorPicker(function(c) ind.BackgroundColor3 = c if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](c) end end, isMobile, MF) end)
            
            elseif t.Look == "Slider" then
                local sB = Instance.new("TextButton"); sB.Size = UDim2.new(0.4, 0, 0, 10); sB.Position = UDim2.new(0.55, 0, 0.5, -5); sB.BackgroundColor3 = Color3.fromRGB(30,30,30); sB.Text = ""; sB.Parent = b; Instance.new("UICorner", sB)
                local sF = Instance.new("Frame"); sF.Size = UDim2.new(0.5, 0, 1, 0); sF.BackgroundColor3 = Color3.fromRGB(0, 170, 255); sF.Parent = sB; Instance.new("UICorner", sF)
                local val = Instance.new("TextLabel"); val.Size = UDim2.new(0, 30, 1, 0); val.Position = UDim2.new(1, 5, 0, 0); val.Text = "50"; val.TextColor3 = Color3.new(1,1,1); val.BackgroundTransparency = 1; val.Parent = sB
                local function upS()
                    local p = math.clamp((UserInputService:GetMouseLocation().X - sB.AbsolutePosition.X) / sB.AbsoluteSize.X, 0, 1)
                    sF.Size = UDim2.new(p, 0, 1, 0); local res = math.floor(t.Min + (p * (t.Max - t.Min))); val.Text = tostring(res)
                    if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](res) end
                end
                sB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local c; c = UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then upS() end end); UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then c:Disconnect() end end); upS() end end)
            end
        end
        return TabObj
    end
    return Lib
end
return Cinox
