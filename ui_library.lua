--[[
    Lightweight Roblox UI Library
    
    INSTALLATION:
    1. Place this script in ReplicatedStorage as "UILibrary"
    2. Require it in your LocalScript: local UI = require(game.ReplicatedStorage.UILibrary)
    
    BASIC USAGE:
    local UI = require(game.ReplicatedStorage.UILibrary)
    local window = UI.CreateWindow({Title = "My GUI", Size = UDim2.new(0, 400, 0, 300)})
    local tab = window:CreateTab("Main", "rbxasset://textures/ui/GuiImagePlaceholder.png")
    local section = tab:CreateSection("Controls")
    local button = section:CreateButton({Name = "Click Me", Callback = function() print("Clicked!") end})
    
    FEATURES:
    - Mobile-friendly touch controls
    - Configurable themes (dark/light)
    - Built-in configuration saving/loading
    - Smooth animations and responsive layouts
    - Icon support (Roblox asset IDs or basic shapes)
    - Clean, extensible API
--]]

local UI = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Constants
local MOBILE_DEVICE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FAST_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Configuration storage
local CONFIG_KEY = "UILibraryConfig"
local Configurations = {}

-- Themes
local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(55, 55, 55),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 60),
        Success = Color3.fromRGB(0, 150, 0),
        Warning = Color3.fromRGB(255, 165, 0),
        Error = Color3.fromRGB(220, 20, 60)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(250, 250, 250),
        Accent = Color3.fromRGB(220, 220, 220),
        Text = Color3.fromRGB(0, 0, 0),
        TextDim = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(0, 120, 0),
        Warning = Color3.fromRGB(200, 140, 0),
        Error = Color3.fromRGB(180, 20, 60)
    }
}

local CurrentTheme = Themes.Dark

-- Utility Functions
local function CreateTween(object, properties, tweenInfo)
    tweenInfo = tweenInfo or TWEEN_INFO
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateElement(className, properties)
    local element = Instance.new(className)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

local function CreateCorner(radius)
    radius = radius or 4
    return CreateElement("UICorner", {CornerRadius = UDim.new(0, radius)})
end

local function CreateStroke(color, thickness)
    return CreateElement("UIStroke", {
        Color = color or CurrentTheme.Border,
        Thickness = thickness or 1
    })
end

local function CreateIcon(parent, iconId, size)
    size = size or UDim2.new(0, 16, 0, 16)
    
    local icon = CreateElement("ImageLabel", {
        Name = "Icon",
        Parent = parent,
        BackgroundTransparency = 1,
        Size = size,
        ImageColor3 = CurrentTheme.Text,
        ScaleType = Enum.ScaleType.Fit
    })
    
    -- Handle different icon types
    if type(iconId) == "string" then
        if iconId:match("^rbxasset://") or iconId:match("^rbxassetid://") or iconId:match("^http") then
            icon.Image = iconId
        else
            -- Simple shape icons
            local shapes = {
                circle = "rbxasset://textures/ui/GuiImagePlaceholder.png",
                square = "rbxasset://textures/ui/GuiImagePlaceholder.png",
                triangle = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            }
            icon.Image = shapes[iconId:lower()] or "rbxasset://textures/ui/GuiImagePlaceholder.png"
        end
    elseif type(iconId) == "number" then
        icon.Image = "rbxassetid://" .. tostring(iconId)
    else
        icon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end
    
    return icon
end

local function SaveConfiguration()
    local success, result = pcall(function()
        return HttpService:JSONEncode(Configurations)
    end)
    
    if success then
        -- In a real implementation, you'd save to DataStore
        -- For now, we'll just store in memory
        _G[CONFIG_KEY] = result
    end
end

local function LoadConfiguration()
    local success, result = pcall(function()
        local data = _G[CONFIG_KEY]
        if data then
            return HttpService:JSONDecode(data)
        end
        return {}
    end)
    
    if success then
        Configurations = result or {}
    end
end

-- Main Window Class
local Window = {}
Window.__index = Window

function Window.new(options)
    local self = setmetatable({}, Window)
    
    -- Default options
    options = options or {}
    self.Title = options.Title or "UI Library"
    self.Size = options.Size or UDim2.new(0, 500, 0, 400)
    self.MinSize = options.MinSize or UDim2.new(0, 300, 0, 200)
    self.Theme = options.Theme or "Dark"
    self.Flags = options.Flags or {}
    
    -- Apply theme
    if Themes[self.Theme] then
        CurrentTheme = Themes[self.Theme]
    end
    
    -- Create UI elements
    self:CreateInterface()
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Load saved configurations
    LoadConfiguration()
    
    return self
