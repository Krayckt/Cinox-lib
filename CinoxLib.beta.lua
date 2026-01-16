local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Utility: Dragging
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
    
    local MF = Instance.new("Frame"); MF.Name = "MainFrame"; MF.Parent = SG; MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MF.BorderSizePixel = 0; MF.ClipsDescendants = true
    MF.Size = UDim2.new(0, 550, 0, 350); MF.Position = UDim2.new(0.5, -275, 0.5, -175); Instance.new("UICorner", MF)
    
    -- TitleBar
    local TB = Instance.new("Frame"); TB.Size = UDim2.new(1, 0, 0, 35); TB.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TB.Parent = MF; TB.ZIndex = 5; CreateDrag(TB, MF); Instance.new("UICorner", TB)
    
    -- Title Text (Platz für Buttons lassen!)
    local Txt = Instance.new("TextLabel"); Txt.Size = UDim2.new(1, -100, 1, 0); Txt.Position = UDim2.new(0, 10, 0, 0); Txt.Text = manifest.Name; Txt.TextColor3 = Color3.new(1,1,1); Txt.BackgroundTransparency = 1; Txt.TextXAlignment = "Left"; Txt.Parent = TB; Txt.ZIndex = 6
    
    -- Buttons (Explicit ZIndex & Order)
    local Close = Instance.new("TextButton"); Close.Text = "X"; Close.Size = UDim2.new(0, 25, 0, 25); Close.Position = UDim2.new(1, -30, 0, 5); Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50); Close.TextColor3 = Color3.new(1,1,1); Close.Parent = TB; Close.ZIndex = 7; Instance.new("UICorner", Close)
    local Mini = Instance.new("TextButton"); Mini.Text = "-"; Mini.Size = UDim2.new(0, 25, 0, 25); Mini.Position = UDim2.new(1, -60, 0, 5); Mini.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Mini.TextColor3 = Color3.new(1,1,1); Mini.Parent = TB; Mini.ZIndex = 7; Instance.new("UICorner", Mini)

    local TabC = Instance.new("ScrollingFrame"); TabC.Size = UDim2.new(0, 110, 1, -50); TabC.Position = UDim2.new(0, 5, 0, 45); TabC.BackgroundTransparency = 1; TabC.Parent = MF; TabC.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabC).Padding = UDim.new(0, 5)
    local PageC = Instance.new("Frame"); PageC.Size = UDim2.new(1, -130, 1, -50); PageC.Position = UDim2.new(0, 120, 0, 45); PageC.BackgroundTransparency = 1; PageC.Parent = MF

    local isMin, fullS = false, MF.Size
    Mini.MouseButton1Click:Connect(function()
        isMin = not isMin
        TabC.Visible = not isMin; PageC.Visible = not isMin
        MF:TweenSize(isMin and UDim2.new(0, 550, 0, 35) or fullS, "Out", "Quad", 0.3, true)
    end)
    Close.MouseButton1Click:Connect(function() SG:Destroy() end)

    local Lib = {Scripts = {}}
    function Lib:AddScript(n, f) Lib.Scripts[n] = f end

    function Lib:AddTab(conf)
        local TBtn = Instance.new("TextButton"); TBtn.Size = UDim2.new(1, 0, 0, 30); TBtn.Text = conf.Name; TBtn.Parent = TabC; Instance.new("UICorner", TBtn)
        local Page = Instance.new("ScrollingFrame"); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.Parent = PageC; Page.AutomaticCanvasSize = "Y"; Page.ScrollBarThickness = 2
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)
        TBtn.MouseButton1Click:Connect(function() for _, v in pairs(PageC:GetChildren()) do v.Visible = false end Page.Visible = true end)

        local TabObj = {POMs = {}}
        function TabObj:AddTool(t)
            local target = Page
            if t["Do.POM"] then
                if not TabObj.POMs[t.PartOfMenu] then
                    local pf = Instance.new("Frame"); pf.Size = UDim2.new(1, 0, 0, 30); pf.BackgroundColor3 = Color3.fromRGB(20, 20, 20); pf.Parent = Page; pf.ClipsDescendants = true; Instance.new("UICorner", pf)
                    local pl = Instance.new("TextButton"); pl.Size = UDim2.new(1, 0, 0, 30); pl.Text = "[+] " .. t.PartOfMenu; pl.BackgroundTransparency = 1; pl.TextColor3 = Color3.new(1,1,1); pl.Parent = pf
                    local pc = Instance.new("Frame"); pc.Size = UDim2.new(1, 0, 0, 0); pc.Position = UDim2.new(0, 0, 0, 30); pc.BackgroundTransparency = 1; pc.Parent = pf
                    local ui = Instance.new("UIListLayout", pc); ui.Padding = UDim.new(0, 2)
                    ui:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() pc.Size = UDim2.new(1, 0, 0, ui.AbsoluteContentSize.Y) end)
                    local op = false
                    pl.MouseButton1Click:Connect(function() op = not op; pf:TweenSize(op and UDim2.new(1, 0, 0, pc.Size.Y.Offset + 35) or UDim2.new(1, 0, 0, 30), "Out", "Quad", 0.3, true) end)
                    TabObj.POMs[t.PartOfMenu] = pc
                end
                target = TabObj.POMs[t.PartOfMenu]
            end

            local b = Instance.new("Frame"); b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.Parent = target; Instance.new("UICorner", b)
            local l = Instance.new("TextLabel"); l.Text = "  " .. t.Name; l.Size = UDim2.new(0.4, 0, 1, 0); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.TextXAlignment = "Left"; l.Parent = b

            -- LOOK: TOGGLE
            if t.Look == "Toggle" then
                local tgl = Instance.new("TextButton"); tgl.Size = UDim2.new(0, 35, 0, 18); tgl.Position = UDim2.new(1, -45, 0.5, -9); tgl.BackgroundColor3 = Color3.fromRGB(30, 30, 30); tgl.Text = ""; tgl.Parent = b; Instance.new("UICorner", tgl).CornerRadius = UDim.new(1,0)
                local cir = Instance.new("Frame"); cir.Size = UDim2.new(0, 14, 0, 14); cir.Position = UDim2.new(0, 2, 0.5, -7); cir.BackgroundColor3 = Color3.new(1,1,1); cir.Parent = tgl; Instance.new("UICorner", cir).CornerRadius = UDim.new(1,0)
                local s = false
                tgl.MouseButton1Click:Connect(function()
                    s = not s
                    cir:TweenPosition(s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true)
                    tgl.BackgroundColor3 = s and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 30)
                    if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](s) end
                end)

            -- LOOK: SLIDER
            elseif t.Look == "Slider" then
                local sB = Instance.new("TextButton"); sB.Size = UDim2.new(0.4, 0, 0, 10); sB.Position = UDim2.new(0.45, 0, 0.5, -5); sB.BackgroundColor3 = Color3.fromRGB(25, 25, 25); sB.Text = ""; sB.Parent = b; Instance.new("UICorner", sB)
                local sF = Instance.new("Frame"); sF.Size = UDim2.new(0, 0, 1, 0); sF.BackgroundColor3 = Color3.fromRGB(0, 170, 255); sF.Parent = sB; Instance.new("UICorner", sF)
                local vL = Instance.new("TextLabel"); vL.Size = UDim2.new(0, 30, 1, 0); vL.Position = UDim2.new(1, 5, 0, 0); vL.Text = tostring(t.Min); vL.TextColor3 = Color3.new(1,1,1); vL.BackgroundTransparency = 1; vL.Parent = sB
                local function up(input)
                    local iPos = (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and input.Position.X or UserInputService:GetMouseLocation().X
                    local rel = math.clamp((iPos - sB.AbsolutePosition.X) / sB.AbsoluteSize.X, 0, 1)
                    sF.Size = UDim2.new(rel, 0, 1, 0); local res = math.floor(t.Min + (rel * (t.Max - t.Min))); vL.Text = res
                    if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](res) end
                end
                local active = false
                sB.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true up(i) end end)
                UserInputService.InputChanged:Connect(function(i) if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then up(i) end end)
                UserInputService.InputEnded:Connect(function() active = false end)
            end
        end
        return TabObj
    end
    return Lib
end
return Cinox
