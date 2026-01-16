local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Utility: Dragging für PC & Mobile
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

-- Utility: Color Picker Fenster (Mobile Optimiert)
local function OpenPicker(mainFrame, accent, callback)
    if mainFrame:FindFirstChild("CP_Window") then mainFrame.CP_Window:Destroy() return end
    
    local CP = Instance.new("Frame")
    CP.Name = "CP_Window"; CP.Size = UDim2.new(0, 160, 0, 180); CP.Position = UDim2.new(1, 10, 0, 0)
    CP.BackgroundColor3 = Color3.fromRGB(25, 25, 25); CP.Parent = mainFrame; CP.ZIndex = 100
    Instance.new("UICorner", CP)
    local s = Instance.new("UIStroke", CP); s.Color = accent; s.Thickness = 1.5

    local Wheel = Instance.new("ImageButton")
    Wheel.Size = UDim2.new(0, 130, 0, 130); Wheel.Position = UDim2.new(0.5, -65, 0, 10)
    Wheel.Image = "rbxassetid://7393858638"; Wheel.BackgroundTransparency = 1; Wheel.Parent = CP; Wheel.ZIndex = 101

    local Pick = Instance.new("Frame")
    Pick.Size = UDim2.new(0, 10, 0, 10); Pick.BackgroundColor3 = Color3.new(1, 1, 1); Pick.Parent = Wheel; Pick.ZIndex = 102
    Instance.new("UICorner", Pick).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function updateColor(input)
        local inputPos = input.Position
        local wheelCenter = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
        local delta = Vector2.new(inputPos.X, inputPos.Y) - wheelCenter
        local angle = math.atan2(delta.Y, delta.X)
        local distance = math.min(delta.Magnitude, 65)
        
        Pick.Position = UDim2.new(0.5, math.cos(angle) * distance - 5, 0.5, math.sin(angle) * distance - 5)
        local h = ((math.deg(angle) + 180) % 360) / 360
        local sat = distance / 65
        callback(Color3.fromHSV(h, sat, 1))
    end

    Wheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; updateColor(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateColor(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 25); b.Position = UDim2.new(0, 10, 1, -30); b.Text = "Fertig"
    b.TextColor3 = Color3.new(1, 1, 1); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Parent = CP; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() CP:Destroy() end)
end