end

function Window:CreateInterface()
    local screenGui = CreateElement("ScreenGui", {
        Name = "UILibrary",
        Parent = Players.LocalPlayer.PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    self.ScreenGui = screenGui
    
    -- Main frame
    local mainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        BackgroundColor3 = CurrentTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2),
        Size = self.Size,
        Active = true,
        Draggable = not MOBILE_DEVICE
    })
    
    CreateCorner(8).Parent = mainFrame
    CreateStroke(CurrentTheme.Border, 2).Parent = mainFrame
    
    -- Title bar
    local titleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    CreateCorner(8).Parent = titleBar
    
    -- Title text
    local titleText = CreateElement("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.SourceSansBold,
        TextColor3 = CurrentTheme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self.Title
    })
    
    -- Close button
    local closeButton = CreateElement("TextButton", {
        Name = "CloseButton",
        Parent = titleBar,
        BackgroundColor3 = CurrentTheme.Error,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -35, 0, 5),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.SourceSansBold,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Text = "×"
    })
    
    CreateCorner(4).Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Tab container
    local tabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Parent = mainFrame,
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 150, 1, -40)
    })
    
    CreateElement("UIListLayout", {
        Parent = tabContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 2)
    })
    
    -- Content area
    local contentArea = CreateElement("Frame", {
        Name = "ContentArea",
        Parent = mainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 40),
        Size = UDim2.new(1, -150, 1, -40)
    })
    
    self.MainFrame = mainFrame
    self.TabContainer = tabContainer
    self.ContentArea = contentArea
    
    -- Mobile adaptations
    if MOBILE_DEVICE then
        self:SetupMobileControls()
    end
end

function Window:SetupMobileControls()
    -- Make draggable on mobile
    local dragToggle = nil
    local dragSpeed = 0.25
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        self.MainFrame.Position = position
    end
    
    self.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragToggle then
            updateInput(input)
        end
    end)
end

function Window:CreateTab(name, icon)
    local tab = Tab.new(self, name, icon)
    table.insert(self.Tabs, tab)
    
    if not self.CurrentTab then
        self:SetCurrentTab(tab)
    end
    
    return tab
end

function Window:SetCurrentTab(tab)
    -- Hide all tabs
    for _, t in pairs(self.Tabs) do
        t.Content.Visible = false
        t.Button.BackgroundColor3 = CurrentTheme.Accent
    end
    
    -- Show selected tab
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = CurrentTheme.Secondary
    self.CurrentTab = tab
end

function Window:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        self:RefreshTheme()
    end
end

function Window:RefreshTheme()
    -- Update all UI elements with new theme
    -- This is a simplified implementation
    self.MainFrame.BackgroundColor3 = CurrentTheme.Background
end

function Window:Destroy()
    SaveConfiguration()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Tab.new(window, name, icon)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Name = name
    self.Icon = icon
    self.Sections = {}
    
    self:CreateInterface()
    
    return self
end

function Tab:CreateInterface()
    -- Tab button
    local tabButton = CreateElement("TextButton", {
        Name = "TabButton",
        Parent = self.Window.TabContainer,
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.SourceSans,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        Text = self.Name
    })
    
    CreateCorner(4).Parent = tabButton
    
    -- Tab content
    local tabContent = CreateElement("ScrollingFrame", {
        Name = "TabContent",
        Parent = self.Window.ContentArea,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        Visible = false
    })
    
    CreateElement("UIListLayout", {
        Parent = tabContent,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 5)
    })
    
    -- Auto-resize canvas
    local layout = tabContent.UIListLayout
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    self.Button = tabButton
    self.Content = tabContent
    
    -- Click handler
    tabButton.MouseButton1Click:Connect(function()
        self.Window:SetCurrentTab(self)
    end)
    
    -- Icon
    if self.Icon then
        CreateIcon(tabButton, self.Icon, UDim2.new(0, 20, 0, 20))
    end
end

function Tab:CreateSection(title)
    local section = Section.new(self, title)
    table.insert(self.Sections, section)
    return section
end

-- Section Class
local Section = {}
Section.__index = Section

function Section.new(tab, title)
    local self = setmetatable({}, Section)
    
    self.Tab = tab
    self.Title = title
    self.Elements = {}
    
    self:CreateInterface()
    
    return self
end

