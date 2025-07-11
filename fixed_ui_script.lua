-- ตรวจสอบว่า HttpService พร้อมใช้งาน
local success, HttpService = pcall(function()
    return game:GetService("HttpService")
end)

if not success then
    warn("HttpService ไม่พร้อมใช้งาน")
    return
end

-- สร้าง UI Library แบบ Local (ไม่ต้องใช้ HttpGet)
local UI = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ตรวจสอบว่าเป็นอุปกรณ์มือถือ
local MOBILE_DEVICE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FAST_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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

-- Window Class
local Window = {}
Window.__index = Window

function Window.new(options)
    local self = setmetatable({}, Window)
    
    options = options or {}
    self.Title = options.Title or "UI Library"
    self.Size = options.Size or UDim2.new(0, 500, 0, 400)
    self.Theme = options.Theme or "Dark"
    
    self:CreateInterface()
    self.Tabs = {}
    self.CurrentTab = nil
    
    return self
end

function Window:CreateInterface()
    -- สร้าง ScreenGui
    local screenGui = CreateElement("ScreenGui", {
        Name = "UILibrary",
        Parent = game.Players.LocalPlayer.PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    self.ScreenGui = screenGui
    
    -- Main Frame
    local mainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        BackgroundColor3 = CurrentTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2),
        Size = self.Size,
        Active = true
    })
    
    CreateCorner(8).Parent = mainFrame
    
    -- ปรับแต่งสำหรับมือถือ
    if MOBILE_DEVICE then
        mainFrame.Size = UDim2.new(0.95, 0, 0.8, 0)
        mainFrame.Position = UDim2.new(0.025, 0, 0.1, 0)
        self:SetupMobileControls(mainFrame)
    else
        mainFrame.Draggable = true
    end
    
    -- Title Bar
    local titleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    CreateCorner(8).Parent = titleBar
    
    -- Title Text
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
    
    -- Close Button
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
    
    -- Tab Container
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
    
    -- Content Area
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
end

function Window:SetupMobileControls(frame)
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        if dragToggle then
            local delta = input.Position - dragStart
            local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            frame.Position = position
        end
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
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
    for _, t in pairs(self.Tabs) do
        t.Content.Visible = false
        t.Button.BackgroundColor3 = CurrentTheme.Accent
    end
    
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = CurrentTheme.Secondary
    self.CurrentTab = tab
end

function Window:Destroy()
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
    -- Tab Button
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
    
    -- Tab Content
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
    
    tabButton.MouseButton1Click:Connect(function()
        self.Window:SetCurrentTab(self)
    end)
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
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    CreateCorner(6).Parent = sectionFrame
    
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
    
    -- Content Container
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

function Section:CreateSlider(options)
    return Slider.new(self, options)
end

function Section:CreateToggle(options)
    return Toggle.new(self, options)
end

function Section:CreateDropdown(options)
    return Dropdown.new(self, options)
end

function Section:CreateButton(options)
    return Button.new(self, options)
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
    self.Flag = options.Flag
    self.Callback = options.Callback or function() end
    
    self.Value = self.Default
    
    self:CreateInterface()
    
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
    
    -- Value Label
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
    
    -- Track
    local track = CreateElement("Frame", {
        Name = "Track",
        Parent = sliderFrame,
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(1, 0, 0, 6)
    })
    
    CreateCorner(3).Parent = track
    
    -- Fill
    local fill = CreateElement("Frame", {
        Name = "Fill",
        Parent = track,
        BackgroundColor3 = CurrentTheme.Success,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 1, 0)
    })
    
    CreateCorner(3).Parent = fill
    
    -- Handle
    local handle = CreateElement("Frame", {
        Name = "Handle",
        Parent = track,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, -6, 0, -3),
        Size = UDim2.new(0, 12, 0, 12)
    })
    
    CreateCorner(6).Parent = handle
    
    self.Frame = sliderFrame
    self.Track = track
    self.Fill = fill
    self.Handle = handle
    self.ValueLabel = valueLabel
    
    -- Input Handling
    local dragging = false
    
    local function updateSlider(input)
        local trackPos = track.AbsolutePosition
        local trackSize = track.AbsoluteSize
        local mousePos = input.Position
        
        local relativePos = (mousePos.X - trackPos.X) / trackSize.X
        relativePos = math.clamp(relativePos, 0, 1)
        
        local newValue = self.Min + (self.Max - self.Min) * relativePos
        newValue = math.floor(newValue + 0.5)
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
    self.Callback(self.Value)
end

