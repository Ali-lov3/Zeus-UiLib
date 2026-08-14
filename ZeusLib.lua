local ZeusLib = {}
ZeusLib.__index = ZeusLib

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Themes = {
    Pink = {
        Background = Color3.fromRGB(8, 8, 10),
        Surface = Color3.fromRGB(15, 15, 19),
        SurfaceAlt = Color3.fromRGB(22, 22, 28),
        Border = Color3.fromRGB(42, 42, 52),
        Text = Color3.fromRGB(247, 247, 250),
        Muted = Color3.fromRGB(150, 150, 165),
        Accent = Color3.fromRGB(239, 63, 151),
        AccentDark = Color3.fromRGB(180, 42, 112),
        Positive = Color3.fromRGB(87, 220, 142),
        Danger = Color3.fromRGB(242, 86, 106),
    },
    Rose = {
        Background = Color3.fromRGB(15, 7, 11),
        Surface = Color3.fromRGB(27, 12, 20),
        SurfaceAlt = Color3.fromRGB(44, 18, 31),
        Border = Color3.fromRGB(77, 35, 55),
        Text = Color3.fromRGB(255, 245, 249),
        Muted = Color3.fromRGB(190, 142, 161),
        Accent = Color3.fromRGB(255, 91, 146),
        AccentDark = Color3.fromRGB(205, 59, 108),
        Positive = Color3.fromRGB(87, 220, 142),
        Danger = Color3.fromRGB(242, 86, 106),
    },
    Violet = {
        Background = Color3.fromRGB(9, 8, 15),
        Surface = Color3.fromRGB(17, 14, 27),
        SurfaceAlt = Color3.fromRGB(27, 22, 42),
        Border = Color3.fromRGB(54, 44, 79),
        Text = Color3.fromRGB(247, 245, 255),
        Muted = Color3.fromRGB(161, 153, 187),
        Accent = Color3.fromRGB(206, 92, 255),
        AccentDark = Color3.fromRGB(155, 55, 205),
        Positive = Color3.fromRGB(87, 220, 142),
        Danger = Color3.fromRGB(242, 86, 106),
    },
}

local Fonts = {
    Gotham = Enum.Font.Gotham,
    GothamBold = Enum.Font.GothamBold,
    SourceSans = Enum.Font.SourceSans,
    SourceSansBold = Enum.Font.SourceSansBold,
    Ubuntu = Enum.Font.Ubuntu,
    BuilderSans = Enum.Font.BuilderSans,
}

local function create(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent,
    })
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = parent,
    })
end

