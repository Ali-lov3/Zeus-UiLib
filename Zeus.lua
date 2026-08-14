local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local ZeusLib = {}
ZeusLib.__index = ZeusLib

local Themes = {
	Pink = {
		Background = Color3.fromRGB(15, 15, 18),
		Secondary = Color3.fromRGB(22, 22, 26),
		Stroke = Color3.fromRGB(40, 40, 46),
		Accent = Color3.fromRGB(255, 45, 130),
		AccentDark = Color3.fromRGB(180, 30, 95),
		Text = Color3.fromRGB(235, 235, 240),
		SubText = Color3.fromRGB(150, 150, 158),
	},
	Midnight = {
		Background = Color3.fromRGB(10, 10, 14),
		Secondary = Color3.fromRGB(18, 18, 24),
		Stroke = Color3.fromRGB(35, 35, 42),
		Accent = Color3.fromRGB(120, 90, 255),
		AccentDark = Color3.fromRGB(80, 60, 190),
		Text = Color3.fromRGB(235, 235, 240),
		SubText = Color3.fromRGB(150, 150, 158),
	},
}

local Fonts = {
	Gotham = Enum.Font.Gotham,
	GothamBold = Enum.Font.GothamBold,
	Code = Enum.Font.Code,
}

local function Create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

local function Tween(inst, props, time, style)
	local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(inst, info, props)
	tween:Play()
	return tween
end