function Section:CreateInterface()
    local sectionFrame = CreateElement("Frame", {
        Name = "Section",
        Parent = self.Tab.Content,
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40) -- Will auto-resize
    })
    
    CreateCorner(6).Parent = sectionFrame
    CreateStroke(CurrentTheme.Border).Parent = sectionFrame
    
    -- Title
    local titleLabel = CreateElement("TextLabel", {
        Name = "Title",
        Parent = sectionFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 25),
        Font = Enum.Font.SourceSansBold,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self.Title
    })
    
    -- Content container
    local contentContainer = CreateElement("Frame", {
        Name = "Content",
        Parent = sectionFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 30),
        Size = UDim2.new(1, -20, 1, -35)
    })
    
    CreateElement("UIListLayout", {
        Parent = contentContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 5)
    })
    
    self.Frame = sectionFrame
    self.Content = contentContainer
    
    -- Auto-resize section
    local layout = contentContainer.UIListLayout
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sectionFrame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 40)
    end)
end

function Section:CreateButton(options)
    return Button.new(self, options)
end

function Section:CreateToggle(options)
    return Toggle.new(self, options)
end

function Section:CreateSlider(options)
    return Slider.new(self, options)
end

function Section:CreateDropdown(options)
    return Dropdown.new(self, options)
end

-- Button Class
local Button = {}
Button.__index = Button

function Button.new(section, options)
    local self = setmetatable({}, Button)
    
    options = options or {}
    self.Section = section
    self.Name = options.Name or "Button"
    self.Callback = options.Callback or function() end
    self.Enabled = options.Enabled ~= false
    
    self:CreateInterface()
    
    return self
end

function Button:CreateInterface()
    local buttonFrame = CreateElement("TextButton", {
        Name = "Button",
        Parent = self.Section.Content,
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        Font = Enum.Font.SourceSans,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        Text = self.Name
    })
    
    CreateCorner(4).Parent = buttonFrame
    CreateStroke(CurrentTheme.Border).Parent = buttonFrame
    
    self.Frame = buttonFrame
    
    -- Click handler
    buttonFrame.MouseButton1Click:Connect(function()
        if self.Enabled then
            CreateTween(buttonFrame, {BackgroundColor3 = CurrentTheme.Success}, FAST_TWEEN)
            wait(0.1)
            CreateTween(buttonFrame, {BackgroundColor3 = CurrentTheme.Accent}, FAST_TWEEN)
            self.Callback()
        end
    end)
    
    -- Hover effects
    buttonFrame.MouseEnter:Connect(function()
        if self.Enabled then
            CreateTween(buttonFrame, {BackgroundColor3 = CurrentTheme.Border}, FAST_TWEEN)
        end
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        if self.Enabled then
            CreateTween(buttonFrame, {BackgroundColor3 = CurrentTheme.Accent}, FAST_TWEEN)
        end
    end)
end

function Button:SetEnabled(enabled)
    self.Enabled = enabled
    self.Frame.BackgroundColor3 = enabled and CurrentTheme.Accent or CurrentTheme.TextDim
end

function Button:Destroy()
    if self.Frame then
        self.Frame:Destroy()
    end
end

-- Toggle Class
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(section, options)
    local self = setmetatable({}, Toggle)
    
    options = options or {}
    self.Section = section
    self.Name = options.Name or "Toggle"
    self.Flag = options.Flag
    self.Default = options.Default or false
    self.Callback = options.Callback or function() end
    
    self.Value = self.Default
    
    self:CreateInterface()
    self:LoadValue()
    
    return self
end