local function tween(object, properties, duration)
    local animation = TweenService:Create(object, TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
    animation:Play()
    return animation
end

local function resolveCallback(callback)
    if typeof(callback) == "function" then
        return callback
    end
    return function() end
end

local function getGuiParent()
    local player = Players.LocalPlayer
    if gethui then
        return gethui()
    end
    if syn and syn.protect_gui then
        return game:GetService("CoreGui")
    end
    if player then
        return player:WaitForChild("PlayerGui")
    end
    return game:GetService("CoreGui")
end

function ZeusLib.new(config)
    local self = setmetatable({}, ZeusLib)
    config = config or {}
    self.Title = config.Title or "ZeusLib"
    self.ThemeName = config.Theme or "Pink"
    self.FontName = config.Font or "Gotham"
    self.Keybind = config.Keybind or Enum.KeyCode.RightControl
    self.Theme = Themes[self.ThemeName] or Themes.Pink
    self.Font = Fonts[self.FontName] or Fonts.Gotham
    self.ThemeRegistry = {}
    self.FontRegistry = {}
    self.Tabs = {}
    self.CurrentTab = nil
    self.Dropdown = nil
    self.Connections = {}
    self.Destroyed = false
    self.Visible = true
    self:_build()
    return self
end

function ZeusLib:CreateWindow(config)
    return ZeusLib.new(config)
end

function ZeusLib:_register(instance, property, themeKey)
    table.insert(self.ThemeRegistry, {
        Instance = instance,
        Property = property,
        Key = themeKey,
    })
    instance[property] = self.Theme[themeKey]
    return instance
end

function ZeusLib:_registerFont(instance)
    table.insert(self.FontRegistry, instance)
    instance.Font = self.Font
    return instance
end

function ZeusLib:_createText(className, properties, themeKey)
    local object = create(className, properties)
    self:_registerFont(object)
    if themeKey then
        self:_register(object, "TextColor3", themeKey)
    end
    return object
end

function ZeusLib:_build()
    self.ScreenGui = create("ScreenGui", {
        Name = "ZeusLib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true,
        Parent = getGuiParent(),
    })

    self.Root = create("Frame", {
        Name = "Root",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = self.ScreenGui,
    })

    self.Scale = create("UIScale", {
        Parent = self.Root,
    })

    self.Main = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(780, 520),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = self.Root,
    })
    corner(self.Main, 12)
    self:_register(self.Main, "BackgroundColor3", "Background")
    stroke(self.Main, self.Theme.Border, 1, 0.15)

    self.Topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundTransparency = 1,
        Parent = self.Main,
    })
    padding(self.Topbar, 18, 12, 0, 0)

    self.Logo = create("Frame", {
        Name = "Logo",
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Parent = self.Topbar,
    })
    corner(self.Logo, 9)
    self:_register(self.Logo, "BackgroundColor3", "Accent")

    self.LogoText = self:_createText("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "Z",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = self.Logo,
    }, "Text")

    self.TitleLabel = self:_createText("TextLabel", {
        Name = "Title",
        Position = UDim2.new(0, 44, 0, 10),
        Size = UDim2.new(1, -160, 0, 22),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Topbar,
    }, "Text")

    self.Subtitle = self:_createText("TextLabel", {
        Position = UDim2.new(0, 44, 0, 30),
        Size = UDim2.new(1, -160, 0, 16),
        BackgroundTransparency = 1,
        Text = "Control panel",
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Topbar,
    }, "Muted")

    self.CloseButton = self:_createText("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = self.Theme.SurfaceAlt,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "×",
        TextSize = 22,
        Parent = self.Topbar,
    }, "Muted")
    corner(self.CloseButton, 8)
    self:_register(self.CloseButton, "BackgroundColor3", "SurfaceAlt")
    self.CloseButton.MouseEnter:Connect(function()
        tween(self.CloseButton, {BackgroundColor3 = self.Theme.Danger, TextColor3 = self.Theme.Text})
    end)
    self.CloseButton.MouseLeave:Connect(function()
        tween(self.CloseButton, {BackgroundColor3 = self.Theme.SurfaceAlt, TextColor3 = self.Theme.Muted})
    end)
    table.insert(self.Connections, self.CloseButton.Activated:Connect(function()
        self:SetVisible(false)
    end))

    self.Body = create("Frame", {
        Name = "Body",
        Position = UDim2.new(0, 12, 0, 58),
        Size = UDim2.new(1, -24, 1, -70),
        BackgroundTransparency = 1,
        Parent = self.Main,
    })

    self.Sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 178, 1, 0),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Parent = self.Body,
    })
    corner(self.Sidebar, 9)
    self:_register(self.Sidebar, "BackgroundColor3", "Surface")
    padding(self.Sidebar, 8, 8, 8, 8)

    self.TabList = create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Sidebar,
    })
    self:_register(self.TabList, "ScrollBarImageColor3", "Accent")
    self.TabLayout = create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.TabList,
    })

    self.Content = create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 190, 0, 0),
        Size = UDim2.new(1, -190, 1, 0),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = self.Body,
    })
    corner(self.Content, 9)
    self:_register(self.Content, "BackgroundColor3", "Surface")

    self.PageLayer = create("Frame", {
        Name = "PageLayer",
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = self.Content,
    })

    self.DropdownLayer = create("Frame", {
        Name = "DropdownLayer",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 200,
        Parent = self.Root,
    })

    self.MobileToggle = self:_createText("TextButton", {
        Name = "MobileToggle",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.fromOffset(52, 52),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "Z",
        TextSize = 20,
        ZIndex = 100,
        Visible = UserInputService.TouchEnabled,
        Parent = self.Root,
    }, "Text")
    corner(self.MobileToggle, 16)
    self:_register(self.MobileToggle, "BackgroundColor3", "Accent")
    table.insert(self.Connections, self.MobileToggle.Activated:Connect(function()
        self:SetVisible(not self.Visible)
    end))

    self:_bindInput()
    self:_bindResponsiveScale()
    self:_createSettingsTab()
    self:SelectTab(self.SettingsTab)