function ZeusLib.new(config)
	config = config or {}
	local self = setmetatable({}, ZeusLib)

	self.Title = config.Title or "ZeusLib"
	self.ToggleKeybind = config.Keybind or Enum.KeyCode.RightShift
	self.CurrentTheme = Themes[config.Theme] or Themes.Pink
	self.CurrentFont = Fonts.GothamBold
	self.Tabs = {}
	self.TabButtons = {}
	self.Open = true
	self.ActiveDropdown = nil

	local ScreenGui = Create("ScreenGui", {
		Name = "ZeusLib",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		IgnoreGuiInset = true,
		Parent = PlayerGui,
	})
	self.ScreenGui = ScreenGui

	local Main = Create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.62, 0.68),
		BackgroundColor3 = self.CurrentTheme.Background,
		BorderSizePixel = 0,
		Parent = ScreenGui,
	})
	self.Main = Main

	local sizeConstraint = Create("UISizeConstraint", {
		MinSize = Vector2.new(520, 340),
		MaxSize = Vector2.new(1000, 680),
	})
	sizeConstraint.Parent = Main

	Create("UICorner", { CornerRadius = UDim.new(0, 10) }, {}).Parent = Main
	local mainStroke = Create("UIStroke", { Color = self.CurrentTheme.Stroke, Thickness = 1 })
	mainStroke.Parent = Main
	self.MainStroke = mainStroke

	local TopBar = Create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = self.CurrentTheme.Secondary,
		BorderSizePixel = 0,
		Parent = Main,
	})
	local topBarConstraint = Create("UIAspectRatioConstraint", {})
	topBarConstraint:Destroy()
	local topBarSize = Create("UISizeConstraint", { MaxSize = Vector2.new(9999, 46), MinSize = Vector2.new(0, 40) })
	topBarSize.Parent = TopBar
	TopBar.Size = UDim2.new(1, 0, 0.09, 0)
	Create("UICorner", { CornerRadius = UDim.new(0, 10) }).Parent = TopBar

	local TopBarCover = Create("Frame", {
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = self.CurrentTheme.Secondary,
		BorderSizePixel = 0,
		Parent = TopBar,
	})

	local TitleLabel = Create("TextLabel", {
		Text = self.Title,
		Font = self.CurrentFont,
		TextSize = 16,
		TextColor3 = self.CurrentTheme.Text,
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.03, 0),
		Size = UDim2.fromScale(0.5, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TopBar,
	})
	self.TitleLabel = TitleLabel

	local CloseBtn = Create("TextButton", {
		Text = "",
		BackgroundColor3 = self.CurrentTheme.Accent,
		Size = UDim2.fromOffset(26, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		AutoButtonColor = false,
		Parent = TopBar,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = CloseBtn

	local TabHolder = Create("Frame", {
		Name = "TabHolder",
		Position = UDim2.new(0, 0, 0.09, 6),
		Size = UDim2.new(0.24, 0, 0.91, -6),
		BackgroundColor3 = self.CurrentTheme.Secondary,
		BorderSizePixel = 0,
		Parent = Main,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = TabHolder

	local TabList = Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	TabList.Parent = TabHolder
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
	}).Parent = TabHolder
	self.TabHolder = TabHolder

	local ContentHolder = Create("Frame", {
		Name = "ContentHolder",
		Position = UDim2.new(0.25, 6, 0.09, 6),
		Size = UDim2.new(0.75, -6, 0.91, -6),
		BackgroundTransparency = 1,
		Parent = Main,
	})
	self.ContentHolder = ContentHolder

	local MobileToggle
	if IsMobile then
		MobileToggle = Create("TextButton", {
			Text = "Z",
			Font = Fonts.GothamBold,
			TextSize = 20,
			TextColor3 = Color3.new(1, 1, 1),
			BackgroundColor3 = self.CurrentTheme.Accent,
			Size = UDim2.fromOffset(50, 50),
			Position = UDim2.fromScale(0.02, 0.4),
			Parent = ScreenGui,
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = MobileToggle

		local dragging, dragStart, startPos
		MobileToggle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = MobileToggle.Position
			end
		end)
		MobileToggle.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - dragStart
				MobileToggle.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
		MobileToggle.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		MobileToggle.MouseButton1Click:Connect(function()
			self:Toggle()
		end)
	end
	self.MobileToggle = MobileToggle

	CloseBtn.MouseButton1Click:Connect(function()
		self:Toggle()
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == self.ToggleKeybind then
			self:Toggle()
		end
	end)

	local dragging, dragInput, dragStart, startPos
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	TopBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	local NotifHolder = Create("Frame", {
		Name = "NotifHolder",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromScale(0.22, 0.6),
		BackgroundTransparency = 1,
		Parent = ScreenGui,
	})
	local notifList = Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	notifList.Parent = NotifHolder
	self.NotifHolder = NotifHolder

	self:CreateUISettingsTab()

	return self
end

function ZeusLib:Toggle()
	self.Open = not self.Open
	if self.Open then
		self.Main.Visible = true
		Tween(self.Main, { Size = UDim2.fromScale(0.62, 0.68) }, 0.2)
	else
		Tween(self.Main, { Size = UDim2.fromScale(0, 0) }, 0.18)
		task.delay(0.18, function()
			if not self.Open then
				self.Main.Visible = false
			end
		end)
	end
end

function ZeusLib:Notify(config)
	config = config or {}
	local theme = self.CurrentTheme

	local NotifFrame = Create("Frame", {
		BackgroundColor3 = theme.Secondary,
		Size = UDim2.new(1, 0, 0, 60),
		BorderSizePixel = 0,
		LayoutOrder = -os.clock(),
		Parent = self.NotifHolder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = NotifFrame
	Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }).Parent = NotifFrame

	local AccentBar = Create("Frame", {
		BackgroundColor3 = theme.Accent,
		Size = UDim2.new(0, 4, 1, 0),
		BorderSizePixel = 0,
		Parent = NotifFrame,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 4) }).Parent = AccentBar

	Create("TextLabel", {
		Text = config.Title or "Notification",
		Font = Fonts.GothamBold,
		TextSize = 14,
		TextColor3 = theme.Text,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 6),
		Size = UDim2.new(1, -20, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = NotifFrame,
	})
	Create("TextLabel", {
		Text = config.Content or "",
		Font = Fonts.Gotham,
		TextSize = 12,
		TextColor3 = theme.SubText,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 26),
		Size = UDim2.new(1, -20, 0, 28),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = NotifFrame,
	})

	NotifFrame.BackgroundTransparency = 1
	AccentBar.BackgroundTransparency = 1
	Tween(NotifFrame, { BackgroundTransparency = 0 }, 0.25)
	Tween(AccentBar, { BackgroundTransparency = 0 }, 0.25)

	task.delay(config.Duration or 4, function()
		Tween(NotifFrame, { BackgroundTransparency = 1 }, 0.25)
		task.wait(0.25)
		NotifFrame:Destroy()
	end)
end

function ZeusLib:AddTab(name, isSettingsTab)
	local theme = self.CurrentTheme

	local TabButton = Create("TextButton", {
		Text = name,
		Font = Fonts.Gotham,
		TextSize = 13,
		TextColor3 = theme.SubText,
		BackgroundColor3 = theme.Background,
		Size = UDim2.new(1, 0, 0, 32),
		AutoButtonColor = false,
		LayoutOrder = isSettingsTab and 999 or #self.Tabs,
		Parent = self.TabHolder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = TabButton

	local Page = Create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.ContentHolder,
	})
	local PageLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	PageLayout.Parent = Page

	local tabData = {
		Name = name,
		Button = TabButton,
		Page = Page,
	}
	table.insert(self.Tabs, tabData)

	TabButton.MouseButton1Click:Connect(function()
		self:SelectTab(tabData)
	end)

	if #self.Tabs == 1 or isSettingsTab == "select" then
		self:SelectTab(tabData)
	end

	local tabObject = {}

	function tabObject:AddSection(sectionName)
		local theme2 = self.Zeus.CurrentTheme
		local Section = Create("Frame", {
			BackgroundColor3 = theme2.Secondary,
			Size = UDim2.new(1, 0, 0, 40),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			Parent = Page,
		})
		Create("UICorner", { CornerRadius = UDim.new(0, 8) }).Parent = Section
		Create("UIStroke", { Color = theme2.Stroke, Thickness = 1 }).Parent = Section

		local SectionTitle = Create("TextLabel", {
			Text = sectionName,
			Font = Fonts.GothamBold,
			TextSize = 13,
			TextColor3 = theme2.Text,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 8),
			Size = UDim2.new(1, -24, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Section,
		})

		local ElementHolder = Create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 32),
			Size = UDim2.new(1, -20, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = Section,
		})
		local ElementLayout = Create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		ElementLayout.Parent = ElementHolder
		Create("UIPadding", { PaddingBottom = UDim.new(0, 12) }).Parent = ElementHolder

		local sectionObject = { Zeus = self.Zeus, Holder = ElementHolder }
		return setmetatable(sectionObject, { __index = ZeusLib.SectionMethods })
	end

	tabObject.Zeus = self
	return setmetatable(tabObject, { __index = tabObject })
