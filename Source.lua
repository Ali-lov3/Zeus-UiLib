local Zeus = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Groupbox = {}
Groupbox.__index = Groupbox

local COLORS = {
    Background = Color3.fromRGB(14, 14, 17),
    Surface = Color3.fromRGB(18, 18, 22),
    SurfaceLight = Color3.fromRGB(23, 23, 28),
    Border = Color3.fromRGB(43, 43, 50),
    Text = Color3.fromRGB(235, 235, 240),
    Muted = Color3.fromRGB(137, 137, 149),
    Accent = Color3.fromRGB(125, 92, 255),
    AccentLight = Color3.fromRGB(158, 133, 255),
    Track = Color3.fromRGB(45, 44, 55),
}

local function create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function addCorner(object, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
    }, object)
end

local function addStroke(object, color, transparency)
    return create("UIStroke", {
        Color = color or COLORS.Border,
        Transparency = transparency or 0,
        Thickness = 1,
    }, object)
end

local function addPadding(object, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    }, object)
end

local function tween(object, duration, properties)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function resolveParent()
    local success, hiddenGui = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return nil
    end)

    if success and hiddenGui then
        return hiddenGui
    end

    local player = Players.LocalPlayer
    if player then
        return player:WaitForChild("PlayerGui")
    end

    return CoreGui
end

local function normalizeOptions(options, fallbackName)
    if type(options) == "string" then
        return { Name = options }
    end

    options = options or {}
    if not options.Name then
        options.Name = fallbackName
    end

    return options
end

function Window:_track(connection)
    table.insert(self._connections, connection)
    return connection
end

function Window:_updateScale()
    if not self.Gui or not self.Gui.Parent then
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local scale = math.min(viewport.X / 980, viewport.Y / 650)
    self.Scale.Scale = math.clamp(scale, 0.72, 1.12)
end

function Window:_selectTab(tab)
    self.ActiveTab = tab

    for _, otherTab in ipairs(self.Tabs) do
        local selected = otherTab == tab
        otherTab.Page.Visible = selected

        if selected then
            tween(otherTab.Button, 0.14, {
                BackgroundColor3 = COLORS.SurfaceLight,
                TextColor3 = COLORS.Text,
            })
            otherTab.Indicator.Visible = true
        else
            tween(otherTab.Button, 0.14, {
                BackgroundColor3 = COLORS.Surface,
                TextColor3 = COLORS.Muted,
            })
            otherTab.Indicator.Visible = false
        end
    end
end

function Window:CreateTab(options)
    options = normalizeOptions(options, "Tab")

    local tab = setmetatable({
        Window = self,
        Name = options.Name,
        Icon = options.Icon or "",
        Page = nil,
        Button = nil,
        Indicator = nil,
        _left = nil,
        _right = nil,
    }, Tab)

    tab.Button = create("TextButton", {
        Name = options.Name .. "Tab",
        AutoButtonColor = false,
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 34),
        Text = "",
        TextColor3 = COLORS.Muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, self.TabList)
    addCorner(tab.Button, 5)
    addPadding(tab.Button, 11, 8, 0, 0)

    if tab.Icon ~= "" then
        create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Size = UDim2.fromOffset(18, 34),
            Text = tab.Icon,
            TextColor3 = COLORS.Muted,
            TextSize = 11,
        }, tab.Button)
    end

    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Position = tab.Icon ~= "" and UDim2.fromOffset(25, 0) or UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, tab.Icon ~= "" and -25 or 0, 1, 0),
        Text = tab.Name,
        TextColor3 = COLORS.Muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, tab.Button)

    tab.Indicator = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -7, 0.5, 0),
        Size = UDim2.fromOffset(3, 16),
        Visible = false,
    }, tab.Button)
    addCorner(tab.Indicator, 2)

    local page = create("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ElasticBehavior = Enum.ElasticBehavior.Always,
        Name = tab.Name .. "Page",
        Position = UDim2.fromOffset(0, 0),
        ScrollBarImageColor3 = COLORS.Accent,
        ScrollBarImageTransparency = 0.25,
        ScrollBarThickness = 3,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
    }, self.PageHolder)
    addPadding(page, 12, 9, 12, 12)
    tab.Page = page

    local columns = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
    }, page)

    local left = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -5, 0, 0),
    }, columns)
    local leftLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, left)

    local right = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.5, -5, 0, 0),
    }, columns)
    local rightLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, right)

    tab._columns = columns
    tab._left = left
    tab._right = right
    tab._leftLayout = leftLayout
    tab._rightLayout = rightLayout

    local function updateCanvas()
        local height = math.max(leftLayout.AbsoluteContentSize.Y, rightLayout.AbsoluteContentSize.Y)
        columns.Size = UDim2.new(1, 0, 0, height)
        page.CanvasSize = UDim2.new(0, 0, 0, height + 4)
    end

    self:_track(leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas))
    self:_track(rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas))
    self:_track(tab.Button.MouseButton1Click:Connect(function()
        self:_selectTab(tab)
    end))

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self:_selectTab(tab)
    end

    return tab