end

function ZeusLib:_bindInput()
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed or self.Destroyed then
            return
        end
        if input.KeyCode == self.Keybind then
            self:SetVisible(not self.Visible)
        end
    end))
end

function ZeusLib:_bindResponsiveScale()
    local function update()
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local scale = math.min(viewport.X / 960, viewport.Y / 650)
        self.Scale.Scale = math.clamp(scale, 0.58, 1)
        if viewport.X < 600 then
            self.Main.Size = UDim2.fromOffset(760, 520)
            self.Main.Position = UDim2.fromScale(0.5, 0.46)
        else
            self.Main.Size = UDim2.fromOffset(780, 520)
            self.Main.Position = UDim2.fromScale(0.5, 0.5)
        end
    end
    update()
    if workspace.CurrentCamera then
        table.insert(self.Connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update))
    end
end

function ZeusLib:_createSettingsTab()
    local tab = self:_createTab("UISettings", true)
    tab:AddSection("Interface")
    tab:AddKeybind({
        Name = "Menu keybind",
        Default = self.Keybind,
        Callback = function(key)
            self:SetKeybind(key)
        end,
    })
    tab:AddDropdown({
        Name = "Theme",
        Options = {"Pink", "Rose", "Violet"},
        Default = self.ThemeName,
        Callback = function(value)
            self:SetTheme(value)
        end,
    })
    tab:AddDropdown({
        Name = "Font",
        Options = {"Gotham", "GothamBold", "SourceSans", "SourceSansBold", "Ubuntu", "BuilderSans"},
        Default = self.FontName,
        Callback = function(value)
            self:SetFont(value)
        end,
    })
    tab:AddSection("Window")
    tab:AddToggle({
        Name = "Mobile button",
        Default = UserInputService.TouchEnabled,
        Callback = function(value)
            self.MobileToggle.Visible = value
        end,
    })
    tab:AddButton({
        Name = "Close menu",
        Callback = function()
            self:SetVisible(false)
        end,
    })
end

function ZeusLib:_createTab(name, isSettings)
    local tab = {
        Window = self,
        Name = name,
        IsSettings = isSettings,
        Sections = {},
    }
    setmetatable(tab, {__index = self:_tabMethods()})

    tab.Button = self:_createText("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 0, 37),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = name,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = isSettings and 1000 or #self.Tabs + 1,
        Parent = self.TabList,
    }, "Muted")
    corner(tab.Button, 8)
    padding(tab.Button, 12, 8, 0, 0)
    self:_register(tab.Button, "BackgroundColor3", "Surface")

    tab.Page = create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.PageLayer,
    })
    self:_register(tab.Page, "ScrollBarImageColor3", "Accent")
    padding(tab.Page, 18, 18, 16, 18)

    tab.Layout = create("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.Page,
    })

    table.insert(self.Tabs, tab)
    if not isSettings then
        tab.Button.LayoutOrder = #self.Tabs
    end
    if self.SettingsTab then
        self.SettingsTab.Button.LayoutOrder = 1000
    end
    table.insert(self.Connections, tab.Button.Activated:Connect(function()
        self:SelectTab(tab)
    end))

    if not isSettings then
        if not self.CurrentTab or self.CurrentTab == self.SettingsTab then
            self:SelectTab(tab)
        end
    else
        self.SettingsTab = tab
    end
    return tab
end