function Slider:UpdateDisplay()
    local percentage = (self.Value - self.Min) / (self.Max - self.Min)
    
    CreateTween(self.Fill, {Size = UDim2.new(percentage, 0, 1, 0)})
    CreateTween(self.Handle, {Position = UDim2.new(percentage, -6, 0, -3)})
    self.ValueLabel.Text = tostring(self.Value)
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
    
    -- Toggle Button
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
    
    -- Indicator
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
    
    toggleButton.MouseButton1Click:Connect(function()
        self:SetValue(not self.Value)
    end)
end

function Toggle:SetValue(value)
    self.Value = value
    
    local color = value and CurrentTheme.Success or CurrentTheme.Accent
    local position = value and UDim2.new(0, 15, 0, 3) or UDim2.new(0, 3, 0, 3)
    
    CreateTween(self.Button, {BackgroundColor3 = color})
    CreateTween(self.Indicator, {Position = position})
    
    self.Callback(value)
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
    
    -- Dropdown Button
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
    
    -- Options Container
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
    
    CreateElement("UIListLayout", {
        Parent = optionsContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })
    
    self.Frame = dropdownFrame
    self.Button = dropdownButton
    self.OptionsContainer = optionsContainer
    
    -- Create options
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
        
        optionButton.MouseButton1Click:Connect(function()
            self:SetValue(option)
            self:Close()
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
end

function Dropdown:SetValue(value)
    if table.find(self.Options, value) then
        self.Value = value
        self.Button.Text = value
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
    self.Frame.Size = UDim2.new(1, 0, 0, 35 + #self.Options * 30 + 5)
end

function Dropdown:Close()
    self.IsOpen = false
    self.OptionsContainer.Visible = false
    self.Frame.Size = UDim2.new(1, 0, 0, 35)
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
    
    self.Frame = buttonFrame
    
    buttonFrame.MouseButton1Click:Connect(function()
        CreateTween(buttonFrame, {BackgroundColor3 = CurrentTheme.Success}, FAST_TWEEN)
        wait(0.1)
        CreateTween(buttonFrame, {BackgroundColor3 = CurrentTheme.Accent}, FAST_TWEEN)
        self.Callback()
    end)
end

-- Main UI Functions
function UI.CreateWindow(options)
    return Window.new(options)
end

-- สร้าง UI ตัวอย่าง
local window = UI.CreateWindow({
    Title = "การตั้งค่าเกม",
    Size = UDim2.new(0, 550, 0, 450),
    Theme = "Dark"
})

-- แท็บหลัก
local mainTab = window:CreateTab("หลัก")
local playerSection = mainTab:CreateSection("การตั้งค่าผู้เล่น")

-- ตรวจสอบว่าตัวละครพร้อมใช้งาน
local function getCharacter()
    local player = Players.LocalPlayer
    return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
    local character = getCharacter()
    return character:FindFirstChild("Humanoid")
end

-- ส่วนที่ขาดหายไปจากสคริปต์ต้นฉบับ
-- ใส่ต่อจาก local speedSlider = playerSection:CreateSl

local speedSlider = playerSection:CreateSlider({
    Name = "ความเร็วเดิน",
    Min = 1,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        -- ตรวจสอบว่าตัวละครและ Humanoid มีอยู่จริง
        pcall(function()
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end)
    end
})

-- สร้าง Slider สำหรับแรงกระโดด
local jumpSlider = playerSection:CreateSlider({
    Name = "แรงกระโดด",
    Min = 7,
    Max = 200,
    Default = 50,
    Flag = "JumpPower",
    Callback = function(value)
        pcall(function()
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.JumpPower = value
            end
        end)
    end
})

-- สร้าง Toggle สำหรับ Infinite Jump
local infJumpToggle = playerSection:CreateToggle({
    Name = "กระโดดไม่จำกัด",
    Default = false,
    Flag = "InfiniteJump",
    Callback = function(value)
        getgenv().InfiniteJump = value
    end
})

-- สร้าง Toggle สำหรับ Noclip
local noclipToggle = playerSection:CreateToggle({
    Name = "เดินทะลุกำแพง",
    Default = false,
    Flag = "Noclip",
    Callback = function(value)
        getgenv().Noclip = value
    end
})

-- สร้าง Toggle สำหรับ Fly
local flyToggle = playerSection:CreateToggle({
    Name = "บิน",
    Default = false,
    Flag = "Fly",
    Callback = function(value)
        getgenv().Flying = value
        if value then
            -- เปิดใช้งานการบิน
            spawn(function()
                local character = getCharacter()
                local humanoid = getHumanoid()
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.Parent = rootPart
                    
                    getgenv().FlyBodyVelocity = bodyVelocity
                end
            end)
        else
            -- ปิดใช้งานการบิน
            if getgenv().FlyBodyVelocity then
                getgenv().FlyBodyVelocity:Destroy()
                getgenv().FlyBodyVelocity = nil
            end
        end
    end
})

-- แท็บอื่นๆ
local visualTab = window:CreateTab("ภาพ")
local visualSection = visualTab:CreateSection("การตั้งค่าภาพ")

-- ESP Toggle
local espToggle = visualSection:CreateToggle({
    Name = "ESP ผู้เล่น",
    Default = false,
    Flag = "PlayerESP",
    Callback = function(value)
        getgenv().PlayerESP = value
    end
})

-- Fullbright Toggle
local fullbrightToggle = visualSection:CreateToggle({
    Name = "ความสว่างเต็ม",
    Default = false,
    Flag = "Fullbright",
    Callback = function(value)
        if value then
            game.Lighting.Brightness = 2
            game.Lighting.ClockTime = 14
            game.Lighting.FogEnd = 100000
            game.Lighting.GlobalShadows = false
            game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            game.Lighting.Brightness = 1
            game.Lighting.ClockTime = 12
            game.Lighting.FogEnd = 100000
            game.Lighting.GlobalShadows = true
            game.Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end
    end
})

-- แท็บอื่นๆ
local miscTab = window:CreateTab("อื่นๆ")
local miscSection = miscTab:CreateSection("เครื่องมือเสริม")

-- Teleport Button
local tpButton = miscSection:CreateButton({
    Name = "เทเลพอร์ตไปยังจุดเกิด",
    Callback = function()
        pcall(function()
            local character = getCharacter()
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(0, 50, 0)
            end
        end)
    end
})

-- Reset Button
local resetButton = miscSection:CreateButton({
    Name = "รีเซ็ตตัวละคร",
    Callback = function()
        pcall(function()
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.Health = 0
            end
        end)
    end
})

-- การจัดการ Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfiniteJump then
        pcall(function()
            local humanoid = getHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- การจัดการ Noclip
RunService.Stepped:Connect(function()
    if getgenv().Noclip then
        pcall(function()
            local character = getCharacter()
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- การจัดการ Fly
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if getgenv().Flying and getgenv().FlyBodyVelocity then
        local camera = workspace.CurrentCamera
        local moveVector = Vector3.new(0, 0, 0)
        
        if input.KeyCode == Enum.KeyCode.W then
            moveVector = moveVector + camera.CFrame.LookVector
        elseif input.KeyCode == Enum.KeyCode.S then
            moveVector = moveVector - camera.CFrame.LookVector
        elseif input.KeyCode == Enum.KeyCode.A then
            moveVector = moveVector - camera.CFrame.RightVector
        elseif input.KeyCode == Enum.KeyCode.D then
            moveVector = moveVector + camera.CFrame.RightVector
        elseif input.KeyCode == Enum.KeyCode.Space then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end
        
        getgenv().FlyBodyVelocity.Velocity = moveVector * 50
    end
end)

-- การจัดการ ESP
local function createESP()
    if not getgenv().PlayerESP then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            
            if not rootPart:FindFirstChild("ESP") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP"
                billboard.Parent = rootPart
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                
                local frame = Instance.new("Frame")
                frame.Parent = billboard
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundTransparency = 1
                frame.BorderSizePixel = 0
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = frame
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.SourceSansBold
                
                local distanceLabel = Instance.new("TextLabel")
                distanceLabel.Parent = frame
                distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                distanceLabel.BackgroundTransparency = 1
                distanceLabel.Text = "0 studs"
                distanceLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
                distanceLabel.TextScaled = true
                distanceLabel.Font = Enum.Font.SourceSans
                
                -- อัพเดตระยะทาง
                spawn(function()
                    while billboard.Parent and getgenv().PlayerESP do
                        pcall(function()
                            local localChar = Players.LocalPlayer.Character
                            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                                local distance = (localChar.HumanoidRootPart.Position - rootPart.Position).Magnitude
                                distanceLabel.Text = math.floor(distance) .. " studs"
                            end
                        end)
                        wait(0.1)
                    end
                end)
            end
        end
    end
end

-- อัพเดต ESP
RunService.Heartbeat:Connect(function()
    if getgenv().PlayerESP then
        createESP()
    else
        -- ลบ ESP ทั้งหมด
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local esp = player.Character.HumanoidRootPart:FindFirstChild("ESP")
                if esp then
                    esp:Destroy()
                end
            end
        end
    end
end)

-- ปิด UI เมื่อผู้เล่นออกจากเกม
Players.LocalPlayer.CharacterRemoving:Connect(function()
    if window then
        window:Destroy()
    end
end)

print("UI สำเร็จแล้ว! ใช้งานได้บนอุปกรณ์มือถือ")