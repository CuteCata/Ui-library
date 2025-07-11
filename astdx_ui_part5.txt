-- ================================
-- ASTDX Custom UI Library - Part 5
-- Additional Components & Window Controls
-- ================================

-- TextBox Creation Function
function UILibrary:CreateTextBox(tab, config)
    config = config or {}
    
    local TextBoxData = {
        Name = config.Name or "TextBox",
        CurrentValue = config.CurrentValue or "",
        PlaceholderText = config.PlaceholderText or "Enter text...",
        Callback = config.Callback or function() end,
        Tab = tab,
        Flag = config.Flag or "",
        ClearTextOnFocus = config.ClearTextOnFocus or false,
        TextDisappear = config.TextDisappear or false
    }
    
    -- TextBox Frame
    local TextBoxFrame = Instance.new("Frame")
    TextBoxFrame.Name = "TextBox_" .. TextBoxData.Name
    TextBoxFrame.Size = UDim2.new(1, 0, 0, 50)
    TextBoxFrame.BackgroundColor3 = Colors.Card
    TextBoxFrame.BorderSizePixel = 0
    TextBoxFrame.Parent = tab.Content
    
    CreateCorner(TextBoxFrame, 6)
    CreateStroke(TextBoxFrame, Colors.Border, 1)
    
    -- TextBox Label
    local TextBoxLabel = Instance.new("TextLabel")
    TextBoxLabel.Name = "Label"
    TextBoxLabel.Size = UDim2.new(1, -20, 0, 20)
    TextBoxLabel.Position = UDim2.new(0, 10, 0, 5)
    TextBoxLabel.BackgroundTransparency = 1
    TextBoxLabel.Text = TextBoxData.Name
    TextBoxLabel.TextColor3 = Colors.Text
    TextBoxLabel.TextSize = 12
    TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextBoxLabel.Font = Enum.Font.Gotham
    TextBoxLabel.Parent = TextBoxFrame
    
    -- TextBox Input
    local TextBoxInput = Instance.new("TextBox")
    TextBoxInput.Name = "Input"
    TextBoxInput.Size = UDim2.new(1, -20, 0, 20)
    TextBoxInput.Position = UDim2.new(0, 10, 0, 25)
    TextBoxInput.BackgroundColor3 = Colors.Secondary
    TextBoxInput.BorderSizePixel = 0
    TextBoxInput.Text = TextBoxData.CurrentValue
    TextBoxInput.PlaceholderText = TextBoxData.PlaceholderText
    TextBoxInput.TextColor3 = Colors.Text
    TextBoxInput.PlaceholderColor3 = Colors.TextMuted
    TextBoxInput.TextSize = 11
    TextBoxInput.TextXAlignment = Enum.TextXAlignment.Left
    TextBoxInput.Font = Enum.Font.Gotham
    TextBoxInput.ClearTextOnFocus = TextBoxData.ClearTextOnFocus
    TextBoxInput.Parent = TextBoxFrame
    
    CreateCorner(TextBoxInput, 4)
    CreateStroke(TextBoxInput, Colors.Border, 1)
    
    -- TextBox Padding
    local TextBoxPadding = Instance.new("UIPadding")
    TextBoxPadding.PaddingLeft = UDim.new(0, 8)
    TextBoxPadding.PaddingRight = UDim.new(0, 8)
    TextBoxPadding.Parent = TextBoxInput
    
    -- TextBox Focus Effects
    TextBoxInput.Focused:Connect(function()
        local focusTween = CreateTween(TextBoxInput, {
            BackgroundColor3 = Colors.Hover
        }, 0.15)
        focusTween:Play()
        
        local strokeTween = CreateTween(TextBoxInput.UIStroke, {
            Color = Colors.Accent
        }, 0.15)
        strokeTween:Play()
    end)
    
    TextBoxInput.FocusLost:Connect(function()
        local unfocusTween = CreateTween(TextBoxInput, {
            BackgroundColor3 = Colors.Secondary
        }, 0.15)
        unfocusTween:Play()
        
        local strokeTween = CreateTween(TextBoxInput.UIStroke, {
            Color = Colors.Border
        }, 0.15)
        strokeTween:Play()
        
        TextBoxData.CurrentValue = TextBoxInput.Text
        TextBoxData.Callback(TextBoxInput.Text)
        
        if TextBoxData.TextDisappear then
            wait(0.1)
            TextBoxInput.Text = ""
        end
    end)
    
    -- Store references
    TextBoxData.Frame = TextBoxFrame
    TextBoxData.Label = TextBoxLabel
    TextBoxData.Input = TextBoxInput
    
    -- Add to tab elements
    table.insert(tab.Elements, TextBoxData)
    
    -- Update tab content canvas size
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    
    return TextBoxData