end

function Window:CreateKeybind(options)
    options = normalizeOptions(options, "Toggle UI")
    local key = options.Default or Enum.KeyCode.RightShift
    local listening = false

    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = COLORS.SurfaceLight,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.new(1, -98, 0, 8),
        Size = UDim2.fromOffset(90, 24),
        Text = key.Name,
        TextColor3 = COLORS.Muted,
        TextSize = 11,
    }, self.Header)
    addCorner(button, 5)

    self:_track(button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "Press a key"
        button.TextColor3 = COLORS.AccentLight
    end))

    self:_track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed or not listening or input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        if input.KeyCode == Enum.KeyCode.Unknown then
            return
        end

        key = input.KeyCode
        listening = false
        button.Text = key.Name
        button.TextColor3 = COLORS.Muted
    end))

    self:_track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed or listening then
            return
        end

        if input.KeyCode == key then
            self:SetVisible(not self.Gui.Enabled)
        end
    end))

    return button
end

function Window:SetVisible(visible)
    self.Gui.Enabled = visible
end

function Window:Toggle()
    self:SetVisible(not self.Gui.Enabled)
end

function Window:Notify(options)
    options = options or {}

    local notification = create("Frame", {
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 280, 1, -70),
        Size = UDim2.fromOffset(260, 52),
    }, self.NotificationHolder)
    addCorner(notification, 6)
    addStroke(notification, COLORS.Border)

    create("Frame", {
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(3, 52),
    }, notification)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.fromOffset(15, 8),
        Size = UDim2.new(1, -25, 0, 16),
        Text = options.Title or "Zeus UI",
        TextColor3 = COLORS.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, notification)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(15, 25),
        Size = UDim2.new(1, -25, 0, 16),
        Text = options.Content or "",
        TextColor3 = COLORS.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, notification)

    tween(notification, 0.2, { Position = UDim2.new(1, -12, 1, -70) })

    task.delay(options.Duration or 3, function()
        if notification.Parent then
            local animation = tween(notification, 0.18, {
                Position = UDim2.new(1, 280, 1, -70),
            })
            animation.Completed:Wait()
            notification:Destroy()
        end
    end)
end

function Window:Destroy()
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end

    if self.Gui then
        self.Gui:Destroy()
    end
end

