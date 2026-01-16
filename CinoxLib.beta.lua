local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
    -- Sicherheits-Checks
    if manifest.OFP_Active then
        local found = false
        for _, v in pairs(manifest.OFP_List or {}) do
            if tostring(v) == LocalPlayer.Name or tostring(v) == tostring(LocalPlayer.UserId) then found = true end
        end
        if not found then return warn("Kein Zugriff") end
    end

    local BG = (manifest.Background_Mode == "D") and Color3.fromRGB(20,20,20) or manifest["C/A-B_Color"] or Color3.fromRGB(30,30,30)
    local Accent = manifest.AccentColor or Color3.fromRGB(0, 170, 255)

    local SG = Instance.new("ScreenGui"); SG.Name = manifest.Name; SG.Parent = LocalPlayer.PlayerGui; SG.ResetOnSpawn = false
    local MF = Instance.new("Frame"); MF.Name = "MainFrame"; MF.Size = UDim2.new(0, 550, 0, 350); MF.Position = UDim2.new(0.5, -275, 0.5, -175); MF.BackgroundColor3 = BG; MF.Parent = SG; MF.Active = true; Instance.new("UICorner", MF)
    local TB = Instance.new("Frame"); TB.Size = UDim2.new(1, 0, 0, 30); TB.BackgroundColor3 = Color3.fromRGB(15,15,15); TB.Parent = MF; CreateDrag(TB, MF); Instance.new("UICorner", TB)
    
    local TabScroll = Instance.new("ScrollingFrame"); TabScroll.Size = UDim2.new(0, 120, 1, -40); TabScroll.Position = UDim2.new(0, 5, 0, 35); TabScroll.BackgroundTransparency = 1; TabScroll.Parent = MF; TabScroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)
    local PageHost = Instance.new("Frame"); PageHost.Size = UDim2.new(1, -135, 1, -40); PageHost.Position = UDim2.new(0, 130, 0, 35); PageHost.BackgroundTransparency = 1; PageHost.Parent = MF

    local Lib = {Scripts = {}, FirstPage = nil}
    function Lib:AddScript(n, f) Lib.Scripts[n] = f end

    function Lib:AddTab(tC)
        local TBtn = Instance.new("TextButton"); TBtn.Size = UDim2.new(1, 0, 0, 30); TBtn.Text = tC.Name; TBtn.Parent = TabScroll; TBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); TBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", TBtn)
        local P = Instance.new("ScrollingFrame"); P.Size = UDim2.new(1, 0, 1, 0); P.BackgroundTransparency = 1; P.Visible = false; P.Parent = PageHost; P.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", P).Padding = UDim.new(0, 5)
        if not Lib.FirstPage then Lib.FirstPage = P end
        TBtn.MouseButton1Click:Connect(function() for _, v in pairs(PageHost:GetChildren()) do v.Visible = false end; P.Visible = true end)

        local TabObj = {POMs = {}}
        function TabObj:AddTool(toolC)
            local target = P
            -- Fix für Do.POM Check
            if toolC["Do.POM"] then
                local pomName = toolC.PartOfMenu or "Unkown"
                if not TabObj.POMs[pomName] then
                    local f = Instance.new("Frame"); f.Size = UDim2.new(1,-5,0,30); f.BackgroundColor3 = Color3.fromRGB(35,35,35); f.Parent = P; f.ClipsDescendants = true; Instance.new("UICorner", f)
                    local l = Instance.new("TextButton"); l.Size = UDim2.new(1,0,0,30); l.Text = "[+] "..pomName; l.TextColor3 = Accent; l.Parent = f; l.BackgroundTransparency = 1
                    local c = Instance.new("Frame"); c.Size = UDim2.new(1,0,0,0); c.Position = UDim2.new(0,0,0,30); c.Parent = f; c.BackgroundTransparency = 1
                    local ui = Instance.new("UIListLayout", c); ui.Padding = UDim.new(0,2)
                    ui:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() c.Size = UDim2.new(1,0,0,ui.AbsoluteContentSize.Y) end)
                    local open = false
                    l.MouseButton1Click:Connect(function() open = not open; f:TweenSize(open and UDim2.new(1,-5,0,c.Size.Y.Offset+35) or UDim2.new(1,-5,0,30), "Out", "Quad", 0.3, true) end)
                    TabObj.POMs[pomName] = c
                end
                target = TabObj.POMs[pomName]
            end

            local b = Instance.new("TextButton"); b.Size = UDim2.new(1,-5,0,35); b.Text = "  "..toolC.Name; b.BackgroundColor3 = Color3.fromRGB(45,45,45); b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = "Left"; b.Parent = target; Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                if toolC.Look == "Button" then
                    local s = not (b.BackgroundColor3 == Accent); b.BackgroundColor3 = s and Accent or Color3.fromRGB(45,45,45)
                    if Lib.Scripts[toolC.Name] then Lib.Scripts[toolC.Name](s) end
                else
                    if Lib.Scripts[toolC.Name] then Lib.Scripts[toolC.Name]() end
                end
            end)
        end
        return TabObj
    end
    task.spawn(function() if Lib.FirstPage then Lib.FirstPage.Visible = true end end)
    return Lib
end
return Cinox
