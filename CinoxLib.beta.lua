local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Dragging Logik (PC & Handy)
local function CreateDrag(gui, target)
    local dragging, dragStart, startPos
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

function Cinox.Init(manifest)
    local SG = Instance.new("ScreenGui"); SG.Name = manifest.Name; SG.Parent = LocalPlayer:WaitForChild("PlayerGui"); SG.ResetOnSpawn = false
    local isMobile = UserInputService.TouchEnabled
    
    local MF = Instance.new("Frame"); MF.Name = "MainFrame"; MF.Parent = SG; MF.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Instance.new("UICorner", MF)
    MF.Size = UDim2.new(0, 550, 0, 350); MF.Position = UDim2.new(0.5, -275, 0.5, -175)
    
    -- TitleBar
    local TB = Instance.new("Frame"); TB.Size = UDim2.new(1, 0, 0, 35); TB.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TB.Parent = MF; Instance.new("UICorner", TB); CreateDrag(TB, MF)
    
    -- CLOSE BUTTON
    local CloseBtn = Instance.new("TextButton"); CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Parent = TB; Instance.new("UICorner", CloseBtn)
    
    -- MINIMIZE BUTTON (Wieder da!)
    local MinBtn = Instance.new("TextButton"); MinBtn.Text = "-"; MinBtn.Size = UDim2.new(0, 25, 0, 25); MinBtn.Position = UDim2.new(1, -60, 0, 5); MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Parent = TB; Instance.new("UICorner", MinBtn)

    local TabC = Instance.new("ScrollingFrame"); TabC.Size = UDim2.new(0, 110, 1, -50); TabC.Position = UDim2.new(0, 5, 0, 45); TabC.BackgroundTransparency = 1; TabC.Parent = MF; Instance.new("UIListLayout", TabC).Padding = UDim.new(0, 5)
    local PageC = Instance.new("Frame"); PageC.Size = UDim2.new(1, -130, 1, -50); PageC.Position = UDim2.new(0, 120, 0, 45); PageC.BackgroundTransparency = 1; PageC.Parent = MF

    local isMin, fullSize = false, MF.Size
    MinBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        TabC.Visible = not isMin; PageC.Visible = not isMin
        MF:TweenSize(isMin and UDim2.new(0, 200, 0, 35) or fullSize, "Out", "Quad", 0.3, true)
    end)
    CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

    local Lib = {Scripts = {}}
    function Lib:AddScript(n, f) Lib.Scripts[n] = f end

    function Lib:AddTab(conf)
        local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(1, 0, 0, 30); TabBtn.Text = conf.Name; TabBtn.Parent = TabC; Instance.new("UICorner", TabBtn)
        local Page = Instance.new("ScrollingFrame"); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.Parent = PageC; Page.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)
        TabBtn.MouseButton1Click:Connect(function() for _, p in pairs(PageC:GetChildren()) do p.Visible = false end Page.Visible = true end)

        local TabObj = {POMs = {}}
        function TabObj:AddTool(t)
            local target = Page
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

            local b = Instance.new("Frame"); b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(50, 50, 50); b.Parent = target; Instance.new("UICorner", b)
            local lbl = Instance.new("TextLabel"); lbl.Text = "  " .. t.Name; lbl.Size = UDim2.new(0.4, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.new(1,1,1); lbl.TextXAlignment = "Left"; lbl.Parent = b

            if t.Look == "Slider" then
                local sB = Instance.new("TextButton"); sB.Size = UDim2.new(0.45, 0, 0, 12); sB.Position = UDim2.new(0.45, 0, 0.5, -6); sB.BackgroundColor3 = Color3.fromRGB(30,30,30); sB.Text = ""; sB.Parent = b; Instance.new("UICorner", sB)
                local sF = Instance.new("Frame"); sF.Size = UDim2.new(0.5, 0, 1, 0); sF.BackgroundColor3 = Color3.fromRGB(0, 170, 255); sF.Parent = sB; Instance.new("UICorner", sF)
                local valLbl = Instance.new("TextLabel"); valLbl.Size = UDim2.new(0, 35, 1, 0); valLbl.Position = UDim2.new(1, 5, 0, 0); valLbl.Text = tostring(t.Min); valLbl.TextColor3 = Color3.new(1,1,1); valLbl.BackgroundTransparency = 1; valLbl.Parent = sB

                local function move(input)
                    local inputPos = (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and input.Position.X or UserInputService:GetMouseLocation().X
                    local relative = math.clamp((inputPos - sB.AbsolutePosition.X) / sB.AbsoluteSize.X, 0, 1)
                    sF.Size = UDim2.new(relative, 0, 1, 0)
                    local res = math.floor(t.Min + (relative * (t.Max - t.Min)))
                    valLbl.Text = tostring(res)
                    if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](res) end
                end

                local active = false
                sB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true move(i) end end)
                UserInputService.InputChanged:Connect(function(i) if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then move(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end end)
            end
        end
        return TabObj
    end
    return Lib
end
return Cinox
