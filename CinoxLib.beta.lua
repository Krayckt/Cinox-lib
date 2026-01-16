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
	CPFrame.Size = UDim2.new(0, 180, 0, 200)
	CPFrame.Position = UDim2.new(1, 10, 0, 0)
	CPFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	CPFrame.ZIndex = 5000 
	CPFrame.Parent = mainFrame
	Instance.new("UICorner", CPFrame)
	Instance.new("UIStroke", CPFrame).Color = Color3.fromRGB(100, 100, 100)

	local Wheel = Instance.new("ImageButton")
	Wheel.Size = UDim2.new(0, 150, 0, 150)
	Wheel.Position = UDim2.new(0.5, -75, 0, 10)
	Wheel.Image = "rbxassetid://7393858625" 
	Wheel.BackgroundTransparency = 1
	Wheel.ZIndex = 5001
	Wheel.Parent = CPFrame
	
	local Picker = Instance.new("Frame")
	Picker.Size = UDim2.new(0, 10, 0, 10)
	Picker.ZIndex = 5002
	Picker.Parent = Wheel
	Instance.new("UICorner", Picker).CornerRadius = UDim.new(1,0)

	local drag = false
	local function update(input)
		local center = Wheel.AbsolutePosition + (Wheel.AbsoluteSize / 2)
		local vec = Vector2.new(input.Position.X, input.Position.Y) - center
		local angle = math.atan2(vec.Y, vec.X)
		local radius = math.min(vec.Magnitude, Wheel.AbsoluteSize.X / 2)
		
		Picker.Position = UDim2.new(0.5, math.cos(angle) * radius - 5, 0.5, math.sin(angle) * radius - 5)
		
		-- FARB-FIX: Der Winkel wird angepasst, damit die Farben synchron zum Bild sind
		local deg = math.deg(angle) + 180 
		local hue = deg / 360
		callback(Color3.fromHSV(hue, radius / (Wheel.AbsoluteSize.X / 2), 1))
	end
	
	Wheel.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true update(i) end end)
	UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
	
	local Close = Instance.new("TextButton")
	Close.Size = UDim2.new(1, -20, 0, 25); Close.Position = UDim2.new(0, 10, 1, -30)
	Close.Text = "OK"; Close.Parent = CPFrame; Close.MouseButton1Click:Connect(function() CPFrame:Destroy() end)
end

function Cinox.Init(manifest)
	local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = manifest.Name; ScreenGui.Parent = LocalPlayer.PlayerGui
	
	local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui
	MainFrame.Size = UDim2.new(0, 550, 0, 350)
	MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
	MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Instance.new("UICorner", MainFrame)

	local TitleBar = Instance.new("Frame"); TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TitleBar.Parent = MainFrame; Instance.new("UICorner", TitleBar); CreateDrag(TitleBar, MainFrame)
	
	local CloseBtn = Instance.new("TextButton"); CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.ZIndex = 100; CloseBtn.Parent = TitleBar; CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

	-- Tab-Container (Links)
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 120, 1, -45)
	TabContainer.Position = UDim2.new(0, 5, 0, 40)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 2
	TabContainer.Parent = MainFrame
	local TabList = Instance.new("UIListLayout", TabContainer); TabList.Padding = UDim.new(0, 5)

	-- Page-Container (Rechts)
	local PageContainer = Instance.new("Frame")
	PageContainer.Name = "PageContainer"
	PageContainer.Size = UDim2.new(1, -140, 1, -45)
	PageContainer.Position = UDim2.new(0, 130, 0, 40)
	PageContainer.BackgroundTransparency = 1
	PageContainer.ClipsDescendants = true -- Verhindert, dass Buttons über den Rand ragen
	PageContainer.Parent = MainFrame

	local Lib = {Scripts = {}}
	function Lib:AddScript(n, f) Lib.Scripts[n] = f end

	function Lib:AddTab(conf)
		local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(1, -5, 0, 30); TabBtn.Text = conf.Name; TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn)
		
		-- FIX: ScrollingFrame für jede Seite, damit Funktionen nicht rausgehen
		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.ScrollBarThickness = 4
		Page.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y -- Wächst mit dem Inhalt
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.Parent = PageContainer
		
		local PageList = Instance.new("UIListLayout", Page); PageList.Padding = UDim.new(0, 8)
		Instance.new("UIPadding", Page).PaddingLeft = UDim.new(0, 5) -- Kleiner Abstand zum Rand

		TabBtn.MouseButton1Click:Connect(function()
			for _, p in pairs(PageContainer:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
			Page.Visible = true
		end)

		local TabObj = {}
		function TabObj:AddTool(t)
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, -10, 0, 40) -- -10 damit der Scrollbalken Platz hat
			b.Text = "  " .. t.Name
			b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			b.TextColor3 = Color3.new(1, 1, 1)
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.Parent = Page
			Instance.new("UICorner", b)

			if t.Look == "ColorPick" then
				local ind = Instance.new("Frame"); ind.Size = UDim2.new(0, 20, 0, 20); ind.Position = UDim2.new(1, -30, 0.5, -10); ind.BackgroundColor3 = Color3.new(1,1,1); ind.Parent = b; Instance.new("UICorner", ind)
				b.MouseButton1Click:Connect(function()
					CreateColorPicker(b, function(c) 
						ind.BackgroundColor3 = c 
						if Lib.Scripts[t.Name] then Lib.Scripts[t.Name](c) end 
					end, false, MainFrame)
				end)
			elseif t.Look == "Toggle" then
				local state = false
				local tgl = Instance.new("Frame"); tgl.Size = UDim2.new(0, 34, 0, 18); tgl.Position = UDim2.new(1, -44, 0.5, -9); tgl.BackgroundColor3 = Color3.fromRGB(20,20,20); tgl.Parent = b; Instance.new("UICorner", tgl).CornerRadius = UDim.new(1,0)
				local cir = Instance.new("Frame"); cir.Size = UDim2.new(0, 14, 0, 14); cir.Position = UDim2.new(0, 2, 0.5, -7); cir.BackgroundColor3 = Color3.new(1,1,1); cir.Parent = tgl; Instance.new("UICorner", cir).CornerRadius = UDim.new(1,0)
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
