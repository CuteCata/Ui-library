-- ================================
-- ASTDX Custom UI Library - Part 1
-- Core Structure & Main Components
-- ================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Main Library Table
local UILibrary = {}
UILibrary.__index = UILibrary

-- Color Scheme (Modern Dark Theme)
local Colors = {
    Primary = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(35, 35, 45),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentHover = Color3.fromRGB(108, 121, 255),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(185, 187, 190),
    TextMuted = Color3.fromRGB(114, 118, 125),
    Border = Color3.fromRGB(45, 45, 55),
    Background = Color3.fromRGB(15, 15, 20),
    Card = Color3.fromRGB(30, 30, 40),
    Hover = Color3.fromRGB(40, 40, 50)
}

-- Animation Settings
local AnimationSpeed = 0.25
local EasingStyle = Enum.EasingStyle.Quad
local EasingDirection = Enum.EasingDirection.Out

-- Utility Functions
local function CreateTween(object, properties, duration, style, direction)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or AnimationSpeed, style or EasingStyle, direction or EasingDirection),
        properties
    )
    return tween
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function CreateGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

-- Main Window Creation
function UILibrary:CreateWindow(config)
    config = config or {}
    
    local WindowData = {
        Name = config.Name or "ASTDX Hub",
        Size = config.Size or UDim2.new(0, 580, 0, 420),
        Position = config.Position or UDim2.new(0.5, -290, 0.5, -210),
        Tabs = {},
        CurrentTab = nil,
        Draggable = config.Draggable ~= false,
        Resizable = config.Resizable or false,
        Theme = config.Theme or "Dark"
    }
    
    -- Create Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ASTDXHub"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = WindowData.Size
    MainFrame.Position = WindowData.Position
    MainFrame.BackgroundColor3 = Colors.Primary
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.ClipsDescendants = true
    
    CreateCorner(MainFrame, 12)
    CreateStroke(MainFrame, Colors.Border, 1)
    
    -- Shadow Effect
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.8
    Shadow.BorderSizePixel = 0
    Shadow.ZIndex = MainFrame.ZIndex - 1
    Shadow.Parent = MainFrame
    
    CreateCorner(Shadow, 12)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Colors.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    CreateCorner(TitleBar, 12)
    
    -- Title Bar Gradient
    CreateGradient(TitleBar, {
        Colors.Secondary,
        Colors.Primary
    }, 90)
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.Size = UDim2.new(1, -100, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = WindowData.Name
    TitleText.TextColor3 = Colors.Text
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 7.5)
    CloseButton.BackgroundColor3 = Colors.Error
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Colors.Text
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    CreateCorner(CloseButton, 6)
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -75, 0, 7.5)
    MinimizeButton.BackgroundColor3 = Colors.Warning
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Colors.Text
    MinimizeButton.TextSize = 16
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = TitleBar
    
    CreateCorner(MinimizeButton, 6)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, -45)
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = Colors.Card
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    -- Tab List
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, -10, 1, -10)
    TabList.Position = UDim2.new(0, 5, 0, 5)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 3
    TabList.ScrollBarImageColor3 = Colors.Accent
    TabList.BorderSizePixel = 0
    TabList.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabList
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -150, 1, -45)
    ContentContainer.Position = UDim2.new(0, 150, 0, 45)
    ContentContainer.BackgroundColor3 = Colors.Background
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    -- Store references
    WindowData.ScreenGui = ScreenGui
    WindowData.MainFrame = MainFrame
    WindowData.TabContainer = TabContainer
    WindowData.TabList = TabList
    WindowData.ContentContainer = ContentContainer
    WindowData.TitleText = TitleText
    
    return WindowData
end

-- Return the library
return UILibrary