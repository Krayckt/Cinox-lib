Cinox UI Framework

The Cinox Framework is a modular and mobile-friendly UI library for Roblox. It uses a tab-based system where functions like Toggles, Sliders, and Color Pickers can be added easily.
1. Initialization

To start the UI, you first need to load the framework and initialize it.
Lua

local Cinox = loadstring(game:HttpGet("YOUR_RAW_GITHUB_LINK"))()
local Hub = Cinox.Init({Name = "My Script Hub"})

2. Creating Tabs

Tabs act as different pages in your menu. All functions must be attached to a specific tab.
Lua

local CombatTab = Hub:CreateTab("Combat")
local VisualsTab = Hub:CreateTab("Visuals")

3. Adding Elements

You can add the following interactive elements to any tab:

    Toggle: For On/Off features.

    Slider: For numerical values (e.g., Speed, Gravity).

    ColorPicker: For choosing colors (e.g., ESP color, UI Theme).

📝 Full Example Script

--´This is a complete boilerplate code showing how to build a functioning GUI:
--Lua´

--´Load the Framework from GitHub´
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Krayckt/Cinox-lib/main/CinoxLib.beta.lua"))()

--´ Initialize the Main Window´
local Hub = Lib.Init({Name = "Cinox GUI"})

--´ Add Window Controls (Minimize/Close) and Player Information´
Lib.AddWindowControls(Hub.MainFrame, Hub.MainFrame.TitleBar)
Hub:AddPlayerInfo(Hub.TabBar)

 ´--1. Create a Tab for Player´
local PlayerTab = Hub:CreateTab("Player")

PlayerTab:AddToggle("Super Speed", function(state)
    local speed = state and 100 or 16
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
end)

PlayerTab:AddSlider("Jump Power", 50, 200, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

--´2. Create a Tab for Visuals/Settings´
local SettingsTab = Hub:CreateTab("Settings")

SettingsTab:AddColorPicker("ESP Glow Color", Color3.fromRGB(255, 0, 0), function(selectedColor)
    print("New ESP Color selected: ", selectedColor)
     --Your ESP logic here
end)

SettingsTab:AddButton("Destroy UI", function()
    Hub.MainFrame.Parent:Destroy()
end)



--Tips-- 

    Order of Elements: Elements appear in the menu in the exact order they are written in the code.

    The Callback: The function(state) or function(value) is the "Callback". This is where you place the actual cheat logic that runs when the user interacts with the UI.

    Mobile Support: Sliders and the Color Picker are fully optimized for touch-screen inputs.

    Scrolling: Each tab automatically becomes scrollable if you add too many elements.