function Cinox.Init(manifest)
    local SG = Instance.new("ScreenGui"); SG.Name = manifest.Name; SG.Parent = LocalPlayer.PlayerGui; SG.ResetOnSpawn = false
    local MF = Instance.new("Frame"); MF.Name = "MainFrame"; MF.Size = UDim2.new(0, 550, 0, 350); MF.Position = UDim2.new(0.5, -275, 0.5, -175); MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MF.Parent = SG; MF.ClipsDescendants = true; Instance.new("UICorner", MF)
    
    local TB = Instance.new("Frame"); TB.Size = UDim2.new(1, 0, 0, 35); TB.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TB.Parent = MF; CreateDrag(TB, MF); Instance.new("UICorner", TB)
    local Close = Instance.new("TextButton"); Close.Text = "X"; Close.Size = UDim2.new(0, 25, 0, 25); Close.Position = UDim2.new(1, -30, 0, 5); Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50); Close.TextColor3 = Color3.new(1,1,1); Close.Parent = TB; Instance.new("UICorner", Close)
    local Mini = Instance.new("TextButton"); Mini.Text = "-"; Mini.Size = UDim2.new(0, 25, 0, 25); Mini.Position = UDim2.new(1, -60, 0, 5); Mini.BackgroundColor3 = Color3.fromRGB(70, 70, 70); Mini.TextColor3 = Color3.new(1,1,1); Mini.Parent = TB; Mini.ZIndex = 10; Instance.new("UICorner", Mini)
    
    local TabScroll = Instance.new("ScrollingFrame"); TabScroll.Size = UDim2.new(0, 115, 1, -45); TabScroll.Position = UDim2.new(0, 5, 0, 40); TabScroll.BackgroundTransparency = 1; TabScroll.Parent = MF; TabScroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)
    local PageHost = Instance.new("Frame"); PageHost.Size = UDim2.new(1, -135, 1, -45); PageHost.Position = UDim2.new(0, 125, 0, 40); PageHost.BackgroundTransparency = 1; PageHost.Parent = MF

    local isMin, fullSize = false, MF.Size
    Mini.MouseButton1Click:Connect(function()
        isMin = not isMin
        MF:TweenSize(isMin and UDim2.new(0, 550, 0, 35) or fullSize, "Out", "Quad", 0.3, true)
    end)
    Close.MouseButton1Click:Connect(function() SG:Destroy() end)

    local Lib = {Scripts = {}}
    function Lib:AddScript(n, f) Lib.Scripts[n] = f end

    function Lib:AddTab(conf)
        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(1, 0, 0, 30); TBtn.Text = conf.Name; TBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); TBtn.TextColor3 = Color3.new(1, 1, 1); TBtn.Parent = TabScroll; Instance.new("UICorner", TBtn)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 2; Page.Parent = PageHost; Page.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)

        TBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageHost:GetChildren()) do v.Visible = false end
            Page.Visible = true
        end)

        local TabObj = {POMs = {}}
        function TabObj:AddTool(t)
            local target = Page
            if t["Do.POM"] then
                local menuName = t.PartOfMenu or "Allgemein"
                if not TabObj.POMs[menuName] then
                    local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 30); f.BackgroundColor3 = Color3.fromRGB(25, 25, 25); f.ClipsDescendants = true; f.Parent = Page; Instance.new("UICorner", f)
                    local l = Instance.new("TextButton"); l.Size = UDim2.new(1, 0, 0, 30); l.Text = "[+] " .. menuName; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Parent = f
                    local c = Instance.new("Frame"); c.Size = UDim2.new(1, 0, 0, 0); c.Position = UDim2.new(0, 0, 0, 30); c.BackgroundTransparency = 1; c.Parent = f
                    local ui = Instance.new("UIListLayout", c); ui.Padding = UDim.new(0, 2)
                    ui:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() c.Size = UDim2.new(1, 0, 0, ui.AbsoluteContentSize.Y) end)
                    local open = false
                    l.MouseButton1Click:Connect(function()
                        open = not open; l.Text = open and "[-] " .. menuName or "[+] " .. menuName
                        f:TweenSize(open and UDim2.new(1, 0, 0, c.Size.Y.Offset + 35) or UDim2.new(1, 0, 0, 30), "Out", "Quad", 0.3, true)
                    end)
                    TabObj.POMs[menuName] = c
                end
                target = TabObj.POMs[menuName]
            end

            local b = Instance.new("Frame"); b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.Parent = target; Instance.new("UICorner", b)
            local lbl = Instance.new("TextLabel"); lbl.Text = "  " .. t.Name; lbl.Size = UDim2.new(0.4, 0, 1, 0); lbl.TextColor3 = Color3.new(1, 1, 1); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = "Left"; lbl.Parent = b

            if t.Look == "Toggle" then
                local tgl = Instance.new("TextButton"); tgl.Size = UDim2.new(0, 35, 0, 18); tgl.Position = UDim2.new(1, -45, 0.5, -9); tgl.BackgroundColor3 = Color3.fromRGB(30, 30, 30); tgl.Text = ""; tgl.Parent = b; Instance.new("UICorner", tgl).CornerRadius = UDim.new(1, 0)
                local cir = Instance.new("Frame"); cir.Size = UDim2.new(0, 14, 0, 14); cir.Position = UDim2.new(0, 2, 0.5, -7); cir.BackgroundColor3 = Color3.new(1, 1, 1); cir.Parent = tgl; Instance.new("UICorner", cir).CornerRadius = UDim.new(1, 0)
                local state = false
                tgl.MouseButton1Click:Connect(function()
                    state = not state; cir:TweenPosition(state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true)
                    tgl.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 30)
                    if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](state) end
                end)
            elseif t.Look == "Slider" then
                local sB = Instance.new("TextButton"); sB.Size = UDim2.new(0.4, 0, 0, 10); sB.Position = UDim2.new(0.45, 0, 0.5, -5); sB.BackgroundColor3 = Color3.fromRGB(25, 25, 25); sB.Text = ""; sB.Parent = b; Instance.new("UICorner", sB)
                local sF = Instance.new("Frame"); sF.Size = UDim2.new(0, 0, 1, 0); sF.BackgroundColor3 = Color3.fromRGB(0, 170, 255); sF.Parent = sB; Instance.new("UICorner", sF)
                local vL = Instance.new("TextLabel"); vL.Size = UDim2.new(0, 30, 1, 0); vL.Position = UDim2.new(1, 5, 0, 0); vL.Text = tostring(t.Min); vL.TextColor3 = Color3.new(1, 1, 1); vL.BackgroundTransparency = 1; vL.Parent = sB
                local function update(input)
                    local iPos = input.Position.X
                    local rel = math.clamp((iPos - sB.AbsolutePosition.X) / sB.AbsoluteSize.X, 0, 1)
                    sF.Size = UDim2.new(rel, 0, 1, 0)
                    local res = math.floor(t.Min + (rel * (t.Max - t.Min)))
                    vL.Text = tostring(res)
                    if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](res) end
                end
                local active = false
                sB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true update(i) end end)
                UserInputService.InputChanged:Connect(function(i) if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
                UserInputService.InputEnded:Connect(function() active = false end)
            elseif t.Look == "ColorPick" then
                local cpB = Instance.new("TextButton"); cpB.Size = UDim2.new(0, 20, 0, 20); cpB.Position = UDim2.new(1, -30, 0.5, -10); cpB.Text = ""; cpB.Parent = b; Instance.new("UICorner", cpB)
                cpB.MouseButton1Click:Connect(function()
                    OpenPicker(MF, Color3.fromRGB(0, 170, 255), function(c)
                        cpB.BackgroundColor3 = c
                        if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](c) end
                    end)
                end)
            end
        end
        return TabObj
    end
    return Lib
end

return Cinox
