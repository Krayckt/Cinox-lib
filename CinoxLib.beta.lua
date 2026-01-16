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
    local BG = (manifest.Background_Mode == "D") and Color3.fromRGB(25,25,25) or manifest["C/A-B_Color"] or Color3.fromRGB(35,35,35)
    local Accent = manifest.AccentColor or Color3.fromRGB(0, 170, 255)

    local SG = Instance.new("ScreenGui"); SG.Name = manifest.Name; SG.Parent = LocalPlayer.PlayerGui; SG.ResetOnSpawn = false
    local MF = Instance.new("Frame"); MF.Name = "MainFrame"; MF.Size = UDim2.new(0, 550, 0, 350); MF.Position = UDim2.new(0.5, -275, 0.5, -175); MF.BackgroundColor3 = BG; MF.Parent = SG; MF.Active = true; Instance.new("UICorner", MF)
    
    -- TitleBar mit Close & Minimize
    local TB = Instance.new("Frame"); TB.Size = UDim2.new(1, 0, 0, 30); TB.BackgroundColor3 = Color3.fromRGB(15,15,15); TB.Parent = MF; CreateDrag(TB, MF); Instance.new("UICorner", TB)
    local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, -80, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0); Title.Text = manifest.Name; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"; Title.Parent = TB
    
    local Close = Instance.new("TextButton"); Close.Size = UDim2.new(0, 25, 0, 25); Close.Position = UDim2.new(1, -30, 0, 2); Close.Text = "X"; Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50); Close.Parent = TB; Instance.new("UICorner", Close)
    local Mini = Instance.new("TextButton"); Mini.Size = UDim2.new(0, 25, 0, 25); Mini.Position = UDim2.new(1, -60, 0, 2); Mini.Text = "-"; Mini.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Mini.Parent = TB; Instance.new("UICorner", Mini)

    local minimized = false
    Mini.MouseButton1Click:Connect(function()
        minimized = not minimized
        MF:TweenSize(minimized and UDim2.new(0, 550, 0, 30) or UDim2.new(0, 550, 0, 350), "Out", "Quad", 0.3, true)
    end)
    Close.MouseButton1Click:Connect(function() SG:Destroy() end)

    local TabScroll = Instance.new("ScrollingFrame"); TabScroll.Size = UDim2.new(0, 120, 1, -40); TabScroll.Position = UDim2.new(0, 5, 0, 35); TabScroll.BackgroundTransparency = 1; TabScroll.Parent = MF; TabScroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)
    local PageHost = Instance.new("Frame"); PageHost.Size = UDim2.new(1, -135, 1, -40); PageHost.Position = UDim2.new(0, 130, 0, 35); PageHost.BackgroundTransparency = 1; PageHost.Parent = MF

    local Lib = {Scripts = {}, FirstPage = nil}
    function Lib:AddScript(n, f) Lib.Scripts[n] = f end

    function Lib:AddTab(tC)
        local TBtn = Instance.new("TextButton"); TBtn.Size = UDim2.new(1, 0, 0, 30); TBtn.Text = tC.Name; TBtn.Parent = TabScroll; TBtn.BackgroundColor3 = Color3.fromRGB(45,45,45); TBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", TBtn)
        local P = Instance.new("ScrollingFrame"); P.Size = UDim2.new(1, 0, 1, 0); P.BackgroundTransparency = 1; P.Visible = false; P.Parent = PageHost; P.AutomaticCanvasSize = "Y"; P.ScrollBarThickness = 2
        Instance.new("UIListLayout", P).Padding = UDim.new(0, 8)
        if not Lib.FirstPage then Lib.FirstPage = P end
        TBtn.MouseButton1Click:Connect(function() for _, v in pairs(PageHost:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end; P.Visible = true end)

        local TabObj = {}
        function TabObj:AddTool(toolC)
            local b = Instance.new("Frame"); b.Size = UDim2.new(1, -5, 0, 40); b.BackgroundColor3 = Color3.fromRGB(45,45,45); b.Parent = P; Instance.new("UICorner", b)
            local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -10, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.Text = toolC.Name; lbl.TextColor3 = Color3.new(1,1,1); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = "Left"; lbl.Parent = b

            if toolC.Look == "Slider" then
                local sBack = Instance.new("Frame"); sBack.Size = UDim2.new(0, 150, 0, 6); sBack.Position = UDim2.new(1, -160, 0.5, -3); sBack.BackgroundColor3 = Color3.fromRGB(30,30,30); sBack.Parent = b; Instance.new("UICorner", sBack)
                local sFill = Instance.new("Frame"); sFill.Size = UDim2.new(0.5, 0, 1, 0); sFill.BackgroundColor3 = Accent; sFill.Parent = sBack; Instance.new("UICorner", sFill)
                local valLbl = Instance.new("TextLabel"); valLbl.Size = UDim2.new(0, 30, 0, 20); valLbl.Position = UDim2.new(0, -40, 0, -7); valLbl.Text = "50"; valLbl.TextColor3 = Color3.new(1,1,1); valLbl.BackgroundTransparency = 1; valLbl.Parent = sBack
                
                local function updateSlider()
                    local mousePos = UserInputService:GetMouseLocation().X
                    local relativePos = mousePos - sBack.AbsolutePosition.X
                    local percent = math.clamp(relativePos / sBack.AbsoluteSize.X, 0, 1)
                    sFill.Size = UDim2.new(percent, 0, 1, 0)
                    local finalVal = math.floor(toolC.Min + (percent * (toolC.Max - toolC.Min)))
                    valLbl.Text = tostring(finalVal)
                    if Lib.Scripts[toolC.Name] then Lib.Scripts[toolC.Name](finalVal) end
                end
                sBack.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    local con; con = UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider() end end)
                    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then con:Disconnect() end end)
                    updateSlider()
                end end)

            elseif toolC.Look == "ColorPick" then
                local cpB = Instance.new("TextButton"); cpB.Size = UDim2.new(0, 30, 0, 20); cpB.Position = UDim2.new(1, -40, 0.5, -10); cpB.Text = ""; cpB.BackgroundColor3 = Accent; cpB.Parent = b; Instance.new("UICorner", cpB)
                cpB.MouseButton1Click:Connect(function()
                    -- Hier würde der Colorpicker-Code von vorhin aufgerufen werden
                    if Lib.Scripts[toolC.Name] then Lib.Scripts[toolC.Name](Accent) end
                end)
            end
        end
        return TabObj
    end
    task.spawn(function() if Lib.FirstPage then Lib.FirstPage.Visible = true end end)
    return Lib
end
return Cinox