function Toggle:CreateInterface()
    local toggleFrame = CreateElement("Frame", {
        Name = "Toggle",
        Parent = self.Section.Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    -- Label
    local label = CreateElement("TextLabel", {
        Name = "Label",
        Parent = toggleFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.SourceSans,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self.Name
    })
    
    -- Toggle button
    local toggleButton = CreateElement("TextButton", {
        Name = "ToggleButton",
        Parent = toggleFrame,
        BackgroundColor3 = self.Value and CurrentTheme.Success or CurrentTheme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -40, 0, 5),
        Size = UDim2.new(0, 35, 0, 25),
        Text = ""
    })
    
    CreateCorner(12).Parent = toggleButton
    CreateStroke(CurrentTheme.Border).Parent = toggleButton
    
    -- Toggle indicator
    local indicator = CreateElement("Frame", {
        Name = "Indicator",
        Parent = toggleButton,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = self.Value and UDim2.new(0, 15, 0, 3) or UDim2.new(0, 3, 0, 3),
        Size = UDim2.new(0, 19, 0, 19)
    })
    
    CreateCorner(10).Parent = indicator
    
    self.Frame = toggleFrame
    self.Button = toggleButton
    self.Indicator = indicator
    
    -- Click handler
    toggleButton.MouseButton1Click:Connect(function()
        self:SetValue(not self.Value)
    end)
end

function Toggle:SetValue(value)
    self.Value = value
    
    local color = value and CurrentTheme.Success or CurrentTheme.Accent
    local position = value and UDim2.new(0, 15, 0, 3) or UDim2.new(0, 3, 0, 3)
    
    CreateTween(self.Fill, {Size = UDim2.new(percentage, 0, 1, 0)})
    CreateTween(self.Handle, {Position = UDim2.new(percentage, -6, 0, -3)})
    
    self.ValueLabel.Text = tostring(self.Value)
end

function Slider:SaveValue()
    if self.Flag then
        Configurations[self.Flag] = self.Value
        SaveConfiguration()
    end
end

function Slider:LoadValue()
    if self.Flag and Configurations[self.Flag] ~= nil then
        self:SetValue(Configurations[self.Flag])
    end
end

function Slider:Destroy()
    if self.Frame then
        self.Frame:Destroy()
    end
end

-- Dropdown Class
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(section, options)
    local self = setmetatable({}, Dropdown)
    
    options = options or {}
    self.Section = section
    self.Name = options.Name or "Dropdown"
    self.Options = options.Options or {"Option 1", "Option 2", "Option 3"}
    self.Default = options.Default or self.Options[1]
    self.Flag = options.Flag
    self.Callback = options.Callback or function() end
    
    self.Value = self.Default
    self.IsOpen = false
    
    self:CreateInterface()
    self:LoadValue()
    
    return self
end

function Dropdown:CreateInterface()
    local dropdownFrame = CreateElement("Frame", {
        Name = "Dropdown",
        Parent = self.Section.Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    -- Label
    local label = CreateElement("TextLabel", {
        Name = "Label",
        Parent = dropdownFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        Font = Enum.Font.SourceSans,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self.Name
    })
    
    -- Dropdown button
    local dropdownButton = CreateElement("TextButton", {
        Name = "DropdownButton",
        Parent = dropdownFrame,
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0.4, 5, 0, 0),
        Size = UDim2.new(0.6, -5, 1, 0),
        Font = Enum.Font.SourceSans,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        Text = self.Value
    })
    
    CreateCorner(4).Parent = dropdownButton
    CreateStroke(CurrentTheme.Border).Parent = dropdownButton
    
    -- Dropdown arrow
    local arrow = CreateElement("TextLabel", {
        Name = "Arrow",
        Parent = dropdownButton,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Font = Enum.Font.SourceSans,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        Text = "▼"
    })
    
    -- Options container
    local optionsContainer = CreateElement("Frame", {
        Name = "OptionsContainer",
        Parent = dropdownFrame,
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.4, 5, 1, 2),
        Size = UDim2.new(0.6, -5, 0, #self.Options * 30),
        Visible = false,
        ZIndex = 10
    })
    
    CreateCorner(4).Parent = optionsContainer
    CreateStroke(CurrentTheme.Border).Parent = optionsContainer
    
    CreateElement("UIListLayout", {
        Parent = optionsContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })
    
    self.Frame = dropdownFrame
    self.Button = dropdownButton
    self.Arrow = arrow
    self.OptionsContainer = optionsContainer
    
    -- Create option buttons
    for _, option in ipairs(self.Options) do
        local optionButton = CreateElement("TextButton", {
            Name = "Option",
            Parent = optionsContainer,
            BackgroundColor3 = CurrentTheme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.SourceSans,
            TextColor3 = CurrentTheme.Text,
            TextSize = 14,
            Text = option
        })
        
        -- Option hover effect
        optionButton.MouseEnter:Connect(function()
            CreateTween(optionButton, {BackgroundColor3 = CurrentTheme.Accent}, FAST_TWEEN)
        end)
        
        optionButton.MouseLeave:Connect(function()
            CreateTween(optionButton, {BackgroundColor3 = CurrentTheme.Secondary}, FAST_TWEEN)
        end)
        
        -- Option click handler
        optionButton.MouseButton1Click:Connect(function()
            self:SetValue(option)
            self:Close()
        end)
    end
    
    -- Main button click handler
    dropdownButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Close dropdown when clicking outside
    game:GetService("RunService").Heartbeat:Connect(function()
        if self.IsOpen then
            local mouse = Players.LocalPlayer:GetMouse()
            local mousePos = Vector2.new(mouse.X, mouse.Y)
            local containerPos = optionsContainer.AbsolutePosition
            local containerSize = optionsContainer.AbsoluteSize
            
            if mousePos.X < containerPos.X or mousePos.X > containerPos.X + containerSize.X or
               mousePos.Y < containerPos.Y or mousePos.Y > containerPos.Y + containerSize.Y then
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    self:Close()
                end
            end
        end
    end)
end

function Dropdown:SetValue(value)
    if table.find(self.Options, value) then
        self.Value = value
        self.Button.Text = value
        self:SaveValue()
        self.Callback(value)
    end
end

function Dropdown:Toggle()
    if self.IsOpen then
        self:Close()
    else
        self:Open()
    end
end

function Dropdown:Open()
    self.IsOpen = true
    self.OptionsContainer.Visible = true
    CreateTween(self.Arrow, {Rotation = 180}, FAST_TWEEN)
    
    -- Animate options container
    local targetSize = UDim2.new(0.6, -5, 0, #self.Options * 30)
    self.OptionsContainer.Size = UDim2.new(0.6, -5, 0, 0)
    CreateTween(self.OptionsContainer, {Size = targetSize})
    
    -- Update parent section size
    self.Frame.Size = UDim2.new(1, 0, 0, 35 + #self.Options * 30 + 5)
end

function Dropdown:Close()
    self.IsOpen = false
    CreateTween(self.Arrow, {Rotation = 0}, FAST_TWEEN)
    CreateTween(self.OptionsContainer, {Size = UDim2.new(0.6, -5, 0, 0)})
    
    wait(0.2)
    self.OptionsContainer.Visible = false
    self.Frame.Size = UDim2.new(1, 0, 0, 35)
end

function Dropdown:AddOption(option)
    if not table.find(self.Options, option) then
        table.insert(self.Options, option)
        self:RefreshOptions()
    end
end

function Dropdown:RemoveOption(option)
    local index = table.find(self.Options, option)
    if index then
        table.remove(self.Options, index)
        if self.Value == option then
            self:SetValue(self.Options[1] or "")
        end
        self:RefreshOptions()
    end
end

function Dropdown:RefreshOptions()
    -- Clear existing options
    for _, child in pairs(self.OptionsContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Recreate options
    for _, option in ipairs(self.Options) do
        local optionButton = CreateElement("TextButton", {
            Name = "Option",
            Parent = self.OptionsContainer,
            BackgroundColor3 = CurrentTheme.Secondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.SourceSans,
            TextColor3 = CurrentTheme.Text,
            TextSize = 14,
            Text = option
        })
        
        optionButton.MouseEnter:Connect(function()
            CreateTween(optionButton, {BackgroundColor3 = CurrentTheme.Accent}, FAST_TWEEN)
        end)
        
        optionButton.MouseLeave:Connect(function()
            CreateTween(optionButton, {BackgroundColor3 = CurrentTheme.Secondary}, FAST_TWEEN)
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            self:SetValue(option)
            self:Close()
        end)
    end
end

function Dropdown:SaveValue()
    if self.Flag then
        Configurations[self.Flag] = self.Value
        SaveConfiguration()
    end
end

function Dropdown:LoadValue()
    if self.Flag and Configurations[self.Flag] ~= nil then
        self:SetValue(Configurations[self.Flag])
    end
end

function Dropdown:Destroy()
    if self.Frame then
        self.Frame:Destroy()
    end
end

-- Main UI Module Functions
function UI.CreateWindow(options)
    return Window.new(options)
end

function UI.SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
    end
end

function UI.AddTheme(name, theme)
    Themes[name] = theme
end

function UI.GetThemes()
    return Themes
end

function UI.SaveConfig()
    SaveConfiguration()
end

function UI.LoadConfig()
    LoadConfiguration()
end

-- Initialize
LoadConfiguration()

return UIButton, {BackgroundColor3 = color})
    CreateTween(self.Indicator, {Position = position})
    
    self:SaveValue()
    self.Callback(value)
end

function Toggle:SaveValue()
    if self.Flag then
        Configurations[self.Flag] = self.Value
        SaveConfiguration()
    end
end

function Toggle:LoadValue()
    if self.Flag and Configurations[self.Flag] ~= nil then
        self:SetValue(Configurations[self.Flag])
    end
end

function Toggle:Destroy()
    if self.Frame then
        self.Frame:Destroy()
    end
end

-- Slider Class
local Slider = {}
Slider.__index = Slider

function Slider.new(section, options)
    local self = setmetatable({}, Slider)
    
    options = options or {}
    self.Section = section
    self.Name = options.Name or "Slider"
    self.Min = options.Min or 0
    self.Max = options.Max or 100
    self.Default = options.Default or self.Min
    self.Increment = options.Increment or 1
    self.Flag = options.Flag
    self.Callback = options.Callback or function() end
    
    self.Value = self.Default
    
    self:CreateInterface()
    self:LoadValue()
    
    return self
end

function Slider:CreateInterface()
    local sliderFrame = CreateElement("Frame", {
        Name = "Slider",
        Parent = self.Section.Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50)
    })
    
    -- Label
    local label = CreateElement("TextLabel", {
        Name = "Label",
        Parent = sliderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -50, 0, 20),
        Font = Enum.Font.SourceSans,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = self.Name
    })
    
    -- Value display
    local valueLabel = CreateElement("TextLabel", {
        Name = "ValueLabel",
        Parent = sliderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 0),
        Size = UDim2.new(0, 50, 0, 20),
        Font = Enum.Font.SourceSans,
        TextColor3 = CurrentTheme.TextDim,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(self.Value)
    })
    
    -- Slider track
    local track = CreateElement("Frame", {
        Name = "Track",
        Parent = sliderFrame,
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(1, 0, 0, 6)
    })
    
    CreateCorner(3).Parent = track
    
    -- Slider fill
    local fill = CreateElement("Frame", {
        Name = "Fill",
        Parent = track,
        BackgroundColor3 = CurrentTheme.Success,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 1, 0)
    })
    
    CreateCorner(3).Parent = fill
    
    -- Slider handle
    local handle = CreateElement("Frame", {
        Name = "Handle",
        Parent = track,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, -6, 0, -3),
        Size = UDim2.new(0, 12, 0, 12)
    })
    
    CreateCorner(6).Parent = handle
    CreateStroke(CurrentTheme.Border).Parent = handle
    
    self.Frame = sliderFrame
    self.Track = track
    self.Fill = fill
    self.Handle = handle
    self.ValueLabel = valueLabel
    
    -- Mouse/Touch input
    local dragging = false
    
    local function updateSlider(input)
        local trackPos = track.AbsolutePosition
        local trackSize = track.AbsoluteSize
        local mousePos = input.Position
        
        local relativePos = (mousePos.X - trackPos.X) / trackSize.X
        relativePos = math.clamp(relativePos, 0, 1)
        
        local newValue = self.Min + (self.Max - self.Min) * relativePos
        newValue = math.floor(newValue / self.Increment) * self.Increment
        newValue = math.clamp(newValue, self.Min, self.Max)
        
        self:SetValue(newValue)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    self:UpdateDisplay()