function ZeusLib:_tabMethods()
    local methods = {}

    function methods:AddSection(name)
        local section = {
            Tab = self,
            Name = name or "Section",
        }
        setmetatable(section, {__index = self.Window:_sectionMethods()})
        section.Frame = create("Frame", {
            Name = "Section",
            Size = UDim2.new(1, 0, 0, 38),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = self.Window.Theme.Background,
            BorderSizePixel = 0,
            LayoutOrder = #self.Sections + 1,
            Parent = self.Page,
        })
        corner(section.Frame, 9)
        self.Window:_register(section.Frame, "BackgroundColor3", "Background")
        section.Title = self.Window:_createText("TextLabel", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Text = name or "Section",
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section.Frame,
        }, "Text")
        padding(section.Title, 14, 12, 0, 0)
        section.List = create("Frame", {
            Position = UDim2.new(0, 0, 0, 36),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = section.Frame,
        })
        padding(section.List, 12, 12, 0, 12)
        section.Layout = create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = section.List,
        })
        table.insert(self.Sections, section)
        return section
    end

    function methods:AddButton(options)
        return self:AddSection("Actions"):AddButton(options)
    end

    function methods:AddToggle(options)
        return self:AddSection("Options"):AddToggle(options)
    end

    function methods:AddCheckbox(options)
        return self:AddSection("Options"):AddCheckbox(options)
    end

    function methods:AddDropdown(options)
        return self:AddSection("Options"):AddDropdown(options)
    end

    function methods:AddInput(options)
        return self:AddSection("Input"):AddInput(options)
    end

    function methods:AddLabel(text)
        return self:AddSection("Info"):AddLabel(text)
    end

    function methods:AddKeybind(options)
        return self:AddSection("Controls"):AddKeybind(options)
    end

    return methods
end