function Zeus:CreateWindow(options)
    options = options or {}

    local existing = resolveParent():FindFirstChild("ZeusUI")
    if existing then
        existing:Destroy()
    end

    local window = setmetatable({
        Tabs = {},
        ActiveTab = nil,
        _connections = {},
    }, Window)

    local gui = create("ScreenGui", {
        DisplayOrder = 100,
        IgnoreGuiInset = true,
        Name = "ZeusUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    }, resolveParent())
    window.Gui = gui

    local scale = create("UIScale", {
        Scale = 1,
    }, gui)
    window.Scale = scale

    local main = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(720, 460),
    }, gui)
    window.Main = main
    addCorner(main, 8)
    addStroke(main, COLORS.Border)

    local header = create("Frame", {
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
    }, main)
    window.Header = header
    addCorner(header, 8)

    create("Frame", {
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 13),
        Size = UDim2.fromOffset(4, 16),
    }, header)
    addCorner(header:FindFirstChildOfClass("Frame"), 2)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.fromOffset(26, 7),
        Size = UDim2.fromOffset(180, 18),
        Text = options.Title or "Zeus UI",
        TextColor3 = COLORS.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(26, 23),
        Size = UDim2.fromOffset(270, 13),
        Text = options.Subtitle or "A focused interface for Roblox",
        TextColor3 = COLORS.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    local minimize = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(1, -30, 0.5, 0),
        Size = UDim2.fromOffset(22, 24),
        Text = "—",
        TextColor3 = COLORS.Muted,
        TextSize = 13,
    }, header)

    local close = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(18, 24),
        Text = "×",
        TextColor3 = COLORS.Muted,
        TextSize = 15,
    }, header)

    window:_track(minimize.MouseButton1Click:Connect(function()
        window:SetVisible(false)
    end))
    window:_track(close.MouseButton1Click:Connect(function()
        window:Destroy()
    end))

    local sidebar = create("Frame", {
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 42),
        Size = UDim2.new(0, 156, 1, -42),
    }, main)
    addCorner(sidebar, 8)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.fromOffset(14, 16),
        Size = UDim2.new(1, -28, 0, 14),
        Text = options.MenuTitle or "MENU",
        TextColor3 = COLORS.Muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sidebar)

    local tabList = create("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        Position = UDim2.fromOffset(10, 42),
        ScrollBarThickness = 0,
        Size = UDim2.new(1, -20, 1, -52),
    }, sidebar)
    create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabList)
    window.TabList = tabList

    local holder = create("Frame", {
        BackgroundColor3 = COLORS.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(156, 42),
        Size = UDim2.new(1, -156, 1, -42),
    }, main)
    window.PageHolder = holder
    addCorner(holder, 8)

    local notifications = create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 1, -10),
        Size = UDim2.fromOffset(270, 240),
    }, gui)
    window.NotificationHolder = notifications

    local dragging = false
    local dragStart
    local startPosition

    window:_track(header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end))

    window:_track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    window:_track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end))

    window:_track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        window:_updateScale()
    end))

    local function connectViewport()
        local camera = workspace.CurrentCamera
        if camera then
            window:_track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                window:_updateScale()
            end))
        end
        window:_updateScale()
    end
    connectViewport()

    window:CreateKeybind({
        Default = options.ToggleKey or Enum.KeyCode.RightShift,
    })

    return window
end

function Groupbox:_resize(amount)
    self.Height = self.Height + amount
    self.Frame.Size = UDim2.new(1, 0, 0, self.Height)
end

function Groupbox:_addRow(height)
    self:_resize(height)
end

function Groupbox:AddLabel(text)
    local label = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Size = UDim2.new(1, 0, 0, 19),
        Text = text or "",
        TextColor3 = COLORS.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, self.Content)

    self:_addRow(25)
    return label
end

function Groupbox:AddDivider()
    local divider = create("Frame", {
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
    }, self.Content)

    self:_addRow(9)
    return divider
end

