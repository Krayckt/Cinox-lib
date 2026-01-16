local Cinox = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function CreateDrag(gui, target)
	local dragging, dragInput, dragStart, startPos
	gui.Active = true
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

local function CreateColorPicker(parent, callback, isMobile, mainFrame)
	if mainFrame:FindFirstChild("CP_Frame") then mainFrame.CP_Frame:Destroy() return end
	
	local CPFrame = Instance.new("Frame")
	CPFrame.Name = "CP_Frame"
	CPFrame.Size = isMobile and UDim2.new(0, 200, 0, 250) or UDim2.new(0, 170, 0, 185)
	CPFrame.Position = isMobile and UDim2.new(0.5, -100, 0.5, -125) or UDim2.new(1, 10, 0, 50)
	CPFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	CPFrame.ZIndex = 5000 
	CPFrame.Active = true
	CPFrame.Parent = mainFrame
	Instance.new("UICorner", CPFrame)
	Instance.new("UIStroke", CPFrame).Color = Color3.fromRGB(100, 100, 100)

	local Wheel = Instance.new("ImageButton")
	Wheel.Name = "ColorWheel"
	Wheel.Size = UDim2.new(0, 140, 0, 140)
	Wheel.Position = UDim2.new(0.5, -70, 0, 10)
	-- NUTZE DIE TEXTURE ID 7393858625
	Wheel.Image = "rbxassetid://7393858625" 
	Wheel.BackgroundTransparency = 1
	Wheel.ZIndex = 5001
	Wheel.Parent = CPFrame
	
	local Picker = Instance.new("Frame")
	Picker.Size = UDim2.new(0, 14, 0, 14)
	Picker.BackgroundColor3 = Color3.new(1,1,1)
	Picker.ZIndex = 5002
	Picker.Position = UDim2.new(0.5, -7, 0.5, -7)
	Picker.Parent = Wheel
	Instance.new("UICorner", Picker).CornerRadius = UDim.new(1,0)
	Instance.new("UIStroke", Picker).Thickness = 2

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(1, -20, 0, 30)
	CloseBtn.Position = UDim2.new(0, 10, 1, -40)
	CloseBtn.Text = "Fertig"
	CloseBtn.ZIndex = 5001
	CloseBtn.Parent = CPFrame
	Instance.new("UICorner", CloseBtn)
	CloseBtn.MouseButton1Click:Connect(function() CPFrame:Destroy() end)

	local drag = false
	local function update(input)
		local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
		local vec = Vector2.new(input.Position.X, input.Position.Y) - center
		local angle = math.atan2(vec.Y, vec.X)
		local radius = math.min(vec.Magnitude, Wheel.AbsoluteSize.X / 2)
		Picker.Position = UDim2.new(0.5, math.cos(angle) * radius - 7, 0.5, math.sin(angle) * radius - 7)
		callback(Color3.fromHSV((math.pi - angle) / (2 * math.pi), radius / (Wheel.AbsoluteSize.X / 2), 1))
	end
	
	Wheel.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true update(i) end end)
	UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
end

