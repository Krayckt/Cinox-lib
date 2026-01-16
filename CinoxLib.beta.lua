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

local function CreateColorPicker(parent, callback, mainFrame)
	if mainFrame:FindFirstChild("CP_Frame") then mainFrame.CP_Frame:Destroy() return end
	
	local CPFrame = Instance.new("Frame")
	CPFrame.Name = "CP_Frame"
	CPFrame.Size = UDim2.new(0, 180, 0, 210)
	CPFrame.Position = UDim2.new(1, 15, 0, 0)
	CPFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	CPFrame.ZIndex = 1000 -- Extrem hoch
	CPFrame.Active = true
	CPFrame.Parent = mainFrame
	Instance.new("UICorner", CPFrame)
	Instance.new("UIStroke", CPFrame).Color = Color3.fromRGB(100, 100, 100)

	local Wheel = Instance.new("ImageButton")
	Wheel.Size = UDim2.new(0, 150, 0, 150)
	Wheel.Position = UDim2.new(0.5, -75, 0, 10)
	Wheel.Image = "rbxassetid://7393858225" 
	Wheel.BackgroundTransparency = 1
	Wheel.ZIndex = 1001
	Wheel.Parent = CPFrame
	
	local Picker = Instance.new("Frame")
	Picker.Size = UDim2.new(0, 10, 0, 10)
	Picker.ZIndex = 1002
	Picker.BackgroundColor3 = Color3.new(1,1,1)
	Picker.Parent = Wheel
	Instance.new("UICorner", Picker).CornerRadius = UDim.new(1,0)

	local drag = false
	local function update(input)
		local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
		local vec = Vector2.new(input.Position.X, input.Position.Y) - center
		local angle = math.atan2(vec.Y, vec.X)
		local radius = math.min(vec.Magnitude, Wheel.AbsoluteSize.X / 2)
		Picker.Position = UDim2.new(0.5, math.cos(angle) * radius - 5, 0.5, math.sin(angle) * radius - 5)
		
		-- 45 Grad Korrektur für deine Textur
		local deg = math.deg(angle) + 180 + 45 
		local hue = (deg % 360) / 360
		callback(Color3.fromHSV(hue, radius / (Wheel.AbsoluteSize.X / 2), 1))
	end
	
	Wheel.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true update(i) end end)
	UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
	
	local Close = Instance.new("TextButton")
	Close.Size = UDim2.new(1, -20, 0, 30); Close.Position = UDim2.new(0, 10, 1, -35); Close.Text = "Fertig"; Close.Parent = CPFrame; Close.ZIndex = 1001
	Instance.new("UICorner", Close)
	Close.MouseButton1Click:Connect(function() CPFrame:Destroy() end)
end

function Cinox.Init(manifest)
	local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = manifest.Name; ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui"); ScreenGui.ResetOnSpawn = false
	
	local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui
	MainFrame.Size = UDim2.new(0, 580, 0, 380)
	MainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
	MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	MainFrame.Active = true
	Instance.new("UICorner", MainFrame)

	local TitleBar = Instance.new("Frame"); TitleBar.Name = "TitleBar"; TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TitleBar.Parent = MainFrame; TitleBar.ZIndex = 10; CreateDrag(TitleBar, MainFrame)
	Instance.new("UICorner", TitleBar)

	-- Buttons mit extrem hohen ZIndex
	local CloseBtn = Instance.new("TextButton"); CloseBtn.Name = "CloseBtn"; CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.ZIndex = 50; CloseBtn.Parent = TitleBar; Instance.new("UICorner", CloseBtn)
	local MinBtn = Instance.new("TextButton"); MinBtn.Name = "MinBtn"; MinBtn.Text = "-"; MinBtn.Size = UDim2.new(0, 25, 0, 25); MinBtn.Position = UDim2.new(1, -60, 0, 5); MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.ZIndex = 50; MinBtn.Parent = TitleBar; Instance.new("UICorner", MinBtn)

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"; TabContainer.Size = UDim2.new(0, 120, 1, -45); TabContainer.Position = UDim2.new(0, 5, 0, 40); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.ZIndex = 20; TabContainer.Parent = MainFrame
	Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

	local PageContainer = Instance.new("Frame")
	PageContainer.Name = "PageContainer"; PageContainer.Size = UDim2.new(1, -145, 1, -50); PageContainer.Position = UDim2.new(0, 135, 0, 40); PageContainer.BackgroundTransparency = 1; PageContainer.ClipsDescendants = true; PageContainer.ZIndex = 15; PageContainer.Parent = MainFrame

	local isMin, fullSize = false, MainFrame.Size
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	MinBtn.MouseButton1Click:Connect(function()
		isMin = not isMin
		TabContainer.Visible = not isMin
		PageContainer.Visible = not isMin
		TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = isMin and UDim2.new(0, 200, 0, 35) or fullSize}):Play()
	end)

	local Lib = {Scripts = {}}
	function Lib:AddScript(n, f) Lib.Scripts[n] = f end

	function Lib:AddTab(conf)
		local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(1, 0, 0, 30); TabBtn.Text = conf.Name; TabBtn.ZIndex = 21; TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn)
		
		local Page = Instance.new("ScrollingFrame")
		Page.Name = conf.Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 4; Page.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y; Page.CanvasSize = UDim2.new(0, 0, 0, 0); Page.ZIndex = 16; Page.Parent = PageContainer
		Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

		TabBtn.MouseButton1Click:Connect(function()
			for _, p in pairs(PageContainer:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
			Page.Visible = true
		end)

		local TabObj = {}
		function TabObj:AddTool(t)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, 410, 0, 40); b.Text = "  " .. t.Name; b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1, 1, 1); b.TextXAlignment = Enum.TextXAlignment.Left; b.ZIndex = 17; b.Parent = Page; Instance.new("UICorner", b)

			if t.Look == "ColorPick" then
				local ind = Instance.new("Frame"); ind.Size = UDim2.new(0, 20, 0, 20); ind.Position = UDim2.new(1, -30, 0.5, -10); ind.BackgroundColor3 = Color3.new(1,1,1); ind.ZIndex = 18; ind.Parent = b; Instance.new("UICorner", ind)
				b.MouseButton1Click:Connect(function() CreateColorPicker(b, function(c) ind.BackgroundColor3 = c if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](c) end end, MainFrame) end)
			elseif t.Look == "Toggle" then
				local state = false
				local tgl = Instance.new("Frame"); tgl.Size = UDim2.new(0, 34, 0, 18); tgl.Position = UDim2.new(1, -44, 0.5, -9); tgl.BackgroundColor3 = Color3.fromRGB(20,20,20); tgl.ZIndex = 18; tgl.Parent = b; Instance.new("UICorner", tgl).CornerRadius = UDim.new(1,0)
				local cir = Instance.new("Frame"); cir.Size = UDim2.new(0, 14, 0, 14); cir.Position = UDim2.new(0, 2, 0.5, -7); cir.BackgroundColor3 = Color3.new(1,1,1); cir.ZIndex = 19; cir.Parent = tgl; Instance.new("UICorner", cir).CornerRadius = UDim.new(1,0)
				b.MouseButton1Click:Connect(function()
					state = not state
					TweenService:Create(cir, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
					TweenService:Create(tgl, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(20, 20, 20)}):Play()
					if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](state) end
				end)
			end
		end
		return TabObj
	end
	return Lib
end
return Cinox