end

-- Keybind Creation Function
function UILibrary:CreateKeybind(tab, config)
    config = config or {}
    
    local KeybindData = {
        Name = config.Name or "Keybind",
        CurrentKeybind = config.CurrentKeybind or "None",
        Callback = config.Callback or function() end,
        Tab = tab,
        Flag = config.Flag or "",
        HoldToInteract = config.HoldToInteract or false,
        IsBinding = false
    }
    
    -- Keybind Frame
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Name = "Keybind_" .. KeybindData.Name
    KeybindFrame.Size = UDim2.new(1, 0, 0, 40)
    KeybindFrame.BackgroundColor3 = Colors.Card
    KeybindFrame.BorderSizePixel = 0
    KeybindFrame.Parent = tab.Content
    
    CreateCorner(KeybindFrame, 6)
    CreateStroke(KeybindFrame, Colors.Border, 1)
    
    -- Keybind Label
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Name = "Label"
    KeybindLabel.Size = UDim2.new(1, -100, 1, 0)
    KeybindLabel.Position = UDim2.new(0, 15, 0, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = KeybindData.Name
    KeybindLabel.TextColor3 = Colors.Text
    KeybindLabel.TextSize = 12
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.Parent = KeybindFrame
    
    -- Keybind Button
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "Button"
    KeybindButton.Size = UDim2.new(0, 80, 0, 25)
    KeybindButton.Position = UDim2.new(1, -90, 0.5, -12.5)
    KeybindButton.BackgroundColor3 = Colors.Secondary
    KeybindButton.BorderSizePixel = 0
    KeybindButton.Text = KeybindData.CurrentKeybind
    KeybindButton.TextColor3 = Colors.Text
    KeybindButton.TextSize = 10
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.Parent = KeybindFrame
    
    CreateCorner(KeybindButton, 4)
    CreateStroke(KeybindButton, Colors.Border, 1)
    
    -- Keybind Functions
    local function UpdateKeybindText()
        if KeybindData.IsBinding then
            KeybindButton.Text = "..."
            KeybindButton.TextColor3 = Colors.Warning
        else
            KeybindButton.Text = KeybindData.CurrentKeybind
            KeybindButton.TextColor3 = Colors.Text
        end
    end
    
    local function SetKeybind(key)
        KeybindData.CurrentKeybind = key
        KeybindData.IsBinding = false
        UpdateKeybindText()
    end
    
    -- Keybind Click Handler
    KeybindButton.MouseButton1Click:Connect(function()
        KeybindData.IsBinding = true
        UpdateKeybindText()
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = input.KeyCode.Name
                SetKeybind(keyName)
                connection:Disconnect()
            end
        end)
        
        -- Timeout after 5 seconds
        wait(5)
        if KeybindData.IsBinding then
            KeybindData.IsBinding = false
            UpdateKeybindText()
            connection:Disconnect()
        end
    end)
    
    -- Keybind Activation
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode.Name == KeybindData.CurrentKeybind then
                if KeybindData.HoldToInteract then
                    KeybindData.Callback(true)
                else
                    KeybindData.Callback()
                end
            end
        end
    end)
    
    if KeybindData.HoldToInteract then
        UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode.Name == KeybindData.CurrentKeybind then
                    KeybindData.Callback(false)
                end
            end
        end)
    end
    
    -- Store references
    KeybindData.Frame = KeybindFrame
    KeybindData.Label = KeybindLabel
    KeybindData.Button = KeybindButton
    KeybindData.SetKeybind = SetKeybind
    
    -- Add to tab elements
    table.insert(tab.Elements, KeybindData)
    
    -- Update tab content canvas size
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    
    return KeybindData
end