function Groupbox:AddButton(options, callback)
    options = normalizeOptions(options, "Button")
    callback = callback or options.Callback

    local button = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = COLORS.SurfaceLight,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 30),
        Text = options.Name,
        TextColor3 = COLORS.Text,
        TextSize = 11,
    }, self.Content)
    addCorner(button, 5)
    addStroke(button, COLORS.Border)

    self.Window:_track(button.MouseEnter:Connect(function()
        tween(button, 0.12, { BackgroundColor3 = COLORS.Border })
    end))
    self.Window:_track(button.MouseLeave:Connect(function()
        tween(button, 0.12, { BackgroundColor3 = COLORS.SurfaceLight })
    end))
    self.Window:_track(button.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(callback)
        end
    end))

    self:_addRow(38)
    return button
end

function Groupbox:AddToggle(options)
    options = normalizeOptions(options, "Toggle")
    local value = options.Default == true
    local row = create("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Text = "",
    }, self.Content)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, -42, 1, 0),
        Text = options.Name,
        TextColor3 = COLORS.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local switch = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = COLORS.Track,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(30, 16),
    }, row)
    addCorner(switch, 8)
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = COLORS.Muted,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
    }, switch)
    addCorner(knob, 6)

    local control = {
        Window = self.Window,
        Value = value,
        Row = row,
    }

    function control:SetValue(newValue, silent)
        value = newValue == true
        control.Value = value
        tween(switch, 0.14, {
            BackgroundColor3 = value and COLORS.Accent or COLORS.Track,
        })
        tween(knob, 0.14, {
            BackgroundColor3 = value and COLORS.Text or COLORS.Muted,
            Position = value and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        })

        if not silent and options.Callback then
            task.spawn(options.Callback, value)
        end
    end

    function control:GetValue()
        return value
    end

    self.Window:_track(row.MouseButton1Click:Connect(function()
        control:SetValue(not value)
    end))
    control:SetValue(value, true)
    self:_addRow(36)
    return control
end

function Groupbox:AddSlider(options)
    options = normalizeOptions(options, "Slider")
    local minimum = options.Min or 0
    local maximum = options.Max or 100
    local value = math.clamp(options.Default or minimum, minimum, maximum)
    local dragging = false

    local row = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42),
    }, self.Content)

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, -58, 0, 17),
        Text = options.Name,
        TextColor3 = COLORS.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local valueLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(52, 17),
        TextColor3 = COLORS.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)

    local track = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = COLORS.Track,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -4),
        Size = UDim2.new(1, 0, 0, 4),
    }, row)
    addCorner(track, 2)
    local fill = create("Frame", {
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
    }, track)
    addCorner(fill, 2)

    local control = {
        Window = self.Window,
        Value = value,
        Row = row,
    }

    local function setFromInput(input)
        local percentage = math.clamp(
            (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0,
            1
        )
        local step = options.Rounding or 1
        local nextValue = minimum + (maximum - minimum) * percentage
        nextValue = math.floor(nextValue / step + 0.5) * step
        control:SetValue(nextValue)
    end

    function control:SetValue(newValue, silent)
        value = math.clamp(newValue, minimum, maximum)
        control.Value = value
        local percentage = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        valueLabel.Text = tostring(value) .. (options.Suffix or "")

        if not silent and options.Callback then
            task.spawn(options.Callback, value)
        end
    end

    function control:GetValue()
        return value
    end

    self.Window:_track(track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromInput(input)
        end
    end))
    self.Window:_track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    self.Window:_track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setFromInput(input)
        end
    end))

    control:SetValue(value, true)
    self:_addRow(50)
    return control
end