end

function Slider:SetValue(value)
    self.Value = math.clamp(value, self.Min, self.Max)
    self:UpdateDisplay()
    self:SaveValue()
    self.Callback(self.Value)
end

function Slider:UpdateDisplay()
    local percentage = (self.Value - self.Min) / (self.Max - self.Min)
    
    -- Update fill bar
    CreateTween(self.Fill, {Size = UDim2.new(percentage, 0, 1, 0)})
    
    -- Update handle position
    CreateTween(self.Handle, {Position = UDim2.new(percentage, -6, 0, -3)})
    
    -- Update value label
    self.ValueLabel.Text = tostring(self.Value)
end

function Slider:SaveValue()
    if self.Flag then
        Configurations[self.Flag] = self.Value
        SaveConfiguration()
    end
end

function Slider:LoadValue()
    if self.Flag and Configurations[self.Flag] ~= nil then
        self:SetValue(Configurations[self.Flag])
    end
end

function Slider:Destroy()
    if self.Frame then
        self.Frame:Destroy()
    end
end

-- Main UI Module Functions
function UI.CreateWindow(options)
    return Window.new(options)
end

function UI.SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
    end
end

function UI.AddTheme(name, theme)
    Themes[name] = theme
end

function UI.GetThemes()
    return Themes
end

function UI.SaveConfig()
    SaveConfiguration()
end

function UI.LoadConfig()
    LoadConfiguration()
end

-- Initialize
LoadConfiguration()

return UI