-- ColorPicker Creation Function
function UILibrary:CreateColorPicker(tab, config)
    config = config or {}
    
    local ColorPickerData = {
        Name = config.Name or "Color Picker",
        CurrentColor = config.CurrentColor or Color3.fromRGB(255, 255, 255),
        Callback = config.Callback or function() end,
        Tab = tab,
        Flag = config.Flag or "",
        IsOpen = false
    }
    
    -- ColorPicker Frame
    local ColorPickerFrame = Instance.new("Frame")
    ColorPickerFrame.Name = "ColorPicker_" .. ColorPickerData.Name
    ColorPickerFrame.Size = UDim2.new(1, 0, 0, 40)
    ColorPickerFrame.BackgroundColor3 = Colors.Card
    ColorPickerFrame.BorderSizePixel = 0
    ColorPickerFrame.Parent = tab.Content
    
    CreateCorner(ColorPickerFrame, 6)
    CreateStroke(ColorPickerFrame, Colors.Border, 1)
    
    -- ColorPicker Label
    local ColorPickerLabel = Instance.new("TextLabel")
    ColorPickerLabel.Name = "Label"
    ColorPickerLabel.Size = UDim2.new(1, -60, 1, 0)
    ColorPickerLabel.Position = UDim2.new(0, 15, 0, 0)
    ColorPickerLabel.BackgroundTransparency = 1
    ColorPickerLabel.Text = ColorPickerData.Name
    ColorPickerLabel.TextColor3 = Colors.Text
    ColorPickerLabel.TextSize = 12
    ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorPickerLabel.Font = Enum.Font.Gotham
    ColorPickerLabel.Parent = ColorPickerFrame
    
    -- ColorPicker Preview
    local ColorPickerPreview = Instance.new("Frame")
    ColorPickerPreview.Name = "Preview"
    ColorPickerPreview.Size = UDim2.new(0, 30, 0, 25)
    ColorPickerPreview.Position = UDim2.new(1, -40, 0.5, -12.5)
    ColorPickerPreview.BackgroundColor3 = ColorPickerData.CurrentColor
    ColorPickerPreview.BorderSizePixel = 0
    ColorPickerPreview.Parent = ColorPickerFrame
    
    CreateCorner(ColorPickerPreview, 4)
    CreateStroke(ColorPickerPreview, Colors.Border, 1)
    
    -- ColorPicker Button
    local ColorPickerButton = Instance.new("TextButton")
    ColorPickerButton.Name = "Button"
    ColorPickerButton.Size = UDim2.new(1, 0, 1, 0)
    ColorPickerButton.BackgroundTransparency = 1
    ColorPickerButton.Text = ""
    ColorPickerButton.Parent = ColorPickerFrame
    
    -- Simple Color Palette
    local ColorPalette = Instance.new("Frame")
    ColorPalette.Name = "Palette"
    ColorPalette.Size = UDim2.new(1, -20, 0, 0)
    ColorPalette.Position = UDim2.new(0, 10, 1, 5)
    ColorPalette.BackgroundColor3 = Colors.Secondary
    ColorPalette.BorderSizePixel = 0
    ColorPalette.Visible = false
    ColorPalette.ZIndex = 10
    ColorPalette.Parent = ColorPickerFrame
    
    CreateCorner(ColorPalette, 4)
    CreateStroke(ColorPalette, Colors.Border, 1)
    
    -- Color Palette Grid
    local PaletteGrid = Instance.new("UIGridLayout")
    PaletteGrid.CellSize = UDim2.new(0, 20, 0, 20)
    PaletteGrid.CellPadding = UDim2.new(0, 2, 0, 2)
    PaletteGrid.SortOrder = Enum.SortOrder.LayoutOrder
    PaletteGrid.Parent = ColorPalette
    
    -- Palette Padding
    local PalettePadding = Instance.new("UIPadding")
    PalettePadding.PaddingTop = UDim.new(0, 5)
    PalettePadding.PaddingBottom = UDim.new(0, 5)
    PalettePadding.PaddingLeft = UDim.new(0, 5)
    PalettePadding.PaddingRight = UDim.new(0, 5)
    PalettePadding.Parent = ColorPalette
    
    -- Common Colors
    local CommonColors = {
        Color3.fromRGB(255, 255, 255), -- White
        Color3.fromRGB(220, 220, 220), -- Light Gray
        Color3.fromRGB(128, 128, 128), -- Gray
        Color3.fromRGB(64, 64, 64),    -- Dark Gray
        Color3.fromRGB(0, 0, 0),       -- Black
        Color3.fromRGB(255, 0, 0),     -- Red
        Color3.fromRGB(255, 165, 0),   -- Orange
        Color3.fromRGB(255, 255, 0),   -- Yellow
        Color3.fromRGB(0, 255, 0),     -- Green
        Color3.fromRGB(0, 255, 255),   -- Cyan
        Color3.fromRGB(0, 0, 255),     -- Blue
        Color3.fromRGB(128, 0, 128),   -- Purple
        Color3.fromRGB(255, 192, 203), -- Pink
        Color3.fromRGB(165, 42, 42),   -- Brown
        Color3.fromRGB(255, 20, 147),  -- Deep Pink
        Color3.fromRGB(0, 250, 154),   -- Medium Spring Green
        Color3.fromRGB(30, 144, 255),  -- Dodger Blue
        Color3.fromRGB(255, 69, 0),    -- Red Orange
        Color3.fromRGB(50, 205, 50),   -- Lime Green
        Color3.fromRGB(138, 43, 226)   -- Blue Violet
    }
    
    -- Create color buttons
    for i, color in ipairs(CommonColors) do
        local ColorButton = Instance.new("TextButton")
        ColorButton.Name = "Color_" .. i
        ColorButton.Size = UDim2.new(0, 20, 0, 20)
        ColorButton.BackgroundColor3 = color
        ColorButton.BorderSizePixel = 0
        ColorButton.Text = ""
        ColorButton.Parent = ColorPalette
        
        CreateCorner(ColorButton, 2)
        CreateStroke(ColorButton, Colors.Border, 1)
        
        ColorButton.MouseButton1Click:Connect(function()
            ColorPickerData.CurrentColor = color
            ColorPickerPreview.BackgroundColor3 = color
            ColorPickerData.Callback(color)
            
            -- Close palette
            ColorPickerData.IsOpen = false
            local closeTween = CreateTween(ColorPalette, {
                Size = UDim2.new(1, -20, 0, 0)
            }, 0.2)
            closeTween:Play()
            
            local frameTween = CreateTween(ColorPickerFrame, {
                Size = UDim2.new(1, 0, 0, 40)
            }, 0.2)
            frameTween:Play()
            
            closeTween.Completed:Connect(function()
                ColorPalette.Visible = false
            end)
        end)
    end
    
    -- Toggle Color Palette
    local function ToggleColorPalette()
        ColorPickerData.IsOpen = not ColorPickerData.IsOpen
        
        if ColorPickerData.IsOpen then
            ColorPalette.Visible = true
            local paletteHeight = math.ceil(#CommonColors / 10) * 22 + 10
            
            local openTween = CreateTween(ColorPalette, {
                Size = UDim2.new(1, -20, 0, paletteHeight)
            }, 0.2)
            openTween:Play()
            
            local frameTween = CreateTween(ColorPickerFrame, {
                Size = UDim2.new(1, 0, 0, 40 + paletteHeight + 10)
            }, 0.2)
            frameTween:Play()
        else
            local closeTween = CreateTween(ColorPalette, {
                Size = UDim2.new(1, -20, 0, 0)
            }, 0.2)
            closeTween:Play()
            
            local frameTween = CreateTween(ColorPickerFrame, {
                Size = UDim2.new(1, 0, 0, 40)
            }, 0.2)
            frameTween:Play()
            
            closeTween.Completed:Connect(function()
                ColorPalette.Visible = false
            end)
        end
        
        -- Update tab content canvas size
        tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    end
    
    -- ColorPicker Click Handler
    ColorPickerButton.MouseButton1Click:Connect(ToggleColorPalette)
    
    -- Store references
    ColorPickerData.Frame = ColorPickerFrame
    ColorPickerData.Label = ColorPickerLabel
    ColorPickerData.Preview = ColorPickerPreview
    ColorPickerData.Button = ColorPickerButton
    ColorPickerData.Palette = ColorPalette
    ColorPickerData.ToggleColorPalette = ToggleColorPalette
    
    -- Add to tab elements
    table.insert(tab.Elements, ColorPickerData)
    
    -- Update tab content canvas size
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    
    return ColorPickerData
end

-- Window Controls Implementation
function UILibrary:AddWindowControls(window)
    -- Dragging functionality
    if window.Draggable then
        local dragStart = nil
        local startPos = nil
        
        local function Update(input)
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            window.MainFrame.Position = newPosition
        end
        
        window.MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragStart = input.Position
                startPos = window.MainFrame.Position
                
                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        connection:Disconnect()
                    end
                end)
                
                local moveConnection
                moveConnection = UserInputService.InputChanged:Connect(function(moveInput)
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                        Update(moveInput)
                    end
                end)
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        moveConnection:Disconnect()
                    end
                end)
            end
        end)
    end
    
    -- Close button functionality
    local closeButton = window.MainFrame.TitleBar.CloseButton
    closeButton.MouseButton1Click:Connect(function()
        -- Close animation
        local closeTween = CreateTween(window.MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3)
        closeTween:Play()
        
        closeTween.Completed:Connect(function()
            window.ScreenGui:Destroy()
        end)
    end)
    
    -- Minimize button functionality
    local minimizeButton = window.MainFrame.TitleBar.MinimizeButton
    local isMinimized = false
    local originalSize = window.MainFrame.Size
    
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        if isMinimized then
            local minimizeTween = CreateTween(window.MainFrame, {
                Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 45)
            }, 0.3)
            minimizeTween:Play()
            
            minimizeButton.Text = "+"
        else
            local restoreTween = CreateTween(window.MainFrame, {
                Size = originalSize
            }, 0.3)
            restoreTween:Play()
            
            minimizeButton.Text = "−"
        end
    end)
    
    -- Close button hover effects
    closeButton.MouseEnter:Connect(function()
        local hoverTween = CreateTween(closeButton, {
            BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        }, 0.15)
        hoverTween:Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        local leaveTween = CreateTween(closeButton, {
            BackgroundColor3 = Colors.Error
        }, 0.15)
        leaveTween:Play()
    end)
    
    -- Minimize button hover effects
    minimizeButton.MouseEnter:Connect(function()
        local hoverTween = CreateTween(minimizeButton, {
            BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        }, 0.15)
        hoverTween:Play()
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        local leaveTween = CreateTween(minimizeButton, {
            BackgroundColor3 = Colors.Warning
        }, 0.15)
        leaveTween:Play()
    end)
