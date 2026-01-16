local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function CheckDevice(req)
	local isMobile = UserInputService.TouchEnabled
	if req == "Mobile" and not isMobile then return false end
	if req == "PC" and isMobile then return false end
	return true
end

local function CreateDrag(gui, target)
	local dragging, dragInput, dragStart, startPos
	gui.Active = true
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			UserInputService.ModalEnabled = true
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then 
					dragging = false 
					UserInputService.ModalEnabled = false
				end
			end)
		end
	end)
	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function CreateColorPicker(parent, callback)
	if parent:FindFirstChild("CP_Frame") then parent.CP_Frame.Visible = not parent.CP_Frame.Visible return end
	local CPFrame = Instance.new("Frame")
	CPFrame.Name = "CP_Frame"; CPFrame.Size = UDim2.new(0, 150, 0, 150); CPFrame.Position = UDim2.new(1, 10, 0, 0)
	CPFrame.BackgroundColor3 = Color3.fromRGB(30,30,30); CPFrame.ZIndex = 20; CPFrame.Parent = parent; Instance.new("UICorner", CPFrame)
	local Wheel = Instance.new("ImageButton")
	Wheel.Size = UDim2.new(0, 130, 0, 130); Wheel.Position = UDim2.new(0, 10, 0, 10); Wheel.Image = "rbxassetid://6020299385"; Wheel.BackgroundTransparency = 1; Wheel.ZIndex = 21; Wheel.Parent = CPFrame
	local Picker = Instance.new("Frame")
	Picker.Size = UDim2.new(0, 10, 0, 10); Picker.BackgroundColor3 = Color3.new(1,1,1); Picker.ZIndex = 22; Picker.Parent = Wheel; Instance.new("UICorner", Picker).CornerRadius = UDim.new(1,0)
	local stroke = Instance.new("UIStroke", Picker); stroke.Thickness = 2; stroke.Color = Color3.new(0,0,0)
	local drag = false
	local function up(input)
		local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize/2)
		local vec = Vector2.new(input.Position.X, input.Position.Y) - center
		local ang = math.atan2(vec.Y, vec.X)
		local rad = math.min(vec.Magnitude, Wheel.AbsoluteSize.X/2)
		Picker.Position = UDim2.new(0.5, math.cos(ang)*rad - 5, 0.5, math.sin(ang)*rad - 5)
		local hue = (math.pi - ang) / (2 * math.pi)
		local sat = rad / (Wheel.AbsoluteSize.X/2)
		callback(Color3.fromHSV(hue, sat, 1))
	end
	Wheel.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true up(i) end end)
	UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then up(i) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
end