end

function ZeusLib:SelectTab(tabData)
	for _, t in ipairs(self.Tabs) do
		t.Page.Visible = false
		Tween(t.Button, { BackgroundColor3 = self.CurrentTheme.Background, TextColor3 = self.CurrentTheme.SubText }, 0.15)
	end
	tabData.Page.Visible = true
	Tween(tabData.Button, { BackgroundColor3 = self.CurrentTheme.AccentDark, TextColor3 = self.CurrentTheme.Text }, 0.15)
	self.ActiveTab = tabData
end

ZeusLib.SectionMethods = {}

function ZeusLib.SectionMethods:AddLabel(text)
	local theme = self.Zeus.CurrentTheme
	local Label = Create("TextLabel", {
		Text = text,
		Font = Fonts.Gotham,
		TextSize = 13,
		TextColor3 = theme.SubText,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Holder,
	})
	return Label
end

function ZeusLib.SectionMethods:AddButton(config)
	config = config or {}
	local theme = self.Zeus.CurrentTheme
	local Btn = Create("TextButton", {
		Text = config.Name or "Button",
		Font = Fonts.Gotham,
		TextSize = 13,
		TextColor3 = theme.Text,
		BackgroundColor3 = theme.Background,
		Size = UDim2.new(1, 0, 0, 32),
		AutoButtonColor = false,
		Parent = self.Holder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = Btn
	Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }).Parent = Btn

	Btn.MouseEnter:Connect(function()
		Tween(Btn, { BackgroundColor3 = theme.AccentDark }, 0.15)
	end)
	Btn.MouseLeave:Connect(function()
		Tween(Btn, { BackgroundColor3 = theme.Background }, 0.15)
	end)
	Btn.MouseButton1Click:Connect(function()
		if config.Callback then
			config.Callback()
		end
	end)
	return Btn
end

function ZeusLib.SectionMethods:AddToggle(config)
	config = config or {}
	local theme = self.Zeus.CurrentTheme
	local state = config.Default or false

	local Holder = Create("Frame", {
		BackgroundColor3 = theme.Background,
		Size = UDim2.new(1, 0, 0, 32),
		BorderSizePixel = 0,
		Parent = self.Holder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = Holder
	Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }).Parent = Holder

	Create("TextLabel", {
		Text = config.Name or "Toggle",
		Font = Fonts.Gotham,
		TextSize = 13,
		TextColor3 = theme.Text,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Holder,
	})

	local Switch = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(38, 20),
		BackgroundColor3 = state and theme.Accent or theme.Stroke,
		Parent = Holder,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = Switch

	local Knob = Create("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = Switch,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0) }).Parent = Knob

	local Click = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = Holder,
	})

	local function setState(new)
		state = new
		Tween(Switch, { BackgroundColor3 = state and theme.Accent or theme.Stroke }, 0.15)
		Tween(Knob, { Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) }, 0.15)
		if config.Callback then
			config.Callback(state)
		end
	end

	Click.MouseButton1Click:Connect(function()
		setState(not state)
	end)

	return { Set = setState, Get = function() return state end }
end