end

-- Notification System
function UILibrary:CreateNotification(config)
    config = config or {}
    
    local NotificationData = {
        Title = config.Title or "Notification",
        Content = config.Content or "This is a notification",
        Duration = config.Duration or 5,
        Type = config.Type or "Info" -- Info, Success, Warning, Error
    }
    
    -- Get notification color based on type
    local notificationColor = Colors.Accent
    if NotificationData.Type == "Success" then
        notificationColor = Colors.Success
    elseif NotificationData.Type == "Warning" then
        notificationColor = Colors.Warning
    elseif NotificationData.Type == "Error" then
        notificationColor = Colors.Error
    end
    
    -- Create notification GUI
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "Notification"
    NotificationGui.Parent = CoreGui
    
    -- Notification Frame
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Size = UDim2.new(0, 300, 0, 80)
    NotificationFrame.Position = UDim2.new(1, -320, 0, 20)
    NotificationFrame.BackgroundColor3 = Colors.Card
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = NotificationGui
    
    CreateCorner(NotificationFrame, 8)
    CreateStroke(NotificationFrame, notificationColor, 2)
    
    -- Notification Title
    local NotificationTitle = Instance.new("TextLabel")
    NotificationTitle.Name = "Title"
    NotificationTitle.Size = UDim2.new(1, -20, 0, 25)
    NotificationTitle.Position = UDim2.new(0, 10, 0, 5)
    NotificationTitle.BackgroundTransparency = 1
    NotificationTitle.Text = NotificationData.Title
    NotificationTitle.TextColor3 = Colors.Text
    NotificationTitle.TextSize = 13
    NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotificationTitle.Font = Enum.Font.GothamBold
    NotificationTitle.Parent = NotificationFrame
    
    -- Notification Content
    local NotificationContent = Instance.new("TextLabel")
    NotificationContent.Name = "Content"
    NotificationContent.Size = UDim2.new(1, -20, 0, 40)
    NotificationContent.Position = UDim2.new(0, 10, 0, 30)
    NotificationContent.BackgroundTransparency = 1
    NotificationContent.Text = NotificationData.Content
    NotificationContent.TextColor3 = Colors.TextSecondary
    NotificationContent.TextSize = 11
    NotificationContent.TextXAlignment = Enum.TextXAlignment.Left
    NotificationContent.TextYAlignment = Enum.TextYAlignment.Top
    NotificationContent.TextWrapped = true
    NotificationContent.Font = Enum.Font.Gotham
    NotificationContent.Parent = NotificationFrame
    
    -- Slide in animation
    local slideInTween = CreateTween(NotificationFrame, {
        Position = UDim2.new(1, -320, 0, 20)
    }, 0.5)
    slideInTween:Play()
    
    -- Auto dismiss after duration
    game:GetService("Debris"):AddItem(NotificationGui, NotificationData.Duration)
    
    -- Slide out animation before destruction
    wait(NotificationData.Duration - 0.5)
    local slideOutTween = CreateTween(NotificationFrame, {
        Position = UDim2.new(1, 0, 0, 20)
    }, 0.5)
    slideOutTween:Play()
    
    return NotificationData
end