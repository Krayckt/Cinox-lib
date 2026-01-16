local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Dragging & ColorPicker Utils
local function CreateDrag(gui, target)
    local dragging, dragInput, dragStart, startPos
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

local function OpenColorPicker(accent, callback, main)
    if main:FindFirstChild("CP_Frame") then main.CP_Frame:Destroy() end
    local CP = Instance.new("Frame"); CP.Name = "CP_Frame"; CP.Size = UDim2.new(0, 150, 0, 170); CP.Position = UDim2.new(1, 10, 0, 0); CP.BackgroundColor3 = Color3.fromRGB(20,20,20); CP.Parent = main; CP.ZIndex = 500
    Instance.new("UICorner", CP); local s = Instance.new("UIStroke", CP); s.Color = accent; s.Thickness = 2
    local Wheel = Instance.new("ImageButton"); Wheel.Size = UDim2.new(0, 120, 0, 120); Wheel.Position = UDim2.new(0.5, -60, 0, 10); Wheel.Image = "rbxassetid://7393858625"; Wheel.BackgroundTransparency = 1; Wheel.Parent = CP; Wheel.ZIndex = 501
    local Picker = Instance.new("Frame"); Picker.Size = UDim2.new(0, 6, 0, 6); Picker.BackgroundColor3 = Color3.new(1,1,1); Picker.Parent = Wheel; Picker.ZIndex = 502; Instance.new("UICorner", Picker).CornerRadius = UDim.new(1,0)
    local drag = false
    local function up(input)
        local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
        local vec = Vector2.new(input.Position.X, input.Position.Y) - center
        local angle = math.atan2(vec.Y, vec.X); local radius = math.min(vec.Magnitude, 60)
        Picker.Position = UDim2.new(0.5, math.cos(angle) * radius - 3, 0.5, math.sin(angle) * radius - 3)
        callback(Color3.fromHSV(((math.deg(angle) + 225) % 360) / 360, radius / 60, 1))
    end
    Wheel.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true up(i) end end)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then up(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -20, 0, 25); btn.Position = UDim2.new(0, 10, 1, -30); btn.Text = "OK"; btn.BackgroundColor3 = accent; btn.Parent = CP; btn.ZIndex = 501; Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() CP:Destroy() end)
end