function ZeusLib.SectionMethods:AddCheckbox(config)
	config = config or {}
	local theme = self.Zeus.CurrentTheme
	local state = config.Default or false

	local Holder = Create("Frame", {
		BackgroundColor3 = theme.Background,
		Size = UDim2.new(1, 0, 0, 32),
		BorderSizePixel = 0,
		Parent = self.Holder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = Holder
	Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }).Parent = Holder

	Create("TextLabel", {
		Text = config.Name or "Checkbox",
		Font = Fonts.Gotham,
		TextSize = 13,
		TextColor3 = theme.Text,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -50, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Holder,
	})

	local Box = Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = theme.Background,
		Parent = Holder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 4) }).Parent = Box
	local BoxStroke = Create("UIStroke", { Color = theme.Stroke, Thickness = 1 })
	BoxStroke.Parent = Box

	local Check = Create("Frame", {
		Size = UDim2.fromScale(0.6, 0.6),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = state and 0 or 1,
		Parent = Box,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 2) }).Parent = Check

	local Click = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = Holder,
	})

	local function setState(new)
		state = new
		Tween(Check, { BackgroundTransparency = state and 0 or 1 }, 0.12)
		if config.Callback then
			config.Callback(state)
		end
	end

	Click.MouseButton1Click:Connect(function()
		setState(not state)
	end)

	return { Set = setState, Get = function() return state end }
end

function ZeusLib.SectionMethods:AddInput(config)
	config = config or {}
	local theme = self.Zeus.CurrentTheme

	local Holder = Create("Frame", {
		BackgroundColor3 = theme.Background,
		Size = UDim2.new(1, 0, 0, 32),
		BorderSizePixel = 0,
		Parent = self.Holder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = Holder
	Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }).Parent = Holder

	Create("TextLabel", {
		Text = config.Name or "",
		Font = Fonts.Gotham,
		TextSize = 12,
		TextColor3 = theme.SubText,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(0.4, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Holder,
	})

	local Box = Create("TextBox", {
		Text = config.Default or "",
		PlaceholderText = config.Placeholder or "...",
		Font = Fonts.Gotham,
		TextSize = 13,
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.SubText,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.42, 0, 0, 0),
		Size = UDim2.new(0.56, -10, 1, 0),
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = Holder,
	})

	Box.FocusLost:Connect(function(enterPressed)
		if config.Callback then
			config.Callback(Box.Text, enterPressed)
		end
	end)

	return { Set = function(v) Box.Text = v end, Get = function() return Box.Text end }
end

function ZeusLib.SectionMethods:AddDropdown(config)
	config = config or {}
	local theme = self.Zeus.CurrentTheme
	local Zeus = self.Zeus
	local options = config.Options or {}
	local selected = config.Default

	local Holder = Create("Frame", {
		BackgroundColor3 = theme.Background,
		Size = UDim2.new(1, 0, 0, 32),
		BorderSizePixel = 0,
		ClipsDescendants = false,
		ZIndex = 2,
		Parent = self.Holder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = Holder
	Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }).Parent = Holder

	local NameLabel = Create("TextLabel", {
		Text = config.Name or "Dropdown",
		Font = Fonts.Gotham,
		TextSize = 13,
		TextColor3 = theme.Text,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = Holder,
	})

	local SelectedLabel = Create("TextLabel", {
		Text = tostring(selected or "Select"),
		Font = Fonts.Gotham,
		TextSize = 13,
		TextColor3 = theme.SubText,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.4, 0, 0, 0),
		Size = UDim2.new(0.5, -30, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 2,
		Parent = Holder,
	})

	local Arrow = Create("TextLabel", {
		Text = "v",
		Font = Fonts.GothamBold,
		TextSize = 12,
		TextColor3 = theme.SubText,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		ZIndex = 2,
		Parent = Holder,
	})

	local ListFrame = Create("Frame", {
		BackgroundColor3 = theme.Secondary,
		Position = UDim2.new(0, 0, 1, 4),
		Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 50,
		Parent = Holder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = ListFrame
	Create("UIStroke", { Color = theme.Stroke, Thickness = 1 }).Parent = ListFrame

	local ListLayout = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	ListLayout.Parent = ListFrame

	local optionButtons = {}
	local function rebuildOptions()
		for _, b in ipairs(optionButtons) do
			b:Destroy()
		end
		optionButtons = {}
		for i, opt in ipairs(options) do
			local OptBtn = Create("TextButton", {
				Text = tostring(opt),
				Font = Fonts.Gotham,
				TextSize = 13,
				TextColor3 = theme.Text,
				BackgroundColor3 = theme.Secondary,
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 28),
				ZIndex = 51,
				Parent = ListFrame,
			})
			OptBtn.MouseEnter:Connect(function()
				Tween(OptBtn, { BackgroundColor3 = theme.AccentDark }, 0.12)
			end)
			OptBtn.MouseLeave:Connect(function()
				Tween(OptBtn, { BackgroundColor3 = theme.Secondary }, 0.12)
			end)
			OptBtn.MouseButton1Click:Connect(function()
				selected = opt
				SelectedLabel.Text = tostring(opt)
				if config.Callback then
					config.Callback(opt)
				end
				Zeus:CloseDropdown()
			end)
			table.insert(optionButtons, OptBtn)
		end
	end
	rebuildOptions()

	local isOpen = false
	local function close()
		isOpen = false
		ListFrame.Visible = false
		ListFrame.Size = UDim2.new(1, 0, 0, 0)
		Arrow.Text = "v"
		Holder.ZIndex = 2
	end

	local function open()
		if Zeus.ActiveDropdown and Zeus.ActiveDropdown ~= close then
			Zeus.ActiveDropdown()
		end
		isOpen = true
		ListFrame.Visible = true
		local targetHeight = math.min(#options, 5) * 28
		ListFrame.Size = UDim2.new(1, 0, 0, targetHeight)
		Arrow.Text = "^"
		Holder.ZIndex = 50
		Zeus.ActiveDropdown = close
	end

	local Click = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = Holder,
	})
	Click.MouseButton1Click:Connect(function()
		if isOpen then
			close()
			Zeus.ActiveDropdown = nil
		else
			open()
		end
	end)

	return {
		Set = function(v)
			selected = v
			SelectedLabel.Text = tostring(v)
		end,
		Get = function() return selected end,
		Refresh = function(newOptions)
			options = newOptions
			rebuildOptions()
		end,
	}