function Cinox.Init(manifest)
	if manifest.OFP_Active then
		local allowed = false
		for _, id in pairs(string.split(manifest.OFP_List or "", ",")) do
			if tonumber(id) == LocalPlayer.UserId or id == LocalPlayer.Name then allowed = true end
		end
		if not allowed then return end
	end
	if manifest.For_Device and not CheckDevice(manifest.For_Device) then return end
	local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = manifest.Name; ScreenGui.ResetOnSpawn = false; ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	local isMobile = UserInputService.TouchEnabled
	local MainFrame = Instance.new("Frame"); MainFrame.Active = true; MainFrame.ClipsDescendants = false; MainFrame.Parent = ScreenGui; Instance.new("UICorner", MainFrame)
	MainFrame.Size = isMobile and UDim2.new(0, 450, 0, 280) or UDim2.new(0, 600, 0, 400)
	MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset/2, 0.5, -MainFrame.Size.Y.Offset/2)
	local bgColor = Color3.fromRGB(35, 35, 35)
	if manifest.Background_Mode == "C" and manifest["C/A-B_Color"] then bgColor = typeof(manifest["C/A-B_Color"]) == "Color3" and manifest["C/A-B_Color"] or Color3.fromHex(tostring(manifest["C/A-B_Color"])) end
	MainFrame.BackgroundColor3 = bgColor
	local TitleBar = Instance.new("Frame"); TitleBar.Active = true; TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TitleBar.Parent = MainFrame; Instance.new("UICorner", TitleBar); CreateDrag(TitleBar, MainFrame)
	local TitleText = Instance.new("TextLabel"); TitleText.Text = "  "..manifest.Name; TitleText.Size = UDim2.new(0.5, 0, 1, 0); TitleText.BackgroundTransparency = 1; TitleText.TextColor3 = Color3.new(1,1,1); TitleText.Font = Enum.Font.GothamBold; TitleText.TextXAlignment = "Left"; TitleText.Parent = TitleBar
	local Buttons = Instance.new("Frame"); Buttons.Size = UDim2.new(0, 80, 1, 0); Buttons.Position = UDim2.new(1, -85, 0, 0); Buttons.BackgroundTransparency = 1; Buttons.Parent = TitleBar
	local TabContainer = Instance.new("ScrollingFrame"); TabContainer.Active = true; TabContainer.Size = UDim2.new(0, 110, 1, -80); TabContainer.Position = UDim2.new(0, 5, 0, 45); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = MainFrame; Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)
	local PageContainer = Instance.new("Frame"); PageContainer.Active = true; PageContainer.Size = UDim2.new(1, -130, 1, -80); PageContainer.Position = UDim2.new(0, 120, 0, 45); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = MainFrame
	local UserInfo = Instance.new("TextLabel")
	if manifest.USER_INFO then UserInfo.Text = LocalPlayer.Name.." | "..LocalPlayer.UserId; UserInfo.Size = UDim2.new(1, -10, 0, 20); UserInfo.Position = UDim2.new(0, 5, 1, -25); UserInfo.BackgroundTransparency = 1; UserInfo.TextColor3 = Color3.new(1,1,1); UserInfo.TextXAlignment = "Left"; UserInfo.Parent = MainFrame end
	local isMin, fullSize = false, MainFrame.Size
	local function mkBtn(t, c, p, cb) local b = Instance.new("TextButton"); b.Active = true; b.Text = t; b.BackgroundColor3 = c; b.Size = UDim2.new(0, 25, 0, 25); b.Position = p; b.TextColor3 = Color3.new(1,1,1); b.Parent = Buttons; Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb) end
	mkBtn("X", Color3.fromRGB(200,50,50), UDim2.new(1,-30,0,5), function() ScreenGui:Destroy() end)
	mkBtn("-", Color3.fromRGB(60,60,60), UDim2.new(1,-60,0,5), function()
		isMin = not isMin
		TabContainer.Visible, PageContainer.Visible = not isMin, not isMin
		if UserInfo then UserInfo.Visible = (not isMin and manifest.USER_INFO) end
		TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = isMin and UDim2.new(0, 200, 0, 35) or fullSize}):Play()
	end)
	UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode[manifest.ToggelKeybind or "RightShift"] then ScreenGui.Enabled = not ScreenGui.Enabled end end)
	local Lib = {Scripts = {}, POMs = {}}
	function Lib:AddScript(n, f) Lib.Scripts[n] = f end
	function Lib:AddTab(conf)
		local TabBtn = Instance.new("TextButton"); TabBtn.Active = true; TabBtn.Size = UDim2.new(1, 0, 0, 30); TabBtn.Text = conf.Name; TabBtn.BackgroundColor3 = Color3.fromRGB(45,45,45); TabBtn.TextColor3 = (conf.Name_Color == "Rainbow") and Color3.new(1,1,1) or conf.Name_Color or Color3.new(1,1,1); TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn)
		local Page = Instance.new("ScrollingFrame"); Page.Active = true; Page.Name = conf.Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.Parent = PageContainer; Page.ScrollBarThickness = 2
		local lay = string.split(manifest.LAYOUT, "+")[1]
		if lay == "TABEL" then local g = Instance.new("UIGridLayout", Page); g.CellSize = isMobile and UDim2.new(0, 100, 0, 100) or UDim2.new(0, 130, 0, 130) else Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5) end
		TabBtn.MouseButton1Click:Connect(function() for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end Page.Visible = true end)
		local TabObj = {}
		function TabObj:AddPOM(n)
			local f = Instance.new("Frame"); f.Active = true; f.Name = n; f.Size = UDim2.new(1, 0, 0, 0); f.AutomaticSize = "Y"; f.BackgroundColor3 = Color3.fromRGB(30,30,30); f.Parent = Page; Instance.new("UICorner", f)
			local l = Instance.new("TextLabel"); l.Text = n; l.Size = UDim2.new(1,0,0,20); l.BackgroundTransparency=1; l.TextColor3=Color3.new(1,1,1); l.Parent=f
			local c = Instance.new("Frame"); c.Name = "Content"; c.Size = UDim2.new(1, -10, 0, 0); c.Position = UDim2.new(0,5,0,25); c.AutomaticSize = "Y"; c.BackgroundTransparency = 1; c.Parent = f; Instance.new("UIListLayout", c).Padding = UDim.new(0,2)
			Lib.POMs[n] = c
		end
		function TabObj:AddTool(t)
			local p = (t["Do.POM"] and t.PartOfMenu and Lib.POMs[t.PartOfMenu]) or Page
			local b = Instance.new("TextButton"); b.Active = true; b.Size = (p == Page and lay == "TABEL") and (isMobile and UDim2.new(0, 100, 0, 100) or UDim2.new(0, 130, 0, 130)) or UDim2.new(1, 0, 0, 30)
			b.Text = t.Name; b.BackgroundColor3 = Color3.fromRGB(50,50,50); b.TextColor3 = Color3.new(1,1,1); b.Parent = p; Instance.new("UICorner", b)
			b.TextWrapped = true; b.TextTruncate = Enum.TextTruncate.AtEnd
			if t.Look == "ColorPick" then
				local ind = Instance.new("Frame"); ind.Size = UDim2.new(0, 15, 0, 15); ind.Position = UDim2.new(1, -20, 0.5, -7); ind.BackgroundColor3 = Color3.new(1,1,1); ind.Parent = b; Instance.new("UICorner", ind)
				b.MouseButton1Click:Connect(function() CreateColorPicker(b, function(c) ind.BackgroundColor3 = c if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](c) end end) end)
			else
				b.MouseButton1Click:Connect(function() if Lib.Scripts[t.Name] then Lib.Scripts[t.Name]() end end)
			end
		end
		return TabObj
	end
	return Lib
end
return Cinox
