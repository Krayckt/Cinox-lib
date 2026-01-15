--[[
    UNIVERSAL GUI SERVICE (UGS) - SINGLE SCRIPT EDITION
    Bereitgestellt für Client-Side Development
]]

local UGS = {}
UGS.__index = UGS

-- Dienste
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-------------------------------------------------------------------
-- INTERNE HILFSFUNKTIONEN (COLOR PICKER & LOGIK)
-------------------------------------------------------------------

local function createColorPicker(parent, callback)
    -- Erscheint nur bei Interaktion
    if parent:FindFirstChild("UGS_Picker") then
        parent.UGS_Picker:Destroy()
        return
    end

    local PickerFrame = Instance.new("Frame")
    PickerFrame.Name = "UGS_Picker"
    PickerFrame.Size = UDim2.new(0, 180, 0, 180)
    PickerFrame.Position = UDim2.new(1, 20, 0, 0)
    PickerFrame.BackgroundTransparency = 1
    PickerFrame.Parent = parent

    -- Der Ring (Video Style)
    local Ring = Instance.new("ImageLabel")
    Ring.Size = UDim2.new(1, 0, 1, 0)
    Ring.Image = "rbxassetid://6020299385" -- Ring Textur
    Ring.BackgroundTransparency = 1
    Ring.Parent = PickerFrame

    -- Der rotierende Strich (Indicator)
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 2, 0, 80)
    Indicator.AnchorPoint = Vector2.new(0.5, 1)
    Indicator.Position = UDim2.new(0.5, 0, 0.5, 0)
    Indicator.BackgroundColor3 = Color3.new(1, 1, 1)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = PickerFrame

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0.5, -7, 0, -7)
    Dot.BackgroundColor3 = Color3.new(1, 1, 1)
    Dot.Parent = Indicator
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Dot

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

    -- Sanftes Einblenden
    PickerFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(PickerFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 180, 0, 180)}):Play()
end

-------------------------------------------------------------------
-- CORE SYSTEM
-------------------------------------------------------------------

function UGS.Init(manifest)
    -- Berechtigungsprüfung (OFP & Device)
    if manifest.OFP_Active then
        local allowed = false
        for _, val in pairs(manifest.OFP_List or {}) do
            if tostring(val) == tostring(LocalPlayer.UserId) or val == LocalPlayer.Name then
                allowed = true break
            end
        end
        if not allowed then warn("UGS: Access Denied"); return nil end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = manifest.Name
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Hauptfenster
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = (manifest.Background_Mode == "D" and Color3.fromRGB(30,30,30)) or (manifest.Background_Mode == "L" and Color3.fromRGB(240,240,240)) or manifest["C/A-B_Color"] or Color3.fromRGB(40,40,40)
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = MainFrame

    -- Titelzeile
    local Title = Instance.new("TextLabel")
    Title.Text = "  " .. manifest.Name
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1,1,1)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = MainFrame

    -- User Info
    if manifest.USER_INFO then
        local Info = Instance.new("TextLabel")
        Info.Text = "User: "..LocalPlayer.Name.." | ID: "..LocalPlayer.UserId
        Info.Size = UDim2.new(1, -20, 0, 20)
        Info.Position = UDim2.new(0, 10, 1, -25)
        Info.BackgroundTransparency = 1
        Info.TextColor3 = Color3.fromRGB(200,200,200)
        Info.TextSize = 12
        Info.TextXAlignment = Enum.TextXAlignment.Left
        Info.Parent = MainFrame
    end

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -80)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.CanvasSize = UDim2.new(0,0,0,0)
    Container.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = Container

    local Library = {Gui = ScreenGui, Container = Container}

    -- Tool Erstellung Funktion
    function Library:AddTool(config)
        local ToolBtn = Instance.new("TextButton")
        ToolBtn.Size = UDim2.new(1, 0, 0, 35)
        ToolBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        ToolBtn.Text = "  " .. config.Name
        ToolBtn.TextColor3 = Color3.new(1,1,1)
        ToolBtn.TextXAlignment = Enum.TextXAlignment.Left
        ToolBtn.AutoButtonColor = true
        ToolBtn.Parent = Container
        Instance.new("UICorner").Parent = ToolBtn

        if config.Look == "ColorPick" then
            ToolBtn.MouseButton1Click:Connect(function()
                createColorPicker(ToolBtn, function(color)
                    -- Hier wird die gewählte Farbe verarbeitet
                    print("Selected Color for " .. config.Name .. ": ", color)
                end)
            end)
        elseif config.Look == "OneTimeInteract" or config.Look == "Button" then
            ToolBtn.MouseButton1Click:Connect(function()
                print("Clicked: " .. config.Name)
                -- Script Aufruf Logik hier einfügen
            end)
        end
    end

    return Library
end

return UGS