function Cinox.Init(manifest)
    -- Device & OFP Checks
    if manifest.OFP_Active then
        local found = false; for _, v in pairs(manifest.OFP_List) do if v == LocalPlayer.Name or v == LocalPlayer.UserId then found = true end end
        if not found then return end
    end
    
    local MainColor = (manifest.Background_Mode == "D") and Color3.fromRGB(25,25,25) or (manifest.Background_Mode == "L") and Color3.fromRGB(220,220,220) or manifest["C/A-B_Color"]
    local Accent = manifest.AccentColor or Color3.fromRGB(0, 170, 255)

    local SG = Instance.new("ScreenGui"); SG.Name = manifest.Name; SG.Parent = LocalPlayer.PlayerGui; SG.ResetOnSpawn = false
    local MF = Instance.new("Frame"); MF.Name = "MainFrame"; MF.Size = UDim2.new(0, 550, 0, 350); MF.Position = UDim2.new(0.5, -275, 0.5, -175); MF.BackgroundColor3 = MainColor; MF.Parent = SG; MF.Active = true; Instance.new("UICorner", MF)
    local TB = Instance.new("Frame"); TB.Size = UDim2.new(1, 0, 0, 30); TB.BackgroundColor3 = Color3.fromRGB(15,15,15); TB.Parent = MF; CreateDrag(TB, MF); Instance.new("UICorner", TB)
    
    local TabS = Instance.new("ScrollingFrame"); TabS.Size = UDim2.new(0, 120, 1, -40); TabS.Position = UDim2.new(0, 5, 0, 35); TabS.BackgroundTransparency = 1; TabS.Parent = MF; TabS.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabS).Padding = UDim.new(0, 5)
    
    local PageS = Instance.new("Frame"); PageS.Size = UDim2.new(1, -135, 1, -40); PageS.Position = UDim2.new(0, 130, 0, 35); PageS.BackgroundTransparency = 1; PageS.Parent = MF

    local Lib = {Scripts = {}}
    function Lib:AddScript(n, f) Lib.Scripts[n] = f end

    function Lib:AddTab(tC)
        local TBtn = Instance.new("TextButton"); TBtn.Size = UDim2.new(1, 0, 0, 30); TBtn.Text = tC.Name; TBtn.Parent = TabS; TBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); TBtn.TextColor3 = tC.Name_Color; Instance.new("UICorner", TBtn)
        local P = Instance.new("ScrollingFrame"); P.Size = UDim2.new(1, 0, 1, 0); P.BackgroundTransparency = 1; P.Visible = false; P.Parent = PageS; P.ScrollBarThickness = 2; P.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", P).Padding = UDim.new(0, 5)
        TBtn.MouseButton1Click:Connect(function() for _, v in pairs(PageS:GetChildren()) do v.Visible = false end; P.Visible = true end)

        local TabObj = {POMs = {}}
        function TabObj:AddTool(toolC)
            local targetParent = P
            -- POM Logik: Falls Do.POM true ist, erstelle/nutze einen Container
            if toolC.Do.POM then
                if not TabObj.POMs[toolC.PartOfMenu] then
                    local pomF = Instance.new("Frame"); pomF.Size = UDim2.new(1, -5, 0, 30); pomF.BackgroundColor3 = Color3.fromRGB(35,35,35); pomF.Parent = P; pomF.ClipsDescendants = true; Instance.new("UICorner", pomF)
                    local pomL = Instance.new("TextButton"); pomL.Size = UDim2.new(1, 0, 0, 30); pomL.Text = "[+] " .. toolC.PartOfMenu; pomL.BackgroundTransparency = 1; pomL.TextColor3 = Accent; pomL.Parent = pomF
                    local pomC = Instance.new("Frame"); pomC.Size = UDim2.new(1, 0, 0, 0); pomC.Position = UDim2.new(0, 0, 0, 30); pomC.BackgroundTransparency = 1; pomC.Parent = pomF
                    local UIList = Instance.new("UIListLayout", pomC); UIList.Padding = UDim.new(0, 2)
                    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() pomC.Size = UDim2.new(1, 0, 0, UIList.AbsoluteContentSize.Y) end)
                    local open = false
                    pomL.MouseButton1Click:Connect(function() open = not open; TweenService:Create(pomF, TweenInfo.new(0.3), {Size = open and UDim2.new(1, -5, 0, pomC.Size.Y.Offset + 35) or UDim2.new(1, -5, 0, 30)}):Play() end)
                    TabObj.POMs[toolC.PartOfMenu] = pomC
                end
                targetParent = TabObj.POMs[toolC.PartOfMenu]
            end

            local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -5, 0, 35); b.Text = "  " .. toolC.Name; b.BackgroundColor3 = Color3.fromRGB(45,45,45); b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = "Left"; b.Parent = targetParent; Instance.new("UICorner", b)
            
            if toolC.Look == "ColorPick" then
                local cpI = Instance.new("Frame"); cpI.Size = UDim2.new(0, 20, 0, 20); cpI.Position = UDim2.new(1, -30, 0.5, -10); cpI.BackgroundColor3 = Accent; cpI.Parent = b; Instance.new("UICorner", cpI)
                b.MouseButton1Click:Connect(function() OpenColorPicker(Accent, function(c) cpI.BackgroundColor3 = c; if Lib.Scripts[toolC.Name] then Lib.Scripts[toolC.Name](c) end end, MF) end)
            elseif toolC.Look == "Button" then
                local state = false
                b.MouseButton1Click:Connect(function() state = not state; b.BackgroundColor3 = state and Accent or Color3.fromRGB(45,45,45); if Lib.Scripts[toolC.Name] then Lib.Scripts[toolC.Name](state) end end)
            else
                b.MouseButton1Click:Connect(function() if Lib.Scripts[toolC.Name] then Lib.Scripts[toolC.Name]() end end)
            end
        end
        return TabObj
    end
    return Lib
end
return Cinox