end

function ZeusLib:CloseDropdown()
	if self.ActiveDropdown then
		self.ActiveDropdown()
		self.ActiveDropdown = nil
	end
end

function ZeusLib:SetTheme(themeName)
	local theme = Themes[themeName]
	if not theme then return end
	self.CurrentTheme = theme
	self.Main.BackgroundColor3 = theme.Background
	self.MainStroke.Color = theme.Stroke
	self:Notify({ Title = "Theme", Content = themeName .. " aktiviert", Duration = 2 })
end

function ZeusLib:SetFont(fontName)
	local font = Fonts[fontName]
	if not font then return end
	self.CurrentFont = font
	self.TitleLabel.Font = font
end

function ZeusLib:CreateUISettingsTab()
	local tab = self:AddTab("UISettings")
	local section = tab:AddSection("Interface")

	local waitingForBind = false

	local KeybindHolder = Create("Frame", {
		BackgroundColor3 = self.CurrentTheme.Background,
		Size = UDim2.new(1, 0, 0, 32),
		BorderSizePixel = 0,
		Parent = section.Holder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 6) }).Parent = KeybindHolder
	Create("UIStroke", { Color = self.CurrentTheme.Stroke, Thickness = 1 }).Parent = KeybindHolder

	Create("TextLabel", {
		Text = "Menu Keybind",
		Font = Fonts.Gotham,
		TextSize = 13,
		TextColor3 = self.CurrentTheme.Text,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = KeybindHolder,
	})

	local BindBtn = Create("TextButton", {
		Text = self.ToggleKeybind.Name,
		Font = Fonts.GothamBold,
		TextSize = 12,
		TextColor3 = self.CurrentTheme.Text,
		BackgroundColor3 = self.CurrentTheme.AccentDark,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(90, 22),
		AutoButtonColor = false,
		Parent = KeybindHolder,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 5) }).Parent = BindBtn

	BindBtn.MouseButton1Click:Connect(function()
		waitingForBind = true
		BindBtn.Text = "..."
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if waitingForBind and input.UserInputType == Enum.UserInputType.Keyboard then
			self.ToggleKeybind = input.KeyCode
			BindBtn.Text = input.KeyCode.Name
			waitingForBind = false
		end
	end)

	section:AddDropdown({
		Name = "Theme",
		Options = { "Pink", "Midnight" },
		Default = "Pink",
		Callback = function(value)
			self:SetTheme(value)
		end,
	})

	section:AddDropdown({
		Name = "Font",
		Options = { "Gotham", "GothamBold", "Code" },
		Default = "GothamBold",
		Callback = function(value)
			self:SetFont(value)
		end,
	})

	section:AddButton({
		Name = "Reset UI",
		Callback = function()
			self:SetTheme("Pink")
			self:SetFont("GothamBold")
		end,
	})
end

return ZeusLib
