-- ================================
-- ASTDX Custom UI Library - Part 2
-- Tab System & Navigation
-- ================================

-- Tab Creation Function
function UILibrary:CreateTab(window, config)
    config = config or {}
    
    local TabData = {
        Name = config.Name or "Tab",
        Icon = config.Icon or "🏠",
        Visible = config.Visible ~= false,
        Active = false,
        Elements = {},
        Window = window
    }
    
    -- Tab Button
    local TabButton = Instance.new("TextButton")
    TabButton.Name = "TabButton_" .. TabData.Name
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundColor3 = Colors.Card
    TabButton.BorderSizePixel = 0
    TabButton.Text = ""
    TabButton.Parent = window.TabList
    
    CreateCorner(TabButton, 6)
    
    -- Tab Icon
    local TabIcon = Instance.new("TextLabel")
    TabIcon.Name = "Icon"
    TabIcon.Size = UDim2.new(0, 20, 0, 20)
    TabIcon.Position = UDim2.new(0, 10, 0, 10)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Text = TabData.Icon
    TabIcon.TextColor3 = Colors.TextSecondary
    TabIcon.TextSize = 16
    TabIcon.Font = Enum.Font.Gotham
    TabIcon.Parent = TabButton
    
    -- Tab Label
    local TabLabel = Instance.new("TextLabel")
    TabLabel.Name = "Label"
    TabLabel.Size = UDim2.new(1, -40, 1, 0)
    TabLabel.Position = UDim2.new(0, 35, 0, 0)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Text = TabData.Name
    TabLabel.TextColor3 = Colors.TextSecondary
    TabLabel.TextSize = 12
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabLabel.Font = Enum.Font.Gotham
    TabLabel.Parent = TabButton
    
    -- Tab Content Frame
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = "TabContent_" .. TabData.Name
    TabContent.Size = UDim2.new(1, -20, 1, -20)
    TabContent.Position = UDim2.new(0, 10, 0, 10)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Colors.Accent
    TabContent.BorderSizePixel = 0
    TabContent.Visible = false
    TabContent.Parent = window.ContentContainer
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.Parent = TabContent
    
    -- Tab Selection Function
    local function SelectTab()
        -- Deselect all tabs
        for _, tab in pairs(window.Tabs) do
            tab.Active = false
            tab.Button.BackgroundColor3 = Colors.Card
            tab.Icon.TextColor3 = Colors.TextSecondary
            tab.Label.TextColor3 = Colors.TextSecondary
            tab.Content.Visible = false
        end
        
        -- Select this tab
        TabData.Active = true
        TabButton.BackgroundColor3 = Colors.Accent
        TabIcon.TextColor3 = Colors.Text
        TabLabel.TextColor3 = Colors.Text
        TabContent.Visible = true
        window.CurrentTab = TabData
        
        -- Animation
        local selectTween = CreateTween(TabButton, {
            BackgroundColor3 = Colors.Accent
        }, 0.2)
        selectTween:Play()
    end
    
    -- Tab Hover Effects
    TabButton.MouseEnter:Connect(function()
        if not TabData.Active then
            local hoverTween = CreateTween(TabButton, {
                BackgroundColor3 = Colors.Hover
            }, 0.15)
            hoverTween:Play()
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if not TabData.Active then
            local leaveTween = CreateTween(TabButton, {
                BackgroundColor3 = Colors.Card
            }, 0.15)
            leaveTween:Play()
        end
    end)
    
    -- Tab Click Handler
    TabButton.MouseButton1Click:Connect(SelectTab)
    
    -- Store references
    TabData.Button = TabButton
    TabData.Icon = TabIcon
    TabData.Label = TabLabel
    TabData.Content = TabContent
    TabData.Layout = ContentLayout
    TabData.SelectTab = SelectTab
    
    -- Add to window tabs
    table.insert(window.Tabs, TabData)
    
    -- Select first tab automatically
    if #window.Tabs == 1 then
        SelectTab()
    end
    
    -- Update tab list canvas size
    window.TabList.CanvasSize = UDim2.new(0, 0, 0, #window.Tabs * 45)
    
    return TabData
end

-- Section Creation Function
function UILibrary:CreateSection(tab, config)
    config = config or {}
    
    local SectionData = {
        Name = config.Name or "Section",
        Tab = tab,
        Elements = {}
    }
    
    -- Section Frame
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "Section_" .. SectionData.Name
    SectionFrame.Size = UDim2.new(1, 0, 0, 35)
    SectionFrame.BackgroundColor3 = Colors.Card
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Parent = tab.Content
    
    CreateCorner(SectionFrame, 8)
    CreateStroke(SectionFrame, Colors.Border, 1)
    
    -- Section Title
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "Title"
    SectionTitle.Size = UDim2.new(1, -20, 1, 0)
    SectionTitle.Position = UDim2.new(0, 10, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = SectionData.Name
    SectionTitle.TextColor3 = Colors.Text
    SectionTitle.TextSize = 14
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.Parent = SectionFrame
    
    -- Section Content Layout
    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SectionLayout.Padding = UDim.new(0, 5)
    SectionLayout.Parent = SectionFrame
    
    -- Store references
    SectionData.Frame = SectionFrame
    SectionData.Title = SectionTitle
    SectionData.Layout = SectionLayout
    
    -- Add to tab elements
    table.insert(tab.Elements, SectionData)
    
    -- Update tab content canvas size
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    
    return SectionData
end

-- Divider Creation Function
function UILibrary:CreateDivider(tab, config)
    config = config or {}
    
    local DividerFrame = Instance.new("Frame")
    DividerFrame.Name = "Divider"
    DividerFrame.Size = UDim2.new(1, 0, 0, 20)
    DividerFrame.BackgroundTransparency = 1
    DividerFrame.Parent = tab.Content
    
    local DividerLine = Instance.new("Frame")
    DividerLine.Name = "Line"
    DividerLine.Size = UDim2.new(1, -40, 0, 1)
    DividerLine.Position = UDim2.new(0, 20, 0.5, 0)
    DividerLine.BackgroundColor3 = Colors.Border
    DividerLine.BorderSizePixel = 0
    DividerLine.Parent = DividerFrame
    
    -- Update tab content canvas size
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    
    return DividerFrame
end

-- Paragraph Creation Function
function UILibrary:CreateParagraph(tab, config)
    config = config or {}
    
    local ParagraphData = {
        Title = config.Title or "Paragraph",
        Content = config.Content or "Content goes here...",
        Tab = tab
    }
    
    -- Calculate content height
    local contentHeight = 25 + (string.len(ParagraphData.Content) / 60) * 15
    contentHeight = math.max(contentHeight, 60)
    
    -- Paragraph Frame
    local ParagraphFrame = Instance.new("Frame")
    ParagraphFrame.Name = "Paragraph_" .. ParagraphData.Title
    ParagraphFrame.Size = UDim2.new(1, 0, 0, contentHeight)
    ParagraphFrame.BackgroundColor3 = Colors.Card
    ParagraphFrame.BorderSizePixel = 0
    ParagraphFrame.Parent = tab.Content
    
    CreateCorner(ParagraphFrame, 6)
    CreateStroke(ParagraphFrame, Colors.Border, 1)
    
    -- Paragraph Title
    local ParagraphTitle = Instance.new("TextLabel")
    ParagraphTitle.Name = "Title"
    ParagraphTitle.Size = UDim2.new(1, -20, 0, 25)
    ParagraphTitle.Position = UDim2.new(0, 10, 0, 5)
    ParagraphTitle.BackgroundTransparency = 1
    ParagraphTitle.Text = ParagraphData.Title
    ParagraphTitle.TextColor3 = Colors.Text
    ParagraphTitle.TextSize = 13
    ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphTitle.Font = Enum.Font.GothamBold
    ParagraphTitle.Parent = ParagraphFrame
    
    -- Paragraph Content
    local ParagraphContent = Instance.new("TextLabel")
    ParagraphContent.Name = "Content"
    ParagraphContent.Size = UDim2.new(1, -20, 1, -30)
    ParagraphContent.Position = UDim2.new(0, 10, 0, 25)
    ParagraphContent.BackgroundTransparency = 1
    ParagraphContent.Text = ParagraphData.Content
    ParagraphContent.TextColor3 = Colors.TextSecondary
    ParagraphContent.TextSize = 11
    ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
    ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
    ParagraphContent.TextWrapped = true
    ParagraphContent.Font = Enum.Font.Gotham
    ParagraphContent.Parent = ParagraphFrame
    
    -- Store references
    ParagraphData.Frame = ParagraphFrame
    ParagraphData.TitleLabel = ParagraphTitle
    ParagraphData.ContentLabel = ParagraphContent
    
    -- Add to tab elements
    table.insert(tab.Elements, ParagraphData)
    
    -- Update tab content canvas size
    tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y)
    
    return ParagraphData
end