function ZeusLib:_sectionMethods()
    local methods = {}

    function methods:_row(height)
        return create("Frame", {
            Size = UDim2.new(1, 0, 0, height or 38),
            BackgroundTransparency = 1,
            LayoutOrder = #self.List:GetChildren(),
            Parent = self.List,
        })
    end

    function methods:_nameLabel(parent, text)
        local label = self.Tab.Window:_createText("TextLabel", {
            Size = UDim2.new(1, -90, 1, 0),
            BackgroundTransparency = 1,
            Text = text or "Option",
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = parent,
        }, "Text")
        return label
    end

    function methods:AddButton(options)
        options = options or {}
        local row = self:_row(38)
        local button = self.Tab.Window:_createText("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = options.Name or options.Title or "Button",
            TextSize = 12,
            Parent = row,
        }, "Text")
        corner(button, 7)
        self.Tab.Window:_register(button, "BackgroundColor3", "SurfaceAlt")
        local callback = resolveCallback(options.Callback)
        button.MouseEnter:Connect(function()
            tween(button, {BackgroundColor3 = self.Tab.Window.Theme.Accent})
        end)
        button.MouseLeave:Connect(function()
            tween(button, {BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt})
        end)
        button.Activated:Connect(function()
            callback()
        end)
        return {
            Row = row,
            Button = button,
            SetText = function(_, text)
                button.Text = text
            end,
        }
    end

    function methods:AddToggle(options)
        options = options or {}
        local value = options.Default == true
        local row = self:_row(38)
        local label = self:_nameLabel(row, options.Name or options.Title or "Toggle")
        local switch = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(44, 24),
            BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            Parent = row,
        })
        corner(switch, 12)
        self.Tab.Window:_register(switch, "BackgroundColor3", "SurfaceAlt")
        local knob = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 4, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            BackgroundColor3 = self.Tab.Window.Theme.Muted,
            BorderSizePixel = 0,
            Parent = switch,
        })
        corner(knob, 8)
        self.Tab.Window:_register(knob, "BackgroundColor3", "Muted")
        local callback = resolveCallback(options.Callback)

        local function render()
            if value then
                tween(switch, {BackgroundColor3 = self.Tab.Window.Theme.Accent})
                tween(knob, {Position = UDim2.new(1, -20, 0.5, 0), BackgroundColor3 = self.Tab.Window.Theme.Text})
            else
                tween(switch, {BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt})
                tween(knob, {Position = UDim2.new(0, 4, 0.5, 0), BackgroundColor3 = self.Tab.Window.Theme.Muted})
            end
        end
        switch.Activated:Connect(function()
            value = not value
            render()
            callback(value)
        end)
        render()
        return {
            Row = row,
            Label = label,
            Set = function(_, state)
                value = state == true
                render()
                callback(value)
            end,
            Get = function()
                return value
            end,
        }
    end

    function methods:AddCheckbox(options)
        options = options or {}
        local value = options.Default == true
        local row = self:_row(38)
        local label = self:_nameLabel(row, options.Name or options.Title or "Checkbox")
        local box = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(22, 22),
            BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            Parent = row,
        })
        corner(box, 6)
        self.Tab.Window:_register(box, "BackgroundColor3", "SurfaceAlt")
        stroke(box, self.Tab.Window.Theme.Border, 1, 0)
        local check = self.Tab.Window:_createText("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "✓",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Visible = value,
            Parent = box,
        }, "Text")
        local callback = resolveCallback(options.Callback)

        box.Activated:Connect(function()
            value = not value
            check.Visible = value
            tween(box, {BackgroundColor3 = value and self.Tab.Window.Theme.Accent or self.Tab.Window.Theme.SurfaceAlt})
            callback(value)
        end)
        if value then
            box.BackgroundColor3 = self.Tab.Window.Theme.Accent
        end
        return {
            Row = row,
            Label = label,
            Set = function(_, state)
                value = state == true
                check.Visible = value
                box.BackgroundColor3 = value and self.Tab.Window.Theme.Accent or self.Tab.Window.Theme.SurfaceAlt
                callback(value)
            end,
            Get = function()
                return value
            end,
        }
    end

    function methods:AddDropdown(options)
        options = options or {}
        local values = options.Options or {}
        local selected = options.Default
        if selected == nil and #values > 0 then
            selected = values[1]
        end
        local row = self:_row(38)
        local label = self:_nameLabel(row, options.Name or options.Title or "Dropdown")
        local dropdown = self.Tab.Window:_createText("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(150, 30),
            BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = tostring(selected or "Select"),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        }, "Text")
        corner(dropdown, 7)
        padding(dropdown, 10, 24, 0, 0)
        self.Tab.Window:_register(dropdown, "BackgroundColor3", "SurfaceAlt")
        local arrow = self.Tab.Window:_createText("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(12, 18),
            BackgroundTransparency = 1,
            Text = "⌄",
            TextSize = 14,
            Parent = dropdown,
        }, "Muted")
        local callback = resolveCallback(options.Callback)
        local popup

        local function close()
            if self.Tab.Window.Dropdown and self.Tab.Window.Dropdown.Button == dropdown then
                self.Tab.Window.Dropdown = nil
                if popup then
                    popup:Destroy()
                end
                popup = nil
            end
        end

        local function open()
            if self.Tab.Window.Dropdown and self.Tab.Window.Dropdown.Button ~= dropdown then
                self.Tab.Window.Dropdown.Close()
            end
            if popup then
                close()
                return
            end
            self.Tab.Window.Dropdown = {
                Button = dropdown,
                Close = close,
            }
            popup = create("ScrollingFrame", {
                Name = "DropdownPopup",
                Position = UDim2.fromOffset(dropdown.AbsolutePosition.X, dropdown.AbsolutePosition.Y + dropdown.AbsoluteSize.Y + 5),
                Size = UDim2.fromOffset(math.max(dropdown.AbsoluteSize.X, 150), 0),
                BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = self.Tab.Window.Theme.Accent,
                ScrollingEnabled = true,
                ClipsDescendants = true,
                ZIndex = 220,
                Parent = self.Tab.Window.DropdownLayer,
            })
            corner(popup, 8)
            self.Tab.Window:_register(popup, "BackgroundColor3", "SurfaceAlt")
            self.Tab.Window:_register(popup, "ScrollBarImageColor3", "Accent")
            stroke(popup, self.Tab.Window.Theme.Border, 1, 0)
            padding(popup, 6, 6, 6, 6)
            local list = create("UIListLayout", {
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = popup,
            })
            for index, option in ipairs(values) do
                local optionButton = self.Tab.Window:_createText("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = tostring(option),
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = index,
                    ZIndex = 221,
                    Parent = popup,
                }, "Text")
                corner(optionButton, 6)
                padding(optionButton, 9, 6, 0, 0)
                self.Tab.Window:_register(optionButton, "BackgroundColor3", "SurfaceAlt")
                optionButton.MouseEnter:Connect(function()
                    tween(optionButton, {BackgroundColor3 = self.Tab.Window.Theme.Accent})
                end)
                optionButton.MouseLeave:Connect(function()
                    tween(optionButton, {BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt})
                end)
                optionButton.Activated:Connect(function()
                    selected = option
                    dropdown.Text = tostring(option)
                    callback(option)
                    close()
                end)
            end
            local viewport = self.Tab.Window.Root.AbsoluteSize
            local popupHeight = math.min(#values * 33 + 12, 190)
            popup.Size = UDim2.fromOffset(math.max(dropdown.AbsoluteSize.X, 150), popupHeight)
            local x = dropdown.AbsolutePosition.X
            local y = dropdown.AbsolutePosition.Y + dropdown.AbsoluteSize.Y + 5
            if y + popupHeight > viewport.Y - 8 then
                y = dropdown.AbsolutePosition.Y - popupHeight - 5
            end
            local scale = self.Tab.Window.Scale.Scale
            popup.Size = UDim2.fromOffset(math.max(dropdown.AbsoluteSize.X, 150) / scale, popupHeight / scale)
            popup.Position = UDim2.fromOffset(math.max(8, x) / scale, math.max(8, y) / scale)
        end

        dropdown.Activated:Connect(open)
        return {
            Row = row,
            Label = label,
            Set = function(_, value)
                selected = value
                dropdown.Text = tostring(value)
                callback(value)
            end,
            Get = function()
                return selected
            end,
            Close = close,
        }
    end

    function methods:AddInput(options)
        options = options or {}
        local row = self:_row(62)
        local label = self.Tab.Window:_createText("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = options.Name or options.Title or "Input",
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        }, "Muted")
        local input = self.Tab.Window:_createText("TextBox", {
            Position = UDim2.new(0, 0, 0, 24),
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            PlaceholderText = options.Placeholder or "Type here",
            Text = options.Default or "",
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        }, "Text")
        corner(input, 7)
        padding(input, 10, 10, 0, 0)
        self.Tab.Window:_register(input, "BackgroundColor3", "SurfaceAlt")
        local callback = resolveCallback(options.Callback)
        input.FocusLost:Connect(function()
            callback(input.Text)
        end)
        if options.Numeric then
            input:GetPropertyChangedSignal("Text"):Connect(function()
                local filtered = input.Text:gsub("[^%d%.%-]", "")
                if input.Text ~= filtered then
                    input.Text = filtered
                end
            end)
        end
        return {
            Row = row,
            Label = label,
            Input = input,
            Set = function(_, value)
                input.Text = tostring(value)
            end,
            Get = function()
                return input.Text
            end,
        }
    end

    function methods:AddLabel(text)
        local row = self:_row(28)
        local label = self.Tab.Window:_createText("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = tostring(text or ""),
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        }, "Muted")
        return {
            Row = row,
            Label = label,
            SetText = function(_, value)
                label.Text = tostring(value)
            end,
        }
    end

    function methods:AddKeybind(options)
        options = options or {}
        local key = options.Default or Enum.KeyCode.RightControl
        local listening = false
        local row = self:_row(38)
        local label = self:_nameLabel(row, options.Name or "Keybind")
        local button = self.Tab.Window:_createText("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(150, 30),
            BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = key.Name,
            TextSize = 11,
            Parent = row,
        }, "Text")
        corner(button, 7)
        self.Tab.Window:_register(button, "BackgroundColor3", "SurfaceAlt")
        local callback = resolveCallback(options.Callback)
        button.Activated:Connect(function()
            listening = true
            button.Text = "Press a key"
            tween(button, {BackgroundColor3 = self.Tab.Window.Theme.Accent})
        end)
        table.insert(self.Tab.Window.Connections, UserInputService.InputBegan:Connect(function(input, processed)
            if processed or not listening or input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end
            key = input.KeyCode
            listening = false
            button.Text = key.Name
            tween(button, {BackgroundColor3 = self.Tab.Window.Theme.SurfaceAlt})
            callback(key)
        end))
        return {
            Row = row,
            Label = label,
            Button = button,
            Set = function(_, value)
                key = value
                button.Text = key.Name
                callback(key)
            end,
            Get = function()
                return key
            end,
        }
    end

    return methods