function Cinox.Init(manifest)
	local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = manifest.Name; ScreenGui.ResetOnSpawn = false; ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui"); ScreenGui.DisplayOrder = 100
	local isMobile = UserInputService.TouchEnabled
	
	local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Active = true; MainFrame.Parent = ScreenGui; Instance.new("UICorner", MainFrame)
	MainFrame.Size = isMobile and UDim2.new(0, 450, 0, 280) or UDim2.new(0, 600, 0, 400)
	MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset/2, 0.5, -MainFrame.Size.Y.Offset/2)
	MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	MainFrame.ClipsDescendants = false 
	
	local TitleBar = Instance.new("Frame"); TitleBar.Name = "TitleBar"; TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TitleBar.Parent = MainFrame; Instance.new("UICorner", TitleBar); CreateDrag(TitleBar, MainFrame)
	TitleBar.ZIndex = 10 -- TitleBar nach vorne

	-- DIE BUTTONS: (Direkt in TitleBar mit hohem ZIndex)
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "CloseBtn"; CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Position = UDim2.new(1, -30, 0, 5)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.ZIndex = 20; CloseBtn.Parent = TitleBar
	Instance.new("UICorner", CloseBtn)
	
	local MinBtn = Instance.new("TextButton")
	MinBtn.Name = "MinBtn"; MinBtn.Text = "-"; MinBtn.Size = UDim2.new(0, 25, 0, 25); MinBtn.Position = UDim2.new(1, -60, 0, 5)
	MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.ZIndex = 20; MinBtn.Parent = TitleBar
	Instance.new("UICorner", MinBtn)

	local TitleText = Instance.new("TextLabel"); TitleText.Text = "  "..manifest.Name; TitleText.Size = UDim2.new(0.6, 0, 1, 0); TitleText.BackgroundTransparency = 1; TitleText.TextColor3 = Color3.new(1,1,1); TitleText.Font = Enum.Font.GothamBold; TitleText.TextXAlignment = "Left"; TitleText.ZIndex = 11; TitleText.Parent = TitleBar
	
	local isMin, fullSize = false, MainFrame.Size
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	MinBtn.MouseButton1Click:Connect(function()
		isMin = not isMin
		MainFrame.TabContainer.Visible = not isMin
		MainFrame.PageContainer.Visible = not isMin
		TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = isMin and UDim2.new(0, 200, 0, 35) or fullSize}):Play()
	end)

	local TabContainer = Instance.new("ScrollingFrame"); TabContainer.Name = "TabContainer"; TabContainer.Size = UDim2.new(0, 110, 1, -80); TabContainer.Position = UDim2.new(0, 5, 0, 45); TabContainer.BackgroundTransparency = 1; TabContainer.Parent = MainFrame; Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5); TabContainer.ScrollBarThickness = 0
	local PageContainer = Instance.new("Frame"); PageContainer.Name = "PageContainer"; PageContainer.Size = UDim2.new(1, -130, 1, -80); PageContainer.Position = UDim2.new(0, 120, 0, 45); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = MainFrame

	local Lib = {Scripts = {}}
	function Lib:AddScript(n, f) Lib.Scripts[n] = f end
	function Lib:AddTab(conf)
		local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(1, 0, 0, 30); TabBtn.Text = conf.Name; TabBtn.BackgroundColor3 = Color3.fromRGB(45,45,45); TabBtn.TextColor3 = Color3.new(1,1,1); TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn)
		local Page = Instance.new("ScrollingFrame"); Page.Name = conf.Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.Parent = PageContainer; Page.AutomaticCanvasSize = "Y"; Page.ClipsDescendants = false; Page.ScrollBarThickness = 2
		Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)
		TabBtn.MouseButton1Click:Connect(function() for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end Page.Visible = true end)
		local TabObj = {}
		function TabObj:AddTool(t)
			local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 35); b.Text = "  " .. t.Name; b.BackgroundColor3 = Color3.fromRGB(50,50,50); b.TextColor3 = Color3.new(1,1,1); b.Parent = Page; Instance.new("UICorner", b); b.TextXAlignment = "Left"; b.ClipsDescendants = false
			if t.Look == "ColorPick" then
				local ind = Instance.new("Frame"); ind.Size = UDim2.new(0, 15, 0, 15); ind.Position = UDim2.new(1, -25, 0.5, -7.5); ind.Parent = b; Instance.new("UICorner", ind)
				b.MouseButton1Click:Connect(function() CreateColorPicker(b, function(c) ind.BackgroundColor3 = c if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](c) end end, isMobile, MainFrame) end)
			elseif t.Look == "Toggle" then
				local state = false
				local tgl = Instance.new("Frame"); tgl.Size = UDim2.new(0, 30, 0, 15); tgl.Position = UDim2.new(1, -40, 0.5, -7.5); tgl.Parent = b; Instance.new("UICorner", tgl).CornerRadius = UDim.new(1,0)
				local cir = Instance.new("Frame"); cir.Size = UDim2.new(0, 11, 0, 11); cir.Position = UDim2.new(0, 2, 0.5, -5.5); cir.Parent = tgl; Instance.new("UICorner", cir).CornerRadius = UDim.new(1,0)
				b.MouseButton1Click:Connect(function()
					state = not state
					cir.Position = state and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5)
					tgl.BackgroundColor3 = state and Color3.fromRGB(60, 150, 60) or Color3.fromRGB(30, 30, 30)
					if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](state) end
				end)
			end
		end
		return TabObj
	end
	return Lib
end
return Cinox
