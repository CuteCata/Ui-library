-- ================================
-- ASTDX Custom UI Library - Part 4
-- Slider & Dropdown Components
-- ================================

-- Slider Creation Function
function UILibrary:CreateSlider(tab, config)
    config = config or {}
    
    local SliderData = {
        Name = config.Name or "Slider",
        Range = config.Range or {0, 100},
        Increment = config.Increment or 1,
        Suffix = config.Suffix or "",
        CurrentValue = config.CurrentValue or config.Range[1],
        Callback = config.Callback or function() end,
        Tab = tab,
        Flag = config.Flag or "",
        Dragging = false
    }
    
    -- Slider Frame
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider_" .. SliderData.Name
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Colors.Card
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = tab.Content
    
    CreateCorner(SliderFrame, 6)
    CreateStroke(SliderFrame, Colors.Border, 1)
    
    -- Slider Label
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, -20, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = SliderData.Name
    SliderLabel.TextColor3 = Colors.Text
    SliderLabel.TextSize = 12
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Parent = SliderFrame
    
    -- Slider Value Label
    local SliderValueLabel = Instance.new("TextLabel")
    SliderValueLabel.Name = "ValueLabel"
    SliderValueLabel.Size = UDim2.new(0, 60, 0, 20)
    SliderValueLabel.Position = UDim2.new(1, -70, 0, 5)
    SliderValueLabel.BackgroundTransparency = 1
    SliderValueLabel.Text = tostring(SliderData.CurrentValue) .. SliderData.Suffix
    SliderValueLabel.TextColor3 = Colors.Accent
    SliderValueLabel.TextSize = 11
    SliderValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    SliderValueLabel.Font = Enum.Font.GothamBold
    SliderValueLabel.Parent = SliderFrame
    
    -- Slider Track
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Name = "Track"
    SliderTrack.Size = UDim2.new(1, -30, 0, 6)
    SliderTrack.Position = UDim2.new(0, 15, 0, 32)
    SliderTrack.BackgroundColor3 = Colors.Secondary
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = SliderFrame
    
    CreateCorner(SliderTrack, 3)
    
    -- Slider Fill
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = Colors.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    CreateCorner(SliderFill, 3)
    
    -- Slider Handle
    local SliderHandle = Instance.new("Frame")
    SliderHandle.Name = "Handle"
    SliderHandle.Size = UDim2.new(0, 16, 0, 16)
    SliderHandle.Position = UDim2.new(0, -8, 0, -5)
    SliderHandle.BackgroundColor3 = Colors.Text
    SliderHandle.BorderSizePixel = 0
    SliderHandle.Parent = SliderFill
    
    CreateCorner(SliderHandle, 8)
    CreateStroke(SliderHandle, Colors.Accent, 2)
    
    -- Slider Button (Invisible click detector)
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "SliderButton"
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.Parent = SliderFrame
    
    -- Slider Functions
    local function UpdateSlider()
        local percentage = (SliderData.CurrentValue - SliderData.Range[1]) / (SliderData.Range[2] - SliderData.Range[1])
        local fillSize = UDim2.new(percentage, 0, 1, 0)
        
        local fillTween = CreateTween(SliderFill, {
            Size = fillSize
        }, 0.1)
        fillTween:Play()
        
        SliderValueLabel.Text = tostring(SliderData.CurrentValue) .. SliderData.Suffix
    end
    
    local function SetValue(value)
        value = math.clamp(value, SliderData.Range[1], SliderData.Range[2])
        value = math.floor(value / SliderData.Increment + 0.5) * SliderData.Increment
        SliderData.CurrentValue = value
        UpdateSlider()
        SliderData.Callback(value)
    end
    
    -- Slider Input Handling
    SliderButton.MouseButton1Down:Connect(function()
        SliderData.Dragging = true
        
        local function Update()
            local mouse = Players.LocalPlayer:GetMouse()
            local percentage = math.clamp((mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
            local value = SliderData.Range[1] + (SliderData.Range[2] - SliderData.Range[1]) * percentage
            SetValue(value)
        end
        
        local connection
        connection = mouse.Move:Connect(Update)
        
        local function Stop()
            SliderData.Dragging = false
            connection:Disconnect()
        end
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Stop()
            end
        end)
        
        Update()
    end)
    
    -- Initialize slider
    UpdateSlider()
    
    -- Store references
    SliderData.Frame = SliderFrame
    SliderData.Label = SliderLabel
    SliderData.ValueLabel = SliderValueLabel
    SliderData.Track = SliderTrack
    SliderData.Fill = SliderFill
    SliderData.Handle = SliderHandle
    SliderData.Button = SliderButton
    SliderData.SetValue = SetValue
    SliderData.UpdateSlider = UpdateSlider
    
    -- Add to tab elements
    table.insert(tab.Elements, SliderData)
    
    -- Update tab content canvas size
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    
    return SliderData
end

-- Dropdown Creation Function
function UILibrary:CreateDropdown(tab, config)
    config = config or {}
    
    local DropdownData = {
        Name = config.Name or "Dropdown",
        Options = config.Options or {"Option 1", "Option 2", "Option 3"},
        CurrentOption = config.CurrentOption or config.Options[1],
        Callback = config.Callback or function() end,
        Tab = tab,
        Flag = config.Flag or "",
        IsOpen = false
    }
    
    -- Dropdown Frame
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "Dropdown_" .. DropdownData.Name
    DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    DropdownFrame.BackgroundColor3 = Colors.Card
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Parent = tab.Content
    
    CreateCorner(DropdownFrame, 6)
    CreateStroke(DropdownFrame, Colors.Border, 1)
    
    -- Dropdown Label
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Name = "Label"
    DropdownLabel.Size = UDim2.new(1, -20, 0, 20)
    DropdownLabel.Position = UDim2.new(0, 10, 0, 2)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = DropdownData.Name
    DropdownLabel.TextColor3 = Colors.Text
    DropdownLabel.TextSize = 11
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.Parent = DropdownFrame
    
    -- Dropdown Selected Frame
    local DropdownSelected = Instance.new("Frame")
    DropdownSelected.Name = "Selected"
    DropdownSelected.Size = UDim2.new(1, -20, 0, 20)
    DropdownSelected.Position = UDim2.new(0, 10, 0, 18)
    DropdownSelected.BackgroundColor3 = Colors.Secondary
    DropdownSelected.BorderSizePixel = 0
    DropdownSelected.Parent = DropdownFrame
    
    CreateCorner(DropdownSelected, 4)
    CreateStroke(DropdownSelected, Colors.Border, 1)
    
    -- Dropdown Selected Text
    local DropdownSelectedText = Instance.new("TextLabel")
    DropdownSelectedText.Name = "SelectedText"
    DropdownSelectedText.Size = UDim2.new(1, -30, 1, 0)
    DropdownSelectedText.Position = UDim2.new(0, 8, 0, 0)
    DropdownSelectedText.BackgroundTransparency = 1
    DropdownSelectedText.Text = DropdownData.CurrentOption
    DropdownSelectedText.TextColor3 = Colors.Text
    DropdownSelectedText.TextSize = 11
    DropdownSelectedText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownSelectedText.Font = Enum.Font.Gotham
    DropdownSelectedText.Parent = DropdownSelected
    
    -- Dropdown Arrow
    local DropdownArrow = Instance.new("TextLabel")
    DropdownArrow.Name = "Arrow"
    DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
    DropdownArrow.Position = UDim2.new(1, -20, 0, 0)
    DropdownArrow.BackgroundTransparency = 1
    DropdownArrow.Text = "▼"
    DropdownArrow.TextColor3 = Colors.TextSecondary
    DropdownArrow.TextSize = 10
    DropdownArrow.Font = Enum.Font.Gotham
    DropdownArrow.Parent = DropdownSelected
    
    -- Dropdown List Frame
    local DropdownList = Instance.new("Frame")
    DropdownList.Name = "List"
    DropdownList.Size = UDim2.new(1, -20, 0, 0)
    DropdownList.Position = UDim2.new(0, 10, 1, 5)
    DropdownList.BackgroundColor3 = Colors.Secondary
    DropdownList.BorderSizePixel = 0
    DropdownList.Visible = false
    DropdownList.ZIndex = 10
    DropdownList.Parent = DropdownFrame
    
    CreateCorner(DropdownList, 4)
    CreateStroke(DropdownList, Colors.Border, 1)
    
    -- Dropdown List Layout
    local DropdownListLayout = Instance.new("UIListLayout")
    DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropdownListLayout.Parent = DropdownList
    
    -- Dropdown Button (Invisible click detector)
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "DropdownButton"
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = ""
    DropdownButton.Parent = DropdownFrame
    
    -- Dropdown Functions
    local function CreateOption(optionText)
        local OptionFrame = Instance.new("TextButton")
        OptionFrame.Name = "Option_" .. optionText
        OptionFrame.Size = UDim2.new(1, 0, 0, 25)
        OptionFrame.BackgroundColor3 = Colors.Secondary
        OptionFrame.BorderSizePixel = 0
        OptionFrame.Text = optionText
        OptionFrame.TextColor3 = Colors.Text
        OptionFrame.TextSize = 11
        OptionFrame.TextXAlignment = Enum.TextXAlignment.Left
        OptionFrame.Font = Enum.Font.Gotham
        OptionFrame.Parent = DropdownList
        
        local OptionPadding = Instance.new("UIPadding")
        OptionPadding.PaddingLeft = UDim.new(0, 8)
        OptionPadding.Parent = OptionFrame
        
        -- Option hover effect
        OptionFrame.MouseEnter:Connect(function()
            local hoverTween = CreateTween(OptionFrame, {
                BackgroundColor3 = Colors.Hover
            }, 0.15)
            hoverTween:Play()
        end)
        
        OptionFrame.MouseLeave:Connect(function()
            local leaveTween = CreateTween(OptionFrame, {
                BackgroundColor3 = Colors.Secondary
            }, 0.15)
            leaveTween:Play()
        end)
        
        -- Option click handler
        OptionFrame.MouseButton1Click:Connect(function()
            DropdownData.CurrentOption = optionText
            DropdownSelectedText.Text = optionText
            ToggleDropdown()
            DropdownData.Callback(optionText)
        end)
        
        return OptionFrame
    end
    
    local function ToggleDropdown()
        DropdownData.IsOpen = not DropdownData.IsOpen
        
        if DropdownData.IsOpen then
            -- Open dropdown
            DropdownList.Visible = true
            local listHeight = #DropdownData.Options * 25
            
            local openTween = CreateTween(DropdownList, {
                Size = UDim2.new(1, -20, 0, listHeight)
            }, 0.2)
            openTween:Play()
            
            local arrowTween = CreateTween(DropdownArrow, {
                Rotation = 180
            }, 0.2)
            arrowTween:Play()
            
            -- Update main frame size
            local newFrameSize = UDim2.new(1, 0, 0, 40 + listHeight + 10)
            local frameTween = CreateTween(DropdownFrame, {
                Size = newFrameSize
            }, 0.2)
            frameTween:Play()
        else
            -- Close dropdown
            local closeTween = CreateTween(DropdownList, {
                Size = UDim2.new(1, -20, 0, 0)
            }, 0.2)
            closeTween:Play()
            
            local arrowTween = CreateTween(DropdownArrow, {
                Rotation = 0
            }, 0.2)
            arrowTween:Play()
            
            -- Update main frame size
            local frameTween = CreateTween(DropdownFrame, {
                Size = UDim2.new(1, 0, 0, 40)
            }, 0.2)
            frameTween:Play()
            
            closeTween.Completed:Connect(function()
                DropdownList.Visible = false
            end)
        end
        
        -- Update tab content canvas size
        tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    end
    
    -- Create options
    for _, option in ipairs(DropdownData.Options) do
        CreateOption(option)
    end
    
    -- Dropdown click handler
    DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
    
    -- Store references
    DropdownData.Frame = DropdownFrame
    DropdownData.Label = DropdownLabel
    DropdownData.Selected = DropdownSelected
    DropdownData.SelectedText = DropdownSelectedText
    DropdownData.Arrow = DropdownArrow
    DropdownData.List = DropdownList
    DropdownData.Button = DropdownButton
    DropdownData.ToggleDropdown = ToggleDropdown
    
    -- Add to tab elements
    table.insert(tab.Elements, DropdownData)
    
    -- Update tab content canvas size
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    
    return DropdownData
end