end

function ZeusLib:AddTab(options)
    options = options or {}
    return self:_createTab(options.Name or options.Title or "Tab", false)
end

function ZeusLib:SelectTab(tab)
    if self.CurrentTab == tab then
        return
    end
    for _, item in ipairs(self.Tabs) do
        local active = item == tab
        item.Page.Visible = active
        if active then
            tween(item.Button, {BackgroundColor3 = self.Theme.Accent, TextColor3 = self.Theme.Text})
        else
            tween(item.Button, {BackgroundColor3 = self.Theme.Surface, TextColor3 = self.Theme.Muted})
        end
    end
    self.CurrentTab = tab
end

function ZeusLib:SetVisible(visible)
    self.Visible = visible == true
    self.Main.Visible = self.Visible
    if self.Dropdown then
        self.Dropdown.Close()
    end
end

function ZeusLib:SetKeybind(key)
    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
        self.Keybind = key
    end
end

function ZeusLib:SetTheme(name)
    if not Themes[name] then
        return
    end
    self.ThemeName = name
    self.Theme = Themes[name]
    for _, entry in ipairs(self.ThemeRegistry) do
        if entry.Instance and entry.Instance.Parent then
            entry.Instance[entry.Property] = self.Theme[entry.Key]
        end
    end
    for _, item in ipairs(self.Tabs) do
        if item == self.CurrentTab then
            item.Button.BackgroundColor3 = self.Theme.Accent
            item.Button.TextColor3 = self.Theme.Text
        end
    end