function Groupbox:AddDropdown(options)
    options = normalizeOptions(options, "Dropdown")
    local values = options.Values or options.Options or {}
    local selected = options.Default or values[1] or "Select"
    local expanded = false

    local row = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
    }, self.Content)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 17),
        Text = options.Name,
        TextColor3 = COLORS.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local selectButton = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = COLORS.SurfaceLight,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 22),
        Size = UDim2.new(1, 0, 0, 26),
        Text = "",
    }, row)
    addCorner(selectButton, 5)
    addStroke(selectButton, COLORS.Border)

    local selectedLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Text = tostring(selected),
        TextColor3 = COLORS.Muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, selectButton)

    create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(1, -9, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        Text = "⌄",
        TextColor3 = COLORS.Muted,
        TextSize = 12,
    }, selectButton)

    local optionList = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = COLORS.SurfaceLight,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 52),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ZIndex = 5,
    }, row)
    addCorner(optionList, 5)
    addStroke(optionList, COLORS.Border)
    local optionLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, optionList)

    local control = {
        Window = self.Window,
        Value = selected,
        Row = row,
    }

    local function close()
        expanded = false
        optionList.Visible = false
        row.Size = UDim2.new(1, 0, 0, 48)
        self.Height = self.Height - (#values * 25 + 5)
        self.Frame.Size = UDim2.new(1, 0, 0, self.Height)
    end

    for _, item in ipairs(values) do
        local optionButton = create("TextButton", {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 25),
            Text = tostring(item),
            TextColor3 = COLORS.Muted,
            TextSize = 10,
            ZIndex = 6,
        }, optionList)

        self.Window:_track(optionButton.MouseEnter:Connect(function()
            optionButton.TextColor3 = COLORS.Text
        end))
        self.Window:_track(optionButton.MouseLeave:Connect(function()
            optionButton.TextColor3 = COLORS.Muted
        end))
        self.Window:_track(optionButton.MouseButton1Click:Connect(function()
            selected = item
            control.Value = item
            selectedLabel.Text = tostring(item)
            close()
            if options.Callback then
                task.spawn(options.Callback, item)
            end
        end))
    end

    function control:SetValue(newValue, silent)
        selected = newValue
        control.Value = newValue
        selectedLabel.Text = tostring(newValue)
        if not silent and options.Callback then
            task.spawn(options.Callback, newValue)
        end
    end

    function control:GetValue()
        return selected
    end

    self.Window:_track(selectButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        optionList.Visible = expanded
        if expanded then
            row.Size = UDim2.new(1, 0, 0, 48 + #values * 25 + 5)
            self.Height = self.Height + (#values * 25 + 5)
        else
            close()
        end
        self.Frame.Size = UDim2.new(1, 0, 0, self.Height)
    end))

    self:_addRow(56)
    return control
end

function Tab:CreateGroupbox(options)
    options = normalizeOptions(options, "Section")
    local group = setmetatable({
        Tab = self,
        Window = self.Window,
        Height = 48,
    }, Groupbox)

    local side = string.lower(options.Side or options.Column or "Left")
    local parent = side == "right" and self._right or self._left
    local layoutOrder = options.LayoutOrder or 1

    local frame = create("Frame", {
        BackgroundColor3 = COLORS.Surface,
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder,
        Size = UDim2.new(1, 0, 0, group.Height),
    }, parent)
    group.Frame = frame
    addCorner(frame, 6)
    addStroke(frame, COLORS.Border)

    local header = create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Position = UDim2.fromOffset(12, 10),
        Size = UDim2.new(1, -24, 0, 17),
        Text = options.Name,
        TextColor3 = COLORS.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local line = create("Frame", {
        BackgroundColor3 = COLORS.Border,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(12, 35),
        Size = UDim2.new(1, -24, 0, 1),
    }, frame)

    local content = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 43),
        Size = UDim2.new(1, -24, 0, 0),
    }, frame)
    group.Content = content
    local contentLayout = create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, content)

    self.Window:_track(contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        group.Frame.Size = UDim2.new(1, 0, 0, math.max(48, 48 + contentLayout.AbsoluteContentSize.Y))
    end))

    return group
end

Tab.CreateSection = Tab.CreateGroupbox
Tab.AddGroupbox = Tab.CreateGroupbox

function Tab:AddLeftGroupbox(name)
    return self:CreateGroupbox({ Name = name, Side = "Left" })
end

function Tab:AddRightGroupbox(name)
    return self:CreateGroupbox({ Name = name, Side = "Right" })
end

return Zeus