end

function ZeusLib:SetFont(name)
    if not Fonts[name] then
        return
    end
    self.FontName = name
    self.Font = Fonts[name]
    for _, instance in ipairs(self.FontRegistry) do
        if instance and instance.Parent then
            instance.Font = self.Font
        end
    end
end

function ZeusLib:Notify(options)
    if typeof(options) == "string" then
        options = {Content = options}
    end
    options = options or {}
    local toast = create("Frame", {
        Name = "Notification",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 330, 0, 18),
        Size = UDim2.fromOffset(300, 76),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 300,
        Parent = self.Root,
    })
    corner(toast, 9)
    self:_register(toast, "BackgroundColor3", "Surface")
    stroke(toast, self.Theme.Accent, 1, 0.35)
    local title = self:_createText("TextLabel", {
        Position = UDim2.fromOffset(14, 10),
        Size = UDim2.new(1, -28, 0, 18),
        BackgroundTransparency = 1,
        Text = options.Title or "ZeusLib",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 301,
        Parent = toast,
    }, "Text")
    local content = self:_createText("TextLabel", {
        Position = UDim2.fromOffset(14, 31),
        Size = UDim2.new(1, -28, 0, 32),
        BackgroundTransparency = 1,
        Text = options.Content or options.Text or "",
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 301,
        Parent = toast,
    }, "Muted")
    tween(toast, {Position = UDim2.new(1, -18, 0, 18)}, 0.3)
    task.delay(options.Duration or 3, function()
        if toast.Parent then
            local animation = tween(toast, {Position = UDim2.new(1, 330, 0, 18)}, 0.25)
            animation.Completed:Wait()
            toast:Destroy()
        end
    end)
    return toast
end

function ZeusLib:Destroy()
    self.Destroyed = true
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

ZeusLib.Themes = Themes
ZeusLib.Fonts = Fonts

return ZeusLib